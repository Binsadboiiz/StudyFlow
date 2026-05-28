using System;
using System.Collections.Generic;

namespace StudyFlowBackend.Models
{
    public class User
    {
        /// <summary>
        /// Firebase UID sẽ được dùng làm Primary Key
        /// </summary>
        public string Id { get; set; } = string.Empty;
        
        public string Username { get; set; } = string.Empty;
        
        public string Email { get; set; } = string.Empty;
        
        public string FullName { get; set; } = string.Empty;
        
        public int Streak { get; set; } = 0;
        
        public int DailyTargetMinutes { get; set; } = 120;
        
        public DateTime? LastStreakDate { get; set; }
        
        /// <summary>
        /// EF Core 8 hỗ trợ map trực tiếp List<string> xuống PostgreSQL Array type.
        /// </summary>
        public List<string> StreakHistory { get; set; } = new List<string>();

        // Navigation Property: 1 User có nhiều Tasks
        public ICollection<StudyTask> Tasks { get; set; } = new List<StudyTask>();
    }
}
