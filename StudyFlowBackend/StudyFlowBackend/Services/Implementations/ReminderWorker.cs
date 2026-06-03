using System;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using StudyFlowBackend.Data;
using StudyFlowBackend.Models;

namespace StudyFlowBackend.Services
{
    public class ReminderWorker : BackgroundService
    {
        private readonly IServiceScopeFactory _serviceScopeFactory;
        private readonly ILogger<ReminderWorker> _logger;
        private readonly TimeSpan _checkInterval = TimeSpan.FromMinutes(1);

        public ReminderWorker(IServiceScopeFactory serviceScopeFactory, ILogger<ReminderWorker> logger)
        {
            _serviceScopeFactory = serviceScopeFactory;
            _logger = logger;
        }

        protected override async Task ExecuteAsync(CancellationToken stoppingToken)
        {
            _logger.LogInformation("Reminder Worker started.");

            while (!stoppingToken.IsCancellationRequested)
            {
                try
                {
                    using (var scope = _serviceScopeFactory.CreateScope())
                    {
                        var context = scope.ServiceProvider.GetRequiredService<AppDbContext>();
                        await CheckRemindersAsync(context);
                    }
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "An error occurred while running the Reminder Worker.");
                }

                await Task.Delay(_checkInterval, stoppingToken);
            }

            _logger.LogInformation("Reminder Worker stopped.");
        }

        private async Task CheckRemindersAsync(AppDbContext context)
        {
            var now = DateTime.Now;
            var todayStart = DateTime.Today;
            var todayEnd = todayStart.AddDays(1);

            // 1. Xử lý nhắc hẹn tuỳ chỉnh của các Task
            var pendingCustomReminders = await context.Tasks
                .Where(t => t.ReminderTime != null && !t.IsReminderSent && t.ReminderTime <= now && !t.IsCompleted)
                .ToListAsync();

            if (pendingCustomReminders.Any())
            {
                _logger.LogInformation($"Found {pendingCustomReminders.Count} pending custom task reminders to send.");
                foreach (var task in pendingCustomReminders)
                {
                    var notification = new UserNotification
                    {
                        Id = Guid.NewGuid(),
                        UserId = task.UserId,
                        Title = "Task Reminder",
                        Message = $"It's time to complete the task: {task.Title}",
                        CreatedAt = now,
                        IsRead = false,
                        Type = "CustomTask"
                    };
                    context.UserNotifications.Add(notification);
                    task.IsReminderSent = true;
                }
            }

            // 2. Xử lý nhắc nhở hàng ngày vào lúc 20:00 pm (8:00 PM) cho các task chưa hoàn thành
            if (now.Hour >= 20)
            {
                var users = await context.Users.ToListAsync();
                foreach (var user in users)
                {
                    // Kiểm tra xem User này có task nào của ngày hôm nay chưa hoàn thành không
                    var hasIncompleteTasks = await context.Tasks.AnyAsync(t =>
                        t.UserId == user.Id &&
                        t.Date >= todayStart &&
                        t.Date < todayEnd &&
                        !t.IsCompleted);

                    if (hasIncompleteTasks)
                    {
                        // Kiểm tra xem đã gửi thông báo Daily cho user này trong ngày hôm nay chưa
                        var alreadySentToday = await context.UserNotifications.AnyAsync(un =>
                            un.UserId == user.Id &&
                            un.Type == "Daily" &&
                            un.CreatedAt >= todayStart &&
                            un.CreatedAt < todayEnd);

                        if (!alreadySentToday)
                        {
                            _logger.LogInformation($"Sending daily reminder to user {user.FullName} ({user.Id})");
                            var notification = new UserNotification
                            {
                                Id = Guid.NewGuid(),
                                UserId = user.Id,
                                Title = "Daily Reminder",
                                Message = "You still have some unfinished tasks for today. Try to complete them as soon as possible!",
                                CreatedAt = now,
                                IsRead = false,
                                Type = "Daily"
                            };
                            context.UserNotifications.Add(notification);
                        }
                    }
                }
            }

            await context.SaveChangesAsync();
        }
    }
}
