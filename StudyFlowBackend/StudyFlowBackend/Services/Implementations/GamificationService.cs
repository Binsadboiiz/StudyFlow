using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using StudyFlowBackend.Data;
using StudyFlowBackend.Models;
using StudyFlowBackend.Constants;

namespace StudyFlowBackend.Services
{
    /// <summary>
    /// Triển khai dịch vụ quản lý Gamification cho người dùng.
    /// </summary>
    public class GamificationService : IGamificationService
    {
        private readonly AppDbContext _context;
        private readonly INotificationService _notificationService;

        public GamificationService(AppDbContext context, INotificationService notificationService)
        {
            _context = context;
            _notificationService = notificationService;
        }

        /// <summary>
        /// Công thức tính XP yêu cầu để thăng cấp: Required XP = Base * L^Exponent
        /// </summary>
        private static double GetXpRequiredForLevel(int level)
        {
            return Math.Round(GamificationConstants.LevelUpBaseXp * Math.Pow(level, GamificationConstants.LevelUpExponent));
        }

        /// <summary>
        /// Cộng điểm kinh nghiệm (XP) và tiền xu (Coins) cho người dùng.
        /// </summary>
        public async Task<bool> AddXpAndCoinsAsync(string userId, double xpAmount, int coinsAmount, string reason)
        {
            var user = await _context.Users.FirstOrDefaultAsync(u => u.Id == userId);
            if (user == null) return false;

            bool leveledUp = false;
            user.ExpPoints += xpAmount;
            user.Coins += coinsAmount;

            // Xử lý logic thăng cấp nếu vượt ngưỡng yêu cầu
            double requiredXp = GetXpRequiredForLevel(user.Level);
            while (user.ExpPoints >= requiredXp)
            {
                user.ExpPoints -= requiredXp;
                user.Level++;
                leveledUp = true;
                requiredXp = GetXpRequiredForLevel(user.Level);
            }

            user.UpdatedAt = DateTime.UtcNow;
            await _context.SaveChangesAsync();

            // Gửi thông báo thăng cấp nếu có
            if (leveledUp)
            {
                await _notificationService.CreateNotificationAsync(
                    userId,
                    "🎉 Congratulations on leveling up!",
                    $"You have reached Level {user.Level} through your dedication and hard work! Keep up the great work!",
                    "LevelUp"
                );
            }

            // Kiểm tra mở khóa huy hiệu sau khi cộng điểm
            await CheckAndAwardBadgesAsync(userId);

            return leveledUp;
        }

        /// <summary>
        /// Kiểm tra và tự động trao các huy hiệu (Badges) cho người dùng dựa trên thành tích.
        /// </summary>
        public async Task CheckAndAwardBadgesAsync(string userId)
        {
            var user = await _context.Users
                .Include(u => u.UserBadges)
                .FirstOrDefaultAsync(u => u.Id == userId);
            
            if (user == null) return;

            // Lấy tất cả các huy hiệu hiện có trong DB
            var allBadges = await _context.Badges.ToListAsync();
            
            // Lọc ra danh sách huy hiệu mà người dùng chưa đạt được
            var earnedBadgeIds = user.UserBadges.Select(ub => ub.BadgeId).ToHashSet();
            var unearnedBadges = allBadges.Where(b => !earnedBadgeIds.Contains(b.Id)).ToList();

            if (!unearnedBadges.Any()) return;

            // Truy vấn các chỉ số học tập để đánh giá điều kiện
            var totalFocusMinutes = await _context.FocusSessions
                .Where(f => f.UserId == userId)
                .SumAsync(f => (int?)f.DurationMinutes) ?? 0;

            var tasksCompletedCount = await _context.Tasks
                .CountAsync(t => t.UserId == userId && t.IsCompleted);

            int currentStreak = user.Streak;

            bool databaseChanged = false;

            foreach (var badge in unearnedBadges)
            {
                bool isEligible = false;

                // Kiểm tra điều kiện mở khóa dựa trên loại chỉ số
                switch (badge.MetricType)
                {
                    case "Level":
                        isEligible = user.Level >= badge.ThresholdValue;
                        break;
                    case "FocusMinutes":
                        isEligible = totalFocusMinutes >= badge.ThresholdValue;
                        break;
                    case "TasksCompleted":
                        isEligible = tasksCompletedCount >= badge.ThresholdValue;
                        break;
                    case "StreakDays":
                        isEligible = currentStreak >= badge.ThresholdValue;
                        break;
                }

                if (isEligible)
                {
                    // Thêm huy hiệu mới đã đạt được cho user
                    var userBadge = new UserBadge
                    {
                        UserId = userId,
                        BadgeId = badge.Id,
                        EarnedAt = DateTime.UtcNow
                    };
                    
                    _context.UserBadges.Add(userBadge);
                    databaseChanged = true;

                    // Tặng quà thưởng trực tiếp cho mỗi huy hiệu mở khóa (lấy từ Constants)
                    user.Coins += GamificationConstants.BadgeUnlockedCoinsBonus;
                    user.ExpPoints += GamificationConstants.BadgeUnlockedXpBonus;

                    // Gửi thông báo chúc mừng
                    await _notificationService.CreateNotificationAsync(
                        userId,
                        $"🏆 New Achievement: {badge.Name}!",
                        $"You have successfully unlocked the badge '{badge.Name}' ({badge.Description}). Bonus +{GamificationConstants.BadgeUnlockedXpBonus} XP and +{GamificationConstants.BadgeUnlockedCoinsBonus} Coins!",
                        "Achievement"
                    );
                }
            }

            if (databaseChanged)
            {
                // Xử lý lại thăng cấp nếu XP từ quà tặng huy hiệu làm thăng cấp
                double requiredXp = GetXpRequiredForLevel(user.Level);
                bool secondaryLevelUp = false;
                while (user.ExpPoints >= requiredXp)
                {
                    user.ExpPoints -= requiredXp;
                    user.Level++;
                    secondaryLevelUp = true;
                    requiredXp = GetXpRequiredForLevel(user.Level);
                }

                user.UpdatedAt = DateTime.UtcNow;
                await _context.SaveChangesAsync();

                if (secondaryLevelUp)
                {
                    await _notificationService.CreateNotificationAsync(
                        userId,
                        "🎉 Level Up from Achievements!",
                        $"Thanks to your badge rewards, you have leveled up to Level {user.Level}!",
                        "LevelUp"
                    );
                }
            }
        }

