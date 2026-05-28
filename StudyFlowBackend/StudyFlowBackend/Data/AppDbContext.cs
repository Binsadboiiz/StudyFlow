using Microsoft.EntityFrameworkCore;
using StudyFlowBackend.Models;

namespace StudyFlowBackend.Data
{
    public class AppDbContext : DbContext
    {
        public AppDbContext(DbContextOptions<AppDbContext> options) : base(options)
        {
        }

        public DbSet<User> Users { get; set; }
        public DbSet<StudyTask> Tasks { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            // Bật extension pgvector cho PostgreSQL nếu cần làm AI Recommendation sau này
            modelBuilder.HasPostgresExtension("vector");

            // Cấu hình khoá chính cho User
            modelBuilder.Entity<User>()
                .HasKey(u => u.Id);

            // Cấu hình khoá chính cho StudyTask
            modelBuilder.Entity<StudyTask>()
                .HasKey(t => t.Id);

            // Cấu hình mối quan hệ 1-N (1 User có nhiều StudyTasks)
            modelBuilder.Entity<StudyTask>()
                .HasOne(t => t.User)
                .WithMany(u => u.Tasks)
                .HasForeignKey(t => t.UserId)
                .OnDelete(DeleteBehavior.Cascade); // Nếu xóa User thì xóa luôn các Tasks
        }
    }
}
