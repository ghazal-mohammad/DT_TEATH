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

  /// No description provided for @privacyScreenHint.
  ///
  /// In en, this message translates to:
  /// **'Protected content'**
  String get privacyScreenHint;

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

  /// No description provided for @authVerifyCodeError.
  ///
  /// In en, this message translates to:
  /// **'Invalid or expired code. Please try again.'**
  String get authVerifyCodeError;

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

  /// No description provided for @systemLabDesc.
  ///
  /// In en, this message translates to:
  /// **'Manage prosthetics orders, technicians and reports'**
  String get systemLabDesc;

  /// No description provided for @systemWarehouseDesc.
  ///
  /// In en, this message translates to:
  /// **'Manage inventory, materials, invoices and clinic requests'**
  String get systemWarehouseDesc;

  /// No description provided for @systemSelectTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a system'**
  String get systemSelectTitle;

  /// No description provided for @systemSelectSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select the system you want to work on'**
  String get systemSelectSubtitle;

  /// No description provided for @systemPreviewNote.
  ///
  /// In en, this message translates to:
  /// **'Preview mode — you can switch anytime'**
  String get systemPreviewNote;

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

  /// No description provided for @reportsPreviousPeriod.
  ///
  /// In en, this message translates to:
  /// **'Previous period'**
  String get reportsPreviousPeriod;

  /// No description provided for @reportsNextPeriod.
  ///
  /// In en, this message translates to:
  /// **'Next period'**
  String get reportsNextPeriod;

  /// No description provided for @reportsBackToToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get reportsBackToToday;

  /// No description provided for @materialRequests.
  ///
  /// In en, this message translates to:
  /// **'Invoices'**
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

  /// No description provided for @commandPaletteHint.
  ///
  /// In en, this message translates to:
  /// **'Search or jump... (order, product, technician, material)'**
  String get commandPaletteHint;

  /// No description provided for @commandPaletteEmpty.
  ///
  /// In en, this message translates to:
  /// **'No matching results'**
  String get commandPaletteEmpty;

  /// No description provided for @commandPaletteNavHint.
  ///
  /// In en, this message translates to:
  /// **'to navigate · Enter to open · Esc to close'**
  String get commandPaletteNavHint;

  /// No description provided for @commandPaletteOpen.
  ///
  /// In en, this message translates to:
  /// **'Global search (Ctrl+K)'**
  String get commandPaletteOpen;

  /// No description provided for @commandCatNav.
  ///
  /// In en, this message translates to:
  /// **'Navigate'**
  String get commandCatNav;

  /// No description provided for @commandCatOrder.
  ///
  /// In en, this message translates to:
  /// **'Order'**
  String get commandCatOrder;

  /// No description provided for @commandCatProduct.
  ///
  /// In en, this message translates to:
  /// **'Product'**
  String get commandCatProduct;

  /// No description provided for @commandCatTechnician.
  ///
  /// In en, this message translates to:
  /// **'Technician'**
  String get commandCatTechnician;

  /// No description provided for @commandCatMaterial.
  ///
  /// In en, this message translates to:
  /// **'Material'**
  String get commandCatMaterial;

  /// No description provided for @commandCatRequest.
  ///
  /// In en, this message translates to:
  /// **'Request'**
  String get commandCatRequest;

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

  /// No description provided for @statusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusCancelled;

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

  /// No description provided for @networkOfflineBanner.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get networkOfflineBanner;

  /// No description provided for @syncPendingBanner.
  ///
  /// In en, this message translates to:
  /// **'{count} change(s) awaiting sync'**
  String syncPendingBanner(int count);

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

  /// No description provided for @dateHintDMY.
  ///
  /// In en, this message translates to:
  /// **'DD/MM/YYYY'**
  String get dateHintDMY;

  /// No description provided for @dateEnterLabel.
  ///
  /// In en, this message translates to:
  /// **'Enter date'**
  String get dateEnterLabel;

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

  /// No description provided for @whCategoryClinic.
  ///
  /// In en, this message translates to:
  /// **'Clinic'**
  String get whCategoryClinic;

  /// No description provided for @whCategoryLab.
  ///
  /// In en, this message translates to:
  /// **'Lab'**
  String get whCategoryLab;

  /// No description provided for @whCategoryBoth.
  ///
  /// In en, this message translates to:
  /// **'Both'**
  String get whCategoryBoth;

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

  /// No description provided for @whMaterialsSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Filter warehouse materials... (name, category)'**
  String get whMaterialsSearchHint;

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

  /// No description provided for @whMaterialNameEn.
  ///
  /// In en, this message translates to:
  /// **'Name (English)'**
  String get whMaterialNameEn;

  /// No description provided for @whMaterialCompany.
  ///
  /// In en, this message translates to:
  /// **'Manufacturer'**
  String get whMaterialCompany;

  /// No description provided for @whMaterialDosage.
  ///
  /// In en, this message translates to:
  /// **'Dosage / Concentration'**
  String get whMaterialDosage;

  /// No description provided for @whMaterialPricePerUnit.
  ///
  /// In en, this message translates to:
  /// **'Unit Price'**
  String get whMaterialPricePerUnit;

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

  /// No description provided for @whMaterialUnitHint.
  ///
  /// In en, this message translates to:
  /// **'Choose unit'**
  String get whMaterialUnitHint;

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

  /// No description provided for @whMaterialDeactivate.
  ///
  /// In en, this message translates to:
  /// **'Deactivate'**
  String get whMaterialDeactivate;

  /// No description provided for @whMaterialDeactivateConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Deactivate Material'**
  String get whMaterialDeactivateConfirmTitle;

  /// No description provided for @whMaterialDeactivateConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Deactivate \"{materialName}\"? It will no longer appear in the active materials list.'**
  String whMaterialDeactivateConfirmMessage(String materialName);

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
  /// **'Order date'**
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

  /// No description provided for @labHeroStatDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get labHeroStatDelivered;

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

  /// No description provided for @labOrdersToday.
  ///
  /// In en, this message translates to:
  /// **'Today\'s orders'**
  String get labOrdersToday;

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

  /// No description provided for @labOrdersDueTodayEmpty.
  ///
  /// In en, this message translates to:
  /// **'No orders due today'**
  String get labOrdersDueTodayEmpty;

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

  /// No description provided for @reportExportError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t export the report'**
  String get reportExportError;

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

  /// No description provided for @labReportStatOnTime.
  ///
  /// In en, this message translates to:
  /// **'On-time Rate'**
  String get labReportStatOnTime;

  /// No description provided for @labReportHourSuffix.
  ///
  /// In en, this message translates to:
  /// **'h'**
  String get labReportHourSuffix;

  /// No description provided for @labReportOrdersByDay.
  ///
  /// In en, this message translates to:
  /// **'Orders by Day'**
  String get labReportOrdersByDay;

  /// No description provided for @labReportOrdersByType.
  ///
  /// In en, this message translates to:
  /// **'Orders by Type'**
  String get labReportOrdersByType;

  /// No description provided for @labReportTeamPerf.
  ///
  /// In en, this message translates to:
  /// **'Team Performance'**
  String get labReportTeamPerf;

  /// No description provided for @labReportNoData.
  ///
  /// In en, this message translates to:
  /// **'No data for this period'**
  String get labReportNoData;

  /// No description provided for @ordersUnit.
  ///
  /// In en, this message translates to:
  /// **'orders'**
  String get ordersUnit;

  /// No description provided for @piecesUnit.
  ///
  /// In en, this message translates to:
  /// **'pieces'**
  String get piecesUnit;

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

  /// No description provided for @labDashboardSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Filter this page\'s orders... (number, doctor, material)'**
  String get labDashboardSearchHint;

  /// No description provided for @priorityUrgent.
  ///
  /// In en, this message translates to:
  /// **'Urgent'**
  String get priorityUrgent;

  /// No description provided for @priorityNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get priorityNormal;

  /// No description provided for @labChipThisMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get labChipThisMonth;

  /// No description provided for @labChipActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get labChipActive;

  /// No description provided for @labStatReadyOrders.
  ///
  /// In en, this message translates to:
  /// **'Ready orders'**
  String get labStatReadyOrders;

  /// No description provided for @labTodayOrders.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Orders'**
  String get labTodayOrders;

  /// No description provided for @labLastUpdatedJustNow.
  ///
  /// In en, this message translates to:
  /// **'Last updated: just now'**
  String get labLastUpdatedJustNow;

  /// No description provided for @labLastUpdatedMinutesAgo.
  ///
  /// In en, this message translates to:
  /// **'Last updated: {minutes}m ago'**
  String labLastUpdatedMinutesAgo(int minutes);

  /// No description provided for @labLastUpdatedHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'Last updated: {hours}h ago'**
  String labLastUpdatedHoursAgo(int hours);

  /// No description provided for @labOrdersCount.
  ///
  /// In en, this message translates to:
  /// **'{count} orders'**
  String labOrdersCount(String count);

  /// No description provided for @colOrderNumber.
  ///
  /// In en, this message translates to:
  /// **'Order #'**
  String get colOrderNumber;

  /// No description provided for @colDoctor.
  ///
  /// In en, this message translates to:
  /// **'Doctor'**
  String get colDoctor;

  /// No description provided for @colType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get colType;

  /// No description provided for @colMaterial.
  ///
  /// In en, this message translates to:
  /// **'Material'**
  String get colMaterial;

  /// No description provided for @colTooth.
  ///
  /// In en, this message translates to:
  /// **'Tooth'**
  String get colTooth;

  /// No description provided for @colDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get colDate;

  /// No description provided for @colPriority.
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get colPriority;

  /// No description provided for @colStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get colStatus;

  /// No description provided for @labGreeting.
  ///
  /// In en, this message translates to:
  /// **'Welcome, {name}'**
  String labGreeting(String name);

  /// No description provided for @labLastUpdate.
  ///
  /// In en, this message translates to:
  /// **'Last update: {time}'**
  String labLastUpdate(String time);

  /// No description provided for @labOrdersSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Filter doctor orders... (number, doctor, material, tooth)'**
  String get labOrdersSearchHint;

  /// No description provided for @labOrdersCountOfTotal.
  ///
  /// In en, this message translates to:
  /// **'{shown} of {total} orders'**
  String labOrdersCountOfTotal(String shown, String total);

  /// No description provided for @labOrderProcess.
  ///
  /// In en, this message translates to:
  /// **'Process'**
  String get labOrderProcess;

  /// No description provided for @actionView.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get actionView;

  /// No description provided for @labNoOrdersInCategory.
  ///
  /// In en, this message translates to:
  /// **'No orders in this category'**
  String get labNoOrdersInCategory;

  /// No description provided for @settingsSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search this page...'**
  String get settingsSearchHint;

  /// No description provided for @settingsTabSecurity.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get settingsTabSecurity;

  /// No description provided for @settingsTabPreferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get settingsTabPreferences;

  /// No description provided for @settingsChangePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get settingsChangePassword;

  /// No description provided for @settingsChangePasswordDesc.
  ///
  /// In en, this message translates to:
  /// **'It\'s recommended to change your password every 90 days for better security'**
  String get settingsChangePasswordDesc;

  /// No description provided for @settingsCurrentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get settingsCurrentPassword;

  /// No description provided for @settingsNewPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get settingsNewPassword;

  /// No description provided for @settingsConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get settingsConfirmPassword;

  /// No description provided for @settingsUpdatePassword.
  ///
  /// In en, this message translates to:
  /// **'Update Password'**
  String get settingsUpdatePassword;

  /// No description provided for @settings2FA.
  ///
  /// In en, this message translates to:
  /// **'Two-Factor Authentication'**
  String get settings2FA;

  /// No description provided for @settings2FADesc.
  ///
  /// In en, this message translates to:
  /// **'Extra protection for your account via OTP'**
  String get settings2FADesc;

  /// No description provided for @settings2FAOtpTitle.
  ///
  /// In en, this message translates to:
  /// **'Require OTP on login'**
  String get settings2FAOtpTitle;

  /// No description provided for @settings2FAOtpDesc.
  ///
  /// In en, this message translates to:
  /// **'You receive a code by email each time you sign in from a new device'**
  String get settings2FAOtpDesc;

  /// No description provided for @settingsLogoutAll.
  ///
  /// In en, this message translates to:
  /// **'Sign out of all devices'**
  String get settingsLogoutAll;

  /// No description provided for @settingsLogoutAllDesc.
  ///
  /// In en, this message translates to:
  /// **'End all active sessions on other devices'**
  String get settingsLogoutAllDesc;

  /// No description provided for @settingsNotifPrefs.
  ///
  /// In en, this message translates to:
  /// **'Notification Preferences'**
  String get settingsNotifPrefs;

  /// No description provided for @settingsNotifPrefsDesc.
  ///
  /// In en, this message translates to:
  /// **'Choose which notifications you want to receive'**
  String get settingsNotifPrefsDesc;

  /// No description provided for @labSettingsNotifUrgentOrders.
  ///
  /// In en, this message translates to:
  /// **'Urgent Orders'**
  String get labSettingsNotifUrgentOrders;

  /// No description provided for @labSettingsNotifUrgentOrdersDesc.
  ///
  /// In en, this message translates to:
  /// **'Orders that must be completed today'**
  String get labSettingsNotifUrgentOrdersDesc;

  /// No description provided for @labSettingsNotifNewFromDoctors.
  ///
  /// In en, this message translates to:
  /// **'New orders from doctors'**
  String get labSettingsNotifNewFromDoctors;

  /// No description provided for @labSettingsNotifNewFromDoctorsDesc.
  ///
  /// In en, this message translates to:
  /// **'When a new order arrives'**
  String get labSettingsNotifNewFromDoctorsDesc;

  /// No description provided for @settingsNotifLowMaterials.
  ///
  /// In en, this message translates to:
  /// **'Low materials'**
  String get settingsNotifLowMaterials;

  /// No description provided for @settingsNotifLowMaterialsDesc.
  ///
  /// In en, this message translates to:
  /// **'When a material reaches its minimum'**
  String get settingsNotifLowMaterialsDesc;

  /// No description provided for @labSettingsNotifWarehouseUpdates.
  ///
  /// In en, this message translates to:
  /// **'Warehouse updates'**
  String get labSettingsNotifWarehouseUpdates;

  /// No description provided for @labSettingsNotifWarehouseUpdatesDesc.
  ///
  /// In en, this message translates to:
  /// **'Status of sent supply requests'**
  String get labSettingsNotifWarehouseUpdatesDesc;

  /// No description provided for @labSettingsNotifTeamUpdates.
  ///
  /// In en, this message translates to:
  /// **'Team updates'**
  String get labSettingsNotifTeamUpdates;

  /// No description provided for @labSettingsNotifTeamUpdatesDesc.
  ///
  /// In en, this message translates to:
  /// **'Adding or changing a technician\'s shift'**
  String get labSettingsNotifTeamUpdatesDesc;

  /// No description provided for @settingsNotifChannels.
  ///
  /// In en, this message translates to:
  /// **'Notification Channels'**
  String get settingsNotifChannels;

  /// No description provided for @settingsNotifChannelsDesc.
  ///
  /// In en, this message translates to:
  /// **'Choose where you receive alerts'**
  String get settingsNotifChannelsDesc;

  /// No description provided for @settingsNotifDailyEmail.
  ///
  /// In en, this message translates to:
  /// **'Daily summary by email'**
  String get settingsNotifDailyEmail;

  /// No description provided for @settingsNotifDailyEmailDesc.
  ///
  /// In en, this message translates to:
  /// **'Delivered at 8:00 AM every day'**
  String get settingsNotifDailyEmailDesc;

  /// No description provided for @settingsNotifSound.
  ///
  /// In en, this message translates to:
  /// **'In-app notification sound'**
  String get settingsNotifSound;

  /// No description provided for @settingsNotifSoundDesc.
  ///
  /// In en, this message translates to:
  /// **'Play a tone when a new notification arrives'**
  String get settingsNotifSoundDesc;

  /// No description provided for @settingsThemeDesc.
  ///
  /// In en, this message translates to:
  /// **'Choose the system appearance'**
  String get settingsThemeDesc;

  /// No description provided for @settingsThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;

  /// No description provided for @settingsThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get settingsThemeSystem;

  /// No description provided for @settingsTextSize.
  ///
  /// In en, this message translates to:
  /// **'Font Size'**
  String get settingsTextSize;

  /// No description provided for @settingsTextSizeDesc.
  ///
  /// In en, this message translates to:
  /// **'Enlarge or reduce the interface font to your comfort'**
  String get settingsTextSizeDesc;

  /// No description provided for @settingsTextSizeSmall.
  ///
  /// In en, this message translates to:
  /// **'Small'**
  String get settingsTextSizeSmall;

  /// No description provided for @settingsTextSizeNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get settingsTextSizeNormal;

  /// No description provided for @settingsTextSizeLarge.
  ///
  /// In en, this message translates to:
  /// **'Large'**
  String get settingsTextSizeLarge;

  /// No description provided for @settingsTextSizeXLarge.
  ///
  /// In en, this message translates to:
  /// **'Larger'**
  String get settingsTextSizeXLarge;

  /// No description provided for @settingsLanguageDesc.
  ///
  /// In en, this message translates to:
  /// **'System display language'**
  String get settingsLanguageDesc;

  /// No description provided for @settingsLangArabicHint.
  ///
  /// In en, this message translates to:
  /// **'RTL · Default'**
  String get settingsLangArabicHint;

  /// No description provided for @settingsLangEnglishHint.
  ///
  /// In en, this message translates to:
  /// **'LTR'**
  String get settingsLangEnglishHint;

  /// No description provided for @settingsDisplayPerf.
  ///
  /// In en, this message translates to:
  /// **'Display & Performance'**
  String get settingsDisplayPerf;

  /// No description provided for @settingsCompactView.
  ///
  /// In en, this message translates to:
  /// **'Compact View'**
  String get settingsCompactView;

  /// No description provided for @settingsCompactViewDesc.
  ///
  /// In en, this message translates to:
  /// **'Show more data on a single screen'**
  String get settingsCompactViewDesc;

  /// No description provided for @settingsAutoSave.
  ///
  /// In en, this message translates to:
  /// **'Auto-save'**
  String get settingsAutoSave;

  /// No description provided for @settingsAutoSaveDesc.
  ///
  /// In en, this message translates to:
  /// **'Automatically save changes every minute'**
  String get settingsAutoSaveDesc;

  /// No description provided for @notifSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search notifications...'**
  String get notifSearchHint;

  /// No description provided for @sectionToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get sectionToday;

  /// No description provided for @sectionYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get sectionYesterday;

  /// No description provided for @notifEmptyInCategory.
  ///
  /// In en, this message translates to:
  /// **'No notifications in this category'**
  String get notifEmptyInCategory;

  /// No description provided for @notifFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get notifFilterAll;

  /// No description provided for @notifFilterUnread.
  ///
  /// In en, this message translates to:
  /// **'Unread'**
  String get notifFilterUnread;

  /// No description provided for @notifFilterOrders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get notifFilterOrders;

  /// No description provided for @notifFilterMaterials.
  ///
  /// In en, this message translates to:
  /// **'Materials'**
  String get notifFilterMaterials;

  /// No description provided for @notifFilterSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get notifFilterSystem;

  /// No description provided for @techSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search technicians... (name, role, task)'**
  String get techSearchHint;

  /// No description provided for @labTeamSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Lab Team'**
  String get labTeamSectionTitle;

  /// No description provided for @techScheduleTitle.
  ///
  /// In en, this message translates to:
  /// **'Work schedule'**
  String get techScheduleTitle;

  /// No description provided for @techScheduleEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit schedule'**
  String get techScheduleEdit;

  /// No description provided for @techPerfTitle.
  ///
  /// In en, this message translates to:
  /// **'Technician performance'**
  String get techPerfTitle;

  /// No description provided for @techPerfThisMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get techPerfThisMonth;

  /// No description provided for @techPerfAssigned.
  ///
  /// In en, this message translates to:
  /// **'Assigned'**
  String get techPerfAssigned;

  /// No description provided for @techPerfInProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get techPerfInProgress;

  /// No description provided for @techPerfCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get techPerfCompleted;

  /// No description provided for @techScheduleDayOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get techScheduleDayOff;

  /// No description provided for @techScheduleNeedOne.
  ///
  /// In en, this message translates to:
  /// **'Select at least one working day'**
  String get techScheduleNeedOne;

  /// No description provided for @techScheduleEndAfterStart.
  ///
  /// In en, this message translates to:
  /// **'End time must be after start time'**
  String get techScheduleEndAfterStart;

  /// No description provided for @techScheduleSaved.
  ///
  /// In en, this message translates to:
  /// **'Work schedule saved'**
  String get techScheduleSaved;

  /// No description provided for @daySaturday.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get daySaturday;

  /// No description provided for @daySunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get daySunday;

  /// No description provided for @dayMonday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get dayMonday;

  /// No description provided for @dayTuesday.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get dayTuesday;

  /// No description provided for @dayWednesday.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get dayWednesday;

  /// No description provided for @dayThursday.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get dayThursday;

  /// No description provided for @dayFriday.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get dayFriday;

  /// No description provided for @labTeamTotalChip.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get labTeamTotalChip;

  /// No description provided for @notifMarkAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get notifMarkAllRead;

  /// No description provided for @whNotifExpiry.
  ///
  /// In en, this message translates to:
  /// **'Expiry'**
  String get whNotifExpiry;

  /// No description provided for @whNotifExpiryDesc.
  ///
  /// In en, this message translates to:
  /// **'30 days before expiry'**
  String get whNotifExpiryDesc;

  /// No description provided for @whNotifNewSupply.
  ///
  /// In en, this message translates to:
  /// **'New supply orders'**
  String get whNotifNewSupply;

  /// No description provided for @whNotifNewSupplyDesc.
  ///
  /// In en, this message translates to:
  /// **'When an order arrives from the lab/clinic'**
  String get whNotifNewSupplyDesc;

  /// No description provided for @whNotifSupplierDelay.
  ///
  /// In en, this message translates to:
  /// **'Supplier delays'**
  String get whNotifSupplierDelay;

  /// No description provided for @whNotifSupplierDelayDesc.
  ///
  /// In en, this message translates to:
  /// **'When a supplier misses a delivery date'**
  String get whNotifSupplierDelayDesc;

  /// No description provided for @whNotifInvoicesDue.
  ///
  /// In en, this message translates to:
  /// **'Invoices pending payment'**
  String get whNotifInvoicesDue;

  /// No description provided for @whNotifInvoicesDueDesc.
  ///
  /// In en, this message translates to:
  /// **'Reminder before the due date'**
  String get whNotifInvoicesDueDesc;

  /// No description provided for @whOrderPartial.
  ///
  /// In en, this message translates to:
  /// **'Partial'**
  String get whOrderPartial;

  /// No description provided for @whOrderFulfilled.
  ///
  /// In en, this message translates to:
  /// **'Fulfilled'**
  String get whOrderFulfilled;

  /// No description provided for @whOrdersEmptyFilter.
  ///
  /// In en, this message translates to:
  /// **'No orders match this filter'**
  String get whOrdersEmptyFilter;

  /// No description provided for @whOrderRequesterParty.
  ///
  /// In en, this message translates to:
  /// **'Requesting party'**
  String get whOrderRequesterParty;

  /// No description provided for @colQuantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get colQuantity;

  /// No description provided for @profileGeneralInfo.
  ///
  /// In en, this message translates to:
  /// **'General Info'**
  String get profileGeneralInfo;

  /// No description provided for @profileHireDate.
  ///
  /// In en, this message translates to:
  /// **'Hire Date'**
  String get profileHireDate;

  /// No description provided for @profileLanguages.
  ///
  /// In en, this message translates to:
  /// **'Languages'**
  String get profileLanguages;

  /// No description provided for @profileAdminNotes.
  ///
  /// In en, this message translates to:
  /// **'Admin Notes'**
  String get profileAdminNotes;

  /// No description provided for @profileCompletion.
  ///
  /// In en, this message translates to:
  /// **'Profile Completion'**
  String get profileCompletion;

  /// No description provided for @profileEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get profileEdit;

  /// No description provided for @profileSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get profileSaving;

  /// No description provided for @profileSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get profileSaveChanges;

  /// No description provided for @profileChangePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change Profile Photo'**
  String get profileChangePhoto;

  /// No description provided for @profilePersonalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get profilePersonalInfo;

  /// No description provided for @profilePersonalInfoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Identity and contact details'**
  String get profilePersonalInfoSubtitle;

  /// No description provided for @profilePhone.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get profilePhone;

  /// No description provided for @profileSecondaryPhone.
  ///
  /// In en, this message translates to:
  /// **'Secondary Phone'**
  String get profileSecondaryPhone;

  /// No description provided for @profileMaritalStatus.
  ///
  /// In en, this message translates to:
  /// **'Marital Status'**
  String get profileMaritalStatus;

  /// No description provided for @profileSalary.
  ///
  /// In en, this message translates to:
  /// **'Salary'**
  String get profileSalary;

  /// No description provided for @profileEducations.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get profileEducations;

  /// No description provided for @profileExperiences.
  ///
  /// In en, this message translates to:
  /// **'Work Experience'**
  String get profileExperiences;

  /// No description provided for @profileTrainings.
  ///
  /// In en, this message translates to:
  /// **'Training Courses'**
  String get profileTrainings;

  /// No description provided for @profileSkills.
  ///
  /// In en, this message translates to:
  /// **'Skills'**
  String get profileSkills;

  /// No description provided for @profileOngoing.
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get profileOngoing;

  /// No description provided for @profilePickDate.
  ///
  /// In en, this message translates to:
  /// **'Pick a date'**
  String get profilePickDate;

  /// No description provided for @profileNationalId.
  ///
  /// In en, this message translates to:
  /// **'National ID'**
  String get profileNationalId;

  /// No description provided for @profileBirthDate.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get profileBirthDate;

  /// No description provided for @profileGender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get profileGender;

  /// No description provided for @profileAddress.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get profileAddress;

  /// No description provided for @profileWorkSchedule.
  ///
  /// In en, this message translates to:
  /// **'Work schedule'**
  String get profileWorkSchedule;

  /// No description provided for @show.
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get show;

  /// No description provided for @hide.
  ///
  /// In en, this message translates to:
  /// **'Hide'**
  String get hide;

  /// No description provided for @profileEmployeeId.
  ///
  /// In en, this message translates to:
  /// **'Employee ID'**
  String get profileEmployeeId;

  /// No description provided for @profileJobInfo.
  ///
  /// In en, this message translates to:
  /// **'Job Information'**
  String get profileJobInfo;

  /// No description provided for @profileJobInfoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Department, schedule and job title'**
  String get profileJobInfoSubtitle;

  /// No description provided for @profileDepartment.
  ///
  /// In en, this message translates to:
  /// **'Department'**
  String get profileDepartment;

  /// No description provided for @profileWorkDays.
  ///
  /// In en, this message translates to:
  /// **'Work Days'**
  String get profileWorkDays;

  /// No description provided for @profilePosition.
  ///
  /// In en, this message translates to:
  /// **'Job Title'**
  String get profilePosition;

  /// No description provided for @profileDayOff.
  ///
  /// In en, this message translates to:
  /// **'Weekly Day Off'**
  String get profileDayOff;

  /// No description provided for @profileWeeklyHours.
  ///
  /// In en, this message translates to:
  /// **'Weekly Work Hours'**
  String get profileWeeklyHours;

  /// No description provided for @profileSavedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Changes saved successfully'**
  String get profileSavedSuccess;

  /// No description provided for @profileSaveError.
  ///
  /// In en, this message translates to:
  /// **'Failed to save changes'**
  String get profileSaveError;

  /// No description provided for @profilePhotoUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile photo updated'**
  String get profilePhotoUpdated;

  /// No description provided for @profileLoadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load profile'**
  String get profileLoadError;

  /// No description provided for @roleEmployee.
  ///
  /// In en, this message translates to:
  /// **'Employee'**
  String get roleEmployee;

  /// No description provided for @profileStatCompletedOrders.
  ///
  /// In en, this message translates to:
  /// **'Completed Orders'**
  String get profileStatCompletedOrders;

  /// No description provided for @profileBadgeThisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get profileBadgeThisMonth;

  /// No description provided for @profileBadgeAverage.
  ///
  /// In en, this message translates to:
  /// **'Average'**
  String get profileBadgeAverage;

  /// No description provided for @profileStatMovementsThisMonth.
  ///
  /// In en, this message translates to:
  /// **'Movements This Month'**
  String get profileStatMovementsThisMonth;

  /// No description provided for @profileStatLowItems.
  ///
  /// In en, this message translates to:
  /// **'Low Stock Items'**
  String get profileStatLowItems;

  /// No description provided for @profileStatStockAccuracy.
  ///
  /// In en, this message translates to:
  /// **'Stock Accuracy'**
  String get profileStatStockAccuracy;

  /// No description provided for @profileBadgeAlert.
  ///
  /// In en, this message translates to:
  /// **'Alert'**
  String get profileBadgeAlert;

  /// No description provided for @profilePhotoError.
  ///
  /// In en, this message translates to:
  /// **'Failed to pick image: {error}'**
  String profilePhotoError(Object error);

  /// No description provided for @ordersFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get ordersFilterAll;

  /// No description provided for @ordersUrgent.
  ///
  /// In en, this message translates to:
  /// **'Urgent'**
  String get ordersUrgent;

  /// No description provided for @ordersStatusNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get ordersStatusNew;

  /// No description provided for @ordersStatusPartial.
  ///
  /// In en, this message translates to:
  /// **'Partial'**
  String get ordersStatusPartial;

  /// No description provided for @ordersStatusFulfilled.
  ///
  /// In en, this message translates to:
  /// **'Fulfilled'**
  String get ordersStatusFulfilled;

  /// No description provided for @whReqStatusNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get whReqStatusNew;

  /// No description provided for @whReqStatusInProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get whReqStatusInProgress;

  /// No description provided for @whReqStatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Fulfilled'**
  String get whReqStatusCompleted;

  /// No description provided for @whReqStatusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get whReqStatusRejected;

  /// No description provided for @whReqStatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get whReqStatusCancelled;

  /// No description provided for @whReqMarkPending.
  ///
  /// In en, this message translates to:
  /// **'Start processing'**
  String get whReqMarkPending;

  /// No description provided for @whReqRequester.
  ///
  /// In en, this message translates to:
  /// **'Requester'**
  String get whReqRequester;

  /// No description provided for @whReqItems.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get whReqItems;

  /// No description provided for @whReqExistingMaterials.
  ///
  /// In en, this message translates to:
  /// **'Catalog materials'**
  String get whReqExistingMaterials;

  /// No description provided for @whReqNewMaterials.
  ///
  /// In en, this message translates to:
  /// **'Proposed new materials'**
  String get whReqNewMaterials;

  /// No description provided for @whReqQtyRequested.
  ///
  /// In en, this message translates to:
  /// **'Requested'**
  String get whReqQtyRequested;

  /// No description provided for @whReqFulfill.
  ///
  /// In en, this message translates to:
  /// **'Fulfill'**
  String get whReqFulfill;

  /// No description provided for @whReqReject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get whReqReject;

  /// No description provided for @whReqViewDetails.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get whReqViewDetails;

  /// No description provided for @whReqDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Request details'**
  String get whReqDetailsTitle;

  /// No description provided for @whReqRejectTitle.
  ///
  /// In en, this message translates to:
  /// **'Reject request'**
  String get whReqRejectTitle;

  /// No description provided for @whReqRejectReason.
  ///
  /// In en, this message translates to:
  /// **'Rejection reason'**
  String get whReqRejectReason;

  /// No description provided for @whReqRejectReasonHint.
  ///
  /// In en, this message translates to:
  /// **'Write the reason for rejection…'**
  String get whReqRejectReasonHint;

  /// No description provided for @whReqFulfillConfirm.
  ///
  /// In en, this message translates to:
  /// **'The requested quantities will be deducted from stock batches (FIFO). Confirm fulfillment?'**
  String get whReqFulfillConfirm;

  /// No description provided for @whReqNotesHint.
  ///
  /// In en, this message translates to:
  /// **'Notes (optional)'**
  String get whReqNotesHint;

  /// No description provided for @whReqNumber.
  ///
  /// In en, this message translates to:
  /// **'Request #{id}'**
  String whReqNumber(String id);

  /// No description provided for @whReqItemsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} item(s)'**
  String whReqItemsCount(int count);

  /// No description provided for @ordersQuantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get ordersQuantity;

  /// No description provided for @ordersRequester.
  ///
  /// In en, this message translates to:
  /// **'Requester'**
  String get ordersRequester;

  /// No description provided for @ordersDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get ordersDate;

  /// No description provided for @ordersView.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get ordersView;

  /// No description provided for @ordersSupply.
  ///
  /// In en, this message translates to:
  /// **'Supply'**
  String get ordersSupply;

  /// No description provided for @ordersEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No Orders'**
  String get ordersEmptyTitle;

  /// No description provided for @ordersEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'No orders match the current filter'**
  String get ordersEmptyMessage;

  /// No description provided for @ordersSupplyConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Supply confirmed for {material} (order {order})'**
  String ordersSupplyConfirmed(Object material, Object order);

  /// No description provided for @ordersCountSummary.
  ///
  /// In en, this message translates to:
  /// **'{count} orders of {total}'**
  String ordersCountSummary(Object count, Object total);

  /// No description provided for @orderDetailsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Details of the materials order sent to the warehouse'**
  String get orderDetailsSubtitle;

  /// No description provided for @orderDetailsInfoSection.
  ///
  /// In en, this message translates to:
  /// **'Order Information'**
  String get orderDetailsInfoSection;

  /// No description provided for @orderDetailsItems.
  ///
  /// In en, this message translates to:
  /// **'Order Items'**
  String get orderDetailsItems;

  /// No description provided for @orderDetailsProgressSection.
  ///
  /// In en, this message translates to:
  /// **'Supply Progress'**
  String get orderDetailsProgressSection;

  /// No description provided for @orderDetailsNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get orderDetailsNotes;

  /// No description provided for @orderDetailsModifications.
  ///
  /// In en, this message translates to:
  /// **'Modification requests'**
  String get orderDetailsModifications;

  /// No description provided for @orderDetailsStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Order Status'**
  String get orderDetailsStatusLabel;

  /// No description provided for @orderDetailsOrderDate.
  ///
  /// In en, this message translates to:
  /// **'Order Date'**
  String get orderDetailsOrderDate;

  /// No description provided for @orderDetailsRequestData.
  ///
  /// In en, this message translates to:
  /// **'Order Data'**
  String get orderDetailsRequestData;

  /// No description provided for @orderDetailsMaterial.
  ///
  /// In en, this message translates to:
  /// **'Material'**
  String get orderDetailsMaterial;

  /// No description provided for @orderDetailsPriority.
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get orderDetailsPriority;

  /// No description provided for @orderDetailsNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get orderDetailsNormal;

  /// No description provided for @orderDetailsRequesterData.
  ///
  /// In en, this message translates to:
  /// **'Requester Data'**
  String get orderDetailsRequesterData;

  /// No description provided for @orderDetailsParty.
  ///
  /// In en, this message translates to:
  /// **'Party'**
  String get orderDetailsParty;

  /// No description provided for @orderDetailsResponsible.
  ///
  /// In en, this message translates to:
  /// **'Responsible'**
  String get orderDetailsResponsible;

  /// No description provided for @orderDetailsRequestNumber.
  ///
  /// In en, this message translates to:
  /// **'Order Number'**
  String get orderDetailsRequestNumber;

  /// No description provided for @orderTimelineReceived.
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get orderTimelineReceived;

  /// No description provided for @orderTimelinePartial.
  ///
  /// In en, this message translates to:
  /// **'Partial Supply'**
  String get orderTimelinePartial;

  /// No description provided for @orderDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Supply Order Details {req}'**
  String orderDetailsTitle(Object req);

  /// No description provided for @notifEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No Notifications'**
  String get notifEmptyTitle;

  /// No description provided for @notifEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'No notifications to show in this filter'**
  String get notifEmptyMessage;

  /// No description provided for @notifGroupToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get notifGroupToday;

  /// No description provided for @notifGroupYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get notifGroupYesterday;

  /// No description provided for @notifGroupOlder.
  ///
  /// In en, this message translates to:
  /// **'Older'**
  String get notifGroupOlder;

  /// No description provided for @notifBadgeOrder.
  ///
  /// In en, this message translates to:
  /// **'Order'**
  String get notifBadgeOrder;

  /// No description provided for @notifBadgeDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get notifBadgeDone;

  /// No description provided for @reportRangeDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get reportRangeDaily;

  /// No description provided for @reportRangeWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get reportRangeWeekly;

  /// No description provided for @reportRangeMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get reportRangeMonthly;

  /// No description provided for @reportRangeYearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get reportRangeYearly;

  /// No description provided for @reportSuppliersPerf.
  ///
  /// In en, this message translates to:
  /// **'Suppliers Performance'**
  String get reportSuppliersPerf;

  /// No description provided for @reportTopMaterials.
  ///
  /// In en, this message translates to:
  /// **'Most Consumed Materials'**
  String get reportTopMaterials;

  /// No description provided for @reportFullReport.
  ///
  /// In en, this message translates to:
  /// **'Full Report'**
  String get reportFullReport;

  /// No description provided for @reportExportPdf.
  ///
  /// In en, this message translates to:
  /// **'Export PDF'**
  String get reportExportPdf;

  /// No description provided for @reportExportExcel.
  ///
  /// In en, this message translates to:
  /// **'Export Excel'**
  String get reportExportExcel;

  /// No description provided for @reportStatAvgSupplyTime.
  ///
  /// In en, this message translates to:
  /// **'Avg Supply Time'**
  String get reportStatAvgSupplyTime;

  /// No description provided for @reportStatSupplyRate.
  ///
  /// In en, this message translates to:
  /// **'Supply Rate'**
  String get reportStatSupplyRate;

  /// No description provided for @reportStatConsumed.
  ///
  /// In en, this message translates to:
  /// **'Materials Consumed'**
  String get reportStatConsumed;

  /// No description provided for @whReportByCategory.
  ///
  /// In en, this message translates to:
  /// **'Consumption by Category'**
  String get whReportByCategory;

  /// No description provided for @whReportActivityByDay.
  ///
  /// In en, this message translates to:
  /// **'Activity by Day'**
  String get whReportActivityByDay;

  /// No description provided for @whReportMockNote.
  ///
  /// In en, this message translates to:
  /// **'Demo data — will be wired when backend is ready'**
  String get whReportMockNote;

  /// No description provided for @whReportPurchasesTitle.
  ///
  /// In en, this message translates to:
  /// **'Purchases report'**
  String get whReportPurchasesTitle;

  /// No description provided for @whReportStatInvoices.
  ///
  /// In en, this message translates to:
  /// **'Invoices'**
  String get whReportStatInvoices;

  /// No description provided for @whReportStatSpending.
  ///
  /// In en, this message translates to:
  /// **'Total spending (SYP)'**
  String get whReportStatSpending;

  /// No description provided for @whReportStatAvgInvoice.
  ///
  /// In en, this message translates to:
  /// **'Avg invoice (SYP)'**
  String get whReportStatAvgInvoice;

  /// No description provided for @whReportStatSuppliers.
  ///
  /// In en, this message translates to:
  /// **'Suppliers'**
  String get whReportStatSuppliers;

  /// No description provided for @whReportBySupplier.
  ///
  /// In en, this message translates to:
  /// **'Spending by supplier'**
  String get whReportBySupplier;

  /// No description provided for @whReportByMonth.
  ///
  /// In en, this message translates to:
  /// **'Monthly spending'**
  String get whReportByMonth;

  /// No description provided for @whReportTypePurchases.
  ///
  /// In en, this message translates to:
  /// **'Purchases'**
  String get whReportTypePurchases;

  /// No description provided for @whReportTypeStockMovement.
  ///
  /// In en, this message translates to:
  /// **'Stock Movement'**
  String get whReportTypeStockMovement;

  /// No description provided for @whReportTypeMaterialRequests.
  ///
  /// In en, this message translates to:
  /// **'Material Requests'**
  String get whReportTypeMaterialRequests;

  /// No description provided for @whReportStockMovementTitle.
  ///
  /// In en, this message translates to:
  /// **'Stock Movement Report'**
  String get whReportStockMovementTitle;

  /// No description provided for @whReportStatIncoming.
  ///
  /// In en, this message translates to:
  /// **'Total Incoming'**
  String get whReportStatIncoming;

  /// No description provided for @whReportStatOutgoing.
  ///
  /// In en, this message translates to:
  /// **'Total Outgoing'**
  String get whReportStatOutgoing;

  /// No description provided for @whReportStatMovements.
  ///
  /// In en, this message translates to:
  /// **'Movements Count'**
  String get whReportStatMovements;

  /// No description provided for @whReportIncomingVsOutgoing.
  ///
  /// In en, this message translates to:
  /// **'Incoming vs Outgoing'**
  String get whReportIncomingVsOutgoing;

  /// No description provided for @whReportIncoming.
  ///
  /// In en, this message translates to:
  /// **'Incoming'**
  String get whReportIncoming;

  /// No description provided for @whReportOutgoing.
  ///
  /// In en, this message translates to:
  /// **'Outgoing'**
  String get whReportOutgoing;

  /// No description provided for @whReportMovementsByDay.
  ///
  /// In en, this message translates to:
  /// **'Movements by Day'**
  String get whReportMovementsByDay;

  /// No description provided for @whReportMaterialRequestsTitle.
  ///
  /// In en, this message translates to:
  /// **'Material Requests Report'**
  String get whReportMaterialRequestsTitle;

  /// No description provided for @whReportStatTotalRequests.
  ///
  /// In en, this message translates to:
  /// **'Total Requests'**
  String get whReportStatTotalRequests;

  /// No description provided for @whReportStatFulfilled.
  ///
  /// In en, this message translates to:
  /// **'Fulfilled Requests'**
  String get whReportStatFulfilled;

  /// No description provided for @whReportStatRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected Requests'**
  String get whReportStatRejected;

  /// No description provided for @whReportStatFulfillmentRate.
  ///
  /// In en, this message translates to:
  /// **'Fulfillment Rate'**
  String get whReportStatFulfillmentRate;

  /// No description provided for @whReportByRequester.
  ///
  /// In en, this message translates to:
  /// **'By Requester'**
  String get whReportByRequester;

  /// No description provided for @whReportRequestsByDay.
  ///
  /// In en, this message translates to:
  /// **'Requests by Day'**
  String get whReportRequestsByDay;

  /// No description provided for @whReportTypeOverview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get whReportTypeOverview;

  /// No description provided for @whReportOverviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Overview Report'**
  String get whReportOverviewTitle;

  /// No description provided for @whReportStatTotalConsumption.
  ///
  /// In en, this message translates to:
  /// **'Total consumption'**
  String get whReportStatTotalConsumption;

  /// No description provided for @whReportStatTopConsumed.
  ///
  /// In en, this message translates to:
  /// **'Top consumed'**
  String get whReportStatTopConsumed;

  /// No description provided for @whReportStatActiveDays.
  ///
  /// In en, this message translates to:
  /// **'Active days'**
  String get whReportStatActiveDays;

  /// No description provided for @whReportTopCompanies.
  ///
  /// In en, this message translates to:
  /// **'Top supplying companies'**
  String get whReportTopCompanies;

  /// No description provided for @reportStatTotalMaterials.
  ///
  /// In en, this message translates to:
  /// **'Total Materials'**
  String get reportStatTotalMaterials;

  /// No description provided for @reportUnitDay.
  ///
  /// In en, this message translates to:
  /// **'day'**
  String get reportUnitDay;

  /// No description provided for @reportConsumptionByCategory.
  ///
  /// In en, this message translates to:
  /// **'Consumption by Category'**
  String get reportConsumptionByCategory;

  /// No description provided for @reportOfConsumption.
  ///
  /// In en, this message translates to:
  /// **'of consumption'**
  String get reportOfConsumption;

  /// No description provided for @reportSupplyByDays.
  ///
  /// In en, this message translates to:
  /// **'Supply orders across the month'**
  String get reportSupplyByDays;

  /// No description provided for @reportLess.
  ///
  /// In en, this message translates to:
  /// **'Less'**
  String get reportLess;

  /// No description provided for @reportMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get reportMore;

  /// No description provided for @reportWeekdaySun.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get reportWeekdaySun;

  /// No description provided for @reportWeekdayMon.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get reportWeekdayMon;

  /// No description provided for @reportWeekdayTue.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get reportWeekdayTue;

  /// No description provided for @reportWeekdayWed.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get reportWeekdayWed;

  /// No description provided for @reportWeekdayThu.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get reportWeekdayThu;

  /// No description provided for @reportWeekdayFri.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get reportWeekdayFri;

  /// No description provided for @reportWeekdaySat.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get reportWeekdaySat;

  /// No description provided for @reportMonthlyTitle.
  ///
  /// In en, this message translates to:
  /// **'{period} — Monthly Report'**
  String reportMonthlyTitle(Object period);

  /// No description provided for @reportGeneratedAt.
  ///
  /// In en, this message translates to:
  /// **'Report generated {date}'**
  String reportGeneratedAt(Object date);

  /// No description provided for @reportDaysCount.
  ///
  /// In en, this message translates to:
  /// **'{days} days'**
  String reportDaysCount(Object days);

  /// No description provided for @reportSupplierSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{invoices} invoices · avg {avgDays} days'**
  String reportSupplierSubtitle(Object invoices, Object avgDays);

  /// No description provided for @whBadgeTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get whBadgeTotal;

  /// No description provided for @whStatOutMaterials.
  ///
  /// In en, this message translates to:
  /// **'Out of Stock'**
  String get whStatOutMaterials;

  /// No description provided for @whStatLowMaterials.
  ///
  /// In en, this message translates to:
  /// **'Low Stock'**
  String get whStatLowMaterials;

  /// No description provided for @whStatAvailMaterials.
  ///
  /// In en, this message translates to:
  /// **'Available Materials'**
  String get whStatAvailMaterials;

  /// No description provided for @whStatTotalMaterials.
  ///
  /// In en, this message translates to:
  /// **'Materials in Warehouse'**
  String get whStatTotalMaterials;

  /// No description provided for @whMaterialsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No Materials'**
  String get whMaterialsEmptyTitle;

  /// No description provided for @whMaterialsEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'No materials match the current filters'**
  String get whMaterialsEmptyMessage;

  /// No description provided for @whColCode.
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get whColCode;

  /// No description provided for @whColName.
  ///
  /// In en, this message translates to:
  /// **'Material Name'**
  String get whColName;

  /// No description provided for @whColCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get whColCategory;

  /// No description provided for @whColStock.
  ///
  /// In en, this message translates to:
  /// **'Stock'**
  String get whColStock;

  /// No description provided for @whColMinStock.
  ///
  /// In en, this message translates to:
  /// **'Min Stock'**
  String get whColMinStock;

  /// No description provided for @whColExpiry.
  ///
  /// In en, this message translates to:
  /// **'Expiry'**
  String get whColExpiry;

  /// No description provided for @whColSupplier.
  ///
  /// In en, this message translates to:
  /// **'Supplier'**
  String get whColSupplier;

  /// No description provided for @whColPrice.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get whColPrice;

  /// No description provided for @whColCompany.
  ///
  /// In en, this message translates to:
  /// **'Company'**
  String get whColCompany;

  /// No description provided for @whColDosage.
  ///
  /// In en, this message translates to:
  /// **'Dosage'**
  String get whColDosage;

  /// No description provided for @whColBatches.
  ///
  /// In en, this message translates to:
  /// **'Batches'**
  String get whColBatches;

  /// No description provided for @whColStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get whColStatus;

  /// No description provided for @whMaterialsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} materials of {total}'**
  String whMaterialsCount(Object count, Object total);

  /// No description provided for @invStatusPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get invStatusPaid;

  /// No description provided for @invStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get invStatusPending;

  /// No description provided for @invEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No Invoices'**
  String get invEmptyTitle;

  /// No description provided for @invEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'No invoices match the current filter'**
  String get invEmptyMessage;

  /// No description provided for @invPurchaseInvoices.
  ///
  /// In en, this message translates to:
  /// **'Purchase Invoices'**
  String get invPurchaseInvoices;

  /// No description provided for @invAddInvoice.
  ///
  /// In en, this message translates to:
  /// **'Add Invoice'**
  String get invAddInvoice;

  /// No description provided for @invBadgePaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get invBadgePaid;

  /// No description provided for @invBadgePending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get invBadgePending;

  /// No description provided for @invBadgeTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get invBadgeTotal;

  /// No description provided for @invStatThisMonth.
  ///
  /// In en, this message translates to:
  /// **'invoices this month'**
  String get invStatThisMonth;

  /// No description provided for @invStatPaidTotal.
  ///
  /// In en, this message translates to:
  /// **'Total Paid'**
  String get invStatPaidTotal;

  /// No description provided for @invStatPendingPay.
  ///
  /// In en, this message translates to:
  /// **'Awaiting Payment'**
  String get invStatPendingPay;

  /// No description provided for @invStatTotalPurchases.
  ///
  /// In en, this message translates to:
  /// **'Total Purchases'**
  String get invStatTotalPurchases;

  /// No description provided for @invColNumber.
  ///
  /// In en, this message translates to:
  /// **'Invoice Number'**
  String get invColNumber;

  /// No description provided for @invColItemCount.
  ///
  /// In en, this message translates to:
  /// **'Item Count'**
  String get invColItemCount;

  /// No description provided for @invColTotalSyp.
  ///
  /// In en, this message translates to:
  /// **'Total (SYP)'**
  String get invColTotalSyp;

  /// No description provided for @invSupplierLabel.
  ///
  /// In en, this message translates to:
  /// **'Supplier'**
  String get invSupplierLabel;

  /// No description provided for @invDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Invoice details'**
  String get invDetailsTitle;

  /// No description provided for @invUnitPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Unit price'**
  String get invUnitPriceLabel;

  /// No description provided for @invLineTotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get invLineTotalLabel;

  /// No description provided for @invCreatedByLabel.
  ///
  /// In en, this message translates to:
  /// **'Created by'**
  String get invCreatedByLabel;

  /// No description provided for @invGrandTotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Total purchases (SYP)'**
  String get invGrandTotalLabel;

  /// No description provided for @invInvoiceNumber.
  ///
  /// In en, this message translates to:
  /// **'Invoice #{id}'**
  String invInvoiceNumber(String id);

  /// No description provided for @invItemsCountLabel.
  ///
  /// In en, this message translates to:
  /// **'{count} material(s)'**
  String invItemsCountLabel(int count);

  /// No description provided for @invCount.
  ///
  /// In en, this message translates to:
  /// **'{count} invoices of {total}'**
  String invCount(Object count, Object total);

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get fieldRequired;

  /// No description provided for @fieldOptional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get fieldOptional;

  /// No description provided for @fieldInvalidNumber.
  ///
  /// In en, this message translates to:
  /// **'Invalid number'**
  String get fieldInvalidNumber;

  /// No description provided for @fieldInvalidAmount.
  ///
  /// In en, this message translates to:
  /// **'Invalid amount'**
  String get fieldInvalidAmount;

  /// No description provided for @fieldWriteOrPick.
  ///
  /// In en, this message translates to:
  /// **'Type or pick from the list...'**
  String get fieldWriteOrPick;

  /// No description provided for @invFormTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Purchase Invoice'**
  String get invFormTitle;

  /// No description provided for @invFormSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Fill in the new invoice details'**
  String get invFormSubtitle;

  /// No description provided for @invFormSupplier.
  ///
  /// In en, this message translates to:
  /// **'Supplier'**
  String get invFormSupplier;

  /// No description provided for @invFormSupplierHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Medical Supplies Co.'**
  String get invFormSupplierHint;

  /// No description provided for @invFormDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get invFormDate;

  /// No description provided for @invFormNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get invFormNotes;

  /// No description provided for @invFormSave.
  ///
  /// In en, this message translates to:
  /// **'Save Invoice'**
  String get invFormSave;

  /// No description provided for @invFormItemsTitle.
  ///
  /// In en, this message translates to:
  /// **'Invoice Items'**
  String get invFormItemsTitle;

  /// No description provided for @invFormAddItem.
  ///
  /// In en, this message translates to:
  /// **'Add Material'**
  String get invFormAddItem;

  /// No description provided for @invFormMaterialLabel.
  ///
  /// In en, this message translates to:
  /// **'Material'**
  String get invFormMaterialLabel;

  /// No description provided for @invFormMaterialHint.
  ///
  /// In en, this message translates to:
  /// **'Choose a material'**
  String get invFormMaterialHint;

  /// No description provided for @invFormQuantityLabel.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get invFormQuantityLabel;

  /// No description provided for @invFormItemsRequired.
  ///
  /// In en, this message translates to:
  /// **'Add at least one material'**
  String get invFormItemsRequired;

  /// No description provided for @invFormQuantityInvalid.
  ///
  /// In en, this message translates to:
  /// **'Quantity must be greater than zero'**
  String get invFormQuantityInvalid;

  /// No description provided for @invFormItemsLockedNotice.
  ///
  /// In en, this message translates to:
  /// **'Items can\'t be edited after the invoice is created'**
  String get invFormItemsLockedNotice;

  /// No description provided for @invCreateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Invoice created successfully'**
  String get invCreateSuccess;

  /// No description provided for @invUpdateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Invoice updated successfully'**
  String get invUpdateSuccess;

  /// No description provided for @whGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hello, {name}'**
  String whGreeting(String name);

  /// No description provided for @whLastUpdateLabel.
  ///
  /// In en, this message translates to:
  /// **'Last update: '**
  String get whLastUpdateLabel;

  /// No description provided for @whLastUpdateJustNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get whLastUpdateJustNow;

  /// No description provided for @whLastUpdateMinutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{minutes}m ago'**
  String whLastUpdateMinutesAgo(int minutes);

  /// No description provided for @whLastUpdateHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{hours}h ago'**
  String whLastUpdateHoursAgo(int hours);

  /// No description provided for @whMiniExpiringSoon.
  ///
  /// In en, this message translates to:
  /// **'Expiring soon'**
  String get whMiniExpiringSoon;

  /// No description provided for @whTotalMaterials.
  ///
  /// In en, this message translates to:
  /// **'Total materials'**
  String get whTotalMaterials;

  /// No description provided for @whMiniOrdersToday.
  ///
  /// In en, this message translates to:
  /// **'Today\'s orders'**
  String get whMiniOrdersToday;

  /// No description provided for @whSupplyRate.
  ///
  /// In en, this message translates to:
  /// **'Supply rate'**
  String get whSupplyRate;

  /// No description provided for @whStatLowStockShort.
  ///
  /// In en, this message translates to:
  /// **'Low-stock materials'**
  String get whStatLowStockShort;

  /// No description provided for @whStatPendingSupply.
  ///
  /// In en, this message translates to:
  /// **'Orders awaiting supply'**
  String get whStatPendingSupply;

  /// No description provided for @whStatMonthPurchases.
  ///
  /// In en, this message translates to:
  /// **'Month purchases (SYP)'**
  String get whStatMonthPurchases;

  /// No description provided for @whStatExpiredBatches.
  ///
  /// In en, this message translates to:
  /// **'Expired batches'**
  String get whStatExpiredBatches;

  /// No description provided for @whStatStockValue.
  ///
  /// In en, this message translates to:
  /// **'Stock value (SYP)'**
  String get whStatStockValue;

  /// No description provided for @whBadgeAlert.
  ///
  /// In en, this message translates to:
  /// **'Alert'**
  String get whBadgeAlert;

  /// No description provided for @whBadgeNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get whBadgeNew;

  /// No description provided for @whBadgeThisMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get whBadgeThisMonth;

  /// No description provided for @whNeedsSupply.
  ///
  /// In en, this message translates to:
  /// **'Needs supply'**
  String get whNeedsSupply;

  /// No description provided for @whTrendThisWeek.
  ///
  /// In en, this message translates to:
  /// **'{count} this week'**
  String whTrendThisWeek(String count);

  /// No description provided for @whTrendToday.
  ///
  /// In en, this message translates to:
  /// **'{count} today'**
  String whTrendToday(String count);

  /// No description provided for @whTrendVsLastMonth.
  ///
  /// In en, this message translates to:
  /// **'{value} from last month'**
  String whTrendVsLastMonth(String value);

  /// No description provided for @whExpiringTitle.
  ///
  /// In en, this message translates to:
  /// **'Materials expiring soon'**
  String get whExpiringTitle;

  /// No description provided for @whExpiringSubtitle.
  ///
  /// In en, this message translates to:
  /// **'These materials must be handled before they expire'**
  String get whExpiringSubtitle;

  /// No description provided for @whTodayOrdersCount.
  ///
  /// In en, this message translates to:
  /// **'{count} orders'**
  String whTodayOrdersCount(Object count);

  /// No description provided for @whRecentOrdersTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent Orders'**
  String get whRecentOrdersTitle;

  /// No description provided for @whInvMostRequestedTitle.
  ///
  /// In en, this message translates to:
  /// **'Most Requested'**
  String get whInvMostRequestedTitle;

  /// No description provided for @whInvLowStockTitle.
  ///
  /// In en, this message translates to:
  /// **'Low Stock'**
  String get whInvLowStockTitle;

  /// No description provided for @whInvNoItems.
  ///
  /// In en, this message translates to:
  /// **'No items right now'**
  String get whInvNoItems;

  /// No description provided for @whInvDaysRemaining.
  ///
  /// In en, this message translates to:
  /// **'{days} days'**
  String whInvDaysRemaining(int days);

  /// No description provided for @labNotifActionOpenOrder.
  ///
  /// In en, this message translates to:
  /// **'Open order'**
  String get labNotifActionOpenOrder;

  /// No description provided for @labNotifActionReview.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get labNotifActionReview;

  /// No description provided for @labActionTrack.
  ///
  /// In en, this message translates to:
  /// **'Track'**
  String get labActionTrack;

  /// No description provided for @labReqStatusUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get labReqStatusUnavailable;

  /// No description provided for @labReqStatusInProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get labReqStatusInProgress;

  /// No description provided for @labReqRequestedBy.
  ///
  /// In en, this message translates to:
  /// **'Requested by'**
  String get labReqRequestedBy;

  /// No description provided for @labReqLabOrder.
  ///
  /// In en, this message translates to:
  /// **'Lab order'**
  String get labReqLabOrder;

  /// No description provided for @labReqEmptyCategory.
  ///
  /// In en, this message translates to:
  /// **'No invoices in this category'**
  String get labReqEmptyCategory;

  /// No description provided for @labReqNewRequest.
  ///
  /// In en, this message translates to:
  /// **'New invoice'**
  String get labReqNewRequest;

  /// No description provided for @labReqSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Filter invoices... (material, id, company)'**
  String get labReqSearchHint;

  /// No description provided for @labReqMaterialPickHint.
  ///
  /// In en, this message translates to:
  /// **'Type to search warehouse materials or enter a new one'**
  String get labReqMaterialPickHint;

  /// No description provided for @labReqDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete invoice'**
  String get labReqDeleteTitle;

  /// No description provided for @labReqDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete invoice #{id}? This cannot be undone.'**
  String labReqDeleteConfirm(String id);

  /// No description provided for @labReqFieldMaterial.
  ///
  /// In en, this message translates to:
  /// **'Material name'**
  String get labReqFieldMaterial;

  /// No description provided for @labReqFieldUnit.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get labReqFieldUnit;

  /// No description provided for @labReqFieldCompany.
  ///
  /// In en, this message translates to:
  /// **'Company name'**
  String get labReqFieldCompany;

  /// No description provided for @labReqFieldReason.
  ///
  /// In en, this message translates to:
  /// **'Request reason'**
  String get labReqFieldReason;

  /// No description provided for @labReqReasonHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. new material not available in the warehouse'**
  String get labReqReasonHint;

  /// No description provided for @labReqMaterialRequired.
  ///
  /// In en, this message translates to:
  /// **'Material name is required'**
  String get labReqMaterialRequired;

  /// No description provided for @labReqQuantityRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid quantity'**
  String get labReqQuantityRequired;

  /// No description provided for @labReqSubmit.
  ///
  /// In en, this message translates to:
  /// **'Send request'**
  String get labReqSubmit;

  /// No description provided for @labReqSentSuccess.
  ///
  /// In en, this message translates to:
  /// **'Invoice sent to the warehouse'**
  String get labReqSentSuccess;

  /// No description provided for @labReqChooseTypeTitle.
  ///
  /// In en, this message translates to:
  /// **'Invoice type'**
  String get labReqChooseTypeTitle;

  /// No description provided for @labReqFromWarehouseTitle.
  ///
  /// In en, this message translates to:
  /// **'From warehouse materials'**
  String get labReqFromWarehouseTitle;

  /// No description provided for @labReqFromWarehouseDesc.
  ///
  /// In en, this message translates to:
  /// **'Choose materials already in the warehouse stock'**
  String get labReqFromWarehouseDesc;

  /// No description provided for @labReqFromCompanyTitle.
  ///
  /// In en, this message translates to:
  /// **'From a company (new material)'**
  String get labReqFromCompanyTitle;

  /// No description provided for @labReqFromCompanyDesc.
  ///
  /// In en, this message translates to:
  /// **'Materials not in the warehouse — requested from an external company'**
  String get labReqFromCompanyDesc;

  /// No description provided for @labReqSearchMaterialHint.
  ///
  /// In en, this message translates to:
  /// **'Search by material name...'**
  String get labReqSearchMaterialHint;

  /// No description provided for @labReqAddToInvoice.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get labReqAddToInvoice;

  /// No description provided for @labReqInvoiceItemsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No materials added yet'**
  String get labReqInvoiceItemsEmpty;

  /// No description provided for @labReqAddMaterialRow.
  ///
  /// In en, this message translates to:
  /// **'+ Add material'**
  String get labReqAddMaterialRow;

  /// No description provided for @labReqRemoveRow.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get labReqRemoveRow;

  /// No description provided for @labReqCompanyNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Company name is required'**
  String get labReqCompanyNameRequired;

  /// No description provided for @labReqAtLeastOneItemRequired.
  ///
  /// In en, this message translates to:
  /// **'Add at least one material'**
  String get labReqAtLeastOneItemRequired;

  /// No description provided for @labReqNotesOptional.
  ///
  /// In en, this message translates to:
  /// **'Notes (optional)'**
  String get labReqNotesOptional;

  /// No description provided for @labReqCatalogLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load warehouse materials'**
  String get labReqCatalogLoadFailed;

  /// No description provided for @labReqCatalogRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get labReqCatalogRetry;

  /// No description provided for @labReqItemsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} materials'**
  String labReqItemsCount(int count);

  /// No description provided for @labReqTypeWarehouse.
  ///
  /// In en, this message translates to:
  /// **'From warehouse'**
  String get labReqTypeWarehouse;

  /// No description provided for @labReqTypeCompany.
  ///
  /// In en, this message translates to:
  /// **'From company'**
  String get labReqTypeCompany;

  /// No description provided for @labReqInvoiceNumber.
  ///
  /// In en, this message translates to:
  /// **'Invoice #{id}'**
  String labReqInvoiceNumber(String id);

  /// No description provided for @labReqDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Invoice details'**
  String get labReqDetailsTitle;

  /// No description provided for @labReqPrint.
  ///
  /// In en, this message translates to:
  /// **'Print'**
  String get labReqPrint;

  /// No description provided for @labReqQuantityColumn.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get labReqQuantityColumn;

  /// No description provided for @labReqUnitColumn.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get labReqUnitColumn;

  /// No description provided for @labReqCompanyColumn.
  ///
  /// In en, this message translates to:
  /// **'Company'**
  String get labReqCompanyColumn;

  /// No description provided for @labTechPendingAssign.
  ///
  /// In en, this message translates to:
  /// **'Awaiting assignment'**
  String get labTechPendingAssign;

  /// No description provided for @labTechWorkloadLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load technicians\' current workload — names and schedules are accurate, but task counts may not reflect reality'**
  String get labTechWorkloadLoadFailed;

  /// No description provided for @techAddButton.
  ///
  /// In en, this message translates to:
  /// **'Add technician'**
  String get techAddButton;

  /// No description provided for @techAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add new technician'**
  String get techAddTitle;

  /// No description provided for @techAddSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the technician\'s details to join the lab team'**
  String get techAddSubtitle;

  /// No description provided for @techSectionBasic.
  ///
  /// In en, this message translates to:
  /// **'Basic information'**
  String get techSectionBasic;

  /// No description provided for @techFieldFullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get techFieldFullName;

  /// No description provided for @techFieldFullNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Mohammad Ali'**
  String get techFieldFullNameHint;

  /// No description provided for @techFieldRole.
  ///
  /// In en, this message translates to:
  /// **'Role / Specialty'**
  String get techFieldRole;

  /// No description provided for @techFieldPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone number (optional)'**
  String get techFieldPhone;

  /// No description provided for @techFieldShiftStart.
  ///
  /// In en, this message translates to:
  /// **'Shift start'**
  String get techFieldShiftStart;

  /// No description provided for @techFieldShiftEnd.
  ///
  /// In en, this message translates to:
  /// **'Shift end'**
  String get techFieldShiftEnd;

  /// No description provided for @techSkills.
  ///
  /// In en, this message translates to:
  /// **'Skills'**
  String get techSkills;

  /// No description provided for @techNotesHint.
  ///
  /// In en, this message translates to:
  /// **'Additional notes about the technician...'**
  String get techNotesHint;

  /// No description provided for @techNoNameYet.
  ///
  /// In en, this message translates to:
  /// **'No name yet'**
  String get techNoNameYet;

  /// No description provided for @orderDetailsProgress.
  ///
  /// In en, this message translates to:
  /// **'Work progress'**
  String get orderDetailsProgress;

  /// No description provided for @orderDetailsHeading.
  ///
  /// In en, this message translates to:
  /// **'Order details'**
  String get orderDetailsHeading;

  /// No description provided for @orderDetailsSubtitleLab.
  ///
  /// In en, this message translates to:
  /// **'Order details sent from the doctor to the lab'**
  String get orderDetailsSubtitleLab;

  /// No description provided for @orderDetailsExpectedDelivery.
  ///
  /// In en, this message translates to:
  /// **'Expected delivery date'**
  String get orderDetailsExpectedDelivery;

  /// No description provided for @orderDetailsOrderData.
  ///
  /// In en, this message translates to:
  /// **'Order data'**
  String get orderDetailsOrderData;

  /// No description provided for @orderDetailsDoctorData.
  ///
  /// In en, this message translates to:
  /// **'Doctor data'**
  String get orderDetailsDoctorData;

  /// No description provided for @orderDetailsSenderDoctor.
  ///
  /// In en, this message translates to:
  /// **'Sending doctor'**
  String get orderDetailsSenderDoctor;

  /// No description provided for @orderDetailsReceivingLab.
  ///
  /// In en, this message translates to:
  /// **'Receiving lab'**
  String get orderDetailsReceivingLab;

  /// No description provided for @orderDetailsReadyForDelivery.
  ///
  /// In en, this message translates to:
  /// **'Ready for delivery'**
  String get orderDetailsReadyForDelivery;

  /// No description provided for @labProcessUpdateStatus.
  ///
  /// In en, this message translates to:
  /// **'Update status'**
  String get labProcessUpdateStatus;

  /// No description provided for @labProcessTitle.
  ///
  /// In en, this message translates to:
  /// **'Process order'**
  String get labProcessTitle;

  /// No description provided for @labProcessDeliveredDesc.
  ///
  /// In en, this message translates to:
  /// **'Material available and delivered to the doctor'**
  String get labProcessDeliveredDesc;

  /// No description provided for @labProcessReadyRequiresInProgress.
  ///
  /// In en, this message translates to:
  /// **'Manufacturing must start first (in progress) before it can be marked ready for delivery'**
  String get labProcessReadyRequiresInProgress;

  /// No description provided for @labProcessMissingDesc.
  ///
  /// In en, this message translates to:
  /// **'Material not available in the lab'**
  String get labProcessMissingDesc;

  /// No description provided for @labAssignTitle.
  ///
  /// In en, this message translates to:
  /// **'Assign order'**
  String get labAssignTitle;

  /// No description provided for @labAssignSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose the order for {name}'**
  String labAssignSubtitle(String name);

  /// No description provided for @profilePageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Employee data and job information'**
  String get profilePageSubtitle;

  /// No description provided for @labInventory.
  ///
  /// In en, this message translates to:
  /// **'Lab Inventory'**
  String get labInventory;

  /// No description provided for @labInvSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search lab materials...'**
  String get labInvSearchHint;

  /// No description provided for @labInvTotal.
  ///
  /// In en, this message translates to:
  /// **'Total materials'**
  String get labInvTotal;

  /// No description provided for @labInvLow.
  ///
  /// In en, this message translates to:
  /// **'Low stock'**
  String get labInvLow;

  /// No description provided for @labInvOut.
  ///
  /// In en, this message translates to:
  /// **'Out of stock'**
  String get labInvOut;

  /// No description provided for @stockLogsTitle.
  ///
  /// In en, this message translates to:
  /// **'Movement log'**
  String get stockLogsTitle;

  /// No description provided for @stockLogsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No recorded movements'**
  String get stockLogsEmpty;

  /// No description provided for @labInvColCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get labInvColCategory;

  /// No description provided for @labInvConsume.
  ///
  /// In en, this message translates to:
  /// **'Record usage'**
  String get labInvConsume;

  /// No description provided for @labInvConsumeTitle.
  ///
  /// In en, this message translates to:
  /// **'Record material usage'**
  String get labInvConsumeTitle;

  /// No description provided for @labInvConsumeAmount.
  ///
  /// In en, this message translates to:
  /// **'Consumed quantity'**
  String get labInvConsumeAmount;

  /// No description provided for @labInvConsumeHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the quantity withdrawn from stock'**
  String get labInvConsumeHint;

  /// No description provided for @labInvCurrentQty.
  ///
  /// In en, this message translates to:
  /// **'Currently available'**
  String get labInvCurrentQty;

  /// No description provided for @labInvEmpty.
  ///
  /// In en, this message translates to:
  /// **'No materials in this category'**
  String get labInvEmpty;

  /// No description provided for @labInvConsumeExceeds.
  ///
  /// In en, this message translates to:
  /// **'Quantity exceeds available stock'**
  String get labInvConsumeExceeds;

  /// No description provided for @labInvConsumeInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid quantity'**
  String get labInvConsumeInvalid;

  /// No description provided for @labProducts.
  ///
  /// In en, this message translates to:
  /// **'Lab Products'**
  String get labProducts;

  /// No description provided for @labProductsSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search products...'**
  String get labProductsSearchHint;

  /// No description provided for @labProdTotal.
  ///
  /// In en, this message translates to:
  /// **'Total products'**
  String get labProdTotal;

  /// No description provided for @labProdAdd.
  ///
  /// In en, this message translates to:
  /// **'New product'**
  String get labProdAdd;

  /// No description provided for @labProdAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add product'**
  String get labProdAddTitle;

  /// No description provided for @labProdEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit product'**
  String get labProdEditTitle;

  /// No description provided for @labProdDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete product'**
  String get labProdDeleteTitle;

  /// No description provided for @labProdDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\"? This action cannot be undone.'**
  String labProdDeleteConfirm(String name);

  /// No description provided for @labProdColType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get labProdColType;

  /// No description provided for @labProdColPrice.
  ///
  /// In en, this message translates to:
  /// **'Price (SYP)'**
  String get labProdColPrice;

  /// No description provided for @labProdColDuration.
  ///
  /// In en, this message translates to:
  /// **'Production time'**
  String get labProdColDuration;

  /// No description provided for @labProdDaysUnit.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get labProdDaysUnit;

  /// No description provided for @labProdFieldName.
  ///
  /// In en, this message translates to:
  /// **'Product name'**
  String get labProdFieldName;

  /// No description provided for @labProdFieldType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get labProdFieldType;

  /// No description provided for @labProdFieldMaterial.
  ///
  /// In en, this message translates to:
  /// **'Material'**
  String get labProdFieldMaterial;

  /// No description provided for @labProdFieldPrice.
  ///
  /// In en, this message translates to:
  /// **'Price in Syrian Pounds'**
  String get labProdFieldPrice;

  /// No description provided for @labProdFieldDuration.
  ///
  /// In en, this message translates to:
  /// **'Production time (days)'**
  String get labProdFieldDuration;

  /// No description provided for @labProdFieldCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get labProdFieldCategory;

  /// No description provided for @labProdNoCategory.
  ///
  /// In en, this message translates to:
  /// **'No category'**
  String get labProdNoCategory;

  /// No description provided for @labProdEmpty.
  ///
  /// In en, this message translates to:
  /// **'No products'**
  String get labProdEmpty;

  /// No description provided for @labOrdersEmpty.
  ///
  /// In en, this message translates to:
  /// **'No orders today'**
  String get labOrdersEmpty;

  /// No description provided for @labCategoriesManage.
  ///
  /// In en, this message translates to:
  /// **'Manage Categories'**
  String get labCategoriesManage;

  /// No description provided for @labCategoryNameHint.
  ///
  /// In en, this message translates to:
  /// **'New category name'**
  String get labCategoryNameHint;

  /// No description provided for @labCategoryAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get labCategoryAdd;

  /// No description provided for @labCategoriesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No categories yet'**
  String get labCategoriesEmpty;

  /// No description provided for @labCategoryDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Category'**
  String get labCategoryDeleteTitle;

  /// No description provided for @labCategoryDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete “{name}”?'**
  String labCategoryDeleteConfirm(String name);

  /// No description provided for @labProcessConsumeFailed.
  ///
  /// In en, this message translates to:
  /// **'Order completed, but stock deduction failed for: {materials}'**
  String labProcessConsumeFailed(String materials);

  /// No description provided for @labProdNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Product name is required'**
  String get labProdNameRequired;

  /// No description provided for @labProcessCost.
  ///
  /// In en, this message translates to:
  /// **'Order cost (SYP)'**
  String get labProcessCost;

  /// No description provided for @labProcessTechnician.
  ///
  /// In en, this message translates to:
  /// **'Executing technician'**
  String get labProcessTechnician;

  /// No description provided for @labProcessTechnicianNone.
  ///
  /// In en, this message translates to:
  /// **'Not specified'**
  String get labProcessTechnicianNone;

  /// No description provided for @labProcessTechnicianRequired.
  ///
  /// In en, this message translates to:
  /// **'Select the executing technician before changing the status'**
  String get labProcessTechnicianRequired;

  /// No description provided for @labProcessManufacturingDesc.
  ///
  /// In en, this message translates to:
  /// **'Order is currently being manufactured'**
  String get labProcessManufacturingDesc;

  /// No description provided for @labProcessReadyTitle.
  ///
  /// In en, this message translates to:
  /// **'Ready for delivery'**
  String get labProcessReadyTitle;

  /// No description provided for @orderDetailsCost.
  ///
  /// In en, this message translates to:
  /// **'Cost'**
  String get orderDetailsCost;

  /// No description provided for @orderDetailsExecutor.
  ///
  /// In en, this message translates to:
  /// **'Executing technician'**
  String get orderDetailsExecutor;

  /// No description provided for @whMovementColumn.
  ///
  /// In en, this message translates to:
  /// **'Movement'**
  String get whMovementColumn;

  /// No description provided for @whMovementTitle.
  ///
  /// In en, this message translates to:
  /// **'Stock movement'**
  String get whMovementTitle;

  /// No description provided for @whMovementIn.
  ///
  /// In en, this message translates to:
  /// **'Stock in'**
  String get whMovementIn;

  /// No description provided for @whMovementOut.
  ///
  /// In en, this message translates to:
  /// **'Stock out'**
  String get whMovementOut;

  /// No description provided for @whMovementAmount.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get whMovementAmount;

  /// No description provided for @whMovementExceeds.
  ///
  /// In en, this message translates to:
  /// **'Quantity exceeds available stock'**
  String get whMovementExceeds;

  /// No description provided for @whMovementInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid quantity'**
  String get whMovementInvalid;

  /// No description provided for @whMovementCurrent.
  ///
  /// In en, this message translates to:
  /// **'Currently available'**
  String get whMovementCurrent;

  /// No description provided for @whStockTitle.
  ///
  /// In en, this message translates to:
  /// **'Stock management'**
  String get whStockTitle;

  /// No description provided for @whStockTotal.
  ///
  /// In en, this message translates to:
  /// **'Total available'**
  String get whStockTotal;

  /// No description provided for @whStockBatches.
  ///
  /// In en, this message translates to:
  /// **'Batches'**
  String get whStockBatches;

  /// No description provided for @whStockNoBatches.
  ///
  /// In en, this message translates to:
  /// **'No batches for this material yet'**
  String get whStockNoBatches;

  /// No description provided for @whStockNewViaPurchaseInvoice.
  ///
  /// In en, this message translates to:
  /// **'New stock is now added via a purchase invoice — from the Purchase Invoices page.'**
  String get whStockNewViaPurchaseInvoice;

  /// No description provided for @whStockExpiry.
  ///
  /// In en, this message translates to:
  /// **'Expiry date (optional)'**
  String get whStockExpiry;

  /// No description provided for @whStockExpiryNone.
  ///
  /// In en, this message translates to:
  /// **'No expiry'**
  String get whStockExpiryNone;

  /// No description provided for @whStockExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get whStockExpired;

  /// No description provided for @whStockNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes (optional)'**
  String get whStockNotes;

  /// No description provided for @whStockReason.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get whStockReason;

  /// No description provided for @whStockAdjust.
  ///
  /// In en, this message translates to:
  /// **'Adjust quantity'**
  String get whStockAdjust;

  /// No description provided for @whStockAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get whStockAdd;

  /// No description provided for @whStockDeduct.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get whStockDeduct;

  /// No description provided for @whStockReasonPurchase.
  ///
  /// In en, this message translates to:
  /// **'Purchase'**
  String get whStockReasonPurchase;

  /// No description provided for @whStockReasonFulfillment.
  ///
  /// In en, this message translates to:
  /// **'Fulfillment'**
  String get whStockReasonFulfillment;

  /// No description provided for @whStockReasonExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired/disposed'**
  String get whStockReasonExpired;

  /// No description provided for @whStockReasonAdjustment.
  ///
  /// In en, this message translates to:
  /// **'Adjustment'**
  String get whStockReasonAdjustment;

  /// No description provided for @whStockReasonReturn.
  ///
  /// In en, this message translates to:
  /// **'Return'**
  String get whStockReasonReturn;

  /// No description provided for @whStockBatchLabel.
  ///
  /// In en, this message translates to:
  /// **'Batch'**
  String get whStockBatchLabel;

  /// No description provided for @whStockCreatedAt.
  ///
  /// In en, this message translates to:
  /// **'Added'**
  String get whStockCreatedAt;

  /// No description provided for @whStockLogButton.
  ///
  /// In en, this message translates to:
  /// **'Movement log'**
  String get whStockLogButton;

  /// No description provided for @whStockLogTitle.
  ///
  /// In en, this message translates to:
  /// **'Stock movement log'**
  String get whStockLogTitle;

  /// No description provided for @whStockLogFilterLabel.
  ///
  /// In en, this message translates to:
  /// **'Filter by material'**
  String get whStockLogFilterLabel;

  /// No description provided for @whStockLogEmpty.
  ///
  /// In en, this message translates to:
  /// **'No movements recorded'**
  String get whStockLogEmpty;

  /// No description provided for @whStockLogLowBadge.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get whStockLogLowBadge;

  /// No description provided for @labProcessConsumedSection.
  ///
  /// In en, this message translates to:
  /// **'Materials consumed from inventory'**
  String get labProcessConsumedSection;

  /// No description provided for @labProcessConsumedHint.
  ///
  /// In en, this message translates to:
  /// **'These materials are deducted from lab inventory on save'**
  String get labProcessConsumedHint;

  /// No description provided for @labProcessAddMaterial.
  ///
  /// In en, this message translates to:
  /// **'Add material'**
  String get labProcessAddMaterial;

  /// No description provided for @labProcessSelectMaterial.
  ///
  /// In en, this message translates to:
  /// **'Select material'**
  String get labProcessSelectMaterial;

  /// No description provided for @labProcessMaterialsCost.
  ///
  /// In en, this message translates to:
  /// **'Materials cost'**
  String get labProcessMaterialsCost;

  /// No description provided for @labProcessNoMaterials.
  ///
  /// In en, this message translates to:
  /// **'No materials added yet'**
  String get labProcessNoMaterials;
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
