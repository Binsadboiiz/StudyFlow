using System;
using System.Collections.Generic;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using StudyFlowBackend.DTOs;

namespace StudyFlowBackend.Services.Implementations
{
    public class GeminiService : IGeminiService
    {
        private readonly HttpClient _httpClient;
        private readonly string _apiKey;
        private readonly string _modelName;
        private readonly ILogger<GeminiService> _logger;

        public GeminiService(HttpClient httpClient, IConfiguration configuration, ILogger<GeminiService> logger)
        {
            _httpClient = httpClient;
            _logger = logger;
            _apiKey = Environment.GetEnvironmentVariable("GEMINI_API_KEY") 
                      ?? configuration["Gemini:ApiKey"] 
                      ?? string.Empty;
            // Dùng gemini-1.5-flash hoặc gemini-2.0-flash-lite theo lựa chọn của người dùng
            _modelName = configuration["Gemini:Model"] ?? "gemini-1.5-flash";
        }

        public async Task<(string Reply, List<AiActionSuggestionDto> Actions, bool IsSuccess)> ProcessChatWithContextAsync(
            string userMessage, 
            List<ChatMessageDto> history, 
            List<FlashcardDto> contextCards)
        {
            if (string.IsNullOrEmpty(_apiKey))
            {
                return ("Error: Gemini API key not configured in the backend.", new List<AiActionSuggestionDto>(), false);
            }

            var url = $"https://generativelanguage.googleapis.com/v1beta/models/{_modelName}:generateContent?key={_apiKey}";

            // Tạo context từ các flashcard liên quan
            var contextBuilder = new StringBuilder();
            if (contextCards != null && contextCards.Count > 0)
            {
                contextBuilder.AppendLine("Below are flashcards related to the user's lesson. Please refer to them to answer the questions if necessary:");
                foreach (var card in contextCards)
                {
                    contextBuilder.AppendLine($"- Question: {card.Question} | Answer: {card.Answer}");
                }
                contextBuilder.AppendLine("---");
            }

            // Tạo system instruction/prompt yêu cầu trả về JSON
            var systemInstruction = "You are a highly efficient learning assistant in the StudyFlow system. Your task is to support users in studying, organizing tasks, and arranging schedules.\n" +
                                    "CRITICAL RULES:\n" +
                                    "1. You MUST NOT trigger any deletion of user data under any circumstances.\n" +
                                    "2. If the user wants to create a new task or plan a new schedule event, provide the structural details in the `suggestedActions` array:\n" +
                                    "   - actionType: 'CREATE_TASK' or 'CREATE_SCHEDULE'.\n" +
                                    "   - Each action must contain a `title`, and optional `description`.\n" +
                                    "   - For 'CREATE_TASK', fill `dueDate` (format: YYYY-MM-DD).\n" +
                                    "   - For 'CREATE_SCHEDULE', fill `date` (YYYY-MM-DD), `startTime` (HH:mm), and `endTime` (HH:mm).\n" +
                                    "3. Always respond strictly in the following JSON format:\n" +
                                    "{\n" +
                                    "  \"reply\": \"Friendly response message to the user, formatted beautifully with markdown\",\n" +
                                    "  \"suggestedActions\": [\n" +
                                    "     { \"actionType\": \"CREATE_TASK\", \"title\": \"Task title\", \"description\": \"Description details\", \"dueDate\": \"YYYY-MM-DD\" }\n" +
                                    "  ]\n" +
                                    "}\n" +
                                    "Provide clean raw JSON output. Do NOT wrap it in markdown code blocks like ```json ```.";

            // Xây dựng payload contents
            var contents = new List<object>();

            // Hệ thống chỉ dẫn
            contents.Add(new
            {
                role = "user",
                parts = new[] { new { text = $"SYSTEM INSTRUCTION:\n{systemInstruction}\n\nCONTEXT:\n{contextBuilder}" } }
            });
            contents.Add(new
            {
                role = "model",
                parts = new[] { new { text = "I understand the instructions clearly and will respond in the requested JSON schema format." } }
            });

            // Lịch sử hội thoại (giới hạn vài tin nhắn gần nhất để tiết kiệm token)
            foreach (var msg in history)
            {
                contents.Add(new
                {
                    role = msg.Role == "user" ? "user" : "model",
                    parts = new[] { new { text = msg.Content } }
                });
            }

            // Câu hỏi hiện tại
            contents.Add(new
            {
                role = "user",
                parts = new[] { new { text = userMessage } }
            });

            var payload = new
            {
                contents = contents,
                generationConfig = new
                {
                    responseMimeType = "application/json",
                    temperature = 0.7
                }
            };

            try
            {
                var jsonPayload = JsonSerializer.Serialize(payload);
                var requestContent = new StringContent(jsonPayload, Encoding.UTF8, "application/json");

                var response = await _httpClient.PostAsync(url, requestContent);
                var responseString = await response.Content.ReadAsStringAsync();

                if (!response.IsSuccessStatusCode)
                {
                    _logger.LogError("Gemini API Error: {Status} - {Response}", response.StatusCode, responseString);
                    return ("The AI system is currently busy, please try again later.", new List<AiActionSuggestionDto>(), false);
                }

                using var doc = JsonDocument.Parse(responseString);
                var root = doc.RootElement;
                
                // Lấy text output từ cấu trúc của Gemini response
                var candidates = root.GetProperty("candidates");
                if (candidates.GetArrayLength() > 0)
                {
                    var text = candidates[0]
                        .GetProperty("content")
                        .GetProperty("parts")[0]
                        .GetProperty("text")
                        .GetString();

                    if (!string.IsNullOrEmpty(text))
                    {
                        try
                        {
                            var chatResult = JsonSerializer.Deserialize<ChatJsonResult>(text, new JsonSerializerOptions
                            {
                                PropertyNameCaseInsensitive = true
                            });

                            if (chatResult != null)
                            {
                                return (chatResult.Reply, chatResult.SuggestedActions ?? new List<AiActionSuggestionDto>(), true);
                            }
                        }
                        catch (Exception ex)
                        {
                            _logger.LogError(ex, "Failed to parse Gemini response JSON: {RawText}", text);
                            return (text, new List<AiActionSuggestionDto>(), true);
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error while calling Gemini API");
            }

            return ("Unable to receive response from AI.", new List<AiActionSuggestionDto>(), false);
        }

        public async Task<List<CreateFlashcardDto>> GenerateFlashcardsFromTextAsync(string documentText)
        {
            var result = new List<CreateFlashcardDto>();
            if (string.IsNullOrEmpty(_apiKey)) return result;

            var url = $"https://generativelanguage.googleapis.com/v1beta/models/{_modelName}:generateContent?key={_apiKey}";

            var systemPrompt = "You are an smart learning assistant. Your task is to read the scanned document text provided below and generate a list of up to 10 flashcards (concise question and corresponding answer pairs) to help the student review and memorize effectively.\n" +
                               "Respond strictly in the following JSON array format:\n" +
                               "[\n" +
                               "  { \"question\": \"Question 1\", \"answer\": \"Answer 1\" },\n" +
                               "  { \"question\": \"Question 2\", \"answer\": \"Answer 2\" }\n" +
                               "]\n" +
                               "Provide clean raw JSON output. Do NOT wrap it in markdown code blocks like ```json ```.";

            var payload = new
            {
                contents = new[]
                {
                    new {
                        role = "user",
                        parts = new[] { new { text = $"{systemPrompt}\n\nTài liệu:\n{documentText}" } }
                    }
                },
                generationConfig = new
                {
                    responseMimeType = "application/json",
                    temperature = 0.5
                }
            };

            try
            {
                var jsonPayload = JsonSerializer.Serialize(payload);
                var requestContent = new StringContent(jsonPayload, Encoding.UTF8, "application/json");

                var response = await _httpClient.PostAsync(url, requestContent);
                var responseString = await response.Content.ReadAsStringAsync();

                if (!response.IsSuccessStatusCode)
                {
                    _logger.LogError("Gemini Flashcard API Error: {Status} - {Response}", response.StatusCode, responseString);
                    return result;
                }

                using var doc = JsonDocument.Parse(responseString);
                var root = doc.RootElement;
                var candidates = root.GetProperty("candidates");
                if (candidates.GetArrayLength() > 0)
                {
                    var text = candidates[0]
                        .GetProperty("content")
                        .GetProperty("parts")[0]
                        .GetProperty("text")
                        .GetString();

                    if (!string.IsNullOrEmpty(text))
                    {
                        var cards = JsonSerializer.Deserialize<List<CreateFlashcardDto>>(text, new JsonSerializerOptions
                        {
                            PropertyNameCaseInsensitive = true
                        });
                        if (cards != null) return cards;
                    }
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error generating flashcards from Gemini API");
            }

            return result;
        }

        private class ChatJsonResult
        {
            public string Reply { get; set; } = string.Empty;
            public List<AiActionSuggestionDto>? SuggestedActions { get; set; }
        }
    }
}
