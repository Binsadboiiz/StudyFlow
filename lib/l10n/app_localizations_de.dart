// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get settings => 'Einstellungen';

  @override
  String get generalSettings => 'Allgemeine Einstellungen';

  @override
  String get editProfile => 'Profil bearbeiten';

  @override
  String get customizeProfileSubtitle => 'Name, Avatar und Passwort anpassen';

  @override
  String get notifications => 'Benachrichtigungen';

  @override
  String get focusHistoryCharts => 'Fokus-Verlauf & Diagramme';

  @override
  String get focusHistorySubtitle =>
      'Diagramme und Statistiken des Fokusmodus anzeigen';

  @override
  String get theme => 'Design';

  @override
  String get lowPerformanceMode => 'Energiesparmodus';

  @override
  String get lowPerformanceSubtitle =>
      'Unschärfe/Animationen deaktivieren für flüssigere UI';

  @override
  String get language => 'Sprache';

  @override
  String get about => 'Über uns';

  @override
  String get privacyPolicy => 'Datenschutzerklärung';

  @override
  String get logout => 'Abmelden';

  @override
  String get chooseTheme => 'Design wählen';

  @override
  String get light => 'Hell';

  @override
  String get lightThemeSubtitle => 'Hell und sauber';

  @override
  String get dark => 'Dunkel';

  @override
  String get darkThemeSubtitle => 'Schont die Augen';

  @override
  String get system => 'System';

  @override
  String get systemThemeSubtitle => 'Geräteeinstellungen folgen';

  @override
  String get chooseLanguage => 'Sprache wählen';

  @override
  String get login => 'Anmelden';

  @override
  String get register => 'Registrieren';

  @override
  String get email => 'E-Mail-Adresse';

  @override
  String get password => 'Passwort';

  @override
  String get confirmPassword => 'Passwort bestätigen';

  @override
  String get fullName => 'Vollständiger Name';

  @override
  String get username => 'Benutzername';

  @override
  String get welcomeBack => 'Willkommen zurück!';

  @override
  String get welcomeSubtitle =>
      'Melden Sie sich an, um Ihre Lernreise fortzusetzen';

  @override
  String get dontHaveAccount => 'Noch kein Konto? ';

  @override
  String get alreadyHaveAccount => 'Bereits ein Konto? ';

  @override
  String get signUp => 'Registrieren';

  @override
  String get signIn => 'Anmelden';

  @override
  String get pleaseFillFields => 'Bitte füllen Sie alle Felder aus';

  @override
  String get passwordsDoNotMatch => 'Passwörter stimmen nicht überein';

  @override
  String get invalidEmail => 'Bitte geben Sie eine gültige E-Mail-Adresse ein';

  @override
  String get usernameEmailIdentical =>
      'Benutzername und E-Mail dürfen nicht identisch sein';

  @override
  String get passwordTooShort => 'Passwort muss mindestens 8 Zeichen lang sein';

  @override
  String get passwordUppercase =>
      'Passwort muss mindestens einen Großbuchstaben enthalten';

  @override
  String get passwordSpecialChar =>
      'Passwort muss mindestens ein Sonderzeichen enthalten';

  @override
  String get registrationSuccessLogin =>
      'Registrierung erfolgreich! Bitte anmelden.';

  @override
  String get continueWithGoogle => 'Mit Google fortfahren';

  @override
  String get createAccountTitle => 'Konto erstellen';

  @override
  String get createAccountSubtitle =>
      'Treten Sie uns bei und verwalten Sie Ihre Aufgaben';

  @override
  String get or => 'oder';

  @override
  String get home => 'Startseite';

  @override
  String get tasks => 'Aufgaben';

  @override
  String get focus => 'Fokus';

  @override
  String get leaderboard => 'Bestenliste';

  @override
  String get schedule => 'Zeitplan';

  @override
  String get quest => 'Quest';

  @override
  String get badge_focused_student_name => 'Fokussierter Schüler';

  @override
  String get badge_focused_student_desc =>
      'Lernen Sie kontinuierlich für 2 Stunden';

  @override
  String get badge_early_bird_name => 'Früher Vogel';

  @override
  String get badge_early_bird_desc =>
      'Starten Sie eine Lerneinheit vor 06:00 Uhr';

  @override
  String get haveAGoodDay => 'Schönen Tag noch,';

  @override
  String get noGoalsForDay => 'Keine Ziele für diesen Tag';

  @override
  String get takeARest => 'Ruh dich aus und genieße deinen Tag!';

  @override
  String get taskCompletedReward => 'Aufgabe erledigt! +10 XP, +10 Münzen';

  @override
  String get today => 'Heute';

  @override
  String get mins => 'Min.';

  @override
  String get progress => 'Fortschritt';

  @override
  String remainingWithCount(Object count) {
    return '$count verbleibend';
  }

  @override
  String get tapToAddFirstTask =>
      'Tippe auf +, um eine neue Aufgabe hinzuzufügen';

  @override
  String get completed => 'Abgeschlossen';

  @override
  String completedWithCount(Object count) {
    return 'Abgeschlossen ($count)';
  }

  @override
  String get taskDeleted => 'Aufgabe erfolgreich gelöscht!';

  @override
  String get deleteTask => 'Aufgabe löschen';

  @override
  String get deleteTaskConfirm => 'Möchtest du diese Aufgabe wirklich löschen?';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get delete => 'Löschen';

  @override
  String get editTask => 'Aufgabe bearbeiten';

  @override
  String get addNewTask => 'Neue Aufgabe hinzufügen';

  @override
  String get taskTitleHint => 'Was möchtest du tun...?';

  @override
  String get taskDescHint => 'Details / Beschreibung hinzufügen...';

  @override
  String get date => 'Datum';

  @override
  String get start => 'Start';

  @override
  String get end => 'Ende';

  @override
  String get reminder => 'Erinnerung';

  @override
  String get noReminder => 'Keine / Keine Erinnerung';

  @override
  String get optional => 'Optional';

  @override
  String get errStartTimePast =>
      'Startzeit darf nicht in der Vergangenheit liegen!';

  @override
  String get errEndTimeZero =>
      'Endzeit darf nicht 00:00 sein (bitte verwende bis zu 23:59)!';

  @override
  String get errEndTimeBeforeStart => 'Endzeit muss nach der Startzeit liegen!';

  @override
  String get errReminderTimePast =>
      'Erinnerungszeit darf nicht in der Vergangenheit liegen!';

  @override
  String get taskUpdated => 'Aufgabe aktualisiert!';

  @override
  String get taskAdded => 'Neue Aufgabe hinzugefügt!';

  @override
  String get saveChanges => 'Änderungen speichern';

  @override
  String get addNow => 'Jetzt hinzufügen';

  @override
  String get focusMode => 'Fokus-Modus';

  @override
  String get focusAnalytics => 'Fokus-Analyse';

  @override
  String get custom => 'Benutzerdefiniert';

  @override
  String get pomodoro => 'Pomodoro';

  @override
  String get rest => 'PAUSE';

  @override
  String get focusLabel => 'FOKUS';

  @override
  String get overviewMetrics => 'Übersichtsmetriken';

  @override
  String get focusHistoryLogs => 'Fokus-Verlaufsprotokolle';

  @override
  String get last7Days => 'Letzte 7 Tage';

  @override
  String get last30Days => 'Letzte 30 Tage';

  @override
  String get chartStyle => 'Diagrammstil';

  @override
  String get noFocusLogsFound =>
      'Keine Fokusprotokolle für diesen Zeitraum gefunden.';

  @override
  String get areaFocusTrend => 'Bereichsfokus-Trend';

  @override
  String get barSessionDistribution => 'Balken-Sitzungsverteilung';

  @override
  String get tapToViewDetails => 'Tippe auf Datenpunkte, um Details anzuzeigen';

  @override
  String get totalFocused => 'Gesamtfokuszeit';

  @override
  String get avgSession => 'Durchschn. / Sitzung';

  @override
  String get activeDays => 'Aktive Tage';

  @override
  String get noFocusHistoryAvailable => 'Kein Fokus-Sitzungsverlauf verfügbar.';

  @override
  String sessionModeLabel(Object mode) {
    return '$mode-Sitzung';
  }

  @override
  String sessionsCount(Object count) {
    return '$count Sitzungen';
  }

  @override
  String activeDaysValue(Object count, Object ratio) {
    return '$count Tage ($ratio)';
  }

  @override
  String get clearAll => 'Alle löschen';

  @override
  String get deleteAllNotifications => 'Alle Benachrichtigungen löschen';

  @override
  String get deleteAllNotificationsConfirm =>
      'Bist du sicher, dass du alle Benachrichtigungen löschen möchtest? Diese Aktion kann nicht rückgängig gemacht werden.';

  @override
  String get noNotification => 'Keine Benachrichtigung';

  @override
  String get notificationsDescription =>
      'Benachrichtigungen und Erinnerungen werden hier angezeigt';

  @override
  String get yesterday => 'Gestern';

  @override
  String get timezoneWarningTitle => 'Zeitzonenabweichungs-Warnung';

  @override
  String get timezoneWarningSubtitle =>
      'Benachrichtigungen/Erinnerungen sind deaktiviert. Tippe zum Aktivieren, um UTC-Abweichungen zu vermeiden.';

  @override
  String get personalInfo => 'Persönliche Infos';

  @override
  String get enterFullName => 'Gib deinen vollständigen Namen ein';

  @override
  String get fullNameRequired => 'Vollständiger Name ist erforderlich';

  @override
  String get emailAddressDisabled => 'E-Mail-Adresse (Deaktiviert)';

  @override
  String get presets => 'Voreinstellungen';

  @override
  String get customUrl => 'Benutzerdefinierte URL';

  @override
  String get avatarImageUrl => 'Avatar-Bild-URL';

  @override
  String get linkedWithGoogle => 'Mit Google verknüpft';

  @override
  String get googlePasswordMgmt =>
      'Die Passwortverwaltung wird sicher von Google durchgeführt.';

  @override
  String get changePassword => 'Passwort ändern';

  @override
  String get currentPassword => 'Aktuelles Passwort';

  @override
  String get requiredIfChanging =>
      'Erforderlich, wenn das Passwort geändert wird';

  @override
  String get currPasswordRequired =>
      'Das aktuelle Passwort ist erforderlich, um ein neues Passwort festzulegen';

  @override
  String get newPassword => 'Neues Passwort';

  @override
  String get atLeast6Chars => 'Mindestens 6 Zeichen';

  @override
  String get passwordTooShort6 =>
      'Passwort muss mindestens 6 Zeichen lang sein';

  @override
  String get confirmNewPassword => 'Neues Passwort bestätigen';

  @override
  String get retypeNewPassword => 'Neues Passwort erneut eingeben';

  @override
  String get streak => 'Streak';

  @override
  String get pet => 'Haustier';

  @override
  String get achievements => 'Erfolge';

  @override
  String get levelUp => 'STUFENAUFSTIEG!';

  @override
  String get levelUpCongrat =>
      'Herzlichen Glückwunsch zu deiner Leistung! Du hast eine neue Stufe erreicht.';

  @override
  String get keepUpWork =>
      'Mach weiter so! Du hast eine Belohnung für den Stufenaufstieg erhalten.';

  @override
  String get awesome => 'Großartig! 🌟';

  @override
  String get level => 'Stufe';

  @override
  String get petLv => 'Haustier LV';

  @override
  String get noPet => 'Kein Haustier';

  @override
  String get notAdopted => 'Nicht adoptiert';

  @override
  String achievementsCount(Object count) {
    return '$count Erfolge';
  }

  @override
  String get earned => 'Verdient';

  @override
  String get petRequiredXp => 'Haustier XP';

  @override
  String get hunger => 'Hunger';

  @override
  String get feed => 'Füttern';

  @override
  String feedCost(Object coins) {
    return 'Kostet 10 Münzen (Du hast: $coins)';
  }

  @override
  String get play => 'Spielen';

  @override
  String get eggEvolution => 'Ei 🥚';

  @override
  String get babyEvolution => 'Baby 🍼';

  @override
  String get teenEvolution => 'Teenager ⚡';

  @override
  String get adultEvolution => 'Erwachsen 👑';

  @override
  String get dontHavePet => 'Du hast noch kein Lern-Haustier!';

  @override
  String get petCompanion => 'Dein Lern-Haustierbegleiter';

  @override
  String get cat => 'Katze';

  @override
  String get dog => 'Hund';

  @override
  String get panda => 'Panda';

  @override
  String get adoptPetDesc =>
      'Adoptiere ein Lern-Haustier, das dich auf deiner Lernreise begleitet.';

  @override
  String get nameYourPet => 'Benenne dein Haustier:';

  @override
  String get enterPetNameHint =>
      'Gib den Namen des Haustiers ein (z. B. Miau)...';

  @override
  String get choosePetEgg => 'Wähle ein Haustier-Ei:';

  @override
  String get adoptNowBtn => 'Jetzt adoptieren 🥚';

  @override
  String get pleaseGivePetName => 'Bitte gib deinem Haustier einen Namen!';

  @override
  String get currentStreak => 'Aktuelle Strähne';

  @override
  String days(Object count) {
    return '$count Tage';
  }

  @override
  String get minutesFocusedToday => 'Minuten heute fokussiert';

  @override
  String get dailyGoalProgress => 'Tägliches Ziel Fortschritt';

  @override
  String get studyHistory => 'Lernverlauf';

  @override
  String get rewardEarned => 'Verdienst:';

  @override
  String get status => 'Status:';

  @override
  String unlockedWithDate(Object date) {
    return 'Freigeschaltet ($date)';
  }

  @override
  String get locked => 'Gesperrt';

  @override
  String get featuredBadgeRemoved => 'Hervorgehobenes Abzeichen entfernt.';

  @override
  String featuredBadgeSet(Object name) {
    return '\"$name\" als hervorgehobenes Abzeichen festgelegt!';
  }

  @override
  String get removeFeaturedBadge => 'Hervorgehobenes Abzeichen entfernen';

  @override
  String get setAsFeaturedBadge => 'Als hervorgehobenes Abzeichen festlegen';

  @override
  String get close => 'Schließen';

  @override
  String get processing => 'Wird verarbeitet...';

  @override
  String get badge_noob_no_more_name => 'Kein Noob mehr';

  @override
  String get badge_noob_no_more_desc => 'Erreiche Level 5';

  @override
  String get badge_touching_grass_never_name => 'Gras anfassen? Niemals';

  @override
  String get badge_touching_grass_never_desc => 'Erreiche Level 10';

  @override
  String get badge_certified_brainrot_name => 'Zertifizierter Lernkönig';

  @override
  String get badge_certified_brainrot_desc => 'Erreiche Level 20';

  @override
  String get badge_main_character_energy_name => 'Hauptcharakter-Energie';

  @override
  String get badge_main_character_energy_desc => 'Erreiche Level 50';

  @override
  String get badge_locked_in_name => 'Fokussiert';

  @override
  String get badge_locked_in_desc => 'Sammle 1 Stunde Fokuszeit';

  @override
  String get badge_distraction_who_name => 'Ablenkung? Was ist das?';

  @override
  String get badge_distraction_who_desc => 'Sammle 10 Stunden Fokuszeit';

  @override
  String get badge_sigma_study_grind_name => 'Sigma-Lernmarathon';

  @override
  String get badge_sigma_study_grind_desc => 'Sammle 50 Stunden Fokuszeit';

  @override
  String get badge_ultra_instinct_name => 'Ultra-Instinkt';

  @override
  String get badge_ultra_instinct_desc => 'Sammle 100 Stunden Fokuszeit';

  @override
  String get badge_the_first_w_name => 'Erster Sieg';

  @override
  String get badge_the_first_w_desc => 'Erledige deine erste Aufgabe';

  @override
  String get badge_task_destroyer_name => 'Aufgaben-Zerstörer';

  @override
  String get badge_task_destroyer_desc => 'Erledige 10 Aufgaben';

  @override
  String get badge_productivity_monster_name => 'Produktivitäts-Monster';

  @override
  String get badge_productivity_monster_desc => 'Erledige 50 Aufgaben';

  @override
  String get badge_day_one_or_one_day_name => 'Tag eins oder eines Tages?';

  @override
  String get badge_day_one_or_one_day_desc => 'Halte eine 3-Tage-Strähne';

  @override
  String get badge_built_different_name => 'Anders gebaut';

  @override
  String get badge_built_different_desc => 'Halte eine 7-Tage-Strähne';

  @override
  String get badge_grassless_legend_name => 'Graslose Legende';

  @override
  String get badge_grassless_legend_desc => 'Halte eine 30-Tage-Strähne';

  @override
  String get noLeaderboardData =>
      'Noch keine Bestenlistendaten verfügbar. Beginne zu lernen, um die Ränge zu erklimmen!';

  @override
  String get noAchievementsData =>
      'Noch keine Leistungsdaten verfügbar. Beginne zu lernen, um Abzeichen zu verdienen!';

  @override
  String get unlocked => 'Freigeschaltet';

  @override
  String get tutorialWelcomeTitle => 'Willkommen bei StudyFlow! 🚀';

  @override
  String get tutorialWelcomeDesc =>
      'Dein ultimativer Begleiter für intelligentes Zeitmanagement, Gewohnheitstracking und Lernanalysen. Lass uns einen kurzen Rundgang durch deinen neuen Arbeitsbereich machen.';

  @override
  String get tutorialWelcomeHighlight =>
      'Drücke auf Weiter, um den Rundgang zu starten';

  @override
  String get tutorialDashboardTitle => 'Intelligentes Dashboard 📊';

  @override
  String get tutorialDashboardDesc =>
      'Behalte deine Lernsträhne (Feuersymbol) im Blick, überprüfe Benachrichtigungen, plane Tagesziele und sieh Kalenderaufgaben in einem einheitlichen visuellen Raum.';

  @override
  String get tutorialDashboardHighlight =>
      'Tagesziele werden unten auf der Startseite angezeigt';

  @override
  String get tutorialTimerTitle => 'Fokus Pomodoro Timer ⏱️';

  @override
  String get tutorialTimerDesc =>
      'Blende Ablenkungen mit anpassbaren Pomodoro-Countdown-Timern aus. Führe Fokussitzungen durch, um Gewohnheiten zu verbessern und detaillierte Produktivitäts-Heatmaps zu erstellen.';

  @override
  String get tutorialTimerHighlight =>
      'Starte eine Sitzung, um Benachrichtigungen zu blockieren';

  @override
  String get tutorialTaskManagerTitle => 'Aufgaben-Manager 📝';

  @override
  String get tutorialTaskManagerDesc =>
      'Erstelle, bearbeite und organisiere Lernaufgaben, Hausaufgaben und persönliche Checklisten. Hake Einträge ab, um sie mit der Datenbank zu synchronisieren.';

  @override
  String get tutorialTaskManagerHighlight =>
      'Klicke auf das \"+\"-Symbol im Dock, um sofort Aufgaben hinzuzufügen';

  @override
  String get tutorialScheduleTitle => 'Wochenplan 📅';

  @override
  String get tutorialScheduleDesc =>
      'Sieh deine wöchentlichen Kurse und Fristen in einem strukturierten Zeitstrahl. Bleibe mit klarer Planung und synchronisierten Kalenderrouten immer auf dem Laufenden.';

  @override
  String get tutorialScheduleHighlight =>
      'Ziehe oder wische, um andere Wochentage anzuzeigen';

  @override
  String get tutorialQuestsTitle => 'Quest Hub & Strähne 🏆';

  @override
  String get tutorialQuestsDesc =>
      'Halte deine tägliche Lernsträhne aufrecht, indem du Aufgaben erledigst und Fokussitzungen beendest. Tippe auf Quest-Tabs, um andere Funktionen zu erkunden!';

  @override
  String get tutorialQuestsHighlight =>
      'Überprüfe tägliche und wöchentliche Quests für Bonus-XP!';

  @override
  String get tutorialPetTitle => 'Adoptiere & erziehe dein Haustier 🐾';

  @override
  String get tutorialPetDesc =>
      'Adoptiere ein virtuelles Lernhaustier! Verdiene beim Lernen Münzen, um dein Haustier zu füttern, sammle XP, um es durch 4 Entwicklungsstufen wachsen zu lassen.';

  @override
  String get tutorialPetHighlight =>
      'Das Füttern deines Haustiers kostet 10 Münzen und bringt XP';

  @override
  String get tutorialBadgesGetTitle => 'Verdiene Leistungsabzeichen 🏅';

  @override
  String get tutorialBadgesGetDesc =>
      'Schalte verschiedene Leistungsabzeichen frei, indem du Meilensteine erreichst: Erledige Aufgaben, halte Strähnen aufrecht oder nutze den Fokus-Modus regelmäßig.';

  @override
  String get tutorialBadgesGetHighlight =>
      'Abzeichen werden automatisch in der Cloud gespeichert';

  @override
  String get tutorialBadgesSetTitle => 'Abzeichen ausrüsten & präsentieren ✨';

  @override
  String get tutorialBadgesSetDesc =>
      'Wähle nach dem Freischalten ein beliebiges Abzeichen aus, um es als dein \"Hervorgehobenes Abzeichen\" zu zeigen. Es erscheint neben deinem Namen auf der Bestenliste!';

  @override
  String get tutorialBadgesSetHighlight =>
      'Tippe auf ein freigeschaltetes Abzeichen, um es zu setzen';

  @override
  String get tutorialSettingsTitle => 'Einstellungen & Anpassung ⚙️';

  @override
  String get tutorialSettingsDesc =>
      'Passe helle/dunkle visuelle Designs an, aktiviere den Energiesparmodus (flüssiger auf älteren Geräten), lies die Info-Seite und greife auf Datenschutzdokumente zu.';

  @override
  String get tutorialSettingsHighlight =>
      'Hier findest du die neuen Info- und Datenschutzbildschirme';

  @override
  String get tutorialReadyTitle => 'Alles bereit! 🎉';

  @override
  String get tutorialReadyDesc =>
      'Du bist bestens gerüstet, um deinen Lernfluss aufzubauen! Erledige Aufgaben, halte deine Strähne aufrecht und steigere deine Produktivität mit StudyFlow.';

  @override
  String get tutorialReadyHighlight =>
      'Tippe auf Los geht\'s!, um deine Reise zu beginnen';

  @override
  String get tutorialSkip => 'Überspringen';

  @override
  String get tutorialBack => 'Zurück';

  @override
  String get tutorialNext => 'Weiter';

  @override
  String get tutorialStart => 'Los geht\'s!';

  @override
  String get tutorialDockTip =>
      'Dock wechselt automatisch in den relevanten Bereich 🪄';

  @override
  String get scanTitle => 'Dokumente';

  @override
  String get scanSearchHint => 'Dokumente suchen...';

  @override
  String get scanNoDocumentsTitle => 'Noch keine Dokumente';

  @override
  String get scanNoDocumentsSubtitle =>
      'Tippen Sie auf die Schaltfläche unten, um Ihr erstes Dokument zu scannen';

  @override
  String get scanNoSearchResults => 'Keine Dokumente gefunden';

  @override
  String get scanNoSearchResultsSubtitle =>
      'Versuchen Sie die Suche mit einem anderen Schlüsselwort';

  @override
  String get scanSave => 'Speichern';

  @override
  String get scanSaving => 'Wird gespeichert...';

  @override
  String get scanReviewTitle => 'Ergebnisse überprüfen';

  @override
  String get scanConfidence => 'Zuverlässigkeit';

  @override
  String get scanLanguage => 'Sprache';

  @override
  String get scanSize => 'Größe';

  @override
  String get scanTitleHint => 'Dokumententitel eingeben...';

  @override
  String get scanSaveButton => 'Dokument speichern';

  @override
  String get scanSavingUpload => 'Hochladen und speichern...';

  @override
  String get scanEmptyTitleError => 'Bitte geben Sie einen Dokumententitel ein';

  @override
  String get scanEmptyTextError => 'Textinhalt darf nicht leer sein';

  @override
  String get scanSaveSuccess => 'Dokument erfolgreich gespeichert!';

  @override
  String get scanSaveFailed => 'Dokument konnte nicht gespeichert werden';

  @override
  String get scanDetailTitle => 'Dokumentdetails';

  @override
  String get scanNotFound => 'Dokument nicht gefunden';

  @override
  String get scanLoadImageFailed => 'Bild konnte nicht geladen werden';

  @override
  String get scanInfoTitle => 'Dokumenteninformation';

  @override
  String get scanCreatedAt => 'Erstellt am';

  @override
  String get scanUpdatedAt => 'Aktualisiert am';

  @override
  String get scanTextContentTitle => 'Textinhalt';

  @override
  String get scanCopyAll => 'Alles kopieren';

  @override
  String get scanCopySuccess => 'Textinhalt kopiert';

  @override
  String get scanEmptyText => 'Kein Textinhalt';

  @override
  String get scanDeleteConfirmTitle => 'Dokument löschen?';

  @override
  String scanDeleteConfirmDesc(Object title) {
    return 'Möchten Sie \"$title\" wirklich löschen?\nDies kann nicht rückgängig gemacht werden.';
  }

  @override
  String get scanDeleteCancel => 'Abbrechen';

  @override
  String get scanDeleteConfirm => 'Löschen';

  @override
  String get scanDeleteSuccess => 'Dokument gelöscht';

  @override
  String get scanCameraOptionsTitle => 'Bild auswählen';

  @override
  String get scanCamera => 'Kamera';

  @override
  String get scanGallery => 'Galerie';

  @override
  String get scanProcessingText => 'Bild wird verarbeitet...';

  @override
  String get scanProcessFailed =>
      'Bildverarbeitung fehlgeschlagen oder abgebrochen';

  @override
  String scanStorageUsage(Object total, Object used) {
    return 'Speicher: $used / $total MB';
  }

  @override
  String get scanQuotaExceeded => 'Speicherkontingent überschritten';

  @override
  String get scanFeatureDesc => 'Physische Dokumente mit OCR scannen';
}
