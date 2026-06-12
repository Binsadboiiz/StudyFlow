using System.Collections.Generic;
using System.Threading.Tasks;
using StudyFlowBackend.DTOs;

namespace StudyFlowBackend.Services
{
    public interface IGeminiService
    {
        Task<(string Reply, List<AiActionSuggestionDto> Actions, bool IsSuccess)> ProcessChatWithContextAsync(
            string userMessage, 
            List<ChatMessageDto> history, 
            List<FlashcardDto> contextCards);

        Task<List<CreateFlashcardDto>> GenerateFlashcardsFromTextAsync(string documentText);
    }
}
