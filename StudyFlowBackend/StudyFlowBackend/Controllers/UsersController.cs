using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using StudyFlowBackend.Data;
using StudyFlowBackend.Models;
using StudyFlowBackend.Utils;

namespace StudyFlowBackend.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class UsersController : ControllerBase
    {
        private readonly AppDbContext _context;
        private readonly IUserUtils _userUtils;

        public UsersController(AppDbContext context, IUserUtils userUtils)
        {
            _context = context;
            _userUtils = userUtils;
        }

        public class SyncUserDto
        {
            public string Email { get; set; } = string.Empty;
            public string Username { get; set; } = string.Empty;
            public string FullName { get; set; } = string.Empty;
            public string? AvatarUrl { get; set; }
        }

        public class UpdateProfileDto
        {
            public string FullName { get; set; } = string.Empty;
            public string AvatarUrl { get; set; } = string.Empty;
        }

        [HttpPost("sync")]
        public async Task<IActionResult> SyncUser([FromBody] SyncUserDto dto)
        {
            var userId = _userUtils.GetCurrentUserId();
            if (string.IsNullOrEmpty(userId))
                return Unauthorized(ApiResponse<object>.ErrorResponse("Unauthorized"));

            var existingUser = await _context.Users.FirstOrDefaultAsync(u => u.Id == userId);
            if (existingUser != null)
            {
                return Ok(ApiResponse<User>.SuccessResponse(existingUser, "User already synced"));
            }

            var newUser = new User
            {
                Id = userId,
                Email = dto.Email,
                Username = dto.Username,
                FullName = dto.FullName,
                AvatarUrl = dto.AvatarUrl ?? string.Empty,
                Streak = 0,
                Level = 1,
                ExpPoints = 0,
                DailyTargetMinutes = 60,
                CreatedAt = System.DateTime.UtcNow,
                UpdatedAt = System.DateTime.UtcNow
            };

            _context.Users.Add(newUser);
            await _context.SaveChangesAsync();

            return Ok(ApiResponse<User>.SuccessResponse(newUser, "User synced successfully"));
        }

        [HttpPut("profile")]
        public async Task<IActionResult> UpdateProfile([FromBody] UpdateProfileDto dto)
        {
            var userId = _userUtils.GetCurrentUserId();
            if (string.IsNullOrEmpty(userId))
                return Unauthorized(ApiResponse<object>.ErrorResponse("Unauthorized"));

            var user = await _context.Users.FirstOrDefaultAsync(u => u.Id == userId);
            if (user == null)
                return NotFound(ApiResponse<object>.ErrorResponse("User not found"));

            user.FullName = dto.FullName;
            user.AvatarUrl = dto.AvatarUrl;
            user.UpdatedAt = System.DateTime.UtcNow;

            await _context.SaveChangesAsync();

            return Ok(ApiResponse<User>.SuccessResponse(user, "Profile updated successfully"));
        }
    }
}
