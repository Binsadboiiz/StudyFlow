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
                Streak = 0,
                DailyTargetMinutes = 120
            };

            _context.Users.Add(newUser);
            await _context.SaveChangesAsync();

            return Ok(ApiResponse<User>.SuccessResponse(newUser, "User synced successfully"));
        }
    }
}
