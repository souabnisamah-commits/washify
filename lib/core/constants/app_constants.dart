// Core constants for the Washify application
class AppConstants {
  AppConstants._();

  static const String appName = 'Washify';
  static const String appVersion = '1.0.0';

  // Default admin credentials
  static const String defaultAdminPhone = '52025870';
  static const String defaultAdminPin = '1012';
  static const String defaultAdminName = 'Administrateur';

  // Firestore collection names
  static const String usersCollection = 'users';
  static const String stationsCollection = 'stations';
  static const String employeesCollection = 'employees';
  static const String servicesCollection = 'services';
  static const String productsCollection = 'products';
  static const String stockCollection = 'stock';
  static const String inventoriesCollection = 'inventories';
  static const String ticketsCollection = 'tickets';
  static const String walletsCollection = 'wallets';
  static const String walletTransactionsCollection = 'wallet_transactions';
  static const String payrollCollection = 'payroll';
  static const String auditLogsCollection = 'audit_logs';
  static const String notificationsCollection = 'notifications';
  static const String commissionRulesCollection = 'commission_rules';
  static const String vehicleCategoriesCollection = 'vehicleCategories';
  static const String serviceDefinitionsCollection = 'serviceDefinitions';
  static const String offersCollection = 'offers';

  // Pagination
  static const int defaultPageSize = 20;

  // Ticket statuses
  static const String ticketStatusPending = 'pending';
  static const String ticketStatusInProgress = 'in_progress';
  static const String ticketStatusCompleted = 'completed';
  static const String ticketStatusCancelled = 'cancelled';

  // Stock movement types
  static const String stockMovementIn = 'in';
  static const String stockMovementOut = 'out';
  static const String stockMovementAdjustment = 'adjustment';

  // Wallet transaction types
  static const String walletDeposit = 'deposit';
  static const String walletWithdrawal = 'withdrawal';
  static const String walletCommission = 'commission';
  static const String walletPayroll = 'payroll';

  // Payroll statuses
  static const String payrollPending = 'pending';
  static const String payrollApproved = 'approved';
  static const String payrollPaid = 'paid';
}
