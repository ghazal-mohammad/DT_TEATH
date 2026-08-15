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
  String get privacyScreenHint => 'Protected content';

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
  String get authVerifyCodeError =>
      'Invalid or expired code. Please try again.';

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
  String get systemLabDesc =>
      'Manage prosthetics orders, technicians and reports';

  @override
  String get systemWarehouseDesc =>
      'Manage inventory, materials, invoices and clinic requests';

  @override
  String get systemSelectTitle => 'Choose a system';

  @override
  String get systemSelectSubtitle => 'Select the system you want to work on';

  @override
  String get systemPreviewNote => 'Preview mode — you can switch anytime';

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
  String get reportsPreviousPeriod => 'Previous period';

  @override
  String get reportsNextPeriod => 'Next period';

  @override
  String get reportsBackToToday => 'Today';

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
  String get commandPaletteHint =>
      'Search or jump... (order, product, technician, material)';

  @override
  String get commandPaletteEmpty => 'No matching results';

  @override
  String get commandPaletteNavHint =>
      'to navigate · Enter to open · Esc to close';

  @override
  String get commandPaletteOpen => 'Global search (Ctrl+K)';

  @override
  String get commandCatNav => 'Navigate';

  @override
  String get commandCatOrder => 'Order';

  @override
  String get commandCatProduct => 'Product';

  @override
  String get commandCatTechnician => 'Technician';

  @override
  String get commandCatMaterial => 'Material';

  @override
  String get commandCatRequest => 'Request';

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
  String get statusCancelled => 'Cancelled';

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
  String get networkOfflineBanner => 'No internet connection';

  @override
  String syncPendingBanner(int count) {
    return '$count change(s) awaiting sync';
  }

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
  String get dateHintDMY => 'DD/MM/YYYY';

  @override
  String get dateEnterLabel => 'Enter date';

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
  String get whCategoryClinic => 'Clinic';

  @override
  String get whCategoryLab => 'Lab';

  @override
  String get whCategoryBoth => 'Both';

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
  String get whMaterialsSearchHint =>
      'Filter warehouse materials... (name, category)';

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
  String get whMaterialNameEn => 'Name (English)';

  @override
  String get whMaterialCompany => 'Manufacturer';

  @override
  String get whMaterialDosage => 'Dosage / Concentration';

  @override
  String get whMaterialPricePerUnit => 'Unit Price';

  @override
  String get whMaterialCategory => 'Category';

  @override
  String get whMaterialQuantity => 'Quantity';

  @override
  String get whMaterialUnit => 'Unit';

  @override
  String get whMaterialUnitHint => 'Choose unit';

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
  String get whMaterialDeactivate => 'Deactivate';

  @override
  String get whMaterialDeactivateConfirmTitle => 'Deactivate Material';

  @override
  String whMaterialDeactivateConfirmMessage(String materialName) {
    return 'Deactivate \"$materialName\"? It will no longer appear in the active materials list.';
  }

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
  String get whOrderDate => 'Order date';

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
  String get labHeroStatDelivered => 'Delivered';

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
  String get labOrdersToday => 'Today\'s orders';

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
  String get labOrdersDueTodayEmpty => 'No orders due today';

  @override
  String get labTeamTitle => 'Manage Technicians';

  @override
  String get labTeamTotal => 'Total Technicians';

  @override
  String get labTeamColumnName => 'Technician';

  @override
  String get labTeamColumnShift => 'Shift Hours';

  @override
  String get labTeamColumnCurrentTask => 'Current Task';

  @override
  String get labTeamColumnAction => 'Action';

  @override
  String get labTeamAssign => 'Assign';

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
  String get reportExportError => 'Couldn\'t export the report';

  @override
  String get labReportStatTotal => 'Period Orders';

  @override
  String get labReportStatCompleted => 'Completed On Time';

  @override
  String get labReportStatAvgTime => 'Avg. Time';

  @override
  String get labReportStatSatisfaction => 'Satisfaction Rate';

  @override
  String get labReportStatOnTime => 'On-time Rate';

  @override
  String get labReportHourSuffix => 'h';

  @override
  String get labReportOrdersByDay => 'Orders by Day';

  @override
  String get labReportOrdersByType => 'Orders by Type';

  @override
  String get labReportTeamPerf => 'Team Performance';

  @override
  String get labReportNoData => 'No data for this period';

  @override
  String get ordersUnit => 'orders';

  @override
  String get piecesUnit => 'pieces';

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

  @override
  String get labDashboardSearchHint =>
      'Filter this page\'s orders... (number, doctor, material)';

  @override
  String get priorityUrgent => 'Urgent';

  @override
  String get priorityNormal => 'Normal';

  @override
  String get labChipThisMonth => 'This month';

  @override
  String get labChipActive => 'Active';

  @override
  String get labStatReadyOrders => 'Ready orders';

  @override
  String get labTodayOrders => 'Today\'s Orders';

  @override
  String get labLastUpdatedJustNow => 'Last updated: just now';

  @override
  String labLastUpdatedMinutesAgo(int minutes) {
    return 'Last updated: ${minutes}m ago';
  }

  @override
  String labLastUpdatedHoursAgo(int hours) {
    return 'Last updated: ${hours}h ago';
  }

  @override
  String labOrdersCount(String count) {
    return '$count orders';
  }

  @override
  String get colOrderNumber => 'Order #';

  @override
  String get colDoctor => 'Doctor';

  @override
  String get colType => 'Type';

  @override
  String get colMaterial => 'Material';

  @override
  String get colTooth => 'Tooth';

  @override
  String get colDate => 'Date';

  @override
  String get colPriority => 'Priority';

  @override
  String get colStatus => 'Status';

  @override
  String labGreeting(String name) {
    return 'Welcome, $name';
  }

  @override
  String get systemAllNormal => 'All systems operating normally';

  @override
  String labLastUpdate(String time) {
    return 'Last update: $time';
  }

  @override
  String get labOrdersSearchHint =>
      'Filter doctor orders... (number, doctor, material, tooth)';

  @override
  String labOrdersCountOfTotal(String shown, String total) {
    return '$shown of $total orders';
  }

  @override
  String get labOrderProcess => 'Process';

  @override
  String get actionView => 'View';

  @override
  String get labNoOrdersInCategory => 'No orders in this category';

  @override
  String get settingsSearchHint => 'Search this page...';

  @override
  String get settingsTabSecurity => 'Security';

  @override
  String get settingsTabPreferences => 'Preferences';

  @override
  String get settingsChangePassword => 'Change Password';

  @override
  String get settingsChangePasswordDesc =>
      'It\'s recommended to change your password every 90 days for better security';

  @override
  String get settingsCurrentPassword => 'Current Password';

  @override
  String get settingsNewPassword => 'New Password';

  @override
  String get settingsConfirmPassword => 'Confirm Password';

  @override
  String get settingsUpdatePassword => 'Update Password';

  @override
  String get settings2FA => 'Two-Factor Authentication';

  @override
  String get settings2FADesc => 'Extra protection for your account via OTP';

  @override
  String get settings2FAOtpTitle => 'Require OTP on login';

  @override
  String get settings2FAOtpDesc =>
      'You receive a code by email each time you sign in from a new device';

  @override
  String get settingsLogoutAll => 'Sign out of all devices';

  @override
  String get settingsLogoutAllDesc =>
      'End all active sessions on other devices';

  @override
  String get settingsNotifPrefs => 'Notification Preferences';

  @override
  String get settingsNotifPrefsDesc =>
      'Choose which notifications you want to receive';

  @override
  String get labSettingsNotifUrgentOrders => 'Urgent Orders';

  @override
  String get labSettingsNotifUrgentOrdersDesc =>
      'Orders that must be completed today';

  @override
  String get labSettingsNotifNewFromDoctors => 'New orders from doctors';

  @override
  String get labSettingsNotifNewFromDoctorsDesc => 'When a new order arrives';

  @override
  String get settingsNotifLowMaterials => 'Low materials';

  @override
  String get settingsNotifLowMaterialsDesc =>
      'When a material reaches its minimum';

  @override
  String get labSettingsNotifWarehouseUpdates => 'Warehouse updates';

  @override
  String get labSettingsNotifWarehouseUpdatesDesc =>
      'Status of sent supply requests';

  @override
  String get labSettingsNotifTeamUpdates => 'Team updates';

  @override
  String get labSettingsNotifTeamUpdatesDesc =>
      'Adding or changing a technician\'s shift';

  @override
  String get settingsNotifChannels => 'Notification Channels';

  @override
  String get settingsNotifChannelsDesc => 'Choose where you receive alerts';

  @override
  String get settingsNotifDailyEmail => 'Daily summary by email';

  @override
  String get settingsNotifDailyEmailDesc => 'Delivered at 8:00 AM every day';

  @override
  String get settingsNotifSound => 'In-app notification sound';

  @override
  String get settingsNotifSoundDesc =>
      'Play a tone when a new notification arrives';

  @override
  String get settingsThemeDesc => 'Choose the system appearance';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeSystem => 'System default';

  @override
  String get settingsTextSize => 'Font Size';

  @override
  String get settingsTextSizeDesc =>
      'Enlarge or reduce the interface font to your comfort';

  @override
  String get settingsTextSizeSmall => 'Small';

  @override
  String get settingsTextSizeNormal => 'Normal';

  @override
  String get settingsTextSizeLarge => 'Large';

  @override
  String get settingsTextSizeXLarge => 'Larger';

  @override
  String get settingsLanguageDesc => 'System display language';

  @override
  String get settingsLangArabicHint => 'RTL · Default';

  @override
  String get settingsLangEnglishHint => 'LTR';

  @override
  String get settingsDisplayPerf => 'Display & Performance';

  @override
  String get settingsCompactView => 'Compact View';

  @override
  String get settingsCompactViewDesc => 'Show more data on a single screen';

  @override
  String get settingsAutoSave => 'Auto-save';

  @override
  String get settingsAutoSaveDesc => 'Automatically save changes every minute';

  @override
  String get notifSearchHint => 'Search notifications...';

  @override
  String get sectionToday => 'Today';

  @override
  String get sectionYesterday => 'Yesterday';

  @override
  String get notifEmptyInCategory => 'No notifications in this category';

  @override
  String get notifFilterAll => 'All';

  @override
  String get notifFilterUnread => 'Unread';

  @override
  String get notifFilterOrders => 'Orders';

  @override
  String get notifFilterMaterials => 'Materials';

  @override
  String get notifFilterSystem => 'System';

  @override
  String get techSearchHint => 'Search technicians... (name, role, task)';

  @override
  String get labTeamSectionTitle => 'Lab Team';

  @override
  String get techScheduleTitle => 'Work schedule';

  @override
  String get techScheduleEdit => 'Edit schedule';

  @override
  String get techPerfTitle => 'Technician performance';

  @override
  String get techPerfThisMonth => 'This month';

  @override
  String get techPerfAssigned => 'Assigned';

  @override
  String get techPerfInProgress => 'In progress';

  @override
  String get techPerfCompleted => 'Completed';

  @override
  String get techScheduleDayOff => 'Off';

  @override
  String get techScheduleNeedOne => 'Select at least one working day';

  @override
  String get techScheduleEndAfterStart => 'End time must be after start time';

  @override
  String get techScheduleSaved => 'Work schedule saved';

  @override
  String get daySaturday => 'Saturday';

  @override
  String get daySunday => 'Sunday';

  @override
  String get dayMonday => 'Monday';

  @override
  String get dayTuesday => 'Tuesday';

  @override
  String get dayWednesday => 'Wednesday';

  @override
  String get dayThursday => 'Thursday';

  @override
  String get dayFriday => 'Friday';

  @override
  String get labTeamTotalChip => 'Total';

  @override
  String get notifMarkAllRead => 'Mark all as read';

  @override
  String get whNotifExpiry => 'Expiry';

  @override
  String get whNotifExpiryDesc => '30 days before expiry';

  @override
  String get whNotifNewSupply => 'New supply orders';

  @override
  String get whNotifNewSupplyDesc =>
      'When an order arrives from the lab/clinic';

  @override
  String get whNotifSupplierDelay => 'Supplier delays';

  @override
  String get whNotifSupplierDelayDesc =>
      'When a supplier misses a delivery date';

  @override
  String get whNotifInvoicesDue => 'Invoices pending payment';

  @override
  String get whNotifInvoicesDueDesc => 'Reminder before the due date';

  @override
  String get whOrderPartial => 'Partial';

  @override
  String get whOrderFulfilled => 'Fulfilled';

  @override
  String get whOrdersEmptyFilter => 'No orders match this filter';

  @override
  String get whOrderRequesterParty => 'Requesting party';

  @override
  String get colQuantity => 'Quantity';

  @override
  String get profileGeneralInfo => 'General Info';

  @override
  String get profileHireDate => 'Hire Date';

  @override
  String get profileLanguages => 'Languages';

  @override
  String get profileAdminNotes => 'Admin Notes';

  @override
  String get profileCompletion => 'Profile Completion';

  @override
  String get profileEdit => 'Edit Profile';

  @override
  String get profileSaving => 'Saving…';

  @override
  String get profileSaveChanges => 'Save Changes';

  @override
  String get profileChangePhoto => 'Change Profile Photo';

  @override
  String get profilePersonalInfo => 'Personal Information';

  @override
  String get profilePersonalInfoSubtitle => 'Identity and contact details';

  @override
  String get profilePhone => 'Phone Number';

  @override
  String get profileSecondaryPhone => 'Secondary Phone';

  @override
  String get profileMaritalStatus => 'Marital Status';

  @override
  String get profileSalary => 'Salary';

  @override
  String get profileEducations => 'Education';

  @override
  String get profileExperiences => 'Work Experience';

  @override
  String get profileTrainings => 'Training Courses';

  @override
  String get profileSkills => 'Skills';

  @override
  String get profileOngoing => 'Now';

  @override
  String get profilePickDate => 'Pick a date';

  @override
  String get profileNationalId => 'National ID';

  @override
  String get profileBirthDate => 'Date of Birth';

  @override
  String get profileGender => 'Gender';

  @override
  String get profileAddress => 'Address';

  @override
  String get profileWorkSchedule => 'Work schedule';

  @override
  String get show => 'Show';

  @override
  String get hide => 'Hide';

  @override
  String get profileEmployeeId => 'Employee ID';

  @override
  String get profileJobInfo => 'Job Information';

  @override
  String get profileJobInfoSubtitle => 'Department, schedule and job title';

  @override
  String get profileDepartment => 'Department';

  @override
  String get profileWorkDays => 'Work Days';

  @override
  String get profilePosition => 'Job Title';

  @override
  String get profileDayOff => 'Weekly Day Off';

  @override
  String get profileWeeklyHours => 'Weekly Work Hours';

  @override
  String get profileSavedSuccess => 'Changes saved successfully';

  @override
  String get profileSaveError => 'Failed to save changes';

  @override
  String get profilePhotoUpdated => 'Profile photo updated';

  @override
  String get profileLoadError => 'Failed to load profile';

  @override
  String get roleEmployee => 'Employee';

  @override
  String get profileStatCompletedOrders => 'Completed Orders';

  @override
  String get profileBadgeThisMonth => 'This Month';

  @override
  String get profileBadgeAverage => 'Average';

  @override
  String get profileStatMovementsThisMonth => 'Movements This Month';

  @override
  String get profileStatLowItems => 'Low Stock Items';

  @override
  String get profileStatStockAccuracy => 'Stock Accuracy';

  @override
  String get profileBadgeAlert => 'Alert';

  @override
  String profilePhotoError(Object error) {
    return 'Failed to pick image: $error';
  }

  @override
  String get ordersFilterAll => 'All';

  @override
  String get ordersUrgent => 'Urgent';

  @override
  String get ordersStatusNew => 'New';

  @override
  String get ordersStatusPartial => 'Partial';

  @override
  String get ordersStatusFulfilled => 'Fulfilled';

  @override
  String get whReqStatusNew => 'New';

  @override
  String get whReqStatusInProgress => 'In progress';

  @override
  String get whReqStatusCompleted => 'Fulfilled';

  @override
  String get whReqStatusRejected => 'Rejected';

  @override
  String get whReqStatusCancelled => 'Cancelled';

  @override
  String get whReqMarkPending => 'Start processing';

  @override
  String get whReqRequester => 'Requester';

  @override
  String get whReqItems => 'Items';

  @override
  String get whReqExistingMaterials => 'Catalog materials';

  @override
  String get whReqNewMaterials => 'Proposed new materials';

  @override
  String get whReqQtyRequested => 'Requested';

  @override
  String get whReqFulfill => 'Fulfill';

  @override
  String get whReqReject => 'Reject';

  @override
  String get whReqViewDetails => 'Details';

  @override
  String get whReqDetailsTitle => 'Request details';

  @override
  String get whReqRejectTitle => 'Reject request';

  @override
  String get whReqRejectReason => 'Rejection reason';

  @override
  String get whReqRejectReasonHint => 'Write the reason for rejection…';

  @override
  String get whReqFulfillConfirm =>
      'The requested quantities will be deducted from stock batches (FIFO). Confirm fulfillment?';

  @override
  String get whReqNotesHint => 'Notes (optional)';

  @override
  String whReqNumber(String id) {
    return 'Request #$id';
  }

  @override
  String whReqItemsCount(int count) {
    return '$count item(s)';
  }

  @override
  String get ordersQuantity => 'Quantity';

  @override
  String get ordersRequester => 'Requester';

  @override
  String get ordersDate => 'Date';

  @override
  String get ordersView => 'View';

  @override
  String get ordersSupply => 'Supply';

  @override
  String get ordersEmptyTitle => 'No Orders';

  @override
  String get ordersEmptyMessage => 'No orders match the current filter';

  @override
  String ordersSupplyConfirmed(Object material, Object order) {
    return 'Supply confirmed for $material (order $order)';
  }

  @override
  String ordersCountSummary(Object count, Object total) {
    return '$count orders of $total';
  }

  @override
  String get orderDetailsSubtitle =>
      'Details of the materials order sent to the warehouse';

  @override
  String get orderDetailsInfoSection => 'Order Information';

  @override
  String get orderDetailsItems => 'Order Items';

  @override
  String get orderDetailsProgressSection => 'Supply Progress';

  @override
  String get orderDetailsNotes => 'Notes';

  @override
  String get orderDetailsModifications => 'Modification requests';

  @override
  String get orderDetailsStatusLabel => 'Order Status';

  @override
  String get orderDetailsOrderDate => 'Order Date';

  @override
  String get orderDetailsRequestData => 'Order Data';

  @override
  String get orderDetailsMaterial => 'Material';

  @override
  String get orderDetailsPriority => 'Priority';

  @override
  String get orderDetailsNormal => 'Normal';

  @override
  String get orderDetailsRequesterData => 'Requester Data';

  @override
  String get orderDetailsParty => 'Party';

  @override
  String get orderDetailsResponsible => 'Responsible';

  @override
  String get orderDetailsRequestNumber => 'Order Number';

  @override
  String get orderTimelineReceived => 'Received';

  @override
  String get orderTimelinePartial => 'Partial Supply';

  @override
  String orderDetailsTitle(Object req) {
    return 'Supply Order Details $req';
  }

  @override
  String get notifEmptyTitle => 'No Notifications';

  @override
  String get notifEmptyMessage => 'No notifications to show in this filter';

  @override
  String get notifGroupToday => 'Today';

  @override
  String get notifGroupYesterday => 'Yesterday';

  @override
  String get notifGroupOlder => 'Older';

  @override
  String get notifBadgeOrder => 'Order';

  @override
  String get notifBadgeDone => 'Done';

  @override
  String get reportRangeDaily => 'Daily';

  @override
  String get reportRangeWeekly => 'Weekly';

  @override
  String get reportRangeMonthly => 'Monthly';

  @override
  String get reportRangeYearly => 'Yearly';

  @override
  String get reportSuppliersPerf => 'Suppliers Performance';

  @override
  String get reportTopMaterials => 'Most Consumed Materials';

  @override
  String get reportFullReport => 'Full Report';

  @override
  String get reportExportPdf => 'Export PDF';

  @override
  String get reportExportExcel => 'Export Excel';

  @override
  String get reportStatAvgSupplyTime => 'Avg Supply Time';

  @override
  String get reportStatSupplyRate => 'Supply Rate';

  @override
  String get reportStatConsumed => 'Materials Consumed';

  @override
  String get whReportByCategory => 'Consumption by Category';

  @override
  String get whReportActivityByDay => 'Activity by Day';

  @override
  String get whReportMockNote =>
      'Demo data — will be wired when backend is ready';

  @override
  String get whReportPurchasesTitle => 'Purchases report';

  @override
  String get whReportStatInvoices => 'Invoices';

  @override
  String get whReportStatSpending => 'Total spending (SYP)';

  @override
  String get whReportStatAvgInvoice => 'Avg invoice (SYP)';

  @override
  String get whReportStatSuppliers => 'Suppliers';

  @override
  String get whReportBySupplier => 'Spending by supplier';

  @override
  String get whReportByMonth => 'Monthly spending';

  @override
  String get whReportTypePurchases => 'Purchases';

  @override
  String get whReportTypeStockMovement => 'Stock Movement';

  @override
  String get whReportTypeMaterialRequests => 'Material Requests';

  @override
  String get whReportStockMovementTitle => 'Stock Movement Report';

  @override
  String get whReportStatIncoming => 'Total Incoming';

  @override
  String get whReportStatOutgoing => 'Total Outgoing';

  @override
  String get whReportStatMovements => 'Movements Count';

  @override
  String get whReportIncomingVsOutgoing => 'Incoming vs Outgoing';

  @override
  String get whReportIncoming => 'Incoming';

  @override
  String get whReportOutgoing => 'Outgoing';

  @override
  String get whReportMovementsByDay => 'Movements by Day';

  @override
  String get whReportMaterialRequestsTitle => 'Material Requests Report';

  @override
  String get whReportStatTotalRequests => 'Total Requests';

  @override
  String get whReportStatFulfilled => 'Fulfilled Requests';

  @override
  String get whReportStatRejected => 'Rejected Requests';

  @override
  String get whReportStatFulfillmentRate => 'Fulfillment Rate';

  @override
  String get whReportByRequester => 'By Requester';

  @override
  String get whReportRequestsByDay => 'Requests by Day';

  @override
  String get whReportTypeOverview => 'Overview';

  @override
  String get whReportOverviewTitle => 'Overview Report';

  @override
  String get whReportStatTotalConsumption => 'Total consumption';

  @override
  String get whReportStatTopConsumed => 'Top consumed';

  @override
  String get whReportStatActiveDays => 'Active days';

  @override
  String get whReportTopCompanies => 'Top supplying companies';

  @override
  String get reportStatTotalMaterials => 'Total Materials';

  @override
  String get reportUnitDay => 'day';

  @override
  String get reportConsumptionByCategory => 'Consumption by Category';

  @override
  String get reportOfConsumption => 'of consumption';

  @override
  String get reportSupplyByDays => 'Supply orders across the month';

  @override
  String get reportLess => 'Less';

  @override
  String get reportMore => 'More';

  @override
  String get reportWeekdaySun => 'Sun';

  @override
  String get reportWeekdayMon => 'Mon';

  @override
  String get reportWeekdayTue => 'Tue';

  @override
  String get reportWeekdayWed => 'Wed';

  @override
  String get reportWeekdayThu => 'Thu';

  @override
  String get reportWeekdayFri => 'Fri';

  @override
  String get reportWeekdaySat => 'Sat';

  @override
  String reportMonthlyTitle(Object period) {
    return '$period — Monthly Report';
  }

  @override
  String reportGeneratedAt(Object date) {
    return 'Report generated $date';
  }

  @override
  String reportDaysCount(Object days) {
    return '$days days';
  }

  @override
  String reportSupplierSubtitle(Object invoices, Object avgDays) {
    return '$invoices invoices · avg $avgDays days';
  }

  @override
  String get whBadgeTotal => 'Total';

  @override
  String get whStatOutMaterials => 'Out of Stock';

  @override
  String get whStatLowMaterials => 'Low Stock';

  @override
  String get whStatAvailMaterials => 'Available Materials';

  @override
  String get whStatTotalMaterials => 'Materials in Warehouse';

  @override
  String get whMaterialsEmptyTitle => 'No Materials';

  @override
  String get whMaterialsEmptyMessage =>
      'No materials match the current filters';

  @override
  String get whColCode => 'Code';

  @override
  String get whColName => 'Material Name';

  @override
  String get whColCategory => 'Category';

  @override
  String get whColStock => 'Stock';

  @override
  String get whColMinStock => 'Min Stock';

  @override
  String get whColExpiry => 'Expiry';

  @override
  String get whColSupplier => 'Supplier';

  @override
  String get whColPrice => 'Price';

  @override
  String get whColCompany => 'Company';

  @override
  String get whColDosage => 'Dosage';

  @override
  String get whColBatches => 'Batches';

  @override
  String get whColStatus => 'Status';

  @override
  String whMaterialsCount(Object count, Object total) {
    return '$count materials of $total';
  }

  @override
  String get invStatusPaid => 'Paid';

  @override
  String get invStatusPending => 'Pending';

  @override
  String get invEmptyTitle => 'No Invoices';

  @override
  String get invEmptyMessage => 'No invoices match the current filter';

  @override
  String get invPurchaseInvoices => 'Purchase Invoices';

  @override
  String get invAddInvoice => 'Add Invoice';

  @override
  String get invBadgePaid => 'Paid';

  @override
  String get invBadgePending => 'Pending';

  @override
  String get invBadgeTotal => 'Total';

  @override
  String get invStatThisMonth => 'invoices this month';

  @override
  String get invStatPaidTotal => 'Total Paid';

  @override
  String get invStatPendingPay => 'Awaiting Payment';

  @override
  String get invStatTotalPurchases => 'Total Purchases';

  @override
  String get invColNumber => 'Invoice Number';

  @override
  String get invColItemCount => 'Item Count';

  @override
  String get invColTotalSyp => 'Total (SYP)';

  @override
  String get invSupplierLabel => 'Supplier';

  @override
  String get invDetailsTitle => 'Invoice details';

  @override
  String get invUnitPriceLabel => 'Unit price';

  @override
  String get invLineTotalLabel => 'Total';

  @override
  String get invCreatedByLabel => 'Created by';

  @override
  String get invGrandTotalLabel => 'Total purchases (SYP)';

  @override
  String invInvoiceNumber(String id) {
    return 'Invoice #$id';
  }

  @override
  String invItemsCountLabel(int count) {
    return '$count material(s)';
  }

  @override
  String invCount(Object count, Object total) {
    return '$count invoices of $total';
  }

  @override
  String get fieldRequired => 'Required';

  @override
  String get fieldOptional => 'Optional';

  @override
  String get fieldInvalidNumber => 'Invalid number';

  @override
  String get fieldInvalidAmount => 'Invalid amount';

  @override
  String get fieldWriteOrPick => 'Type or pick from the list...';

  @override
  String get invFormTitle => 'Add Purchase Invoice';

  @override
  String get invFormSubtitle => 'Fill in the new invoice details';

  @override
  String get invFormSupplier => 'Supplier';

  @override
  String get invFormSupplierHint => 'e.g. Medical Supplies Co.';

  @override
  String get invFormDate => 'Date';

  @override
  String get invFormNotes => 'Notes';

  @override
  String get invFormSave => 'Save Invoice';

  @override
  String get invFormItemsTitle => 'Invoice Items';

  @override
  String get invFormAddItem => 'Add Material';

  @override
  String get invFormMaterialLabel => 'Material';

  @override
  String get invFormMaterialHint => 'Choose a material';

  @override
  String get invFormQuantityLabel => 'Quantity';

  @override
  String get invFormItemsRequired => 'Add at least one material';

  @override
  String get invFormQuantityInvalid => 'Quantity must be greater than zero';

  @override
  String get invFormItemsLockedNotice =>
      'Items can\'t be edited after the invoice is created';

  @override
  String get invCreateSuccess => 'Invoice created successfully';

  @override
  String get invUpdateSuccess => 'Invoice updated successfully';

  @override
  String whGreeting(String name) {
    return 'Hello, $name';
  }

  @override
  String get whSystemsNormal => 'All systems operating normally';

  @override
  String get whLastUpdateLabel => 'Last update: ';

  @override
  String get whLastUpdateJustNow => 'Just now';

  @override
  String whLastUpdateMinutesAgo(int minutes) {
    return '${minutes}m ago';
  }

  @override
  String whLastUpdateHoursAgo(int hours) {
    return '${hours}h ago';
  }

  @override
  String get whMiniExpiringSoon => 'Expiring soon';

  @override
  String get whTotalMaterials => 'Total materials';

  @override
  String get whMiniOrdersToday => 'Today\'s orders';

  @override
  String get whSupplyRate => 'Supply rate';

  @override
  String get whStatLowStockShort => 'Low-stock materials';

  @override
  String get whStatPendingSupply => 'Orders awaiting supply';

  @override
  String get whStatMonthPurchases => 'Month purchases (SYP)';

  @override
  String get whStatExpiredBatches => 'Expired batches';

  @override
  String get whStatStockValue => 'Stock value (SYP)';

  @override
  String get whBadgeAlert => 'Alert';

  @override
  String get whBadgeNew => 'New';

  @override
  String get whBadgeThisMonth => 'This month';

  @override
  String get whNeedsSupply => 'Needs supply';

  @override
  String whTrendThisWeek(String count) {
    return '$count this week';
  }

  @override
  String whTrendToday(String count) {
    return '$count today';
  }

  @override
  String whTrendVsLastMonth(String value) {
    return '$value from last month';
  }

  @override
  String get whExpiringTitle => 'Materials expiring soon';

  @override
  String get whExpiringSubtitle =>
      'These materials must be handled before they expire';

  @override
  String whTodayOrdersCount(Object count) {
    return '$count orders';
  }

  @override
  String get whInvMostRequestedTitle => 'Most Requested';

  @override
  String get whInvLowStockTitle => 'Low Stock';

  @override
  String get whInvNoItems => 'No items right now';

  @override
  String whInvDaysRemaining(int days) {
    return '$days days';
  }

  @override
  String get labNotifActionOpenOrder => 'Open order';

  @override
  String get labNotifActionReview => 'Review';

  @override
  String get labActionTrack => 'Track';

  @override
  String get labReqStatusUnavailable => 'Unavailable';

  @override
  String get labReqStatusInProgress => 'In Progress';

  @override
  String get labReqRequestedBy => 'Requested by';

  @override
  String get labReqLabOrder => 'Lab order';

  @override
  String get labReqEmptyCategory => 'No material requests in this category';

  @override
  String get labReqNewRequest => 'New material request';

  @override
  String get labReqSearchHint =>
      'Filter material requests... (material, id, company)';

  @override
  String get labReqMaterialPickHint =>
      'Type to search warehouse materials or enter a new one';

  @override
  String get labReqDeleteTitle => 'Delete material request';

  @override
  String labReqDeleteConfirm(String material) {
    return 'Delete the \"$material\" request? This cannot be undone.';
  }

  @override
  String get labReqFieldMaterial => 'Material name';

  @override
  String get labReqFieldUnit => 'Unit';

  @override
  String get labReqFieldCompany => 'Company name';

  @override
  String get labReqFieldReason => 'Request reason';

  @override
  String get labReqReasonHint =>
      'e.g. new material not available in the warehouse';

  @override
  String get labReqMaterialRequired => 'Material name is required';

  @override
  String get labReqQuantityRequired => 'Enter a valid quantity';

  @override
  String get labReqSubmit => 'Send request';

  @override
  String get labReqSentSuccess => 'Material request sent to the warehouse';

  @override
  String get labTechPendingAssign => 'Awaiting assignment';

  @override
  String get labTechWorkloadLoadFailed =>
      'Couldn\'t load technicians\' current workload — names and schedules are accurate, but task counts may not reflect reality';

  @override
  String get techAddButton => 'Add technician';

  @override
  String get techAddTitle => 'Add new technician';

  @override
  String get techAddSubtitle =>
      'Enter the technician\'s details to join the lab team';

  @override
  String get techSectionBasic => 'Basic information';

  @override
  String get techFieldFullName => 'Full name';

  @override
  String get techFieldFullNameHint => 'e.g. Mohammad Ali';

  @override
  String get techFieldRole => 'Role / Specialty';

  @override
  String get techFieldPhone => 'Phone number (optional)';

  @override
  String get techFieldShiftStart => 'Shift start';

  @override
  String get techFieldShiftEnd => 'Shift end';

  @override
  String get techSkills => 'Skills';

  @override
  String get techNotesHint => 'Additional notes about the technician...';

  @override
  String get techNoNameYet => 'No name yet';

  @override
  String get orderDetailsProgress => 'Work progress';

  @override
  String get orderDetailsHeading => 'Order details';

  @override
  String get orderDetailsSubtitleLab =>
      'Order details sent from the doctor to the lab';

  @override
  String get orderDetailsExpectedDelivery => 'Expected delivery date';

  @override
  String get orderDetailsOrderData => 'Order data';

  @override
  String get orderDetailsDoctorData => 'Doctor data';

  @override
  String get orderDetailsSenderDoctor => 'Sending doctor';

  @override
  String get orderDetailsReceivingLab => 'Receiving lab';

  @override
  String get orderDetailsReadyForDelivery => 'Ready for delivery';

  @override
  String get labProcessUpdateStatus => 'Update status';

  @override
  String get labProcessTitle => 'Process order';

  @override
  String get labProcessDeliveredDesc =>
      'Material available and delivered to the doctor';

  @override
  String get labProcessReadyRequiresInProgress =>
      'Manufacturing must start first (in progress) before it can be marked ready for delivery';

  @override
  String get labProcessMissingDesc => 'Material not available in the lab';

  @override
  String get labAssignTitle => 'Assign order';

  @override
  String labAssignSubtitle(String name) {
    return 'Choose the order for $name';
  }

  @override
  String get profilePageSubtitle => 'Employee data and job information';

  @override
  String get labInventory => 'Lab Inventory';

  @override
  String get labInvSearchHint => 'Search lab materials...';

  @override
  String get labInvTotal => 'Total materials';

  @override
  String get labInvLow => 'Low stock';

  @override
  String get labInvOut => 'Out of stock';

  @override
  String get stockLogsTitle => 'Movement log';

  @override
  String get stockLogsEmpty => 'No recorded movements';

  @override
  String get labInvColCategory => 'Category';

  @override
  String get labInvConsume => 'Record usage';

  @override
  String get labInvConsumeTitle => 'Record material usage';

  @override
  String get labInvConsumeAmount => 'Consumed quantity';

  @override
  String get labInvConsumeHint => 'Enter the quantity withdrawn from stock';

  @override
  String get labInvCurrentQty => 'Currently available';

  @override
  String get labInvEmpty => 'No materials in this category';

  @override
  String get labInvConsumeExceeds => 'Quantity exceeds available stock';

  @override
  String get labInvConsumeInvalid => 'Enter a valid quantity';

  @override
  String get labProducts => 'Lab Products';

  @override
  String get labProductsSearchHint => 'Search products...';

  @override
  String get labProdTotal => 'Total products';

  @override
  String get labProdAdd => 'New product';

  @override
  String get labProdAddTitle => 'Add product';

  @override
  String get labProdEditTitle => 'Edit product';

  @override
  String get labProdDeleteTitle => 'Delete product';

  @override
  String labProdDeleteConfirm(String name) {
    return 'Delete \"$name\"? This action cannot be undone.';
  }

  @override
  String get labProdColType => 'Type';

  @override
  String get labProdColPrice => 'Price (SYP)';

  @override
  String get labProdColDuration => 'Production time';

  @override
  String get labProdDaysUnit => 'days';

  @override
  String get labProdFieldName => 'Product name';

  @override
  String get labProdFieldType => 'Type';

  @override
  String get labProdFieldMaterial => 'Material';

  @override
  String get labProdFieldPrice => 'Price in Syrian Pounds';

  @override
  String get labProdFieldDuration => 'Production time (days)';

  @override
  String get labProdFieldCategory => 'Category';

  @override
  String get labProdNoCategory => 'No category';

  @override
  String get labProdEmpty => 'No products';

  @override
  String get labOrdersEmpty => 'No orders today';

  @override
  String get labCategoriesManage => 'Manage Categories';

  @override
  String get labCategoryNameHint => 'New category name';

  @override
  String get labCategoryAdd => 'Add';

  @override
  String get labCategoriesEmpty => 'No categories yet';

  @override
  String get labCategoryDeleteTitle => 'Delete Category';

  @override
  String labCategoryDeleteConfirm(String name) {
    return 'Delete “$name”?';
  }

  @override
  String labProcessConsumeFailed(String materials) {
    return 'Order completed, but stock deduction failed for: $materials';
  }

  @override
  String get labProdNameRequired => 'Product name is required';

  @override
  String get labProcessCost => 'Order cost (SYP)';

  @override
  String get labProcessTechnician => 'Executing technician';

  @override
  String get labProcessTechnicianNone => 'Not specified';

  @override
  String get labProcessTechnicianRequired =>
      'Select the executing technician before changing the status';

  @override
  String get labProcessManufacturingDesc =>
      'Order is currently being manufactured';

  @override
  String get labProcessReadyTitle => 'Ready for delivery';

  @override
  String get orderDetailsCost => 'Cost';

  @override
  String get orderDetailsExecutor => 'Executing technician';

  @override
  String get whMovementColumn => 'Movement';

  @override
  String get whMovementTitle => 'Stock movement';

  @override
  String get whMovementIn => 'Stock in';

  @override
  String get whMovementOut => 'Stock out';

  @override
  String get whMovementAmount => 'Quantity';

  @override
  String get whMovementExceeds => 'Quantity exceeds available stock';

  @override
  String get whMovementInvalid => 'Enter a valid quantity';

  @override
  String get whMovementCurrent => 'Currently available';

  @override
  String get whStockTitle => 'Stock management';

  @override
  String get whStockTotal => 'Total available';

  @override
  String get whStockBatches => 'Batches';

  @override
  String get whStockNoBatches => 'No batches for this material yet';

  @override
  String get whStockNewViaPurchaseInvoice =>
      'New stock is now added via a purchase invoice — from the Purchase Invoices page.';

  @override
  String get whStockExpiry => 'Expiry date (optional)';

  @override
  String get whStockExpiryNone => 'No expiry';

  @override
  String get whStockExpired => 'Expired';

  @override
  String get whStockNotes => 'Notes (optional)';

  @override
  String get whStockReason => 'Reason';

  @override
  String get whStockAdjust => 'Adjust quantity';

  @override
  String get whStockAdd => 'Add';

  @override
  String get whStockDeduct => 'Remove';

  @override
  String get whStockReasonPurchase => 'Purchase';

  @override
  String get whStockReasonFulfillment => 'Fulfillment';

  @override
  String get whStockReasonExpired => 'Expired/disposed';

  @override
  String get whStockReasonAdjustment => 'Adjustment';

  @override
  String get whStockReasonReturn => 'Return';

  @override
  String get whStockBatchLabel => 'Batch';

  @override
  String get whStockCreatedAt => 'Added';

  @override
  String get whStockLogButton => 'Movement log';

  @override
  String get whStockLogTitle => 'Stock movement log';

  @override
  String get whStockLogFilterLabel => 'Filter by material';

  @override
  String get whStockLogEmpty => 'No movements recorded';

  @override
  String get whStockLogLowBadge => 'Low';

  @override
  String get labProcessConsumedSection => 'Materials consumed from inventory';

  @override
  String get labProcessConsumedHint =>
      'These materials are deducted from lab inventory on save';

  @override
  String get labProcessAddMaterial => 'Add material';

  @override
  String get labProcessSelectMaterial => 'Select material';

  @override
  String get labProcessMaterialsCost => 'Materials cost';

  @override
  String get labProcessNoMaterials => 'No materials added yet';
}
