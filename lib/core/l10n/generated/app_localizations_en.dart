// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'DT.Teeth';

  @override
  String get appSubtitle => 'Comprehensive Dental Clinic Management System';

  @override
  String get appVersion => 'v1.0 · Flutter Web';

  @override
  String get login => 'Sign In';

  @override
  String get loginTitle => 'Welcome Back';

  @override
  String get loginSubtitle => 'Sign in to continue';

  @override
  String get email => 'Email';

  @override
  String get emailHint => 'example@dtteeth.com';

  @override
  String get emailInvalid => 'Please enter a valid email address';

  @override
  String get emailRequired => 'Email is required';

  @override
  String get password => 'Password';

  @override
  String get passwordHint => 'Enter your password';

  @override
  String get passwordConfirm => 'Confirm Password';

  @override
  String get passwordMismatch => 'Passwords do not match';

  @override
  String get passwordTooShort => 'Password must be at least 8 characters';

  @override
  String get passwordWeak => 'Weak';

  @override
  String get passwordMedium => 'Medium';

  @override
  String get passwordStrong => 'Strong';

  @override
  String get firstLogin => 'First Time';

  @override
  String get rememberMe => 'Remember Me';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get logout => 'Sign Out';

  @override
  String get authEnterEmailTitle => 'Let\'s get you started';

  @override
  String get authEnterEmailSubtitle =>
      'Enter the email your administrator registered';

  @override
  String get authNext => 'Next';

  @override
  String get authBack => 'Back';

  @override
  String get authContinue => 'Continue';

  @override
  String get authVerifyCodeTitle => 'Verify Your Identity';

  @override
  String authVerifyCodeSubtitle(String email) {
    return 'We sent a 6-digit code to $email';
  }

  @override
  String get authResendCode => 'Resend Code';

  @override
  String authResendCodeIn(int seconds) {
    return 'Resend in ${seconds}s';
  }

  @override
  String get authCodeExpired => 'Code expired. Please request a new one.';

  @override
  String get authCodeInvalid => 'Invalid code. Please check and try again.';

  @override
  String get authSetPasswordTitle => 'Create Your Password';

  @override
  String get authSetPasswordSubtitle =>
      'Choose a strong password to secure your account';

  @override
  String get authSaveAndLogin => 'Save & Sign In';

  @override
  String get authCheckEmailSent =>
      'If this email is registered, a code was sent';

  @override
  String get labSystem => 'Lab System';

  @override
  String get warehouseSystem => 'Warehouse System';

  @override
  String get switchSystem => 'Switch System';

  @override
  String get dashboard => 'Home';

  @override
  String get reports => 'Reports';

  @override
  String get notifications => 'Notifications';

  @override
  String get settings => 'Settings';

  @override
  String get doctorOrders => 'Doctor Orders';

  @override
  String get technicians => 'Technicians';

  @override
  String get labReports => 'Lab Reports';

  @override
  String get materialRequests => 'Material Requests';

  @override
  String get materials => 'Materials';

  @override
  String get orders => 'Orders';

  @override
  String get invoices => 'Invoices';

  @override
  String get suppliers => 'Suppliers';

  @override
  String get inventory => 'Inventory';

  @override
  String get sectionMain => 'Main';

  @override
  String get sectionInventory => 'Inventory';

  @override
  String get sectionFinance => 'Finance';

  @override
  String get sectionSystem => 'System';

  @override
  String get sectionTeam => 'Team';

  @override
  String get sectionOrders => 'Orders';

  @override
  String get sectionOperations => 'Operations';

  @override
  String get sectionAccount => 'Account';

  @override
  String get menu => 'Menu';

  @override
  String get search => 'Search in system...';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get add => 'Add';

  @override
  String get confirm => 'Confirm';

  @override
  String get apply => 'Apply';

  @override
  String get reset => 'Reset';

  @override
  String get close => 'Close';

  @override
  String get viewAll => 'View All';

  @override
  String get viewDetails => 'View Details';

  @override
  String get retry => 'Retry';

  @override
  String get loading => 'Loading...';

  @override
  String get noData => 'No Data';

  @override
  String get noResults => 'No Results';

  @override
  String get error => 'Error Occurred';

  @override
  String get success => 'Operation Successful';

  @override
  String get statusNew => 'New';

  @override
  String get statusPendingMaterials => 'Pending Materials';

  @override
  String get statusManufacturing => 'Manufacturing';

  @override
  String get statusReady => 'Ready';

  @override
  String get statusDelivered => 'Delivered';

  @override
  String get statusRejected => 'Rejected';

  @override
  String get statusReserved => 'Reserved';

  @override
  String get statusEmpty => 'Empty';

  @override
  String get statusOccupied => 'Occupied';

  @override
  String get statusMaintenance => 'Maintenance';

  @override
  String get errorNetwork => 'No internet connection — check your network';

  @override
  String get errorServer => 'Server error — try again in a moment';

  @override
  String get errorTimeout => 'Request timed out — server not responding';

  @override
  String get errorUnauthorized => 'Session expired — please sign in again';

  @override
  String get errorForbidden => 'You don\'t have permission to access this page';

  @override
  String get errorNotFound => 'The requested item was not found';

  @override
  String get errorValidation => 'Please check required fields';

  @override
  String get errorMaintenance => 'Server under maintenance — come back later';

  @override
  String get errorCache => 'Local data error — please try again';

  @override
  String get theme => 'Theme';

  @override
  String get darkMode => 'Dark';

  @override
  String get lightMode => 'Light';

  @override
  String get language => 'Language';

  @override
  String get languageArabic => 'العربية';

  @override
  String get languageEnglish => 'English';

  @override
  String get fontSize => 'Font Size';

  @override
  String get fontSmall => 'Small';

  @override
  String get fontMedium => 'Medium';

  @override
  String get fontNormal => 'Normal';

  @override
  String get fontLarge => 'Large';

  @override
  String get fontXLarge => 'Extra Large';

  @override
  String get welcomeWarehouse => 'Welcome to the Warehouse System 📦';

  @override
  String get welcomeLab => 'Welcome to the Lab System 🧪';

  @override
  String get systemStatusOk =>
      'Last updated: today — all systems operating normally';

  @override
  String get roleLabManager => 'Lab Manager';

  @override
  String get roleWarehouseManager => 'Warehouse Manager';

  @override
  String get roleDentist => 'Dentist';

  @override
  String get roleSecretary => 'Secretary';

  @override
  String get roleAdmin => 'Administrator';

  @override
  String get labSystemBadge => 'Lab System';

  @override
  String get warehouseSystemBadge => 'Warehouse System';

  @override
  String get emptyNoOrdersTitle => 'No Orders Yet';

  @override
  String get emptyNoOrdersMessage => 'Orders will appear here when added';

  @override
  String get emptyNoMaterialsTitle => 'No Materials';

  @override
  String get emptyNoMaterialsMessage =>
      'No materials have been added to inventory yet';

  @override
  String get emptyNoInvoicesTitle => 'No Invoices';

  @override
  String get emptyNoInvoicesMessage => 'Invoice history is currently empty';

  @override
  String get emptyNoNotificationsTitle => 'No New Notifications';

  @override
  String get emptyNoNotificationsMessage =>
      'We\'ll notify you when something new arrives';

  @override
  String get emptyNoSearchResultsTitle => 'No Results Found';

  @override
  String get emptyNoSearchResultsMessage => 'Try different search terms';

  @override
  String get emptyNoTechniciansTitle => 'No Technicians';

  @override
  String get emptyNoTechniciansMessage =>
      'Start by adding the first technician to the team';

  @override
  String get emptyNoReportsTitle => 'No Reports Available';

  @override
  String get emptyNoReportsMessage =>
      'Reports will appear once data is collected';

  @override
  String get emptyErrorTitle => 'Failed to Load Data';

  @override
  String get emptyErrorMessage =>
      'An error occurred while connecting to the server';

  @override
  String get actionAddFirst => 'Add First Item';

  @override
  String get actionClearFilters => 'Clear Filters';

  @override
  String get loadingData => 'Loading data...';

  @override
  String get loadingPleaseWait => 'Please wait...';

  @override
  String get systemSelectionTitle => 'Select System';

  @override
  String get systemSelectionSubtitle =>
      'Choose the system you want to work with';

  @override
  String get systemSelectionLabTitle => 'Lab System';

  @override
  String get systemSelectionLabDescription =>
      'Manage dental prosthetics orders, technicians, and reports';

  @override
  String get systemSelectionWarehouseTitle => 'Warehouse System';

  @override
  String get systemSelectionWarehouseDescription =>
      'Manage inventory, materials, invoices, and clinic orders';

  @override
  String get systemSelectionEnterButton => 'Enter';

  @override
  String get systemSelectionDemoNotice =>
      'Preview mode — you can switch between systems anytime';

  @override
  String get systemSwitcherSwitchTo => 'Switch to';

  @override
  String get systemSwitcherCurrentSystem => 'Current System';

  @override
  String get f4TopbarSubtitles => '─── Topbar subtitles ───';

  @override
  String get warehouseTopbarSubtitle =>
      'Warehouse Management System · DT.Teeth';

  @override
  String get labTopbarSubtitle => 'Lab Management System · DT.Teeth';

  @override
  String get f4Dashboard => '─── Dashboard — warehouse ───';

  @override
  String get whDashboardTitle => 'Dashboard';

  @override
  String get whDashboardHeroSubtitle =>
      'Last updated: today — all systems operating normally';

  @override
  String get whHeroStatRegisteredMaterials => 'Registered Materials';

  @override
  String get whHeroStatPendingOrders => 'Pending Orders';

  @override
  String get whHeroStatActiveAlerts => 'Active Alerts';

  @override
  String get whStatCurrentInventory => 'Current Inventory';

  @override
  String get whStatLowStockMaterials => 'Low Stock Materials';

  @override
  String get whStatIncomingOrders => 'Incoming Orders';

  @override
  String get whStatExpiringMaterials => 'Expiring Materials';

  @override
  String get whSectionTopRequested => 'Most Requested Materials';

  @override
  String get whSectionExpiringSoon => 'Materials Expiring Soon';

  @override
  String get whSectionTopRequestedCaption => 'This Month';

  @override
  String get whSectionExpiringCaption => 'Within 30 days';

  @override
  String get whAlertLowStockTitle => 'Low Stock';

  @override
  String whAlertLowStockSubtitle(int count) {
    return '$count critical materials';
  }

  @override
  String get whAlertNewOrdersTitle => 'New Orders';

  @override
  String whAlertNewOrdersSubtitle(int count) {
    return '$count pending';
  }

  @override
  String get whQuickActions => 'Quick Actions';

  @override
  String get whQuickActionAddMaterial => 'Material';

  @override
  String get whQuickActionAddInvoice => 'Invoice';

  @override
  String get whQuickActionReports => 'Reports';

  @override
  String get whQuickActionOrders => 'Orders';

  @override
  String get whInventoryDistribution => 'Inventory Distribution';

  @override
  String get whCategoryConsumables => 'Consumables';

  @override
  String get whCategoryMedicines => 'Medicines';

  @override
  String get whCategoryMedical => 'Medical';

  @override
  String get whCategoryEquipment => 'Equipment';

  @override
  String get whExpiryDaysLeft => 'Days Left';

  @override
  String get errorRequired => 'This field is required';

  @override
  String get errorInvalidNumber => 'Please enter a valid number';

  @override
  String get whFullReport => 'Full Report';

  @override
  String get f4Materials => '─── Materials Management ───';

  @override
  String get whMaterialsTitle => 'Materials';

  @override
  String get whMaterialsAdd => 'Add Material';

  @override
  String get whFilterAll => 'All';

  @override
  String get whFilterLowStock => 'Low Stock';

  @override
  String get whFilterExpiring => 'Expiring';

  @override
  String get whFilterConsumables => 'Consumables';

  @override
  String get whFilterMedicines => 'Medicines';

  @override
  String get whFilterMedical => 'Medical';

  @override
  String get whMaterialName => 'Material Name';

  @override
  String get whMaterialCategory => 'Category';

  @override
  String get whMaterialQuantity => 'Quantity';

  @override
  String get whMaterialUnit => 'Unit';

  @override
  String get whMaterialMinStock => 'Minimum Stock';

  @override
  String get whMaterialExpiryDate => 'Expiry Date';

  @override
  String get whMaterialSupplier => 'Supplier';

  @override
  String get whMaterialPrice => 'Price';

  @override
  String get whMaterialNotes => 'Notes';

  @override
  String get whStatusAvailable => 'Available';

  @override
  String get whStatusLow => 'Low';

  @override
  String get whStatusOut => 'Out of Stock';

  @override
  String get f4Orders => '─── Orders ───';

  @override
  String get whOrdersTitle => 'Orders';

  @override
  String get whOrderNumber => 'Order #';

  @override
  String get whOrderRequester => 'Requester';

  @override
  String get whOrderDate => 'Date';

  @override
  String get whOrderStatus => 'Status';

  @override
  String get whOrderAction => 'Action';

  @override
  String get whOrderFilterNew => 'New';

  @override
  String get whOrderFilterDone => 'Fulfilled';

  @override
  String get whOrderFilterMissing => 'Missing';

  @override
  String get whOrderStatusNew => 'New';

  @override
  String get whOrderStatusFulfilled => 'Fulfilled';

  @override
  String get whOrderStatusMissing => 'Missing';

  @override
  String get f4Invoices => '─── Invoices ───';

  @override
  String get whInvoicesTitle => 'Invoices';

  @override
  String get whInvoiceAdd => 'New Invoice';

  @override
  String get whInvoiceFilterPurchase => 'Purchase';

  @override
  String get whInvoiceFilterUsage => 'Usage';

  @override
  String get whInvoiceWeekly => 'Weekly Invoices';

  @override
  String get whInvoiceWeekSummary => 'Week Summary';

  @override
  String get whInvoiceTotalPurchase => 'Total Purchase';

  @override
  String get whInvoiceTotalUsage => 'Total Usage';

  @override
  String get whInvoiceTotalLoss => 'Loss — Expired';

  @override
  String get whInvoiceExportPdf => 'Export PDF';

  @override
  String get f4Reports => '─── Reports ───';

  @override
  String get whReportsTitle => 'Reports';

  @override
  String get whReportTabTopMaterials => 'Top 10 Materials';

  @override
  String get whReportTabFinancial => 'Financial';

  @override
  String get whReportTopMaterialsTitle => 'Most Requested Materials';

  @override
  String get whReportMonthlyOrders => 'Monthly Orders';

  @override
  String get whReportRank => 'Rank';

  @override
  String get whReportRequestCount => 'Requests';

  @override
  String get whReportCost => 'Cost';

  @override
  String get whReportExport => 'Export';

  @override
  String get whReportWeeklyPurchases => 'Weekly Purchases';

  @override
  String get whReportUsageCost => 'Usage Cost';

  @override
  String get whReportExpiredLoss => 'Expired Loss';

  @override
  String get f4Notifications => '─── Notifications ───';

  @override
  String get whNotificationsTitle => 'Notifications';

  @override
  String get whNotifFilterUnread => 'Unread';

  @override
  String get whNotifFilterLow => 'Low Stock';

  @override
  String get whNotifFilterExpiry => 'Expiry';

  @override
  String get whNotifFilterOrder => 'Orders';

  @override
  String get whNotifMarkAllRead => 'Mark All Read';

  @override
  String get f4Settings => '─── Settings ───';

  @override
  String get whSettingsTitle => 'Settings';

  @override
  String get whSettingsTabProfile => 'Profile';

  @override
  String get whSettingsTabNotifications => 'Notifications';

  @override
  String get whSettingsTabSecurity => 'Security';

  @override
  String get whSettingsTabAbout => 'About';

  @override
  String get whSettingsFirstName => 'First Name';

  @override
  String get whSettingsLastName => 'Last Name';

  @override
  String get whSettingsEmail => 'Email';

  @override
  String get whSettingsSaveChanges => 'Save Changes';

  @override
  String get whSettingsNotifLowStock => 'Low Stock Alert';

  @override
  String get whSettingsNotifLowStockDesc => 'When stock reaches minimum';

  @override
  String get whSettingsNotifExpiry => 'Expiry Alert';

  @override
  String get whSettingsNotifExpiryDesc => '30 days before expiry';

  @override
  String get whSettingsNotifOrders => 'New Orders';

  @override
  String get whSettingsNotifOrdersDesc => 'Upon arrival';

  @override
  String get whSettingsNotifWeekly => 'Weekly Report';

  @override
  String get whSettingsNotifWeeklyDesc => 'Every Sunday';

  @override
  String get whSettingsCurrentPassword => 'Current Password';

  @override
  String get whSettingsNewPassword => 'New Password';

  @override
  String get whSettingsConfirmPassword => 'Confirm Password';

  @override
  String get whSettingsUpdatePassword => 'Update';

  @override
  String get whSettingsAboutTitle => 'DT.Teeth Repository';

  @override
  String get whSettingsAboutVersion => 'v1.0.0 · March 2026 · Flutter Web';

  @override
  String get f4ComingSoon => '─── Under construction badge ───';

  @override
  String get comingSoonTitle => 'Coming Soon';

  @override
  String get comingSoonSubtitle =>
      'This screen is under construction — coming soon';

  @override
  String get screenUnderConstruction => 'Under Construction';

  @override
  String get f4Lab => '─── Lab System ───';

  @override
  String get labDashboardTitle => 'Dashboard';

  @override
  String get labHeroWelcome => 'Welcome to Lab System 🧪';

  @override
  String get labHeroSubtitle =>
      'Last update: Today — All systems running normally ✅';

  @override
  String get labHeroStatTodayOrders => 'Today\'s Orders';

  @override
  String get labHeroStatInProgress => 'In Progress';

  @override
  String get labHeroStatCompletionRate => 'Completion Rate';

  @override
  String get labStatNewOrders => 'New Orders';

  @override
  String get labStatManufacturing => 'Manufacturing';

  @override
  String get labStatReady => 'Ready';

  @override
  String get labStatUrgentToday => 'Due Today';

  @override
  String get labOrdersFilterAll => 'All';

  @override
  String get labOrdersFilterNew => 'New';

  @override
  String get labOrdersFilterManufacturing => 'Manufacturing';

  @override
  String get labOrdersFilterReady => 'Ready';

  @override
  String get labOrdersDueToday => 'Due Today';

  @override
  String get labOrdersDueTodaySubtitle => 'Must be completed before evening';

  @override
  String get labTeamTitle => 'Manage Technicians';

  @override
  String get labTeamTotal => 'Total Technicians';

  @override
  String get labTeamActive => 'Active';

  @override
  String get labTeamAvailable => 'Available';

  @override
  String get labTeamColumnName => 'Technician';

  @override
  String get labTeamColumnShift => 'Shift Hours';

  @override
  String get labTeamColumnCurrentTask => 'Current Task';

  @override
  String get labTeamColumnStatus => 'Status';

  @override
  String get labTeamColumnAction => 'Action';

  @override
  String get labTeamAssign => 'Assign';

  @override
  String get labTeamFree => 'Free';

  @override
  String get labTeamBusy => 'Busy';

  @override
  String get labReportTabByType => 'By Type';

  @override
  String get labReportTabByDate => 'By Date';

  @override
  String get labReportTabTeam => 'Team Performance';

  @override
  String get labReportFilterMonthly => 'Monthly';

  @override
  String get labReportFilterWeekly => 'Weekly';

  @override
  String get labReportFilterDaily => 'Daily';

  @override
  String get labReportFilterYearly => 'Yearly';

  @override
  String get labReportExportPdf => '📤 Export PDF';

  @override
  String get labReportExportExcel => '📊 Export Excel';

  @override
  String get labReportSendEmail => '📧 Send by Email';

  @override
  String get labReportStatTotal => 'Period Orders';

  @override
  String get labReportStatCompleted => 'Completed On Time';

  @override
  String get labReportStatAvgTime => 'Avg. Time';

  @override
  String get labReportStatSatisfaction => 'Satisfaction Rate';

  @override
  String get labReportCrownType => 'Crowns';

  @override
  String get labReportBridgeType => 'Bridges';

  @override
  String get labReportOtherType => 'Other';

  @override
  String get labQuickActionOrders => 'Orders';

  @override
  String get labQuickActionReport => 'Report';

  @override
  String get labQuickActionTeam => 'Team';

  @override
  String get labQuickActionAlerts => 'Alerts';

  @override
  String get labTeamPerformanceTitle => 'Team Performance';

  @override
  String get labSettingsTabProfile => 'Profile';

  @override
  String get labSettingsTabNotifications => 'Notifications';

  @override
  String get labSettingsTabAbout => 'About';

  @override
  String get labSettingsNotifNewOrders => 'New Orders';

  @override
  String get labSettingsNotifNewOrdersDesc => 'Instant notification';

  @override
  String get labSettingsNotifUrgent => 'Urgent Alert';

  @override
  String get labSettingsNotifUrgentDesc => '3 hours before deadline';

  @override
  String get labSettingsNotifDoctorReady => 'Doctor Notification';

  @override
  String get labSettingsNotifDoctorReadyDesc => 'On completion via FCM';

  @override
  String get labSettingsAboutTitle => 'DT.Teeth Lab';

  @override
  String get labSettingsAboutVersion => 'v1.0.0 · Flutter Web · Laravel API';

  @override
  String get labTopbarSubtitleFull => 'Lab Management System · DT.Teeth';

  @override
  String get labProfile => 'My Profile';

  @override
  String get labManageTechnicians => 'Manage Technicians';
}
