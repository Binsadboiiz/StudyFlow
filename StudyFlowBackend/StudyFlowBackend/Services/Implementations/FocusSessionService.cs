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
    public class FocusSessionService : IFocusSessionService
    {
        private readonly AppDbContext _context;

        public FocusSessionService(AppDbContext context)
        {
            _context = context;
        }

        public async Task<FocusSessionDto> CreateFocusSessionAsync(string userId, CreateFocusSessionDto dto)
        {
            var session = new FocusSession
            {
                UserId = userId,
                StartTime = dto.StartTime,
                EndTime = dto.EndTime,
                DurationMinutes = dto.DurationMinutes,
                Mode = dto.Mode,
                CreatedAt = DateTime.UtcNow
            };

            _context.FocusSessions.Add(session);
            await _context.SaveChangesAsync();

            return new FocusSessionDto
            {
                Id = session.Id,
                UserId = session.UserId,
                StartTime = session.StartTime,
                EndTime = session.EndTime,
                DurationMinutes = session.DurationMinutes,
                Mode = session.Mode,
                CreatedAt = session.CreatedAt
            };
        }

        public async Task<IEnumerable<FocusSessionDto>> GetFocusSessionsByUserIdAsync(string userId)
        {
            return await _context.FocusSessions
                .Where(f => f.UserId == userId)
                .OrderByDescending(f => f.CreatedAt)
                .Select(f => new FocusSessionDto
                {
                    Id = f.Id,
                    UserId = f.UserId,
                    StartTime = f.StartTime,
                    EndTime = f.EndTime,
                    DurationMinutes = f.DurationMinutes,
                    Mode = f.Mode,
                    CreatedAt = f.CreatedAt
                })
                .ToListAsync();
        }

        public async Task<IEnumerable<DailyFocusHeatmapDto>> GetHeatmapDataAsync(string userId, DateTime startDate, DateTime endDate)
        {
            // Group by Date part of StartTime
            var heatmapData = await _context.FocusSessions
                .Where(f => f.UserId == userId && f.StartTime >= startDate && f.StartTime <= endDate)
                .GroupBy(f => f.StartTime.Date)
                .Select(g => new DailyFocusHeatmapDto
                {
                    Date = g.Key,
                    TotalMinutes = g.Sum(f => f.DurationMinutes)
                })
                .OrderBy(h => h.Date)
                .ToListAsync();

            return heatmapData;
        }
    }
}