        /// <summary>
        /// Cập nhật tiến trình thời gian học tập trong ngày để cộng chuỗi Streak.
        /// </summary>
        public async Task UpdateDailyTargetProgressAsync(string userId, int focusedMinutesToday)
        {
            var user = await _context.Users.FirstOrDefaultAsync(u => u.Id == userId);
            if (user == null) return;

            // Lấy ngày hiện tại (không lấy phần giờ)
            var todayStr = DateTime.UtcNow.ToString("yyyy-MM-dd");

            // Nếu hôm nay chưa có trong lịch sử streak và đã đạt chỉ tiêu
            if (!user.StreakHistory.Contains(todayStr) && focusedMinutesToday >= user.DailyTargetMinutes)
            {
                var yesterdayStr = DateTime.UtcNow.AddDays(-1).ToString("yyyy-MM-dd");
                
                // Cập nhật ngọn lửa Streak
                if (user.LastStreakDate.HasValue && user.LastStreakDate.Value.ToString("yyyy-MM-dd") == yesterdayStr)
                {
                    user.Streak += 1;
                }
                else if (user.LastStreakDate.HasValue && user.LastStreakDate.Value.ToString("yyyy-MM-dd") == todayStr)
                {
                    // Hôm nay đã cập nhật rồi thì không làm gì thêm
                }
                else
                {
                    user.Streak = 1; // Bắt đầu chuỗi mới
                }

                user.LastStreakDate = DateTime.UtcNow;
                user.StreakHistory.Add(todayStr);
                user.UpdatedAt = DateTime.UtcNow;

                await _context.SaveChangesAsync();

                // Cộng bonus đặc biệt cho việc hoàn thành Daily Target (lấy từ Constants)
                await AddXpAndCoinsAsync(
                    userId, 
                    GamificationConstants.DailyTargetXpBonus, 
                    GamificationConstants.DailyTargetCoinsBonus, 
                    "Completed Daily Target"
                );

                await _notificationService.CreateNotificationAsync(
                    userId,
                    "🔥 Daily Target Achieved!",
                    $"Congratulations! You have completed your daily focus target of {user.DailyTargetMinutes} minutes today! Your current streak is: {user.Streak} days.",
                    "Streak"
                );
            }
        }

        /// <summary>
        /// Thiết lập huy hiệu nổi bật (danh hiệu hiển thị bên cạnh tên).
        /// </summary>
        public async Task<bool> SetFeaturedBadgeAsync(string userId, Guid? badgeId)
        {
            var user = await _context.Users.FirstOrDefaultAsync(u => u.Id == userId);
            if (user == null) return false;

            if (badgeId == null)
            {
                user.FeaturedBadgeId = null;
                user.UpdatedAt = DateTime.UtcNow;
                await _context.SaveChangesAsync();
                return true;
            }

            // Kiểm tra xem người dùng đã thực sự mở khóa huy hiệu này chưa
            var hasBadge = await _context.UserBadges.AnyAsync(ub => ub.UserId == userId && ub.BadgeId == badgeId.Value);
            if (!hasBadge) return false;

            user.FeaturedBadgeId = badgeId;
            user.UpdatedAt = DateTime.UtcNow;
            await _context.SaveChangesAsync();
            return true;
        }
    }
}
