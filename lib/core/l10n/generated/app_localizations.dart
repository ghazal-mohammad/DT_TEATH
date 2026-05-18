import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
    Locale('ar'),
    Locale('en'),
  ];

  /// Application name — never translated.
  ///
  /// In en, this message translates to:
  /// **'DT.Teeth'**
  String get appName;

  /// App tagline shown on splash and login screens.
  ///
  /// In en, this message translates to:
  /// **'Comprehensive Dental Clinic Management System'**
  String get appSubtitle;

  /// Version label shown in sidebar.
  ///
  /// In en, this message translates to:
  /// **'v1.0 · Flutter Web'**
  String get appVersion;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get login;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue'**
  String get loginSubtitle;

  /// Email field label — used in Email Entry screen (Phase 3.3).
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'example@dtteeth.com'**
  String get emailHint;

  /// No description provided for @emailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get emailInvalid;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailRequired;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get passwordHint;

  /// No description provided for @passwordConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get passwordConfirm;

  /// No description provided for @passwordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordMismatch;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get passwordTooShort;

  /// No description provided for @passwordWeak.
  ///
  /// In en, this message translates to:
  /// **'Weak'**
  String get passwordWeak;

  /// No description provided for @passwordMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get passwordMedium;

  /// No description provided for @passwordStrong.
  ///
  /// In en, this message translates to:
  /// **'Strong'**
  String get passwordStrong;

  /// No description provided for @firstLogin.
  ///
  /// In en, this message translates to:
  /// **'First Time'**
  String get firstLogin;

  /// No description provided for @rememberMe.
  ///
  /// In en, this message translates to:
  /// **'Remember Me'**
  String get rememberMe;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get logout;

  /// Email entry screen title — Phase 3.3.
  ///
  /// In en, this message translates to:
  /// **'Let\'s get you started'**
  String get authEnterEmailTitle;

  /// No description provided for @authEnterEmailSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the email your administrator registered'**
  String get authEnterEmailSubtitle;

  /// No description provided for @authNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get authNext;

  /// No description provided for @authBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get authBack;

  /// No description provided for @authContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get authContinue;

  /// No description provided for @authVerifyCodeTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify Your Identity'**
  String get authVerifyCodeTitle;

  /// OTP screen subtitle with email placeholder.
  ///
  /// In en, this message translates to:
  /// **'We sent a 6-digit code to {email}'**
  String authVerifyCodeSubtitle(String email);

  /// No description provided for @authResendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend Code'**
  String get authResendCode;

  /// No description provided for @authResendCodeIn.
  ///
  /// In en, this message translates to:
  /// **'Resend in {seconds}s'**
  String authResendCodeIn(int seconds);

  /// No description provided for @authCodeExpired.
  ///
  /// In en, this message translates to:
  /// **'Code expired. Please request a new one.'**
  String get authCodeExpired;

  /// No description provided for @authCodeInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid code. Please check and try again.'**
  String get authCodeInvalid;

  /// No description provided for @authSetPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Your Password'**
  String get authSetPasswordTitle;

  /// No description provided for @authSetPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a strong password to secure your account'**
  String get authSetPasswordSubtitle;

  /// No description provided for @authSaveAndLogin.
  ///
  /// In en, this message translates to:
  /// **'Save & Sign In'**
  String get authSaveAndLogin;

  /// Generic response for security (doesn't reveal if email exists).
  ///
  /// In en, this message translates to:
  /// **'If this email is registered, a code was sent'**
  String get authCheckEmailSent;

  /// No description provided for @labSystem.
  ///
  /// In en, this message translates to:
  /// **'Lab System'**
  String get labSystem;

  /// No description provided for @warehouseSystem.
  ///
  /// In en, this message translates to:
  /// **'Warehouse System'**
  String get warehouseSystem;

  /// No description provided for @switchSystem.
  ///
  /// In en, this message translates to:
  /// **'Switch System'**
  String get switchSystem;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get dashboard;

  /// No description provided for @reports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reports;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @doctorOrders.
  ///
  /// In en, this message translates to:
  /// **'Doctor Orders'**
  String get doctorOrders;

  /// No description provided for @technicians.
  ///
  /// In en, this message translates to:
  /// **'Technicians'**
  String get technicians;

  /// No description provided for @labReports.
  ///
  /// In en, this message translates to:
  /// **'Lab Reports'**
  String get labReports;

  /// No description provided for @materialRequests.
  ///
  /// In en, this message translates to:
  /// **'Material Requests'**
  String get materialRequests;

  /// No description provided for @materials.
  ///
  /// In en, this message translates to:
  /// **'Materials'**
  String get materials;

  /// No description provided for @orders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get orders;

  /// No description provided for @invoices.
  ///
  /// In en, this message translates to:
  /// **'Invoices'**
  String get invoices;

  /// No description provided for @suppliers.
  ///
  /// In en, this message translates to:
  /// **'Suppliers'**
  String get suppliers;

  /// No description provided for @inventory.
  ///
  /// In en, this message translates to:
  /// **'Inventory'**
  String get inventory;

  /// No description provided for @sectionMain.
  ///
  /// In en, this message translates to:
  /// **'Main'**
  String get sectionMain;

  /// No description provided for @sectionInventory.
  ///
  /// In en, this message translates to:
  /// **'Inventory'**
  String get sectionInventory;

  /// No description provided for @sectionFinance.
  ///
  /// In en, this message translates to:
  /// **'Finance'**
  String get sectionFinance;

  /// No description provided for @sectionSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get sectionSystem;

  /// No description provided for @sectionTeam.
  ///
  /// In en, this message translates to:
  /// **'Team'**
  String get sectionTeam;

  /// No description provided for @sectionOrders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get sectionOrders;

  /// No description provided for @sectionOperations.
  ///
  /// In en, this message translates to:
  /// **'Operations'**
  String get sectionOperations;

  /// No description provided for @sectionAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get sectionAccount;

  /// No description provided for @menu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menu;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search in system...'**
  String get search;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

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

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No Data'**
  String get noData;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No Results'**
  String get noResults;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error Occurred'**
  String get error;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Operation Successful'**
  String get success;

  /// No description provided for @statusNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get statusNew;

  /// No description provided for @statusPendingMaterials.
  ///
  /// In en, this message translates to:
  /// **'Pending Materials'**
  String get statusPendingMaterials;

  /// No description provided for @statusManufacturing.
  ///
  /// In en, this message translates to:
  /// **'Manufacturing'**
  String get statusManufacturing;

  /// No description provided for @statusReady.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get statusReady;

  /// No description provided for @statusDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get statusDelivered;

  /// No description provided for @statusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get statusRejected;

  /// No description provided for @statusReserved.
  ///
  /// In en, this message translates to:
  /// **'Reserved'**
  String get statusReserved;

  /// No description provided for @statusEmpty.
  ///
  /// In en, this message translates to:
  /// **'Empty'**
  String get statusEmpty;

  /// No description provided for @statusOccupied.
  ///
  /// In en, this message translates to:
  /// **'Occupied'**
  String get statusOccupied;

  /// No description provided for @statusMaintenance.
  ///
  /// In en, this message translates to:
  /// **'Maintenance'**
  String get statusMaintenance;

  /// No description provided for @errorNetwork.
  ///
  /// In en, this message translates to:
  /// **'No internet connection — check your network'**
  String get errorNetwork;

  /// No description provided for @errorServer.
  ///
  /// In en, this message translates to:
  /// **'Server error — try again in a moment'**
  String get errorServer;

  /// No description provided for @errorTimeout.
  ///
  /// In en, this message translates to:
  /// **'Request timed out — server not responding'**
  String get errorTimeout;

  /// No description provided for @errorUnauthorized.
  ///
  /// In en, this message translates to:
  /// **'Session expired — please sign in again'**
  String get errorUnauthorized;

  /// No description provided for @errorForbidden.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have permission to access this page'**
  String get errorForbidden;

  /// No description provided for @errorNotFound.
  ///
  /// In en, this message translates to:
  /// **'The requested item was not found'**
  String get errorNotFound;

  /// No description provided for @errorValidation.
  ///
  /// In en, this message translates to:
  /// **'Please check required fields'**
  String get errorValidation;

  /// No description provided for @errorMaintenance.
  ///
  /// In en, this message translates to:
  /// **'Server under maintenance — come back later'**
  String get errorMaintenance;

  /// No description provided for @errorCache.
  ///
  /// In en, this message translates to:
  /// **'Local data error — please try again'**
  String get errorCache;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get darkMode;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get lightMode;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Arabic language name — always in Arabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get languageArabic;

  /// English language name — always in English.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @fontSize.
  ///
  /// In en, this message translates to:
  /// **'Font Size'**
  String get fontSize;

  /// No description provided for @fontSmall.
  ///
  /// In en, this message translates to:
  /// **'Small'**
  String get fontSmall;

  /// No description provided for @fontMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get fontMedium;

  /// No description provided for @fontNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get fontNormal;

  /// No description provided for @fontLarge.
  ///
  /// In en, this message translates to:
  /// **'Large'**
  String get fontLarge;

  /// No description provided for @fontXLarge.
  ///
  /// In en, this message translates to:
  /// **'Extra Large'**
  String get fontXLarge;

  /// No description provided for @welcomeWarehouse.
  ///
  /// In en, this message translates to:
  /// **'Welcome to the Warehouse System 📦'**
  String get welcomeWarehouse;

  /// No description provided for @welcomeLab.
  ///
  /// In en, this message translates to:
  /// **'Welcome to the Lab System 🧪'**
  String get welcomeLab;

  /// No description provided for @systemStatusOk.
  ///
  /// In en, this message translates to:
  /// **'Last updated: today — all systems operating normally'**
  String get systemStatusOk;

  /// No description provided for @roleLabManager.
  ///
  /// In en, this message translates to:
  /// **'Lab Manager'**
  String get roleLabManager;

  /// No description provided for @roleWarehouseManager.
  ///
  /// In en, this message translates to:
  /// **'Warehouse Manager'**
  String get roleWarehouseManager;

  /// No description provided for @roleDentist.
  ///
  /// In en, this message translates to:
  /// **'Dentist'**
  String get roleDentist;

  /// No description provided for @roleSecretary.
  ///
  /// In en, this message translates to:
  /// **'Secretary'**
  String get roleSecretary;

  /// No description provided for @roleAdmin.
  ///
  /// In en, this message translates to:
  /// **'Administrator'**
  String get roleAdmin;

  /// No description provided for @labSystemBadge.
  ///
  /// In en, this message translates to:
  /// **'Lab System'**
  String get labSystemBadge;

  /// No description provided for @warehouseSystemBadge.
  ///
  /// In en, this message translates to:
  /// **'Warehouse System'**
  String get warehouseSystemBadge;

  /// No description provided for @emptyNoOrdersTitle.
  ///
  /// In en, this message translates to:
  /// **'No Orders Yet'**
  String get emptyNoOrdersTitle;

  /// No description provided for @emptyNoOrdersMessage.
  ///
  /// In en, this message translates to:
  /// **'Orders will appear here when added'**
  String get emptyNoOrdersMessage;

  /// No description provided for @emptyNoMaterialsTitle.
  ///
  /// In en, this message translates to:
  /// **'No Materials'**
  String get emptyNoMaterialsTitle;

  /// No description provided for @emptyNoMaterialsMessage.
  ///
  /// In en, this message translates to:
  /// **'No materials have been added to inventory yet'**
  String get emptyNoMaterialsMessage;

  /// No description provided for @emptyNoInvoicesTitle.
  ///
  /// In en, this message translates to:
  /// **'No Invoices'**
  String get emptyNoInvoicesTitle;

  /// No description provided for @emptyNoInvoicesMessage.
  ///
  /// In en, this message translates to:
  /// **'Invoice history is currently empty'**
  String get emptyNoInvoicesMessage;

  /// No description provided for @emptyNoNotificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'No New Notifications'**
  String get emptyNoNotificationsTitle;

  /// No description provided for @emptyNoNotificationsMessage.
  ///
  /// In en, this message translates to:
  /// **'We\'ll notify you when something new arrives'**
  String get emptyNoNotificationsMessage;

  /// No description provided for @emptyNoSearchResultsTitle.
  ///
  /// In en, this message translates to:
  /// **'No Results Found'**
  String get emptyNoSearchResultsTitle;

  /// No description provided for @emptyNoSearchResultsMessage.
  ///
  /// In en, this message translates to:
  /// **'Try different search terms'**
  String get emptyNoSearchResultsMessage;

  /// No description provided for @emptyNoTechniciansTitle.
  ///
  /// In en, this message translates to:
  /// **'No Technicians'**
  String get emptyNoTechniciansTitle;

  /// No description provided for @emptyNoTechniciansMessage.
  ///
  /// In en, this message translates to:
  /// **'Start by adding the first technician to the team'**
  String get emptyNoTechniciansMessage;

  /// No description provided for @emptyNoReportsTitle.
  ///
  /// In en, this message translates to:
  /// **'No Reports Available'**
  String get emptyNoReportsTitle;

  /// No description provided for @emptyNoReportsMessage.
  ///
  /// In en, this message translates to:
  /// **'Reports will appear once data is collected'**
  String get emptyNoReportsMessage;

  /// No description provided for @emptyErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Failed to Load Data'**
  String get emptyErrorTitle;

  /// No description provided for @emptyErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while connecting to the server'**
  String get emptyErrorMessage;

  /// No description provided for @actionAddFirst.
  ///
  /// In en, this message translates to:
  /// **'Add First Item'**
  String get actionAddFirst;

  /// No description provided for @actionClearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear Filters'**
  String get actionClearFilters;

  /// No description provided for @loadingData.
  ///
  /// In en, this message translates to:
  /// **'Loading data...'**
  String get loadingData;

  /// No description provided for @loadingPleaseWait.
  ///
  /// In en, this message translates to:
  /// **'Please wait...'**
  String get loadingPleaseWait;

  /// No description provided for @systemSelectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Select System'**
  String get systemSelectionTitle;

  /// No description provided for @systemSelectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose the system you want to work with'**
  String get systemSelectionSubtitle;

  /// No description provided for @systemSelectionLabTitle.
  ///
  /// In en, this message translates to:
  /// **'Lab System'**
  String get systemSelectionLabTitle;

  /// No description provided for @systemSelectionLabDescription.
  ///
  /// In en, this message translates to:
  /// **'Manage dental prosthetics orders, technicians, and reports'**
  String get systemSelectionLabDescription;

  /// No description provided for @systemSelectionWarehouseTitle.
  ///
  /// In en, this message translates to:
  /// **'Warehouse System'**
  String get systemSelectionWarehouseTitle;

  /// No description provided for @systemSelectionWarehouseDescription.
  ///
  /// In en, this message translates to:
  /// **'Manage inventory, materials, invoices, and clinic orders'**
  String get systemSelectionWarehouseDescription;

  /// No description provided for @systemSelectionEnterButton.
  ///
  /// In en, this message translates to:
  /// **'Enter'**
  String get systemSelectionEnterButton;

  /// No description provided for @systemSelectionDemoNotice.
  ///
  /// In en, this message translates to:
  /// **'Preview mode — you can switch between systems anytime'**
  String get systemSelectionDemoNotice;

  /// No description provided for @systemSwitcherSwitchTo.
  ///
  /// In en, this message translates to:
  /// **'Switch to'**
  String get systemSwitcherSwitchTo;

  /// No description provided for @systemSwitcherCurrentSystem.
  ///
  /// In en, this message translates to:
  /// **'Current System'**
  String get systemSwitcherCurrentSystem;

  /// No description provided for @f4TopbarSubtitles.
  ///
  /// In en, this message translates to:
  /// **'─── Topbar subtitles ───'**
  String get f4TopbarSubtitles;

  /// No description provided for @warehouseTopbarSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Warehouse Management System · DT.Teeth'**
  String get warehouseTopbarSubtitle;

  /// No description provided for @labTopbarSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Lab Management System · DT.Teeth'**
  String get labTopbarSubtitle;

  /// No description provided for @f4Dashboard.
  ///
  /// In en, this message translates to:
  /// **'─── Dashboard — warehouse ───'**
  String get f4Dashboard;

  /// No description provided for @whDashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get whDashboardTitle;

  /// No description provided for @whDashboardHeroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Last updated: today — all systems operating normally'**
  String get whDashboardHeroSubtitle;

  /// No description provided for @whHeroStatRegisteredMaterials.
  ///
  /// In en, this message translates to:
  /// **'Registered Materials'**
  String get whHeroStatRegisteredMaterials;

  /// No description provided for @whHeroStatPendingOrders.
  ///
  /// In en, this message translates to:
  /// **'Pending Orders'**
  String get whHeroStatPendingOrders;

  /// No description provided for @whHeroStatActiveAlerts.
  ///
  /// In en, this message translates to:
  /// **'Active Alerts'**
  String get whHeroStatActiveAlerts;

  /// No description provided for @whStatCurrentInventory.
  ///
  /// In en, this message translates to:
  /// **'Current Inventory'**
  String get whStatCurrentInventory;

  /// No description provided for @whStatLowStockMaterials.
  ///
  /// In en, this message translates to:
  /// **'Low Stock Materials'**
  String get whStatLowStockMaterials;

  /// No description provided for @whStatIncomingOrders.
  ///
  /// In en, this message translates to:
  /// **'Incoming Orders'**
  String get whStatIncomingOrders;

  /// No description provided for @whStatExpiringMaterials.
  ///
  /// In en, this message translates to:
  /// **'Expiring Materials'**
  String get whStatExpiringMaterials;

  /// No description provided for @whSectionTopRequested.
  ///
  /// In en, this message translates to:
  /// **'Most Requested Materials'**
  String get whSectionTopRequested;

  /// No description provided for @whSectionExpiringSoon.
  ///
  /// In en, this message translates to:
  /// **'Materials Expiring Soon'**
  String get whSectionExpiringSoon;

  /// No description provided for @whSectionTopRequestedCaption.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get whSectionTopRequestedCaption;

  /// No description provided for @whSectionExpiringCaption.
  ///
  /// In en, this message translates to:
  /// **'Within 30 days'**
  String get whSectionExpiringCaption;

  /// No description provided for @whAlertLowStockTitle.
  ///
  /// In en, this message translates to:
  /// **'Low Stock'**
  String get whAlertLowStockTitle;

  /// No description provided for @whAlertLowStockSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{count} critical materials'**
  String whAlertLowStockSubtitle(int count);

  /// No description provided for @whAlertNewOrdersTitle.
  ///
  /// In en, this message translates to:
  /// **'New Orders'**
  String get whAlertNewOrdersTitle;

  /// No description provided for @whAlertNewOrdersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{count} pending'**
  String whAlertNewOrdersSubtitle(int count);

  /// No description provided for @whQuickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get whQuickActions;

  /// No description provided for @whQuickActionAddMaterial.
  ///
  /// In en, this message translates to:
  /// **'Material'**
  String get whQuickActionAddMaterial;

  /// No description provided for @whQuickActionAddInvoice.
  ///
  /// In en, this message translates to:
  /// **'Invoice'**
  String get whQuickActionAddInvoice;

  /// No description provided for @whQuickActionReports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get whQuickActionReports;

  /// No description provided for @whQuickActionOrders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get whQuickActionOrders;

  /// No description provided for @whInventoryDistribution.
  ///
  /// In en, this message translates to:
  /// **'Inventory Distribution'**
  String get whInventoryDistribution;

  /// No description provided for @whCategoryConsumables.
  ///
  /// In en, this message translates to:
  /// **'Consumables'**
  String get whCategoryConsumables;

  /// No description provided for @whCategoryMedicines.
  ///
  /// In en, this message translates to:
  /// **'Medicines'**
  String get whCategoryMedicines;

  /// No description provided for @whCategoryMedical.
  ///
  /// In en, this message translates to:
  /// **'Medical'**
  String get whCategoryMedical;

  /// No description provided for @whCategoryEquipment.
  ///
  /// In en, this message translates to:
  /// **'Equipment'**
  String get whCategoryEquipment;

  /// No description provided for @whExpiryDaysLeft.
  ///
  /// In en, this message translates to:
  /// **'Days Left'**
  String get whExpiryDaysLeft;

  /// No description provided for @errorRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get errorRequired;

  /// No description provided for @errorInvalidNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid number'**
  String get errorInvalidNumber;

  /// No description provided for @whFullReport.
  ///
  /// In en, this message translates to:
  /// **'Full Report'**
  String get whFullReport;

  /// No description provided for @f4Materials.
  ///
  /// In en, this message translates to:
  /// **'─── Materials Management ───'**
  String get f4Materials;

  /// No description provided for @whMaterialsTitle.
  ///
  /// In en, this message translates to:
  /// **'Materials'**
  String get whMaterialsTitle;

  /// No description provided for @whMaterialsAdd.
  ///
  /// In en, this message translates to:
  /// **'Add Material'**
  String get whMaterialsAdd;

  /// No description provided for @whFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get whFilterAll;

  /// No description provided for @whFilterLowStock.
  ///
  /// In en, this message translates to:
  /// **'Low Stock'**
  String get whFilterLowStock;

  /// No description provided for @whFilterExpiring.
  ///
  /// In en, this message translates to:
  /// **'Expiring'**
  String get whFilterExpiring;

  /// No description provided for @whFilterConsumables.
  ///
  /// In en, this message translates to:
  /// **'Consumables'**
  String get whFilterConsumables;

  /// No description provided for @whFilterMedicines.
  ///
  /// In en, this message translates to:
  /// **'Medicines'**
  String get whFilterMedicines;

  /// No description provided for @whFilterMedical.
  ///
  /// In en, this message translates to:
  /// **'Medical'**
  String get whFilterMedical;

  /// No description provided for @whMaterialName.
  ///
  /// In en, this message translates to:
  /// **'Material Name'**
  String get whMaterialName;

  /// No description provided for @whMaterialCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get whMaterialCategory;

  /// No description provided for @whMaterialQuantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get whMaterialQuantity;

  /// No description provided for @whMaterialUnit.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get whMaterialUnit;

  /// No description provided for @whMaterialMinStock.
  ///
  /// In en, this message translates to:
  /// **'Minimum Stock'**
  String get whMaterialMinStock;

  /// No description provided for @whMaterialExpiryDate.
  ///
  /// In en, this message translates to:
  /// **'Expiry Date'**
  String get whMaterialExpiryDate;

  /// No description provided for @whMaterialSupplier.
  ///
  /// In en, this message translates to:
  /// **'Supplier'**
  String get whMaterialSupplier;

  /// No description provided for @whMaterialPrice.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get whMaterialPrice;

  /// No description provided for @whMaterialNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get whMaterialNotes;

  /// No description provided for @whStatusAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get whStatusAvailable;

  /// No description provided for @whStatusLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get whStatusLow;

  /// No description provided for @whStatusOut.
  ///
  /// In en, this message translates to:
  /// **'Out of Stock'**
  String get whStatusOut;

  /// No description provided for @f4Orders.
  ///
  /// In en, this message translates to:
  /// **'─── Orders ───'**
  String get f4Orders;

  /// No description provided for @whOrdersTitle.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get whOrdersTitle;

  /// No description provided for @whOrderNumber.
  ///
  /// In en, this message translates to:
  /// **'Order #'**
  String get whOrderNumber;

  /// No description provided for @whOrderRequester.
  ///
  /// In en, this message translates to:
  /// **'Requester'**
  String get whOrderRequester;

  /// No description provided for @whOrderDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get whOrderDate;

  /// No description provided for @whOrderStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get whOrderStatus;

  /// No description provided for @whOrderAction.
  ///
  /// In en, this message translates to:
  /// **'Action'**
  String get whOrderAction;

  /// No description provided for @whOrderFilterNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get whOrderFilterNew;

  /// No description provided for @whOrderFilterDone.
  ///
  /// In en, this message translates to:
  /// **'Fulfilled'**
  String get whOrderFilterDone;

  /// No description provided for @whOrderFilterMissing.
  ///
  /// In en, this message translates to:
  /// **'Missing'**
  String get whOrderFilterMissing;

  /// No description provided for @whOrderStatusNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get whOrderStatusNew;

  /// No description provided for @whOrderStatusFulfilled.
  ///
  /// In en, this message translates to:
  /// **'Fulfilled'**
  String get whOrderStatusFulfilled;

  /// No description provided for @whOrderStatusMissing.
  ///
  /// In en, this message translates to:
  /// **'Missing'**
  String get whOrderStatusMissing;

  /// No description provided for @f4Invoices.
  ///
  /// In en, this message translates to:
  /// **'─── Invoices ───'**
  String get f4Invoices;

  /// No description provided for @whInvoicesTitle.
  ///
  /// In en, this message translates to:
  /// **'Invoices'**
  String get whInvoicesTitle;

  /// No description provided for @whInvoiceAdd.
  ///
  /// In en, this message translates to:
  /// **'New Invoice'**
  String get whInvoiceAdd;

  /// No description provided for @whInvoiceFilterPurchase.
  ///
  /// In en, this message translates to:
  /// **'Purchase'**
  String get whInvoiceFilterPurchase;

  /// No description provided for @whInvoiceFilterUsage.
  ///
  /// In en, this message translates to:
  /// **'Usage'**
  String get whInvoiceFilterUsage;

  /// No description provided for @whInvoiceWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly Invoices'**
  String get whInvoiceWeekly;

  /// No description provided for @whInvoiceWeekSummary.
  ///
  /// In en, this message translates to:
  /// **'Week Summary'**
  String get whInvoiceWeekSummary;

  /// No description provided for @whInvoiceTotalPurchase.
  ///
  /// In en, this message translates to:
  /// **'Total Purchase'**
  String get whInvoiceTotalPurchase;

  /// No description provided for @whInvoiceTotalUsage.
  ///
  /// In en, this message translates to:
  /// **'Total Usage'**
  String get whInvoiceTotalUsage;

  /// No description provided for @whInvoiceTotalLoss.
  ///
  /// In en, this message translates to:
  /// **'Loss — Expired'**
  String get whInvoiceTotalLoss;

  /// No description provided for @whInvoiceExportPdf.
  ///
  /// In en, this message translates to:
  /// **'Export PDF'**
  String get whInvoiceExportPdf;

  /// No description provided for @f4Reports.
  ///
  /// In en, this message translates to:
  /// **'─── Reports ───'**
  String get f4Reports;

  /// No description provided for @whReportsTitle.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get whReportsTitle;

  /// No description provided for @whReportTabTopMaterials.
  ///
  /// In en, this message translates to:
  /// **'Top 10 Materials'**
  String get whReportTabTopMaterials;

  /// No description provided for @whReportTabFinancial.
  ///
  /// In en, this message translates to:
  /// **'Financial'**
  String get whReportTabFinancial;

  /// No description provided for @whReportTopMaterialsTitle.
  ///
  /// In en, this message translates to:
  /// **'Most Requested Materials'**
  String get whReportTopMaterialsTitle;

  /// No description provided for @whReportMonthlyOrders.
  ///
  /// In en, this message translates to:
  /// **'Monthly Orders'**
  String get whReportMonthlyOrders;

  /// No description provided for @whReportRank.
  ///
  /// In en, this message translates to:
  /// **'Rank'**
  String get whReportRank;

  /// No description provided for @whReportRequestCount.
  ///
  /// In en, this message translates to:
  /// **'Requests'**
  String get whReportRequestCount;

  /// No description provided for @whReportCost.
  ///
  /// In en, this message translates to:
  /// **'Cost'**
  String get whReportCost;

  /// No description provided for @whReportExport.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get whReportExport;

  /// No description provided for @whReportWeeklyPurchases.
  ///
  /// In en, this message translates to:
  /// **'Weekly Purchases'**
  String get whReportWeeklyPurchases;

  /// No description provided for @whReportUsageCost.
  ///
  /// In en, this message translates to:
  /// **'Usage Cost'**
  String get whReportUsageCost;

  /// No description provided for @whReportExpiredLoss.
  ///
  /// In en, this message translates to:
  /// **'Expired Loss'**
  String get whReportExpiredLoss;

  /// No description provided for @f4Notifications.
  ///
  /// In en, this message translates to:
  /// **'─── Notifications ───'**
  String get f4Notifications;

  /// No description provided for @whNotificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get whNotificationsTitle;

  /// No description provided for @whNotifFilterUnread.
  ///
  /// In en, this message translates to:
  /// **'Unread'**
  String get whNotifFilterUnread;

  /// No description provided for @whNotifFilterLow.
  ///
  /// In en, this message translates to:
  /// **'Low Stock'**
  String get whNotifFilterLow;

  /// No description provided for @whNotifFilterExpiry.
  ///
  /// In en, this message translates to:
  /// **'Expiry'**
  String get whNotifFilterExpiry;

  /// No description provided for @whNotifFilterOrder.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get whNotifFilterOrder;

  /// No description provided for @whNotifMarkAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark All Read'**
  String get whNotifMarkAllRead;

  /// No description provided for @f4Settings.
  ///
  /// In en, this message translates to:
  /// **'─── Settings ───'**
  String get f4Settings;

  /// No description provided for @whSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get whSettingsTitle;

  /// No description provided for @whSettingsTabProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get whSettingsTabProfile;

  /// No description provided for @whSettingsTabNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get whSettingsTabNotifications;

  /// No description provided for @whSettingsTabSecurity.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get whSettingsTabSecurity;

  /// No description provided for @whSettingsTabAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get whSettingsTabAbout;

  /// No description provided for @whSettingsFirstName.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get whSettingsFirstName;

  /// No description provided for @whSettingsLastName.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get whSettingsLastName;

  /// No description provided for @whSettingsEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get whSettingsEmail;

  /// No description provided for @whSettingsSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get whSettingsSaveChanges;

  /// No description provided for @whSettingsNotifLowStock.
  ///
  /// In en, this message translates to:
  /// **'Low Stock Alert'**
  String get whSettingsNotifLowStock;

  /// No description provided for @whSettingsNotifLowStockDesc.
  ///
  /// In en, this message translates to:
  /// **'When stock reaches minimum'**
  String get whSettingsNotifLowStockDesc;

  /// No description provided for @whSettingsNotifExpiry.
  ///
  /// In en, this message translates to:
  /// **'Expiry Alert'**
  String get whSettingsNotifExpiry;

  /// No description provided for @whSettingsNotifExpiryDesc.
  ///
  /// In en, this message translates to:
  /// **'30 days before expiry'**
  String get whSettingsNotifExpiryDesc;

  /// No description provided for @whSettingsNotifOrders.
  ///
  /// In en, this message translates to:
  /// **'New Orders'**
  String get whSettingsNotifOrders;

  /// No description provided for @whSettingsNotifOrdersDesc.
  ///
  /// In en, this message translates to:
  /// **'Upon arrival'**
  String get whSettingsNotifOrdersDesc;

  /// No description provided for @whSettingsNotifWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly Report'**
  String get whSettingsNotifWeekly;

  /// No description provided for @whSettingsNotifWeeklyDesc.
  ///
  /// In en, this message translates to:
  /// **'Every Sunday'**
  String get whSettingsNotifWeeklyDesc;

  /// No description provided for @whSettingsCurrentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get whSettingsCurrentPassword;

  /// No description provided for @whSettingsNewPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get whSettingsNewPassword;

  /// No description provided for @whSettingsConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get whSettingsConfirmPassword;

  /// No description provided for @whSettingsUpdatePassword.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get whSettingsUpdatePassword;

  /// No description provided for @whSettingsAboutTitle.
  ///
  /// In en, this message translates to:
  /// **'DT.Teeth Repository'**
  String get whSettingsAboutTitle;

  /// No description provided for @whSettingsAboutVersion.
  ///
  /// In en, this message translates to:
  /// **'v1.0.0 · March 2026 · Flutter Web'**
  String get whSettingsAboutVersion;

  /// No description provided for @f4ComingSoon.
  ///
  /// In en, this message translates to:
  /// **'─── Under construction badge ───'**
  String get f4ComingSoon;

  /// No description provided for @comingSoonTitle.
  ///
  /// In en, this message translates to:
  /// **'Coming Soon'**
  String get comingSoonTitle;

  /// No description provided for @comingSoonSubtitle.
  ///
  /// In en, this message translates to:
  /// **'This screen is under construction — coming soon'**
  String get comingSoonSubtitle;

  /// No description provided for @screenUnderConstruction.
  ///
  /// In en, this message translates to:
  /// **'Under Construction'**
  String get screenUnderConstruction;

  /// No description provided for @f4Lab.
  ///
  /// In en, this message translates to:
  /// **'─── Lab System ───'**
  String get f4Lab;

  /// No description provided for @labDashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get labDashboardTitle;

  /// No description provided for @labHeroWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Lab System 🧪'**
  String get labHeroWelcome;

  /// No description provided for @labHeroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Last update: Today — All systems running normally ✅'**
  String get labHeroSubtitle;

  /// No description provided for @labHeroStatTodayOrders.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Orders'**
  String get labHeroStatTodayOrders;

  /// No description provided for @labHeroStatInProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get labHeroStatInProgress;

  /// No description provided for @labHeroStatCompletionRate.
  ///
  /// In en, this message translates to:
  /// **'Completion Rate'**
  String get labHeroStatCompletionRate;

  /// No description provided for @labStatNewOrders.
  ///
  /// In en, this message translates to:
  /// **'New Orders'**
  String get labStatNewOrders;

  /// No description provided for @labStatManufacturing.
  ///
  /// In en, this message translates to:
  /// **'Manufacturing'**
  String get labStatManufacturing;

  /// No description provided for @labStatReady.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get labStatReady;

  /// No description provided for @labStatUrgentToday.
  ///
  /// In en, this message translates to:
  /// **'Due Today'**
  String get labStatUrgentToday;

  /// No description provided for @labOrdersFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get labOrdersFilterAll;

  /// No description provided for @labOrdersFilterNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get labOrdersFilterNew;

  /// No description provided for @labOrdersFilterManufacturing.
  ///
  /// In en, this message translates to:
  /// **'Manufacturing'**
  String get labOrdersFilterManufacturing;

  /// No description provided for @labOrdersFilterReady.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get labOrdersFilterReady;

  /// No description provided for @labOrdersDueToday.
  ///
  /// In en, this message translates to:
  /// **'Due Today'**
  String get labOrdersDueToday;

  /// No description provided for @labOrdersDueTodaySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Must be completed before evening'**
  String get labOrdersDueTodaySubtitle;

  /// No description provided for @labTeamTitle.
  ///
  /// In en, this message translates to:
  /// **'Manage Technicians'**
  String get labTeamTitle;

  /// No description provided for @labTeamTotal.
  ///
  /// In en, this message translates to:
  /// **'Total Technicians'**
  String get labTeamTotal;

  /// No description provided for @labTeamActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get labTeamActive;

  /// No description provided for @labTeamAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get labTeamAvailable;

  /// No description provided for @labTeamColumnName.
  ///
  /// In en, this message translates to:
  /// **'Technician'**
  String get labTeamColumnName;

  /// No description provided for @labTeamColumnShift.
  ///
  /// In en, this message translates to:
  /// **'Shift Hours'**
  String get labTeamColumnShift;

  /// No description provided for @labTeamColumnCurrentTask.
  ///
  /// In en, this message translates to:
  /// **'Current Task'**
  String get labTeamColumnCurrentTask;

  /// No description provided for @labTeamColumnStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get labTeamColumnStatus;

  /// No description provided for @labTeamColumnAction.
  ///
  /// In en, this message translates to:
  /// **'Action'**
  String get labTeamColumnAction;

  /// No description provided for @labTeamAssign.
  ///
  /// In en, this message translates to:
  /// **'Assign'**
  String get labTeamAssign;

  /// No description provided for @labTeamFree.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get labTeamFree;

  /// No description provided for @labTeamBusy.
  ///
  /// In en, this message translates to:
  /// **'Busy'**
  String get labTeamBusy;

  /// No description provided for @labReportTabByType.
  ///
  /// In en, this message translates to:
  /// **'By Type'**
  String get labReportTabByType;

  /// No description provided for @labReportTabByDate.
  ///
  /// In en, this message translates to:
  /// **'By Date'**
  String get labReportTabByDate;

  /// No description provided for @labReportTabTeam.
  ///
  /// In en, this message translates to:
  /// **'Team Performance'**
  String get labReportTabTeam;

  /// No description provided for @labReportFilterMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get labReportFilterMonthly;

  /// No description provided for @labReportFilterWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get labReportFilterWeekly;

  /// No description provided for @labReportFilterDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get labReportFilterDaily;

  /// No description provided for @labReportFilterYearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get labReportFilterYearly;

  /// No description provided for @labReportExportPdf.
  ///
  /// In en, this message translates to:
  /// **'📤 Export PDF'**
  String get labReportExportPdf;

  /// No description provided for @labReportExportExcel.
  ///
  /// In en, this message translates to:
  /// **'📊 Export Excel'**
  String get labReportExportExcel;

  /// No description provided for @labReportSendEmail.
  ///
  /// In en, this message translates to:
  /// **'📧 Send by Email'**
  String get labReportSendEmail;

  /// No description provided for @labReportStatTotal.
  ///
  /// In en, this message translates to:
  /// **'Period Orders'**
  String get labReportStatTotal;

  /// No description provided for @labReportStatCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed On Time'**
  String get labReportStatCompleted;

  /// No description provided for @labReportStatAvgTime.
  ///
  /// In en, this message translates to:
  /// **'Avg. Time'**
  String get labReportStatAvgTime;

  /// No description provided for @labReportStatSatisfaction.
  ///
  /// In en, this message translates to:
  /// **'Satisfaction Rate'**
  String get labReportStatSatisfaction;

  /// No description provided for @labReportCrownType.
  ///
  /// In en, this message translates to:
  /// **'Crowns'**
  String get labReportCrownType;

  /// No description provided for @labReportBridgeType.
  ///
  /// In en, this message translates to:
  /// **'Bridges'**
  String get labReportBridgeType;

  /// No description provided for @labReportOtherType.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get labReportOtherType;

  /// No description provided for @labQuickActionOrders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get labQuickActionOrders;

  /// No description provided for @labQuickActionReport.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get labQuickActionReport;

  /// No description provided for @labQuickActionTeam.
  ///
  /// In en, this message translates to:
  /// **'Team'**
  String get labQuickActionTeam;

  /// No description provided for @labQuickActionAlerts.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get labQuickActionAlerts;

  /// No description provided for @labTeamPerformanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Team Performance'**
  String get labTeamPerformanceTitle;

  /// No description provided for @labSettingsTabProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get labSettingsTabProfile;

  /// No description provided for @labSettingsTabNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get labSettingsTabNotifications;

  /// No description provided for @labSettingsTabAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get labSettingsTabAbout;

  /// No description provided for @labSettingsNotifNewOrders.
  ///
  /// In en, this message translates to:
  /// **'New Orders'**
  String get labSettingsNotifNewOrders;

  /// No description provided for @labSettingsNotifNewOrdersDesc.
  ///
  /// In en, this message translates to:
  /// **'Instant notification'**
  String get labSettingsNotifNewOrdersDesc;

  /// No description provided for @labSettingsNotifUrgent.
  ///
  /// In en, this message translates to:
  /// **'Urgent Alert'**
  String get labSettingsNotifUrgent;

  /// No description provided for @labSettingsNotifUrgentDesc.
  ///
  /// In en, this message translates to:
  /// **'3 hours before deadline'**
  String get labSettingsNotifUrgentDesc;

  /// No description provided for @labSettingsNotifDoctorReady.
  ///
  /// In en, this message translates to:
  /// **'Doctor Notification'**
  String get labSettingsNotifDoctorReady;

  /// No description provided for @labSettingsNotifDoctorReadyDesc.
  ///
  /// In en, this message translates to:
  /// **'On completion via FCM'**
  String get labSettingsNotifDoctorReadyDesc;

  /// No description provided for @labSettingsAboutTitle.
  ///
  /// In en, this message translates to:
  /// **'DT.Teeth Lab'**
  String get labSettingsAboutTitle;

  /// No description provided for @labSettingsAboutVersion.
  ///
  /// In en, this message translates to:
  /// **'v1.0.0 · Flutter Web · Laravel API'**
  String get labSettingsAboutVersion;

  /// No description provided for @labTopbarSubtitleFull.
  ///
  /// In en, this message translates to:
  /// **'Lab Management System · DT.Teeth'**
  String get labTopbarSubtitleFull;

  /// No description provided for @labProfile.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get labProfile;

  /// No description provided for @labManageTechnicians.
  ///
  /// In en, this message translates to:
  /// **'Manage Technicians'**
  String get labManageTechnicians;
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
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
