// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get settings => 'Settings';

  @override
  String get generalSettings => 'General Settings';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get customizeProfileSubtitle => 'Customize name, avatar, and password';

  @override
  String get notifications => 'Notifications';

  @override
  String get focusHistoryCharts => 'Focus History & Charts';

  @override
  String get focusHistorySubtitle => 'View charts and statistics of focus mode';

  @override
  String get theme => 'Theme';

  @override
  String get lowPerformanceMode => 'Low Performance Mode';

  @override
  String get lowPerformanceSubtitle =>
      'Disable blurs/animations for smoother UI';

  @override
  String get language => 'Language';

  @override
  String get about => 'About';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get logout => 'Logout';

  @override
  String get chooseTheme => 'Choose Theme';

  @override
  String get light => 'Light';

  @override
  String get lightThemeSubtitle => 'Bright and clean';

  @override
  String get dark => 'Dark';

  @override
  String get darkThemeSubtitle => 'Easy on the eyes';

  @override
  String get system => 'System';

  @override
  String get systemThemeSubtitle => 'Follow device settings';

  @override
  String get chooseLanguage => 'Choose Language';

  @override
  String get login => 'Login';

  @override
  String get register => 'Register';

  @override
  String get email => 'Email Address';

  @override
  String get password => 'Password';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get fullName => 'Full Name';

  @override
  String get username => 'Username';

  @override
  String get welcomeBack => 'Welcome Back!';

  @override
  String get welcomeSubtitle => 'Login to continue your study flow';

  @override
  String get dontHaveAccount => 'Don\'t have an account? ';

  @override
  String get alreadyHaveAccount => 'Already have an account? ';

  @override
  String get signUp => 'Sign Up';

  @override
  String get signIn => 'Sign In';

  @override
  String get pleaseFillFields => 'Please fill in all fields';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get invalidEmail => 'Please enter a valid email address';

  @override
  String get usernameEmailIdentical => 'Username and Email cannot be identical';

  @override
  String get passwordTooShort => 'Password must be at least 8 characters long';

  @override
  String get passwordUppercase =>
      'Password must contain at least one uppercase letter';

  @override
  String get passwordSpecialChar =>
      'Password must contain at least one special character';

  @override
  String get registrationSuccessLogin =>
      'Registration successful! Please login.';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get createAccountTitle => 'Create Account';

  @override
  String get createAccountSubtitle => 'Join us and start organizing your tasks';

  @override
  String get or => 'or';

  @override
  String get home => 'Home';

  @override
  String get tasks => 'Tasks';

  @override
  String get focus => 'Focus';

  @override
  String get leaderboard => 'Leaderboard';

  @override
  String get schedule => 'Schedule';

  @override
  String get quest => 'Quest';

  @override
  String get badge_focused_student_name => 'Focused Student';

  @override
  String get badge_focused_student_desc => 'Study continuously for 2 hours';

  @override
  String get badge_early_bird_name => 'Early Bird';

  @override
  String get badge_early_bird_desc => 'Start a study session before 6:00 AM';

  @override
  String get haveAGoodDay => 'Have a good day,';

  @override
  String get noGoalsForDay => 'No goals for this day';

  @override
  String get takeARest => 'Take a rest and enjoy your day!';

  @override
  String get taskCompletedReward => 'Task completed! +10 XP, +10 coins';

  @override
  String get today => 'Today';

  @override
  String get mins => 'mins';

  @override
  String get progress => 'Progress';

  @override
  String remainingWithCount(Object count) {
    return '$count remaining';
  }

  @override
  String get tapToAddFirstTask => 'Tap + to add a new task';

  @override
  String get completed => 'Completed';

  @override
  String completedWithCount(Object count) {
    return 'Completed ($count)';
  }

  @override
  String get taskDeleted => 'Task deleted successfully!';

  @override
  String get deleteTask => 'Delete Task';

  @override
  String get deleteTaskConfirm => 'Are you sure you want to delete this task?';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get editTask => 'Edit task';

  @override
  String get addNewTask => 'Add new task';

  @override
  String get taskTitleHint => 'What do you want to do...?';

  @override
  String get taskDescHint => 'Add details / description...';

  @override
  String get date => 'Date';

  @override
  String get start => 'Start';

  @override
  String get end => 'End';

  @override
  String get reminder => 'Reminder';

  @override
  String get noReminder => 'None / No Reminder';

  @override
  String get optional => 'Optional';

  @override
  String get errStartTimePast => 'Start time cannot be in the past!';

  @override
  String get errEndTimeZero =>
      'End time cannot be 00:00 (please use up to 23:59)!';

  @override
  String get errEndTimeBeforeStart => 'End time must be after start time!';

  @override
  String get errReminderTimePast => 'Reminder time cannot be in the past!';

  @override
  String get taskUpdated => 'Task updated!';

  @override
  String get taskAdded => 'Added new task!';

  @override
  String get saveChanges => 'Save changes';

  @override
  String get addNow => 'Add now';

  @override
  String get focusMode => 'Focus Mode';

  @override
  String get focusAnalytics => 'Focus Analytics';

  @override
  String get custom => 'Custom';

  @override
  String get pomodoro => 'Pomodoro';

  @override
  String get rest => 'REST';

  @override
  String get focusLabel => 'FOCUS';

  @override
  String get overviewMetrics => 'Overview Metrics';

  @override
  String get focusHistoryLogs => 'Focus History Logs';

  @override
  String get last7Days => 'Last 7 Days';

  @override
  String get last30Days => 'Last 30 Days';

  @override
  String get chartStyle => 'Chart Style';

  @override
  String get noFocusLogsFound => 'No focus logs found for this range.';

  @override
  String get areaFocusTrend => 'Area Focus Trend';

  @override
  String get barSessionDistribution => 'Bar Session Distribution';

  @override
  String get tapToViewDetails => 'Tap on data points to view details';

  @override
  String get totalFocused => 'Total Focused';

  @override
  String get avgSession => 'Avg / Session';

  @override
  String get activeDays => 'Active Days';

  @override
  String get noFocusHistoryAvailable => 'No focus session history available.';

  @override
  String sessionModeLabel(Object mode) {
    return '$mode Session';
  }

  @override
  String sessionsCount(Object count) {
    return '$count sessions';
  }

  @override
  String activeDaysValue(Object count, Object ratio) {
    return '$count days ($ratio)';
  }

  @override
  String get clearAll => 'Clear all';

  @override
  String get deleteAllNotifications => 'Delete all notifications';

  @override
  String get deleteAllNotificationsConfirm =>
      'Are you sure you want to delete all notifications? This action cannot be undone.';

  @override
  String get noNotification => 'No notification';

  @override
  String get notificationsDescription =>
      'Notifications and reminders will appear here';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get timezoneWarningTitle => 'Timezone Offset Warning';

  @override
  String get timezoneWarningSubtitle =>
      'Notifications/reminders are disabled. Tap to enable to avoid UTC offsets.';

  @override
  String get personalInfo => 'Personal Info';

  @override
  String get enterFullName => 'Enter your full name';

  @override
  String get fullNameRequired => 'Full name is required';

  @override
  String get emailAddressDisabled => 'Email Address (Disabled)';

  @override
  String get presets => 'Presets';

  @override
  String get customUrl => 'Custom URL';

  @override
  String get avatarImageUrl => 'Avatar Image URL';

  @override
  String get linkedWithGoogle => 'Linked with Google';

  @override
  String get googlePasswordMgmt =>
      'Password management is securely handled by Google.';

  @override
  String get changePassword => 'Change Password';

  @override
  String get currentPassword => 'Current Password';

  @override
  String get requiredIfChanging => 'Required if changing password';

  @override
  String get currPasswordRequired =>
      'Current password is required to set a new password';

  @override
  String get newPassword => 'New Password';

  @override
  String get atLeast6Chars => 'At least 6 characters';

  @override
  String get passwordTooShort6 => 'Password must be at least 6 characters long';

  @override
  String get confirmNewPassword => 'Confirm New Password';

  @override
  String get retypeNewPassword => 'Retype new password';

  @override
  String get streak => 'Streak';

  @override
  String get pet => 'Pet';

  @override
  String get achievements => 'Achievements';

  @override
  String get levelUp => 'LEVEL UP!';

  @override
  String get levelUpCongrat =>
      'Congratulations on your achievement! You have reached a new level.';

  @override
  String get keepUpWork =>
      'Keep up the great work! You have earned a level-up reward.';

  @override
  String get awesome => 'Awesome! 🌟';

  @override
  String get level => 'Level';

  @override
  String get petLv => 'Pet LV';

  @override
  String get noPet => 'No Pet';

  @override
  String get notAdopted => 'Not Adopted';

  @override
  String achievementsCount(Object count) {
    return '$count Achievements';
  }

  @override
  String get earned => 'Earned';

  @override
  String get petRequiredXp => 'Pet Experience';

  @override
  String get hunger => 'Hunger';

  @override
  String get feed => 'Feed';

  @override
  String feedCost(Object coins) {
    return 'Costs 10 Coins (You have: $coins)';
  }

  @override
  String get play => 'Play';

  @override
  String get eggEvolution => 'Egg 🥚';

  @override
  String get babyEvolution => 'Baby 🍼';

  @override
  String get teenEvolution => 'Teen ⚡';

  @override
  String get adultEvolution => 'Adult 👑';

  @override
  String get dontHavePet => 'You don\'t have a Study Pet yet!';

  @override
  String get petCompanion => 'Your learning pet companion';

  @override
  String get cat => 'Cat';

  @override
  String get dog => 'Dog';

  @override
  String get panda => 'Panda';

  @override
  String get adoptPetDesc =>
      'Adopt a learning pet to join you on your study journey.';

  @override
  String get nameYourPet => 'Name your Pet:';

  @override
  String get enterPetNameHint => 'Enter pet name (e.g., Meow meow)...';

  @override
  String get choosePetEgg => 'Choose a pet egg:';

  @override
  String get adoptNowBtn => 'Adopt Now 🥚';

  @override
  String get pleaseGivePetName => 'Please give your pet a name!';

  @override
  String get currentStreak => 'Current Streak';

  @override
  String days(Object count) {
    return '$count Days';
  }

  @override
  String get minutesFocusedToday => 'Minutes focused today';

  @override
  String get dailyGoalProgress => 'Daily Goal Progress';

  @override
  String get studyHistory => 'Study History';

  @override
  String get rewardEarned => 'Reward Earned:';

  @override
  String get status => 'Status:';

  @override
  String unlockedWithDate(Object date) {
    return 'Unlocked ($date)';
  }

  @override
  String get locked => 'Locked';

  @override
  String get featuredBadgeRemoved => 'Featured badge removed.';

  @override
  String featuredBadgeSet(Object name) {
    return '\"$name\" set as featured badge!';
  }

  @override
  String get removeFeaturedBadge => 'Remove Featured Badge';

  @override
  String get setAsFeaturedBadge => 'Set as Featured Badge';

  @override
  String get close => 'Close';

  @override
  String get processing => 'Processing...';

  @override
  String get badge_noob_no_more_name => 'Noob No More';

  @override
  String get badge_noob_no_more_desc => 'Reach Level 5';

  @override
  String get badge_touching_grass_never_name => 'Touching Grass? Never';

  @override
  String get badge_touching_grass_never_desc => 'Reach Level 10';

  @override
  String get badge_certified_brainrot_name => 'Certified Brainrot';

  @override
  String get badge_certified_brainrot_desc => 'Reach Level 20';

  @override
  String get badge_main_character_energy_name => 'Main Character Energy';

  @override
  String get badge_main_character_energy_desc => 'Reach Level 50';

  @override
  String get badge_locked_in_name => 'Locked In';

  @override
  String get badge_locked_in_desc => 'Accumulate 1 hour of focus time';

  @override
  String get badge_distraction_who_name => 'Distraction Who?';

  @override
  String get badge_distraction_who_desc => 'Accumulate 10 hours of focus time';

  @override
  String get badge_sigma_study_grind_name => 'Sigma Study Grind';

  @override
  String get badge_sigma_study_grind_desc =>
      'Accumulate 50 hours of focus time';

  @override
  String get badge_ultra_instinct_name => 'Ultra Instinct';

  @override
  String get badge_ultra_instinct_desc => 'Accumulate 100 hours of focus time';

  @override
  String get badge_the_first_w_name => 'The First W';

  @override
  String get badge_the_first_w_desc => 'Complete your first task';

  @override
  String get badge_task_destroyer_name => 'Task Destroyer';

  @override
  String get badge_task_destroyer_desc => 'Complete 10 tasks';

  @override
  String get badge_productivity_monster_name => 'Productivity Monster';

  @override
  String get badge_productivity_monster_desc => 'Complete 50 tasks';

  @override
  String get badge_day_one_or_one_day_name => 'Day One or One Day?';

  @override
  String get badge_day_one_or_one_day_desc => 'Maintain a 3-day streak';

  @override
  String get badge_built_different_name => 'Built Different';

  @override
  String get badge_built_different_desc => 'Maintain a 7-day streak';

  @override
  String get badge_grassless_legend_name => 'Grassless Legend';

  @override
  String get badge_grassless_legend_desc => 'Maintain a 30-day streak';

  @override
  String get noLeaderboardData =>
      'No leaderboard data available yet. Start studying to climb the ranks!';

  @override
  String get noAchievementsData =>
      'No achievement data available yet. Start studying to earn badges!';

  @override
  String get unlocked => 'Unlocked';

  @override
  String get tutorialWelcomeTitle => 'Welcome to StudyFlow! 🚀';

  @override
  String get tutorialWelcomeDesc =>
      'Your ultimate companion for smart time management, habits tracking, and learning analytics. Let us take a quick tour of your new workspace.';

  @override
  String get tutorialWelcomeHighlight => 'Press Next to begin the tour';

  @override
  String get tutorialDashboardTitle => 'Smart Dashboard 📊';

  @override
  String get tutorialDashboardDesc =>
      'Keep track of your learning streak (fire icon), check notifications, plan daily goals, and view calendar tasks all in one unified visual space.';

  @override
  String get tutorialDashboardHighlight =>
      'Daily targets are shown at the bottom of Home';

  @override
  String get tutorialTimerTitle => 'Focus Pomodoro Timer ⏱️';

  @override
  String get tutorialTimerDesc =>
      'Block out distractions using customized Pomodoro countdown timers. Run focus sessions to level up your habits and generate detailed productivity heatmaps.';

  @override
  String get tutorialTimerHighlight => 'Start a session to block notifications';

  @override
  String get tutorialTaskManagerTitle => 'Task Manager 📝';

  @override
  String get tutorialTaskManagerDesc =>
      'Create, edit, and organize study tasks, class assignments, and personal checklists. Check off items as you complete them to sync with our database.';

  @override
  String get tutorialTaskManagerHighlight =>
      'Click the \"+\" button in the dock to add tasks instantly';

  @override
  String get tutorialScheduleTitle => 'Weekly Schedule 📅';

  @override
  String get tutorialScheduleDesc =>
      'View your weekly classes and deadlines in a structured timeline. Stay ahead of your curriculum with clear scheduling and auto-syncing calendar routes.';

  @override
  String get tutorialScheduleHighlight =>
      'Drag or swipe to view different dates of the week';

  @override
  String get tutorialQuestsTitle => 'Quest Hub & Streak 🏆';

  @override
  String get tutorialQuestsDesc =>
      'Maintain your daily learning streak by completing tasks and finishing focus sessions. Tap Quest tabs to explore other features!';

  @override
  String get tutorialQuestsHighlight =>
      'Check daily and weekly quests for bonus XP!';

  @override
  String get tutorialPetTitle => 'Adopt & Raise Your Pet 🐾';

  @override
  String get tutorialPetDesc =>
      'Adopt a virtual study pet! Earn coins from studying to feed your pet, earn XP to evolve them through 4 growth stages, and watch them grow alongside you.';

  @override
  String get tutorialPetHighlight =>
      'Costs 10 coins to feed your pet and gain XP';

  @override
  String get tutorialBadgesGetTitle => 'Earn Achievement Badges 🏅';

  @override
  String get tutorialBadgesGetDesc =>
      'Unlock various achievement badges by hitting specific milestones: completing tasks, keeping streaks alive, or using Focus Mode consistently.';

  @override
  String get tutorialBadgesGetHighlight =>
      'Badges are saved to the cloud automatically';

  @override
  String get tutorialBadgesSetTitle => 'Equip & Show Off Badges ✨';

  @override
  String get tutorialBadgesSetDesc =>
      'Once unlocked, select any badge to show it off as your \"Featured Badge\". It will appear next to your name on the Leaderboard and in your profile!';

  @override
  String get tutorialBadgesSetHighlight => 'Tap on an unlocked badge to set it';

  @override
  String get tutorialSettingsTitle => 'Settings & Customization ⚙️';

  @override
  String get tutorialSettingsDesc =>
      'Customize light/dark visual themes, toggle Low Performance mode (smoother for older devices), review the About page, and access our Privacy Policy documents.';

  @override
  String get tutorialSettingsHighlight =>
      'Find the new About and Privacy Policy screens here';

  @override
  String get tutorialReadyTitle => 'All Set & Ready! 🎉';

  @override
  String get tutorialReadyDesc =>
      'You are completely set to establish your learning flow! Complete tasks, maintain your streak, and see your productivity soar with StudyFlow.';

  @override
  String get tutorialReadyHighlight => 'Tap Let\'s Go! to begin your journey';

  @override
  String get tutorialSkip => 'Skip';

  @override
  String get tutorialBack => 'Back';

  @override
  String get tutorialNext => 'Next';

  @override
  String get tutorialStart => 'Let\'s Go!';

  @override
  String get tutorialDockTip =>
      'Dock switches to relevant section automatically 🪄';

  @override
  String get scanTitle => 'Documents';

  @override
  String get scanSearchHint => 'Search documents...';

  @override
  String get scanNoDocumentsTitle => 'No documents yet';

  @override
  String get scanNoDocumentsSubtitle =>
      'Tap the button below to scan your first document';

  @override
  String get scanNoSearchResults => 'No documents found';

  @override
  String get scanNoSearchResultsSubtitle =>
      'Try searching with a different keyword';

  @override
  String get scanSave => 'Save';

  @override
  String get scanSaving => 'Saving...';

  @override
  String get scanReviewTitle => 'Review Results';

  @override
  String get scanConfidence => 'Confidence';

  @override
  String get scanLanguage => 'Language';

  @override
  String get scanSize => 'Size';

  @override
  String get scanTitleHint => 'Enter document title...';

  @override
  String get scanSaveButton => 'Save Document';

  @override
  String get scanSavingUpload => 'Uploading and saving...';

  @override
  String get scanEmptyTitleError => 'Please enter a document title';

  @override
  String get scanEmptyTextError => 'Text content cannot be empty';

  @override
  String get scanSaveSuccess => 'Document saved successfully!';

  @override
  String get scanSaveFailed => 'Could not save document';

  @override
  String get scanDetailTitle => 'Document Detail';

  @override
  String get scanNotFound => 'Document not found';

  @override
  String get scanLoadImageFailed => 'Could not load image';

  @override
  String get scanInfoTitle => 'Document Information';

  @override
  String get scanCreatedAt => 'Created At';

  @override
  String get scanUpdatedAt => 'Updated At';

  @override
  String get scanTextContentTitle => 'Text Content';

  @override
  String get scanCopyAll => 'Copy All';

  @override
  String get scanCopySuccess => 'Text content copied';

  @override
  String get scanEmptyText => 'No text content';

  @override
  String get scanDeleteConfirmTitle => 'Delete Document?';

  @override
  String scanDeleteConfirmDesc(Object title) {
    return 'Are you sure you want to delete \"$title\"?\nThis action cannot be undone.';
  }

  @override
  String get scanDeleteCancel => 'Cancel';

  @override
  String get scanDeleteConfirm => 'Delete';

  @override
  String get scanDeleteSuccess => 'Document deleted';

  @override
  String get scanCameraOptionsTitle => 'Select Image';

  @override
  String get scanCamera => 'Camera';

  @override
  String get scanGallery => 'Gallery';

  @override
  String get scanProcessingText => 'Processing image...';

  @override
  String get scanProcessFailed => 'Image processing failed or cancelled';

  @override
  String scanStorageUsage(Object total, Object used) {
    return 'Storage: $used / $total MB';
  }

  @override
  String get scanQuotaExceeded => 'Storage quota exceeded';

  @override
  String get scanFeatureDesc => 'Scan physical documents using OCR';
}
