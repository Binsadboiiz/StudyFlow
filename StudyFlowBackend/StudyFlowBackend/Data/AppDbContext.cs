using Microsoft.EntityFrameworkCore;
using StudyFlowBackend.Models;
using StudyFlowBackend.Constants;

namespace StudyFlowBackend.Data
{
    public class AppDbContext : DbContext
    {
        public AppDbContext(DbContextOptions<AppDbContext> options) : base(options)
        {
        }

        public DbSet<User> Users { get; set; }
        public DbSet<StudyTask> Tasks { get; set; }
        public DbSet<FocusSession> FocusSessions { get; set; }
        public DbSet<UserNotification> UserNotifications { get; set; }
        public DbSet<Badge> Badges { get; set; }
        public DbSet<UserBadge> UserBadges { get; set; }
        public DbSet<StudyPet> StudyPets { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            // Bật extension pgvector cho PostgreSQL nếu cần làm AI Recommendation sau này
            // modelBuilder.HasPostgresExtension("vector"); // Tạm thời comment vì máy bạn chưa cài pgvector


            // Cấu hình khoá chính cho User
            modelBuilder.Entity<User>()
                .HasKey(u => u.Id);

            // Cấu hình khoá chính cho StudyTask
            modelBuilder.Entity<StudyTask>()
                .HasKey(t => t.Id);

            // Cấu hình khoá chính cho UserNotification
            modelBuilder.Entity<UserNotification>()
                .HasKey(un => un.Id);

            // Cấu hình khoá chính & mối quan hệ Many-to-Many cho UserBadge
            modelBuilder.Entity<UserBadge>()
                .HasKey(ub => new { ub.UserId, ub.BadgeId });

            modelBuilder.Entity<UserBadge>()
                .HasOne(ub => ub.User)
                .WithMany(u => u.UserBadges)
                .HasForeignKey(ub => ub.UserId)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<UserBadge>()
                .HasOne(ub => ub.Badge)
                .WithMany(b => b.UserBadges)
                .HasForeignKey(ub => ub.BadgeId)
                .OnDelete(DeleteBehavior.Cascade);

            // Cấu hình mối quan hệ 1-1 giữa User và StudyPet
            modelBuilder.Entity<StudyPet>()
                .HasKey(sp => sp.Id);

            modelBuilder.Entity<StudyPet>()
                .HasOne(sp => sp.User)
                .WithOne(u => u.Pet)
                .HasForeignKey<StudyPet>(sp => sp.UserId)
                .OnDelete(DeleteBehavior.Cascade);

            // Cấu hình mối quan hệ 1-N (1 User có nhiều StudyTasks)
            modelBuilder.Entity<StudyTask>()
                .HasOne(t => t.User)
                .WithMany(u => u.Tasks)
                .HasForeignKey(t => t.UserId)
                .OnDelete(DeleteBehavior.Cascade); // Nếu xóa User thì xóa luôn các Tasks

            // Cấu hình mối quan hệ 1-N (1 User có nhiều FocusSessions)
            modelBuilder.Entity<FocusSession>()
                .HasOne(f => f.User)
                .WithMany(u => u.FocusSessions)
                .HasForeignKey(f => f.UserId)
                .OnDelete(DeleteBehavior.Cascade);

            // Cấu hình mối quan hệ User - UserNotification
            modelBuilder.Entity<UserNotification>()
                .HasOne(un => un.User)
                .WithMany()
                .HasForeignKey(un => un.UserId)
                .OnDelete(DeleteBehavior.Cascade);

            // Cấu hình mối quan hệ User - FeaturedBadge (1 Badge được gán nổi bật bởi nhiều Users)
            modelBuilder.Entity<User>()
                .HasOne(u => u.FeaturedBadge)
                .WithMany()
                .HasForeignKey(u => u.FeaturedBadgeId)
                .OnDelete(DeleteBehavior.SetNull);

            // Seed dữ liệu ban đầu cho bảng Badges (Achievements) từ GamificationConstants
            modelBuilder.Entity<Badge>().HasData(GamificationConstants.DefaultBadges.ToArray());
        }
    }
}
