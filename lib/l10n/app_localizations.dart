import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('vi'),
  ];

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @generalSettings.
  ///
  /// In en, this message translates to:
  /// **'General Settings'**
  String get generalSettings;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @customizeProfileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Customize name, avatar, and password'**
  String get customizeProfileSubtitle;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @focusHistoryCharts.
  ///
  /// In en, this message translates to:
  /// **'Focus History & Charts'**
  String get focusHistoryCharts;

  /// No description provided for @focusHistorySubtitle.
  ///
  /// In en, this message translates to:
  /// **'View charts and statistics of focus mode'**
  String get focusHistorySubtitle;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @lowPerformanceMode.
  ///
  /// In en, this message translates to:
  /// **'Low Performance Mode'**
  String get lowPerformanceMode;

  /// No description provided for @lowPerformanceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Disable blurs/animations for smoother UI'**
  String get lowPerformanceSubtitle;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @chooseTheme.
  ///
  /// In en, this message translates to:
  /// **'Choose Theme'**
  String get chooseTheme;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @lightThemeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Bright and clean'**
  String get lightThemeSubtitle;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @darkThemeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Easy on the eyes'**
  String get darkThemeSubtitle;

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// No description provided for @systemThemeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Follow device settings'**
  String get systemThemeSubtitle;

  /// No description provided for @chooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose Language'**
  String get chooseLanguage;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back!'**
  String get welcomeBack;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Login to continue your study flow'**
  String get welcomeSubtitle;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get dontHaveAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyHaveAccount;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @pleaseFillFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all fields'**
  String get pleaseFillFields;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get invalidEmail;

  /// No description provided for @usernameEmailIdentical.
  ///
  /// In en, this message translates to:
  /// **'Username and Email cannot be identical'**
  String get usernameEmailIdentical;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters long'**
  String get passwordTooShort;

  /// No description provided for @passwordUppercase.
  ///
  /// In en, this message translates to:
  /// **'Password must contain at least one uppercase letter'**
  String get passwordUppercase;

  /// No description provided for @passwordSpecialChar.
  ///
  /// In en, this message translates to:
  /// **'Password must contain at least one special character'**
  String get passwordSpecialChar;

  /// No description provided for @registrationSuccessLogin.
  ///
  /// In en, this message translates to:
  /// **'Registration successful! Please login.'**
  String get registrationSuccessLogin;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @createAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccountTitle;

  /// No description provided for @createAccountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Join us and start organizing your tasks'**
  String get createAccountSubtitle;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get or;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @tasks.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get tasks;

  /// No description provided for @focus.
  ///
  /// In en, this message translates to:
  /// **'Focus'**
  String get focus;

  /// No description provided for @leaderboard.
  ///
  /// In en, this message translates to:
  /// **'Leaderboard'**
  String get leaderboard;

  /// No description provided for @schedule.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get schedule;

  /// No description provided for @quest.
  ///
  /// In en, this message translates to:
  /// **'Quest'**
  String get quest;

  /// No description provided for @badge_focused_student_name.
  ///
  /// In en, this message translates to:
  /// **'Focused Student'**
  String get badge_focused_student_name;

  /// No description provided for @badge_focused_student_desc.
  ///
  /// In en, this message translates to:
  /// **'Study continuously for 2 hours'**
  String get badge_focused_student_desc;

  /// No description provided for @badge_early_bird_name.
  ///
  /// In en, this message translates to:
  /// **'Early Bird'**
  String get badge_early_bird_name;

  /// No description provided for @badge_early_bird_desc.
  ///
  /// In en, this message translates to:
  /// **'Start a study session before 6:00 AM'**
  String get badge_early_bird_desc;

  /// No description provided for @haveAGoodDay.
  ///
  /// In en, this message translates to:
  /// **'Have a good day,'**
  String get haveAGoodDay;

  /// No description provided for @noGoalsForDay.
  ///
  /// In en, this message translates to:
  /// **'No goals for this day'**
  String get noGoalsForDay;

  /// No description provided for @takeARest.
  ///
  /// In en, this message translates to:
  /// **'Take a rest and enjoy your day!'**
  String get takeARest;

  /// No description provided for @taskCompletedReward.
  ///
  /// In en, this message translates to:
  /// **'Task completed! +10 XP, +10 coins'**
  String get taskCompletedReward;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @mins.
  ///
  /// In en, this message translates to:
  /// **'mins'**
  String get mins;

  /// No description provided for @progress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progress;

  /// No description provided for @remainingWithCount.
  ///
  /// In en, this message translates to:
  /// **'{count} remaining'**
  String remainingWithCount(Object count);

  /// No description provided for @tapToAddFirstTask.
  ///
  /// In en, this message translates to:
  /// **'Tap + to add a new task'**
  String get tapToAddFirstTask;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @completedWithCount.
  ///
  /// In en, this message translates to:
  /// **'Completed ({count})'**
  String completedWithCount(Object count);

  /// No description provided for @taskDeleted.
  ///
  /// In en, this message translates to:
  /// **'Task deleted successfully!'**
  String get taskDeleted;

  /// No description provided for @deleteTask.
  ///
  /// In en, this message translates to:
  /// **'Delete Task'**
  String get deleteTask;

  /// No description provided for @deleteTaskConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this task?'**
  String get deleteTaskConfirm;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @editTask.
  ///
  /// In en, this message translates to:
  /// **'Edit task'**
  String get editTask;

  /// No description provided for @addNewTask.
  ///
  /// In en, this message translates to:
  /// **'Add new task'**
  String get addNewTask;

  /// No description provided for @taskTitleHint.
  ///
  /// In en, this message translates to:
  /// **'What do you want to do...?'**
  String get taskTitleHint;

  /// No description provided for @taskDescHint.
  ///
  /// In en, this message translates to:
  /// **'Add details / description...'**
  String get taskDescHint;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @end.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get end;

  /// No description provided for @reminder.
  ///
  /// In en, this message translates to:
  /// **'Reminder'**
  String get reminder;

  /// No description provided for @noReminder.
  ///
  /// In en, this message translates to:
  /// **'None / No Reminder'**
  String get noReminder;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optional;

  /// No description provided for @errStartTimePast.
  ///
  /// In en, this message translates to:
  /// **'Start time cannot be in the past!'**
  String get errStartTimePast;

  /// No description provided for @errEndTimeZero.
  ///
  /// In en, this message translates to:
  /// **'End time cannot be 00:00 (please use up to 23:59)!'**
  String get errEndTimeZero;

  /// No description provided for @errEndTimeBeforeStart.
  ///
  /// In en, this message translates to:
  /// **'End time must be after start time!'**
  String get errEndTimeBeforeStart;

  /// No description provided for @errReminderTimePast.
  ///
  /// In en, this message translates to:
  /// **'Reminder time cannot be in the past!'**
  String get errReminderTimePast;

  /// No description provided for @taskUpdated.
  ///
  /// In en, this message translates to:
  /// **'Task updated!'**
  String get taskUpdated;

  /// No description provided for @taskAdded.
  ///
  /// In en, this message translates to:
  /// **'Added new task!'**
  String get taskAdded;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChanges;

  /// No description provided for @addNow.
  ///
  /// In en, this message translates to:
  /// **'Add now'**
  String get addNow;

  /// No description provided for @focusMode.
  ///
  /// In en, this message translates to:
  /// **'Focus Mode'**
  String get focusMode;

  /// No description provided for @focusAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Focus Analytics'**
  String get focusAnalytics;

  /// No description provided for @custom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get custom;

  /// No description provided for @pomodoro.
  ///
  /// In en, this message translates to:
  /// **'Pomodoro'**
  String get pomodoro;

  /// No description provided for @rest.
  ///
  /// In en, this message translates to:
  /// **'REST'**
  String get rest;

  /// No description provided for @focusLabel.
  ///
  /// In en, this message translates to:
  /// **'FOCUS'**
  String get focusLabel;

  /// No description provided for @overviewMetrics.
  ///
  /// In en, this message translates to:
  /// **'Overview Metrics'**
  String get overviewMetrics;

  /// No description provided for @focusHistoryLogs.
  ///
  /// In en, this message translates to:
  /// **'Focus History Logs'**
  String get focusHistoryLogs;

  /// No description provided for @last7Days.
  ///
  /// In en, this message translates to:
  /// **'Last 7 Days'**
  String get last7Days;

  /// No description provided for @last30Days.
  ///
  /// In en, this message translates to:
  /// **'Last 30 Days'**
  String get last30Days;

  /// No description provided for @chartStyle.
  ///
  /// In en, this message translates to:
  /// **'Chart Style'**
  String get chartStyle;

  /// No description provided for @noFocusLogsFound.
  ///
  /// In en, this message translates to:
  /// **'No focus logs found for this range.'**
  String get noFocusLogsFound;

  /// No description provided for @areaFocusTrend.
  ///
  /// In en, this message translates to:
  /// **'Area Focus Trend'**
  String get areaFocusTrend;

  /// No description provided for @barSessionDistribution.
  ///
  /// In en, this message translates to:
  /// **'Bar Session Distribution'**
  String get barSessionDistribution;

  /// No description provided for @tapToViewDetails.
  ///
  /// In en, this message translates to:
  /// **'Tap on data points to view details'**
  String get tapToViewDetails;

  /// No description provided for @totalFocused.
  ///
  /// In en, this message translates to:
  /// **'Total Focused'**
  String get totalFocused;

  /// No description provided for @avgSession.
  ///
  /// In en, this message translates to:
  /// **'Avg / Session'**
  String get avgSession;

  /// No description provided for @activeDays.
  ///
  /// In en, this message translates to:
  /// **'Active Days'**
  String get activeDays;

  /// No description provided for @noFocusHistoryAvailable.
  ///
  /// In en, this message translates to:
  /// **'No focus session history available.'**
  String get noFocusHistoryAvailable;

  /// No description provided for @sessionModeLabel.
  ///
  /// In en, this message translates to:
  /// **'{mode} Session'**
  String sessionModeLabel(Object mode);

  /// No description provided for @sessionsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} sessions'**
  String sessionsCount(Object count);

  /// No description provided for @activeDaysValue.
  ///
  /// In en, this message translates to:
  /// **'{count} days ({ratio})'**
  String activeDaysValue(Object count, Object ratio);

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get clearAll;

  /// No description provided for @deleteAllNotifications.
  ///
  /// In en, this message translates to:
  /// **'Delete all notifications'**
  String get deleteAllNotifications;

  /// No description provided for @deleteAllNotificationsConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete all notifications? This action cannot be undone.'**
  String get deleteAllNotificationsConfirm;

  /// No description provided for @noNotification.
  ///
  /// In en, this message translates to:
  /// **'No notification'**
  String get noNotification;

  /// No description provided for @notificationsDescription.
  ///
  /// In en, this message translates to:
  /// **'Notifications and reminders will appear here'**
  String get notificationsDescription;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @timezoneWarningTitle.
  ///
  /// In en, this message translates to:
  /// **'Timezone Offset Warning'**
  String get timezoneWarningTitle;

  /// No description provided for @timezoneWarningSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications/reminders are disabled. Tap to enable to avoid UTC offsets.'**
  String get timezoneWarningSubtitle;

  /// No description provided for @personalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal Info'**
  String get personalInfo;

  /// No description provided for @enterFullName.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get enterFullName;

  /// No description provided for @fullNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Full name is required'**
  String get fullNameRequired;

  /// No description provided for @emailAddressDisabled.
  ///
  /// In en, this message translates to:
  /// **'Email Address (Disabled)'**
  String get emailAddressDisabled;

  /// No description provided for @presets.
  ///
  /// In en, this message translates to:
  /// **'Presets'**
  String get presets;

  /// No description provided for @customUrl.
  ///
  /// In en, this message translates to:
  /// **'Custom URL'**
  String get customUrl;

  /// No description provided for @avatarImageUrl.
  ///
  /// In en, this message translates to:
  /// **'Avatar Image URL'**
  String get avatarImageUrl;

  /// No description provided for @linkedWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Linked with Google'**
  String get linkedWithGoogle;

  /// No description provided for @googlePasswordMgmt.
  ///
  /// In en, this message translates to:
  /// **'Password management is securely handled by Google.'**
  String get googlePasswordMgmt;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get currentPassword;

  /// No description provided for @requiredIfChanging.
  ///
  /// In en, this message translates to:
  /// **'Required if changing password'**
  String get requiredIfChanging;

  /// No description provided for @currPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Current password is required to set a new password'**
  String get currPasswordRequired;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @atLeast6Chars.
  ///
  /// In en, this message translates to:
  /// **'At least 6 characters'**
  String get atLeast6Chars;

  /// No description provided for @passwordTooShort6.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters long'**
  String get passwordTooShort6;

  /// No description provided for @confirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get confirmNewPassword;

  /// No description provided for @retypeNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Retype new password'**
  String get retypeNewPassword;

  /// No description provided for @streak.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get streak;

  /// No description provided for @pet.
  ///
  /// In en, this message translates to:
  /// **'Pet'**
  String get pet;

  /// No description provided for @achievements.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get achievements;

  /// No description provided for @levelUp.
  ///
  /// In en, this message translates to:
  /// **'LEVEL UP!'**
  String get levelUp;

  /// No description provided for @levelUpCongrat.
  ///
  /// In en, this message translates to:
  /// **'Congratulations on your achievement! You have reached a new level.'**
  String get levelUpCongrat;

  /// No description provided for @keepUpWork.
  ///
  /// In en, this message translates to:
  /// **'Keep up the great work! You have earned a level-up reward.'**
  String get keepUpWork;

  /// No description provided for @awesome.
  ///
  /// In en, this message translates to:
  /// **'Awesome! 🌟'**
  String get awesome;

  /// No description provided for @level.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get level;

  /// No description provided for @petLv.
  ///
  /// In en, this message translates to:
  /// **'Pet LV'**
  String get petLv;

  /// No description provided for @noPet.
  ///
  /// In en, this message translates to:
  /// **'No Pet'**
  String get noPet;

  /// No description provided for @notAdopted.
  ///
  /// In en, this message translates to:
  /// **'Not Adopted'**
  String get notAdopted;

  /// No description provided for @achievementsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Achievements'**
  String achievementsCount(Object count);

  /// No description provided for @earned.
  ///
  /// In en, this message translates to:
  /// **'Earned'**
  String get earned;

  /// No description provided for @petRequiredXp.
  ///
  /// In en, this message translates to:
  /// **'Pet Experience'**
  String get petRequiredXp;

  /// No description provided for @hunger.
  ///
  /// In en, this message translates to:
  /// **'Hunger'**
  String get hunger;

  /// No description provided for @feed.
  ///
  /// In en, this message translates to:
  /// **'Feed'**
  String get feed;

  /// No description provided for @feedCost.
  ///
  /// In en, this message translates to:
  /// **'Costs 10 Coins (You have: {coins})'**
  String feedCost(Object coins);

  /// No description provided for @play.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get play;

  /// No description provided for @eggEvolution.
  ///
  /// In en, this message translates to:
  /// **'Egg 🥚'**
  String get eggEvolution;

  /// No description provided for @babyEvolution.
  ///
  /// In en, this message translates to:
  /// **'Baby 🍼'**
  String get babyEvolution;

  /// No description provided for @teenEvolution.
  ///
  /// In en, this message translates to:
  /// **'Teen ⚡'**
  String get teenEvolution;

  /// No description provided for @adultEvolution.
  ///
  /// In en, this message translates to:
  /// **'Adult 👑'**
  String get adultEvolution;

  /// No description provided for @dontHavePet.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have a Study Pet yet!'**
  String get dontHavePet;

  /// No description provided for @petCompanion.
  ///
  /// In en, this message translates to:
  /// **'Your learning pet companion'**
  String get petCompanion;

  /// No description provided for @cat.
  ///
  /// In en, this message translates to:
  /// **'Cat'**
  String get cat;

  /// No description provided for @dog.
  ///
  /// In en, this message translates to:
  /// **'Dog'**
  String get dog;

  /// No description provided for @panda.
  ///
  /// In en, this message translates to:
  /// **'Panda'**
  String get panda;

  /// No description provided for @adoptPetDesc.
  ///
  /// In en, this message translates to:
  /// **'Adopt a learning pet to join you on your study journey.'**
  String get adoptPetDesc;

  /// No description provided for @nameYourPet.
  ///
  /// In en, this message translates to:
  /// **'Name your Pet:'**
  String get nameYourPet;

  /// No description provided for @enterPetNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter pet name (e.g., Meow meow)...'**
  String get enterPetNameHint;

  /// No description provided for @choosePetEgg.
  ///
  /// In en, this message translates to:
  /// **'Choose a pet egg:'**
  String get choosePetEgg;

  /// No description provided for @adoptNowBtn.
  ///
  /// In en, this message translates to:
  /// **'Adopt Now 🥚'**
  String get adoptNowBtn;

  /// No description provided for @pleaseGivePetName.
  ///
  /// In en, this message translates to:
  /// **'Please give your pet a name!'**
  String get pleaseGivePetName;

  /// No description provided for @currentStreak.
  ///
  /// In en, this message translates to:
  /// **'Current Streak'**
  String get currentStreak;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'{count} Days'**
  String days(Object count);

  /// No description provided for @minutesFocusedToday.
  ///
  /// In en, this message translates to:
  /// **'Minutes focused today'**
  String get minutesFocusedToday;

  /// No description provided for @dailyGoalProgress.
  ///
  /// In en, this message translates to:
  /// **'Daily Goal Progress'**
  String get dailyGoalProgress;

  /// No description provided for @studyHistory.
  ///
  /// In en, this message translates to:
  /// **'Study History'**
  String get studyHistory;

  /// No description provided for @rewardEarned.
  ///
  /// In en, this message translates to:
  /// **'Reward Earned:'**
  String get rewardEarned;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status:'**
  String get status;

  /// No description provided for @unlockedWithDate.
  ///
  /// In en, this message translates to:
  /// **'Unlocked ({date})'**
  String unlockedWithDate(Object date);

  /// No description provided for @locked.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get locked;

  /// No description provided for @featuredBadgeRemoved.
  ///
  /// In en, this message translates to:
  /// **'Featured badge removed.'**
  String get featuredBadgeRemoved;

  /// No description provided for @featuredBadgeSet.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" set as featured badge!'**
  String featuredBadgeSet(Object name);

  /// No description provided for @removeFeaturedBadge.
  ///
  /// In en, this message translates to:
  /// **'Remove Featured Badge'**
  String get removeFeaturedBadge;

  /// No description provided for @setAsFeaturedBadge.
  ///
  /// In en, this message translates to:
  /// **'Set as Featured Badge'**
  String get setAsFeaturedBadge;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @processing.
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get processing;

  /// No description provided for @badge_noob_no_more_name.
  ///
  /// In en, this message translates to:
  /// **'Noob No More'**
  String get badge_noob_no_more_name;

  /// No description provided for @badge_noob_no_more_desc.
  ///
  /// In en, this message translates to:
  /// **'Reach Level 5'**
  String get badge_noob_no_more_desc;

  /// No description provided for @badge_touching_grass_never_name.
  ///
  /// In en, this message translates to:
  /// **'Touching Grass? Never'**
  String get badge_touching_grass_never_name;

  /// No description provided for @badge_touching_grass_never_desc.
  ///
  /// In en, this message translates to:
  /// **'Reach Level 10'**
  String get badge_touching_grass_never_desc;

  /// No description provided for @badge_certified_brainrot_name.
  ///
  /// In en, this message translates to:
  /// **'Certified Brainrot'**
  String get badge_certified_brainrot_name;

  /// No description provided for @badge_certified_brainrot_desc.
  ///
  /// In en, this message translates to:
  /// **'Reach Level 20'**
  String get badge_certified_brainrot_desc;

  /// No description provided for @badge_main_character_energy_name.
  ///
  /// In en, this message translates to:
  /// **'Main Character Energy'**
  String get badge_main_character_energy_name;

  /// No description provided for @badge_main_character_energy_desc.
  ///
  /// In en, this message translates to:
  /// **'Reach Level 50'**
  String get badge_main_character_energy_desc;

  /// No description provided for @badge_locked_in_name.
  ///
  /// In en, this message translates to:
  /// **'Locked In'**
  String get badge_locked_in_name;

  /// No description provided for @badge_locked_in_desc.
  ///
  /// In en, this message translates to:
  /// **'Accumulate 1 hour of focus time'**
  String get badge_locked_in_desc;

  /// No description provided for @badge_distraction_who_name.
  ///
  /// In en, this message translates to:
  /// **'Distraction Who?'**
  String get badge_distraction_who_name;

  /// No description provided for @badge_distraction_who_desc.
  ///
  /// In en, this message translates to:
  /// **'Accumulate 10 hours of focus time'**
  String get badge_distraction_who_desc;

  /// No description provided for @badge_sigma_study_grind_name.
  ///
  /// In en, this message translates to:
  /// **'Sigma Study Grind'**
  String get badge_sigma_study_grind_name;

  /// No description provided for @badge_sigma_study_grind_desc.
  ///
  /// In en, this message translates to:
  /// **'Accumulate 50 hours of focus time'**
  String get badge_sigma_study_grind_desc;

  /// No description provided for @badge_ultra_instinct_name.
  ///
  /// In en, this message translates to:
  /// **'Ultra Instinct'**
  String get badge_ultra_instinct_name;

  /// No description provided for @badge_ultra_instinct_desc.
  ///
  /// In en, this message translates to:
  /// **'Accumulate 100 hours of focus time'**
  String get badge_ultra_instinct_desc;

  /// No description provided for @badge_the_first_w_name.
  ///
  /// In en, this message translates to:
  /// **'The First W'**
  String get badge_the_first_w_name;

  /// No description provided for @badge_the_first_w_desc.
  ///
  /// In en, this message translates to:
  /// **'Complete your first task'**
  String get badge_the_first_w_desc;

  /// No description provided for @badge_task_destroyer_name.
  ///
  /// In en, this message translates to:
  /// **'Task Destroyer'**
  String get badge_task_destroyer_name;

  /// No description provided for @badge_task_destroyer_desc.
  ///
  /// In en, this message translates to:
  /// **'Complete 10 tasks'**
  String get badge_task_destroyer_desc;

  /// No description provided for @badge_productivity_monster_name.
  ///
  /// In en, this message translates to:
  /// **'Productivity Monster'**
  String get badge_productivity_monster_name;

  /// No description provided for @badge_productivity_monster_desc.
  ///
  /// In en, this message translates to:
  /// **'Complete 50 tasks'**
  String get badge_productivity_monster_desc;

  /// No description provided for @badge_day_one_or_one_day_name.
  ///
  /// In en, this message translates to:
  /// **'Day One or One Day?'**
  String get badge_day_one_or_one_day_name;

  /// No description provided for @badge_day_one_or_one_day_desc.
  ///
  /// In en, this message translates to:
  /// **'Maintain a 3-day streak'**
  String get badge_day_one_or_one_day_desc;

  /// No description provided for @badge_built_different_name.
  ///
  /// In en, this message translates to:
  /// **'Built Different'**
  String get badge_built_different_name;

  /// No description provided for @badge_built_different_desc.
  ///
  /// In en, this message translates to:
  /// **'Maintain a 7-day streak'**
  String get badge_built_different_desc;

  /// No description provided for @badge_grassless_legend_name.
  ///
  /// In en, this message translates to:
  /// **'Grassless Legend'**
  String get badge_grassless_legend_name;

  /// No description provided for @badge_grassless_legend_desc.
  ///
  /// In en, this message translates to:
  /// **'Maintain a 30-day streak'**
  String get badge_grassless_legend_desc;

  /// No description provided for @noLeaderboardData.
  ///
  /// In en, this message translates to:
  /// **'No leaderboard data available yet. Start studying to climb the ranks!'**
  String get noLeaderboardData;

  /// No description provided for @noAchievementsData.
  ///
  /// In en, this message translates to:
  /// **'No achievement data available yet. Start studying to earn badges!'**
  String get noAchievementsData;

  /// No description provided for @unlocked.
  ///
  /// In en, this message translates to:
  /// **'Unlocked'**
  String get unlocked;

  /// No description provided for @tutorialWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to StudyFlow! 🚀'**
  String get tutorialWelcomeTitle;

  /// No description provided for @tutorialWelcomeDesc.
  ///
  /// In en, this message translates to:
  /// **'Your ultimate companion for smart time management, habits tracking, and learning analytics. Let us take a quick tour of your new workspace.'**
  String get tutorialWelcomeDesc;

  /// No description provided for @tutorialWelcomeHighlight.
  ///
  /// In en, this message translates to:
  /// **'Press Next to begin the tour'**
  String get tutorialWelcomeHighlight;

  /// No description provided for @tutorialDashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Smart Dashboard 📊'**
  String get tutorialDashboardTitle;

  /// No description provided for @tutorialDashboardDesc.
  ///
  /// In en, this message translates to:
  /// **'Keep track of your learning streak (fire icon), check notifications, plan daily goals, and view calendar tasks all in one unified visual space.'**
  String get tutorialDashboardDesc;

  /// No description provided for @tutorialDashboardHighlight.
  ///
  /// In en, this message translates to:
  /// **'Daily targets are shown at the bottom of Home'**
  String get tutorialDashboardHighlight;

  /// No description provided for @tutorialTimerTitle.
  ///
  /// In en, this message translates to:
  /// **'Focus Pomodoro Timer ⏱️'**
  String get tutorialTimerTitle;

  /// No description provided for @tutorialTimerDesc.
  ///
  /// In en, this message translates to:
  /// **'Block out distractions using customized Pomodoro countdown timers. Run focus sessions to level up your habits and generate detailed productivity heatmaps.'**
  String get tutorialTimerDesc;

  /// No description provided for @tutorialTimerHighlight.
  ///
  /// In en, this message translates to:
  /// **'Start a session to block notifications'**
  String get tutorialTimerHighlight;

  /// No description provided for @tutorialTaskManagerTitle.
  ///
  /// In en, this message translates to:
  /// **'Task Manager 📝'**
  String get tutorialTaskManagerTitle;

  /// No description provided for @tutorialTaskManagerDesc.
  ///
  /// In en, this message translates to:
  /// **'Create, edit, and organize study tasks, class assignments, and personal checklists. Check off items as you complete them to sync with our database.'**
  String get tutorialTaskManagerDesc;

  /// No description provided for @tutorialTaskManagerHighlight.
  ///
  /// In en, this message translates to:
  /// **'Click the \"+\" button in the dock to add tasks instantly'**
  String get tutorialTaskManagerHighlight;

  /// No description provided for @tutorialScheduleTitle.
  ///
  /// In en, this message translates to:
  /// **'Weekly Schedule 📅'**
  String get tutorialScheduleTitle;

  /// No description provided for @tutorialScheduleDesc.
  ///
  /// In en, this message translates to:
  /// **'View your weekly classes and deadlines in a structured timeline. Stay ahead of your curriculum with clear scheduling and auto-syncing calendar routes.'**
  String get tutorialScheduleDesc;

  /// No description provided for @tutorialScheduleHighlight.
  ///
  /// In en, this message translates to:
  /// **'Drag or swipe to view different dates of the week'**
  String get tutorialScheduleHighlight;

  /// No description provided for @tutorialQuestsTitle.
  ///
  /// In en, this message translates to:
  /// **'Quest Hub & Streak 🏆'**
  String get tutorialQuestsTitle;

  /// No description provided for @tutorialQuestsDesc.
  ///
  /// In en, this message translates to:
  /// **'Maintain your daily learning streak by completing tasks and finishing focus sessions. Tap Quest tabs to explore other features!'**
  String get tutorialQuestsDesc;

  /// No description provided for @tutorialQuestsHighlight.
  ///
  /// In en, this message translates to:
  /// **'Check daily and weekly quests for bonus XP!'**
  String get tutorialQuestsHighlight;

  /// No description provided for @tutorialPetTitle.
  ///
  /// In en, this message translates to:
  /// **'Adopt & Raise Your Pet 🐾'**
  String get tutorialPetTitle;

  /// No description provided for @tutorialPetDesc.
  ///
  /// In en, this message translates to:
  /// **'Adopt a virtual study pet! Earn coins from studying to feed your pet, earn XP to evolve them through 4 growth stages, and watch them grow alongside you.'**
  String get tutorialPetDesc;

  /// No description provided for @tutorialPetHighlight.
  ///
  /// In en, this message translates to:
  /// **'Costs 10 coins to feed your pet and gain XP'**
  String get tutorialPetHighlight;

  /// No description provided for @tutorialBadgesGetTitle.
  ///
  /// In en, this message translates to:
  /// **'Earn Achievement Badges 🏅'**
  String get tutorialBadgesGetTitle;

  /// No description provided for @tutorialBadgesGetDesc.
  ///
  /// In en, this message translates to:
  /// **'Unlock various achievement badges by hitting specific milestones: completing tasks, keeping streaks alive, or using Focus Mode consistently.'**
  String get tutorialBadgesGetDesc;

  /// No description provided for @tutorialBadgesGetHighlight.
  ///
  /// In en, this message translates to:
  /// **'Badges are saved to the cloud automatically'**
  String get tutorialBadgesGetHighlight;

  /// No description provided for @tutorialBadgesSetTitle.
  ///
  /// In en, this message translates to:
  /// **'Equip & Show Off Badges ✨'**
  String get tutorialBadgesSetTitle;

  /// No description provided for @tutorialBadgesSetDesc.
  ///
  /// In en, this message translates to:
  /// **'Once unlocked, select any badge to show it off as your \"Featured Badge\". It will appear next to your name on the Leaderboard and in your profile!'**
  String get tutorialBadgesSetDesc;

  /// No description provided for @tutorialBadgesSetHighlight.
  ///
  /// In en, this message translates to:
  /// **'Tap on an unlocked badge to set it'**
  String get tutorialBadgesSetHighlight;

  /// No description provided for @tutorialSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings & Customization ⚙️'**
  String get tutorialSettingsTitle;

  /// No description provided for @tutorialSettingsDesc.
  ///
  /// In en, this message translates to:
  /// **'Customize light/dark visual themes, toggle Low Performance mode (smoother for older devices), review the About page, and access our Privacy Policy documents.'**
  String get tutorialSettingsDesc;

  /// No description provided for @tutorialSettingsHighlight.
  ///
  /// In en, this message translates to:
  /// **'Find the new About and Privacy Policy screens here'**
  String get tutorialSettingsHighlight;

  /// No description provided for @tutorialReadyTitle.
  ///
  /// In en, this message translates to:
  /// **'All Set & Ready! 🎉'**
  String get tutorialReadyTitle;

  /// No description provided for @tutorialReadyDesc.
  ///
  /// In en, this message translates to:
  /// **'You are completely set to establish your learning flow! Complete tasks, maintain your streak, and see your productivity soar with StudyFlow.'**
  String get tutorialReadyDesc;

  /// No description provided for @tutorialReadyHighlight.
  ///
  /// In en, this message translates to:
  /// **'Tap Let\'s Go! to begin your journey'**
  String get tutorialReadyHighlight;

  /// No description provided for @tutorialSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get tutorialSkip;

  /// No description provided for @tutorialBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get tutorialBack;

  /// No description provided for @tutorialNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get tutorialNext;

  /// No description provided for @tutorialStart.
  ///
  /// In en, this message translates to:
  /// **'Let\'s Go!'**
  String get tutorialStart;

  /// No description provided for @tutorialDockTip.
  ///
  /// In en, this message translates to:
  /// **'Dock switches to relevant section automatically 🪄'**
  String get tutorialDockTip;

  /// No description provided for @scanTitle.
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get scanTitle;

  /// No description provided for @scanSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search documents...'**
  String get scanSearchHint;

  /// No description provided for @scanNoDocumentsTitle.
  ///
  /// In en, this message translates to:
  /// **'No documents yet'**
  String get scanNoDocumentsTitle;

  /// No description provided for @scanNoDocumentsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap the button below to scan your first document'**
  String get scanNoDocumentsSubtitle;

  /// No description provided for @scanNoSearchResults.
  ///
  /// In en, this message translates to:
  /// **'No documents found'**
  String get scanNoSearchResults;

  /// No description provided for @scanNoSearchResultsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Try searching with a different keyword'**
  String get scanNoSearchResultsSubtitle;

  /// No description provided for @scanSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get scanSave;

  /// No description provided for @scanSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get scanSaving;

  /// No description provided for @scanReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Review Results'**
  String get scanReviewTitle;

  /// No description provided for @scanConfidence.
  ///
  /// In en, this message translates to:
  /// **'Confidence'**
  String get scanConfidence;

  /// No description provided for @scanLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get scanLanguage;

  /// No description provided for @scanSize.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get scanSize;

  /// No description provided for @scanTitleHint.
  ///
  /// In en, this message translates to:
  /// **'Enter document title...'**
  String get scanTitleHint;

  /// No description provided for @scanSaveButton.
  ///
  /// In en, this message translates to:
  /// **'Save Document'**
  String get scanSaveButton;

  /// No description provided for @scanSavingUpload.
  ///
  /// In en, this message translates to:
  /// **'Uploading and saving...'**
  String get scanSavingUpload;

  /// No description provided for @scanEmptyTitleError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a document title'**
  String get scanEmptyTitleError;

  /// No description provided for @scanEmptyTextError.
  ///
  /// In en, this message translates to:
  /// **'Text content cannot be empty'**
  String get scanEmptyTextError;

  /// No description provided for @scanSaveSuccess.
  ///
  /// In en, this message translates to:
  /// **'Document saved successfully!'**
  String get scanSaveSuccess;

  /// No description provided for @scanSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save document'**
  String get scanSaveFailed;

  /// No description provided for @scanDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Document Detail'**
  String get scanDetailTitle;

  /// No description provided for @scanNotFound.
  ///
  /// In en, this message translates to:
  /// **'Document not found'**
  String get scanNotFound;

  /// No description provided for @scanLoadImageFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load image'**
  String get scanLoadImageFailed;

  /// No description provided for @scanInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Document Information'**
  String get scanInfoTitle;

  /// No description provided for @scanCreatedAt.
  ///
  /// In en, this message translates to:
  /// **'Created At'**
  String get scanCreatedAt;

  /// No description provided for @scanUpdatedAt.
  ///
  /// In en, this message translates to:
  /// **'Updated At'**
  String get scanUpdatedAt;

  /// No description provided for @scanTextContentTitle.
  ///
  /// In en, this message translates to:
  /// **'Text Content'**
  String get scanTextContentTitle;

  /// No description provided for @scanCopyAll.
  ///
  /// In en, this message translates to:
  /// **'Copy All'**
  String get scanCopyAll;

  /// No description provided for @scanCopySuccess.
  ///
  /// In en, this message translates to:
  /// **'Text content copied'**
  String get scanCopySuccess;

  /// No description provided for @scanEmptyText.
  ///
  /// In en, this message translates to:
  /// **'No text content'**
  String get scanEmptyText;

  /// No description provided for @scanDeleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Document?'**
  String get scanDeleteConfirmTitle;

  /// No description provided for @scanDeleteConfirmDesc.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{title}\"?\nThis action cannot be undone.'**
  String scanDeleteConfirmDesc(Object title);

  /// No description provided for @scanDeleteCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get scanDeleteCancel;

  /// No description provided for @scanDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get scanDeleteConfirm;

  /// No description provided for @scanDeleteSuccess.
  ///
  /// In en, this message translates to:
  /// **'Document deleted'**
  String get scanDeleteSuccess;

  /// No description provided for @scanCameraOptionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Image'**
  String get scanCameraOptionsTitle;

  /// No description provided for @scanCamera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get scanCamera;

  /// No description provided for @scanGallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get scanGallery;

  /// No description provided for @scanProcessingText.
  ///
  /// In en, this message translates to:
  /// **'Processing image...'**
  String get scanProcessingText;

  /// No description provided for @scanProcessFailed.
  ///
  /// In en, this message translates to:
  /// **'Image processing failed or cancelled'**
  String get scanProcessFailed;

  /// No description provided for @scanStorageUsage.
  ///
  /// In en, this message translates to:
  /// **'Storage: {used} / {total} MB'**
  String scanStorageUsage(Object total, Object used);

  /// No description provided for @scanQuotaExceeded.
  ///
  /// In en, this message translates to:
  /// **'Storage quota exceeded'**
  String get scanQuotaExceeded;

  /// No description provided for @scanFeatureDesc.
  ///
  /// In en, this message translates to:
  /// **'Scan physical documents using OCR'**
  String get scanFeatureDesc;

  /// No description provided for @scanLoadingStorage.
  ///
  /// In en, this message translates to:
  /// **'Loading storage...'**
  String get scanLoadingStorage;

  /// No description provided for @scanErrorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get scanErrorOccurred;

  /// No description provided for @scanLoadListFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load document list: {error}'**
  String scanLoadListFailed(String error);

  /// No description provided for @scanRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get scanRetry;

  /// No description provided for @scanDocumentCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{0 documents} =1{1 document} other{{count} documents}}'**
  String scanDocumentCount(int count);

  /// No description provided for @scanTrash.
  ///
  /// In en, this message translates to:
  /// **'Trash'**
  String get scanTrash;

  /// No description provided for @scanRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get scanRestore;

  /// No description provided for @scanHardDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete Permanently'**
  String get scanHardDelete;

  /// No description provided for @scanEmptyTrash.
  ///
  /// In en, this message translates to:
  /// **'Empty Trash'**
  String get scanEmptyTrash;

  /// No description provided for @scanFilter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get scanFilter;

  /// No description provided for @scanBatchDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete Selected'**
  String get scanBatchDelete;

  /// No description provided for @scanSelect.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get scanSelect;

  /// No description provided for @scanSelectAll.
  ///
  /// In en, this message translates to:
  /// **'Select All'**
  String get scanSelectAll;

  /// No description provided for @scanSelectedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String scanSelectedCount(int count);

  /// No description provided for @scanRestoreSuccess.
  ///
  /// In en, this message translates to:
  /// **'Document restored'**
  String get scanRestoreSuccess;

  /// No description provided for @scanHardDeleteSuccess.
  ///
  /// In en, this message translates to:
  /// **'Document permanently deleted'**
  String get scanHardDeleteSuccess;

  /// No description provided for @scanBatchDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Move {count} documents to trash?'**
  String scanBatchDeleteConfirm(int count);

  /// No description provided for @scanTrashEmpty.
  ///
  /// In en, this message translates to:
  /// **'Trash is empty'**
  String get scanTrashEmpty;

  /// No description provided for @scanTrashEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Deleted documents will appear here'**
  String get scanTrashEmptySubtitle;

  /// No description provided for @scanHardDeleteConfirmDesc.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete the document. This action cannot be undone.'**
  String get scanHardDeleteConfirmDesc;

  /// No description provided for @scanFilterAllTime.
  ///
  /// In en, this message translates to:
  /// **'All Time'**
  String get scanFilterAllTime;

  /// No description provided for @scanFilterLast7Days.
  ///
  /// In en, this message translates to:
  /// **'Last 7 Days'**
  String get scanFilterLast7Days;

  /// No description provided for @scanFilterLast30Days.
  ///
  /// In en, this message translates to:
  /// **'Last 30 Days'**
  String get scanFilterLast30Days;

  /// No description provided for @petGuideTooltip.
  ///
  /// In en, this message translates to:
  /// **'Pet Guide'**
  String get petGuideTooltip;

  /// No description provided for @petGuideTitle.
  ///
  /// In en, this message translates to:
  /// **'Pet Guidebook'**
  String get petGuideTitle;

  /// No description provided for @petGuideEarnCoinsTitle.
  ///
  /// In en, this message translates to:
  /// **'How to earn Coins'**
  String get petGuideEarnCoinsTitle;

  /// No description provided for @petGuideEarnCoinsContent.
  ///
  /// In en, this message translates to:
  /// **'• Complete focused study sessions.\n• Complete daily tasks.'**
  String get petGuideEarnCoinsContent;

  /// No description provided for @petGuideCareTitle.
  ///
  /// In en, this message translates to:
  /// **'Pet Care'**
  String get petGuideCareTitle;

  /// No description provided for @petGuideCareContent.
  ///
  /// In en, this message translates to:
  /// **'• Spend 10 Coins to buy food (Feed) for your Pet.\n• Staying full helps your Pet grow best.'**
  String get petGuideCareContent;

  /// No description provided for @petGuideEvolutionTitle.
  ///
  /// In en, this message translates to:
  /// **'Level Up & Evolution'**
  String get petGuideEvolutionTitle;

  /// No description provided for @petGuideEvolutionContent.
  ///
  /// In en, this message translates to:
  /// **'• Playing with your Pet grants 10 EXP but costs 5 hunger.\n• Your pet will evolve through stages: Egg ➔ Baby ➔ Adult at certain Level milestones.'**
  String get petGuideEvolutionContent;

  /// No description provided for @gotItBtn.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get gotItBtn;

  /// No description provided for @aiChatTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Study Assistant'**
  String get aiChatTitle;

  /// No description provided for @aiChatRequestsRemaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining {count} AI requests today'**
  String aiChatRequestsRemaining(int count);

  /// No description provided for @aiChatClearConfirm.
  ///
  /// In en, this message translates to:
  /// **'Clear conversation?'**
  String get aiChatClearConfirm;

  /// No description provided for @aiChatEmptyStateTitle.
  ///
  /// In en, this message translates to:
  /// **'Hello! How can I help you?'**
  String get aiChatEmptyStateTitle;

  /// No description provided for @aiChatEmptyStateSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You can ask me to organize tasks, schedule study sessions, or plan exam preparations.'**
  String get aiChatEmptyStateSubtitle;

  /// No description provided for @aiChatThinking.
  ///
  /// In en, this message translates to:
  /// **'AI is thinking...'**
  String get aiChatThinking;

  /// No description provided for @aiChatActionSuggestions.
  ///
  /// In en, this message translates to:
  /// **'AI Action Suggestions'**
  String get aiChatActionSuggestions;

  /// No description provided for @aiChatTaskPrefix.
  ///
  /// In en, this message translates to:
  /// **'📝 TASK'**
  String get aiChatTaskPrefix;

  /// No description provided for @aiChatSchedulePrefix.
  ///
  /// In en, this message translates to:
  /// **'📅 SCHEDULE'**
  String get aiChatSchedulePrefix;

  /// No description provided for @aiChatAddedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Successfully added: \"{title}\"'**
  String aiChatAddedSuccess(String title);

  /// No description provided for @aiChatAddFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not add: {error}'**
  String aiChatAddFailed(String error);

  /// No description provided for @aiChatDismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get aiChatDismiss;

  /// No description provided for @aiChatAccept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get aiChatAccept;

  /// No description provided for @aiChatInputHint.
  ///
  /// In en, this message translates to:
  /// **'Type a study message...'**
  String get aiChatInputHint;

  /// No description provided for @aiChatDailyLimitReached.
  ///
  /// In en, this message translates to:
  /// **'You have reached your daily AI limit today.'**
  String get aiChatDailyLimitReached;

  /// No description provided for @flashcardTitle.
  ///
  /// In en, this message translates to:
  /// **'Study Flashcards'**
  String get flashcardTitle;

  /// No description provided for @flashcardEmpty.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any flashcard sets yet.'**
  String get flashcardEmpty;

  /// No description provided for @flashcardGeneratePrompt.
  ///
  /// In en, this message translates to:
  /// **'Use AI to generate flashcards from scanned documents!'**
  String get flashcardGeneratePrompt;

  /// No description provided for @flashcardsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{0 cards} =1{1 card} other{{count} cards}}'**
  String flashcardsCount(int count);

  /// No description provided for @flashcardDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{title}\"?'**
  String flashcardDeleteConfirm(String title);

  /// No description provided for @flashcardGenerateAI.
  ///
  /// In en, this message translates to:
  /// **'Generate Flashcards with AI'**
  String get flashcardGenerateAI;

  /// No description provided for @flashcardGenerating.
  ///
  /// In en, this message translates to:
  /// **'AI is analyzing and generating flashcards...'**
  String get flashcardGenerating;

  /// No description provided for @flashcardGenerateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Flashcards generated successfully!'**
  String get flashcardGenerateSuccess;

  /// No description provided for @flashcardStudyFinished.
  ///
  /// In en, this message translates to:
  /// **'Study Completed!'**
  String get flashcardStudyFinished;

  /// No description provided for @flashcardSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get flashcardSummaryTitle;

  /// No description provided for @flashcardSummaryTotal.
  ///
  /// In en, this message translates to:
  /// **'Total Cards'**
  String get flashcardSummaryTotal;

  /// No description provided for @flashcardSummaryRemembered.
  ///
  /// In en, this message translates to:
  /// **'Remembered'**
  String get flashcardSummaryRemembered;

  /// No description provided for @flashcardSummaryForgotten.
  ///
  /// In en, this message translates to:
  /// **'Forgotten'**
  String get flashcardSummaryForgotten;

  /// No description provided for @flashcardReplay.
  ///
  /// In en, this message translates to:
  /// **'Study Again'**
  String get flashcardReplay;

  /// No description provided for @flashcardFlipHint.
  ///
  /// In en, this message translates to:
  /// **'Tap card to flip and view answer'**
  String get flashcardFlipHint;

  /// No description provided for @homeQuickAiTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Assistant'**
  String get homeQuickAiTitle;

  /// No description provided for @homeQuickAiSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Organize tasks & chat'**
  String get homeQuickAiSubtitle;

  /// No description provided for @homeQuickFlashcardsTitle.
  ///
  /// In en, this message translates to:
  /// **'Flashcards'**
  String get homeQuickFlashcardsTitle;

  /// No description provided for @homeQuickFlashcardsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Smart review'**
  String get homeQuickFlashcardsSubtitle;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
