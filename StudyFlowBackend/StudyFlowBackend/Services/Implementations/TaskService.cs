using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using StudyFlowBackend.Data;
using StudyFlowBackend.DTOs;
using StudyFlowBackend.Models;

namespace StudyFlowBackend.Services
{
    public class TaskService : ITaskService
    {
        private readonly AppDbContext _context;
        private readonly IGamificationService _gamificationService;

        public TaskService(AppDbContext context, IGamificationService gamificationService)
        {
            _context = context;
            _gamificationService = gamificationService;
        }

        public async Task<IEnumerable<TaskDto>> GetTasksByUserIdAsync(string userId)
        {
            var tasks = await _context.Tasks
                .Where(t => t.UserId == userId)
                .OrderByDescending(t => t.Date)
                .ToListAsync();

            return tasks.Select(MapToDto);
        }

        public async Task<TaskDto?> GetTaskByIdAsync(Guid id, string userId)
        {
            var task = await _context.Tasks
                .FirstOrDefaultAsync(t => t.Id == id && t.UserId == userId);

            if (task == null) return null;
            return MapToDto(task);
        }

        public async Task<TaskDto> CreateTaskAsync(string userId, CreateTaskDto dto)
        {
            var task = new StudyTask
            {
                Id = Guid.NewGuid(),
                UserId = userId,
                Title = dto.Title,
                Description = dto.Description,
                Date = dto.Date,
                StartTime = dto.StartTime,
                EndTime = dto.EndTime,
                IsCompleted = false,
                ReminderTime = dto.ReminderTime,
                IsReminderSent = false
            };

            _context.Tasks.Add(task);
            await _context.SaveChangesAsync();

            return MapToDto(task);
        }

        public async Task<TaskDto?> UpdateTaskAsync(Guid id, string userId, UpdateTaskDto dto)
        {
            var task = await _context.Tasks
                .FirstOrDefaultAsync(t => t.Id == id && t.UserId == userId);

            if (task == null) return null;

            bool wasCompleted = task.IsCompleted;

            if (dto.Title != null) task.Title = dto.Title;
            if (dto.Description != null) task.Description = dto.Description;
            if (dto.Date.HasValue) task.Date = dto.Date.Value;
            if (dto.StartTime.HasValue) task.StartTime = dto.StartTime.Value;
            if (dto.EndTime.HasValue) task.EndTime = dto.EndTime.Value;
            if (dto.IsCompleted.HasValue) task.IsCompleted = dto.IsCompleted.Value;
            
            // Check if ReminderTime is modified
            if (dto.ReminderTime != task.ReminderTime)
            {
                task.ReminderTime = dto.ReminderTime;
                task.IsReminderSent = false;
            }

            await _context.SaveChangesAsync();

            // Nếu nhiệm vụ được chuyển trạng thái sang Hoàn thành (từ chưa hoàn thành)
            if (task.IsCompleted && !wasCompleted)
            {
                await _gamificationService.AddXpAndCoinsAsync(userId, 10, 10, $"Task completed: {task.Title}");
            }

            return MapToDto(task);
        }

        public async Task<bool> DeleteTaskAsync(Guid id, string userId)
        {
            var task = await _context.Tasks
                .FirstOrDefaultAsync(t => t.Id == id && t.UserId == userId);

            if (task == null) return false;

            _context.Tasks.Remove(task);
            await _context.SaveChangesAsync();
            return true;
        }

        private static TaskDto MapToDto(StudyTask task)
        {
            return new TaskDto
            {
                Id = task.Id,
                Title = task.Title,
                Description = task.Description,
                Date = task.Date,
                StartTime = task.StartTime,
                EndTime = task.EndTime,
                IsCompleted = task.IsCompleted,
                UserId = task.UserId,
                ReminderTime = task.ReminderTime
            };
        }
    }
}
