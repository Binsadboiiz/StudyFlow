// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get settings => 'Cài đặt';

  @override
  String get generalSettings => 'Cài đặt chung';

  @override
  String get editProfile => 'Chỉnh sửa hồ sơ';

  @override
  String get customizeProfileSubtitle =>
      'Tùy chỉnh tên, ảnh đại diện và mật khẩu';

  @override
  String get notifications => 'Thông báo';

  @override
  String get focusHistoryCharts => 'Lịch sử & Biểu đồ tập trung';

  @override
  String get focusHistorySubtitle =>
      'Xem biểu đồ và thống kê của chế độ tập trung';

  @override
  String get theme => 'Giao diện';

  @override
  String get lowPerformanceMode => 'Chế độ hiệu năng thấp';

  @override
  String get lowPerformanceSubtitle =>
      'Tắt hiệu ứng mờ/hoạt ảnh để UI mượt hơn';

  @override
  String get language => 'Ngôn ngữ';

  @override
  String get about => 'Giới thiệu';

  @override
  String get privacyPolicy => 'Chính sách bảo mật';

  @override
  String get logout => 'Đăng xuất';

  @override
  String get chooseTheme => 'Chọn giao diện';

  @override
  String get light => 'Sáng';

  @override
  String get lightThemeSubtitle => 'Tươi sáng và rõ ràng';

  @override
  String get dark => 'Tối';

  @override
  String get darkThemeSubtitle => 'Dễ chịu cho mắt';

  @override
  String get system => 'Hệ thống';

  @override
  String get systemThemeSubtitle => 'Theo cài đặt của thiết bị';

  @override
  String get chooseLanguage => 'Chọn ngôn ngữ';

  @override
  String get login => 'Đăng nhập';

  @override
  String get register => 'Đăng ký';

  @override
  String get email => 'Địa chỉ Email';

  @override
  String get password => 'Mật khẩu';

  @override
  String get confirmPassword => 'Xác nhận mật khẩu';

  @override
  String get fullName => 'Họ và tên';

  @override
  String get username => 'Tên đăng nhập';

  @override
  String get welcomeBack => 'Chào mừng trở lại!';

  @override
  String get welcomeSubtitle => 'Đăng nhập để tiếp tục hành trình học tập';

  @override
  String get dontHaveAccount => 'Chưa có tài khoản? ';

  @override
  String get alreadyHaveAccount => 'Đã có tài khoản? ';

  @override
  String get signUp => 'Đăng ký';

  @override
  String get signIn => 'Đăng nhập';

  @override
  String get pleaseFillFields => 'Vui lòng điền đầy đủ các thông tin';

  @override
  String get passwordsDoNotMatch => 'Mật khẩu xác nhận không khớp';

  @override
  String get invalidEmail => 'Vui lòng nhập địa chỉ email hợp lệ';

  @override
  String get usernameEmailIdentical =>
      'Tên đăng nhập và Email không được trùng nhau';

  @override
  String get passwordTooShort => 'Mật khẩu phải dài ít nhất 8 ký tự';

  @override
  String get passwordUppercase =>
      'Mật khẩu phải chứa ít nhất một chữ cái viết hoa';

  @override
  String get passwordSpecialChar =>
      'Mật khẩu phải chứa ít nhất một ký tự đặc biệt';

  @override
  String get registrationSuccessLogin =>
      'Đăng ký thành công! Vui lòng đăng nhập.';

  @override
  String get continueWithGoogle => 'Tiếp tục với Google';

  @override
  String get createAccountTitle => 'Tạo tài khoản';

  @override
  String get createAccountSubtitle =>
      'Tham gia cùng chúng tôi và quản lý công việc của bạn';

  @override
  String get or => 'hoặc';

  @override
  String get home => 'Trang chủ';

  @override
  String get tasks => 'Nhiệm vụ';

  @override
  String get focus => 'Tập trung';

  @override
  String get leaderboard => 'Bảng xếp hạng';

  @override
  String get schedule => 'Lịch trình';

  @override
  String get quest => 'Thử thách';

  @override
  String get badge_focused_student_name => 'Học giả tập trung';

  @override
  String get badge_focused_student_desc => 'Học liên tục trong vòng 2 giờ';

  @override
  String get badge_early_bird_name => 'Chú chim chăm chỉ';

  @override
  String get badge_early_bird_desc => 'Bắt đầu phiên học trước 6:00 sáng';

  @override
  String get haveAGoodDay => 'Chúc bạn một ngày tốt lành,';

  @override
  String get noGoalsForDay => 'Không có mục tiêu nào cho ngày này';

  @override
  String get takeARest => 'Hãy nghỉ ngơi và tận hưởng ngày của bạn!';

  @override
  String get taskCompletedReward => 'Nhiệm vụ đã hoàn thành! +10 XP, +10 xu';

  @override
  String get today => 'Hôm nay';

  @override
  String get mins => 'phút';

  @override
  String get progress => 'Tiến độ';

  @override
  String remainingWithCount(Object count) {
    return '$count còn lại';
  }

  @override
  String get tapToAddFirstTask => 'Nhấn + để thêm nhiệm vụ mới';

  @override
  String get completed => 'Đã hoàn thành';

  @override
  String completedWithCount(Object count) {
    return 'Đã hoàn thành ($count)';
  }

  @override
  String get taskDeleted => 'Đã xóa nhiệm vụ thành công!';

  @override
  String get deleteTask => 'Xóa nhiệm vụ';

  @override
  String get deleteTaskConfirm => 'Bạn có chắc muốn xóa nhiệm vụ này không?';

  @override
  String get cancel => 'Hủy';

  @override
  String get delete => 'Xóa';

  @override
  String get editTask => 'Chỉnh sửa nhiệm vụ';

  @override
  String get addNewTask => 'Thêm nhiệm vụ mới';

  @override
  String get taskTitleHint => 'Bạn muốn làm gì...?';

  @override
  String get taskDescHint => 'Thêm chi tiết / mô tả...';

  @override
  String get date => 'Ngày';

  @override
  String get start => 'Bắt đầu';

  @override
  String get end => 'Kết thúc';

  @override
  String get reminder => 'Nhắc nhở';

  @override
  String get noReminder => 'Không / Không nhắc nhở';

  @override
  String get optional => 'Tùy chọn';

  @override
  String get errStartTimePast => 'Thời gian bắt đầu không thể ở quá khứ!';

  @override
  String get errEndTimeZero =>
      'Thời gian kết thúc không thể là 00:00 (vui lòng chọn tối đa 23:59)!';

  @override
  String get errEndTimeBeforeStart =>
      'Thời gian kết thúc phải sau thời gian bắt đầu!';

  @override
  String get errReminderTimePast => 'Thời gian nhắc nhở không thể ở quá khứ!';

  @override
  String get taskUpdated => 'Đã cập nhật nhiệm vụ!';

  @override
  String get taskAdded => 'Đã thêm nhiệm vụ mới!';

  @override
  String get saveChanges => 'Lưu thay đổi';

  @override
  String get addNow => 'Thêm ngay';

  @override
  String get focusMode => 'Chế độ tập trung';

  @override
  String get focusAnalytics => 'Phân tích tập trung';

  @override
  String get custom => 'Tùy chỉnh';

  @override
  String get pomodoro => 'Pomodoro';

  @override
  String get rest => 'NGHỈ NGƠI';

  @override
  String get focusLabel => 'TẬP TRUNG';

  @override
  String get overviewMetrics => 'Số liệu tổng quan';

  @override
  String get focusHistoryLogs => 'Lịch sử tập trung';

  @override
  String get last7Days => '7 ngày qua';

  @override
  String get last30Days => '30 ngày qua';

  @override
  String get chartStyle => 'Kiểu biểu đồ';

  @override
  String get noFocusLogsFound =>
      'Không tìm thấy dữ liệu tập trung trong khoảng thời gian này.';

  @override
  String get areaFocusTrend => 'Xu hướng tập trung diện tích';

  @override
  String get barSessionDistribution => 'Phân phối phiên học dạng cột';

  @override
  String get tapToViewDetails => 'Nhấn vào các điểm dữ liệu để xem chi tiết';

  @override
  String get totalFocused => 'Tổng thời gian tập trung';

  @override
  String get avgSession => 'Trung bình / Phiên';

  @override
  String get activeDays => 'Ngày hoạt động';

  @override
  String get noFocusHistoryAvailable => 'Không có lịch sử phiên tập trung.';

  @override
  String sessionModeLabel(Object mode) {
    return 'Phiên $mode';
  }

  @override
  String sessionsCount(Object count) {
    return '$count phiên';
  }

  @override
  String activeDaysValue(Object count, Object ratio) {
    return '$count ngày ($ratio)';
  }

  @override
  String get clearAll => 'Xóa tất cả';

  @override
  String get deleteAllNotifications => 'Xóa tất cả thông báo';

  @override
  String get deleteAllNotificationsConfirm =>
      'Bạn có chắc chắn muốn xóa tất cả thông báo không? Hành động này không thể hoàn tác.';

  @override
  String get noNotification => 'Không có thông báo';

  @override
  String get notificationsDescription =>
      'Thông báo và lời nhắc của bạn sẽ xuất hiện tại đây';

  @override
  String get yesterday => 'Hôm qua';

  @override
  String get timezoneWarningTitle => 'Cảnh báo lệch múi giờ';

  @override
  String get timezoneWarningSubtitle =>
      'Chưa bật Thông báo/Lời nhắc. Nhấp để bật nhằm tránh lệch múi giờ UTC.';

  @override
  String get personalInfo => 'Thông tin cá nhân';

  @override
  String get enterFullName => 'Nhập họ và tên của bạn';

  @override
  String get fullNameRequired => 'Vui lòng nhập họ và tên';

  @override
  String get emailAddressDisabled => 'Địa chỉ Email (Không thể sửa)';

  @override
  String get presets => 'Mặc định';

  @override
  String get customUrl => 'URL tùy chỉnh';

  @override
  String get avatarImageUrl => 'Đường dẫn ảnh đại diện';

  @override
  String get linkedWithGoogle => 'Đã liên kết với Google';

  @override
  String get googlePasswordMgmt =>
      'Quản lý mật khẩu được bảo mật hoàn toàn bởi Google.';

  @override
  String get changePassword => 'Đổi mật khẩu';

  @override
  String get currentPassword => 'Mật khẩu hiện tại';

  @override
  String get requiredIfChanging => 'Yêu cầu nếu thay đổi mật khẩu';

  @override
  String get currPasswordRequired =>
      'Mật khẩu hiện tại là bắt buộc để đặt mật khẩu mới';

  @override
  String get newPassword => 'Mật khẩu mới';

  @override
  String get atLeast6Chars => 'Tối thiểu 6 ký tự';

  @override
  String get passwordTooShort6 => 'Mật khẩu phải chứa ít nhất 6 ký tự';

  @override
  String get confirmNewPassword => 'Xác nhận mật khẩu mới';

  @override
  String get retypeNewPassword => 'Nhập lại mật khẩu mới';

  @override
  String get streak => 'Chuỗi';

  @override
  String get pet => 'Thú cưng';

  @override
  String get achievements => 'Thành tích';

  @override
  String get levelUp => 'THĂNG CẤP!';

  @override
  String get levelUpCongrat =>
      'Chúc mừng thành tích của bạn! Bạn đã đạt đến một cấp độ mới.';

  @override
  String get keepUpWork =>
      'Hãy tiếp tục phát huy! Bạn đã nhận được một phần thưởng thăng cấp.';

  @override
  String get awesome => 'Tuyệt vời! 🌟';

  @override
  String get level => 'Cấp độ';

  @override
  String get petLv => 'Thú cưng cấp';

  @override
  String get noPet => 'Chưa có Thú cưng';

  @override
  String get notAdopted => 'Chưa nhận nuôi';

  @override
  String achievementsCount(Object count) {
    return '$count Thành tích';
  }

  @override
  String get earned => 'Đạt được';

  @override
  String get petRequiredXp => 'Kinh nghiệm Thú cưng';

  @override
  String get hunger => 'Độ no';

  @override
  String get feed => 'Cho ăn';

  @override
  String feedCost(Object coins) {
    return 'Tốn 10 Xu (Bạn có: $coins)';
  }

  @override
  String get play => 'Chơi cùng';

  @override
  String get eggEvolution => 'Trứng 🥚';

  @override
  String get babyEvolution => 'Sơ sinh 🍼';

  @override
  String get teenEvolution => 'Thiếu niên ⚡';

  @override
  String get adultEvolution => 'Trưởng thành 👑';

  @override
  String get dontHavePet => 'Bạn chưa có Thú cưng học tập!';

  @override
  String get petCompanion => 'Thú cưng đồng hành học tập của bạn';

  @override
  String get cat => 'Mèo';

  @override
  String get dog => 'Chó';

  @override
  String get panda => 'Gấu trúc';

  @override
  String get adoptPetDesc =>
      'Nhận nuôi một thú cưng học tập để đồng hành cùng bạn trên hành trình này.';

  @override
  String get nameYourPet => 'Đặt tên cho Thú cưng:';

  @override
  String get enterPetNameHint => 'Nhập tên thú cưng (vd: Meo Meo)...';

  @override
  String get choosePetEgg => 'Chọn một quả trứng thú cưng:';

  @override
  String get adoptNowBtn => 'Nhận nuôi ngay 🥚';

  @override
  String get pleaseGivePetName => 'Vui lòng đặt tên cho thú cưng của bạn!';

  @override
  String get currentStreak => 'Chuỗi hiện tại';

  @override
  String days(Object count) {
    return '$count Ngày';
  }

  @override
  String get minutesFocusedToday => 'Số phút tập trung hôm nay';

  @override
  String get dailyGoalProgress => 'Tiến độ mục tiêu ngày';

  @override
  String get studyHistory => 'Lịch sử học tập';

  @override
  String get rewardEarned => 'Phần thưởng nhận được:';

  @override
  String get status => 'Trạng thái:';

  @override
  String unlockedWithDate(Object date) {
    return 'Đã mở khóa ($date)';
  }

  @override
  String get locked => 'Chưa mở khóa';

  @override
  String get featuredBadgeRemoved => 'Đã gỡ danh hiệu nổi bật.';

  @override
  String featuredBadgeSet(Object name) {
    return 'Đã đặt \"$name\" làm danh hiệu nổi bật!';
  }

  @override
  String get removeFeaturedBadge => 'Gỡ danh hiệu nổi bật';

  @override
  String get setAsFeaturedBadge => 'Đặt làm danh hiệu nổi bật';

  @override
  String get close => 'Đóng';

  @override
  String get processing => 'Đang xử lý...';

  @override
  String get badge_noob_no_more_name => 'Luyện Khí Sơ Kỳ';

  @override
  String get badge_noob_no_more_desc => 'Đạt cấp độ 5';

  @override
  String get badge_touching_grass_never_name => 'Trúc Cơ Thành Công';

  @override
  String get badge_touching_grass_never_desc => 'Đạt cấp độ 10';

  @override
  String get badge_certified_brainrot_name => 'Học thần nhập thể';

  @override
  String get badge_certified_brainrot_desc => 'Đạt cấp độ 20';

  @override
  String get badge_main_character_energy_name => 'Hào quang nhân vật chính';

  @override
  String get badge_main_character_energy_desc => 'Đạt cấp độ 50';

  @override
  String get badge_locked_in_name => 'AFK Mọi Drama';

  @override
  String get badge_locked_in_desc => 'Tích lũy 1 giờ tập trung';

  @override
  String get badge_distraction_who_name => 'Tôi Không Nghe, Tôi Không Thấy';

  @override
  String get badge_distraction_who_desc => 'Tích lũy 10 giờ tập trung';

  @override
  String get badge_sigma_study_grind_name => 'Bế Quan Khổ Tu';

  @override
  String get badge_sigma_study_grind_desc => 'Tích lũy 50 giờ tập trung';

  @override
  String get badge_ultra_instinct_name => 'Ngộ Đạo Thiên Cơ';

  @override
  String get badge_ultra_instinct_desc => 'Tích lũy 100 giờ tập trung';

  @override
  String get badge_the_first_w_name => 'NPC Bắt Đầu Thức Tỉnh';

  @override
  String get badge_the_first_w_desc => 'Hoàn thành nhiệm vụ đầu tiên';

  @override
  String get badge_task_destroyer_name => 'Kẻ hủy diệt nhiệm vụ';

  @override
  String get badge_task_destroyer_desc => 'Hoàn thành 10 nhiệm vụ';

  @override
  String get badge_productivity_monster_name => 'To-do List Khóc Thét';

  @override
  String get badge_productivity_monster_desc => 'Hoàn thành 50 nhiệm vụ';

  @override
  String get badge_day_one_or_one_day_name => 'Day One or One Day?';

  @override
  String get badge_day_one_or_one_day_desc => 'Duy trì chuỗi học tập 3 ngày';

  @override
  String get badge_built_different_name => 'Mấy con gà thì biết gì';

  @override
  String get badge_built_different_desc => 'Duy trì chuỗi học tập 7 ngày';

  @override
  String get badge_grassless_legend_name => 'Huyền thoại bất bại';

  @override
  String get badge_grassless_legend_desc => 'Duy trì chuỗi học tập 30 ngày';

  @override
  String get noLeaderboardData =>
      'Chưa có dữ liệu bảng xếp hạng. Hãy bắt đầu học tập để leo hạng!';

  @override
  String get noAchievementsData =>
      'Chưa có dữ liệu thành tích. Hãy bắt đầu học tập để nhận huy hiệu!';

  @override
  String get unlocked => 'Đã mở khóa';

  @override
  String get tutorialWelcomeTitle => 'Chào mừng đến với StudyFlow! 🚀';

  @override
  String get tutorialWelcomeDesc =>
      'Người bạn đồng hành tối ưu giúp quản lý thời gian thông minh, theo dõi thói quen và phân tích học tập. Hãy cùng dạo một vòng nhanh quanh góc học tập mới của bạn.';

  @override
  String get tutorialWelcomeHighlight =>
      'Nhấn Tiếp tục để bắt đầu chuyến tham quan';

  @override
  String get tutorialDashboardTitle => 'Bảng điều khiển thông minh 📊';

  @override
  String get tutorialDashboardDesc =>
      'Theo dõi chuỗi ngày học tập (biểu tượng lửa), kiểm tra thông báo, lập mục tiêu hàng ngày và xem lịch nhiệm vụ trong một không gian trực quan thống nhất.';

  @override
  String get tutorialDashboardHighlight =>
      'Mục tiêu hàng ngày hiển thị ở dưới cùng trang chủ';

  @override
  String get tutorialTimerTitle => 'Đồng hồ tập trung Pomodoro ⏱️';

  @override
  String get tutorialTimerDesc =>
      'Loại bỏ xao nhãng bằng đồng hồ đếm ngược Pomodoro tùy chỉnh. Thực hiện các phiên tập trung để nâng cấp thói quen và tạo biểu đồ nhiệt năng suất chi tiết.';

  @override
  String get tutorialTimerHighlight =>
      'Bắt đầu một phiên học để chặn thông báo';

  @override
  String get tutorialTaskManagerTitle => 'Quản lý nhiệm vụ 📝';

  @override
  String get tutorialTaskManagerDesc =>
      'Tạo, sửa và sắp xếp nhiệm vụ học tập, bài tập trên lớp và danh sách kiểm tra cá nhân. Tích chọn các mục hoàn thành để đồng bộ với cơ sở dữ liệu.';

  @override
  String get tutorialTaskManagerHighlight =>
      'Nhấn nút \"+\" trên thanh điều hướng để thêm nhanh nhiệm vụ';

  @override
  String get tutorialScheduleTitle => 'Thời khóa biểu tuần 📅';

  @override
  String get tutorialScheduleDesc =>
      'Xem các lớp học và thời hạn trong tuần theo một dòng thời gian có cấu trúc. Luôn đi trước chương trình học với việc lập lịch rõ ràng.';

  @override
  String get tutorialScheduleHighlight =>
      'Kéo hoặc vuốt để xem các ngày khác nhau trong tuần';

  @override
  String get tutorialQuestsTitle => 'Trung tâm nhiệm vụ & Chuỗi ngày 🏆';

  @override
  String get tutorialQuestsDesc =>
      'Duy trì chuỗi học tập hàng ngày bằng cách hoàn thành nhiệm vụ và các phiên tập trung. Nhấn vào các tab Quest để khám phá thêm các tính năng khác!';

  @override
  String get tutorialQuestsHighlight =>
      'Kiểm tra nhiệm vụ hàng ngày/hàng tuần để nhận thêm XP!';

  @override
  String get tutorialPetTitle => 'Nhận nuôi & Nuôi Pet học tập 🐾';

  @override
  String get tutorialPetDesc =>
      'Nhận nuôi một thú cưng học tập ảo! Kiếm xu từ việc học để cho thú cưng ăn, nhận XP giúp thú cưng tiến hóa qua 4 giai đoạn phát triển và lớn lên cùng bạn.';

  @override
  String get tutorialPetHighlight =>
      'Tốn 10 xu để cho pet ăn và tăng XP tiến hóa';

  @override
  String get tutorialBadgesGetTitle => 'Nhận huy hiệu thành tích 🏅';

  @override
  String get tutorialBadgesGetDesc =>
      'Mở khóa các huy hiệu thành tích đa dạng bằng cách đạt các mốc cột mốc: hoàn thành nhiệm vụ, duy trì chuỗi ngày học hoặc tập trung đều đặn.';

  @override
  String get tutorialBadgesGetHighlight =>
      'Huy hiệu sẽ tự động được lưu trữ trên đám mây';

  @override
  String get tutorialBadgesSetTitle => 'Trang bị & Trưng bày huy hiệu ✨';

  @override
  String get tutorialBadgesSetDesc =>
      'Sau khi mở khóa, chọn bất kỳ huy hiệu nào để đặt làm \"Huy hiệu nổi bật\". Nó sẽ xuất hiện cạnh tên bạn trên Bảng xếp hạng và trong hồ sơ cá nhân!';

  @override
  String get tutorialBadgesSetHighlight =>
      'Nhấn vào một huy hiệu đã mở khóa để thiết lập';

  @override
  String get tutorialSettingsTitle => 'Cài đặt & Tùy chỉnh ⚙️';

  @override
  String get tutorialSettingsDesc =>
      'Tùy chỉnh giao diện sáng/tối, bật chế độ Hiệu năng thấp (mượt hơn cho máy yếu), xem trang Giới thiệu và truy cập các tài liệu Chính sách bảo mật.';

  @override
  String get tutorialSettingsHighlight =>
      'Tìm màn hình Giới thiệu và Chính sách bảo mật tại đây';

  @override
  String get tutorialReadyTitle => 'Tất cả đã sẵn sàng! 🎉';

  @override
  String get tutorialReadyDesc =>
      'Bạn đã hoàn toàn sẵn sàng để thiết lập dòng chảy học tập của mình! Hoàn thành nhiệm vụ, duy trì chuỗi ngày và nâng cao năng suất cùng StudyFlow.';

  @override
  String get tutorialReadyHighlight =>
      'Nhấn Bắt đầu! để bắt đầu hành trình của bạn';

  @override
  String get tutorialSkip => 'Bỏ qua';

  @override
  String get tutorialBack => 'Quay lại';

  @override
  String get tutorialNext => 'Tiếp tục';

  @override
  String get tutorialStart => 'Bắt đầu!';

  @override
  String get tutorialDockTip =>
      'Thanh điều hướng tự động chuyển mục phù hợp 🪄';

  @override
  String get scanTitle => 'Tài liệu';

  @override
  String get scanSearchHint => 'Tìm kiếm tài liệu...';

  @override
  String get scanNoDocumentsTitle => 'Chưa có tài liệu nào';

  @override
  String get scanNoDocumentsSubtitle =>
      'Nhấn nút bên dưới để quét tài liệu đầu tiên';

  @override
  String get scanNoSearchResults => 'Không tìm thấy tài liệu';

  @override
  String get scanNoSearchResultsSubtitle => 'Thử tìm kiếm với từ khóa khác';

  @override
  String get scanSave => 'Lưu';

  @override
  String get scanSaving => 'Đang lưu...';

  @override
  String get scanReviewTitle => 'Xem lại kết quả';

  @override
  String get scanConfidence => 'Tin cậy';

  @override
  String get scanLanguage => 'Ngôn ngữ';

  @override
  String get scanSize => 'Kích thước';

  @override
  String get scanTitleHint => 'Nhập tiêu đề tài liệu...';

  @override
  String get scanSaveButton => 'Lưu tài liệu';

  @override
  String get scanSavingUpload => 'Đang tải lên và lưu...';

  @override
  String get scanEmptyTitleError => 'Vui lòng nhập tiêu đề tài liệu';

  @override
  String get scanEmptyTextError => 'Nội dung văn bản không được để trống';

  @override
  String get scanSaveSuccess => 'Đã lưu tài liệu thành công!';

  @override
  String get scanSaveFailed => 'Không thể lưu tài liệu';

  @override
  String get scanDetailTitle => 'Chi tiết tài liệu';

  @override
  String get scanNotFound => 'Không tìm thấy tài liệu';

  @override
  String get scanLoadImageFailed => 'Không thể tải ảnh';

  @override
  String get scanInfoTitle => 'Thông tin tài liệu';

  @override
  String get scanCreatedAt => 'Ngày tạo';

  @override
  String get scanUpdatedAt => 'Cập nhật';

  @override
  String get scanTextContentTitle => 'Nội dung văn bản';

  @override
  String get scanCopyAll => 'Sao chép toàn bộ';

  @override
  String get scanCopySuccess => 'Đã sao chép nội dung văn bản';

  @override
  String get scanEmptyText => 'Không có nội dung văn bản';

  @override
  String get scanDeleteConfirmTitle => 'Xóa tài liệu?';

  @override
  String scanDeleteConfirmDesc(Object title) {
    return 'Bạn có chắc chắn muốn xóa \"$title\"?\nHành động này không thể hoàn tác.';
  }

  @override
  String get scanDeleteCancel => 'Hủy';

  @override
  String get scanDeleteConfirm => 'Xóa';

  @override
  String get scanDeleteSuccess => 'Đã xóa tài liệu';

  @override
  String get scanCameraOptionsTitle => 'Chọn ảnh';

  @override
  String get scanCamera => 'Máy ảnh';

  @override
  String get scanGallery => 'Thư viện';

  @override
  String get scanProcessingText => 'Đang xử lý ảnh...';

  @override
  String get scanProcessFailed => 'Xử lý ảnh thất bại hoặc bị hủy';

  @override
  String scanStorageUsage(Object total, Object used) {
    return 'Lưu trữ: $used / $total MB';
  }

  @override
  String get scanQuotaExceeded => 'Đã vượt quá giới hạn lưu trữ';

  @override
  String get scanFeatureDesc => 'Quét tài liệu vật lý sử dụng OCR';
}
