using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using StudyFlowBackend.Data;
using StudyFlowBackend.DTOs;
using StudyFlowBackend.Models;
using StudyFlowBackend.Services;
using StudyFlowBackend.Utils;

namespace StudyFlowBackend.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class AiController : ControllerBase
    {
        private readonly IGeminiService _geminiService;
        private readonly IFlashcardService _flashcardService;
        private readonly IScannedDocumentService _documentService;
        private readonly AppDbContext _context;
        private readonly IUserUtils _userUtils;

        public AiController(
            IGeminiService geminiService,
            IFlashcardService flashcardService,
            IScannedDocumentService documentService,
            AppDbContext context,
            IUserUtils userUtils)
        {
            _geminiService = geminiService;
            _flashcardService = flashcardService;
            _documentService = documentService;
            _context = context;
            _userUtils = userUtils;
        }

        [HttpPost("chat")]
        public async Task<IActionResult> Chat([FromBody] ChatRequestDto request)
        {
            var user = await _userUtils.GetCurrentUserAsync();
            if (user == null) return Unauthorized();

            // Kiểm tra và reset hạn mức hàng ngày (20 requests)
            if (!CheckAndIncrementAiRequestLimit(user))
            {
                return StatusCode(429, ApiResponse<object>.ErrorResponse("You have used up all your AI requests today (Maximum 20 requests/day). Please try again tomorrow!"));
            }

            await _context.SaveChangesAsync();

            // 1. Tìm các flashcards liên quan để làm context (RAG Lite)
            var relevantCards = await _flashcardService.SearchRelevantFlashcardsAsync(user.Id, request.Message, limit: 15);

            // 2. Gửi request đến Gemini
            var result = await _geminiService.ProcessChatWithContextAsync(request.Message, request.History, relevantCards);

            var responseDto = new ChatResponseDto
            {
                Response = result.Reply,
                DailyRequestsRemaining = Math.Max(0, 20 - user.DailyAiRequestsUsed),
                SuggestedActions = result.Actions
            };

            return Ok(ApiResponse<ChatResponseDto>.SuccessResponse(responseDto));
        }

        [HttpPost("generate-flashcards")]
        public async Task<IActionResult> GenerateFlashcards([FromBody] GenerateFlashcardsRequestDto request)
        {
            var user = await _userUtils.GetCurrentUserAsync();
            if (user == null) return Unauthorized();

            // 1. Kiểm tra hạn mức request AI
            if (!CheckAndIncrementAiRequestLimit(user))
            {
                return StatusCode(429, ApiResponse<object>.ErrorResponse("You have used up all your AI requests today. Please try again tomorrow!"));
            }

            // 2. Lấy tài liệu scan
            var doc = await _context.ScannedDocuments.FirstOrDefaultAsync(d => d.Id == request.DocumentId && d.UserId == user.Id);
            if (doc == null)
            {
                return NotFound(ApiResponse<object>.ErrorResponse("Could not find the scanned document."));
            }

            if (string.IsNullOrWhiteSpace(doc.ExtractedText))
            {
                return BadRequest(ApiResponse<object>.ErrorResponse("The document does not contain any extracted text."));
            }

            // 3. Đánh dấu lưu DB trước khi gọi để update hạn mức request
            await _context.SaveChangesAsync();

            // 4. Sinh flashcard từ Gemini
            var generatedCards = await _geminiService.GenerateFlashcardsFromTextAsync(doc.ExtractedText);
            if (generatedCards == null || generatedCards.Count == 0)
            {
                return BadRequest(ApiResponse<object>.ErrorResponse("Could not generate flashcards from this document text."));
            }

            // 5. Lưu bộ flashcard vào DB
            var createDto = new CreateFlashcardSetDto
            {
                Title = string.IsNullOrEmpty(request.CustomTitle) ? $"Flashcards: {doc.Title}" : request.CustomTitle,
                TargetDocumentId = doc.Id,
                Flashcards = generatedCards
            };

            try
            {
                var createdSet = await _flashcardService.CreateFlashcardSetAsync(user.Id, createDto);
                return Ok(ApiResponse<FlashcardSetDto>.SuccessResponse(createdSet, "Successfully generated flashcards using AI!"));
            }
            catch (InvalidOperationException ex)
            {
                return BadRequest(ApiResponse<object>.ErrorResponse(ex.Message));
            }
        }

        private bool CheckAndIncrementAiRequestLimit(User user)
        {
            var today = DateTime.Today;
            
            if (user.LastAiRequestDate == null || user.LastAiRequestDate.Value.Date != today)
            {
                user.DailyAiRequestsUsed = 0;
                user.LastAiRequestDate = today;
            }

            if (user.DailyAiRequestsUsed >= 20)
            {
                return false;
            }

            user.DailyAiRequestsUsed++;
            return true;
        }
    }
}
