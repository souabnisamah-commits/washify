import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:washify/core/constants/user_roles.dart';
import 'package:washify/providers/auth_provider.dart';
import 'package:washify/core/observers/audit_navigator_observer.dart';

// Screens
import 'package:washify/features/auth/login_screen.dart';
import 'package:washify/features/dashboard/admin_dashboard.dart';
import 'package:washify/features/dashboard/patron_dashboard.dart';
import 'package:washify/features/dashboard/cashier_dashboard.dart';
import 'package:washify/features/dashboard/worker_dashboard.dart';
import 'package:washify/features/audit/screens/audit_application_screen.dart';
import 'package:washify/features/employees/employees_screen.dart';
import 'package:washify/features/clients/clients_screen.dart';
import 'package:washify/features/clients/b2b_client_dashboard_screen.dart';

// Child Screens
import 'package:washify/features/stations/stations_screen.dart';
import 'package:washify/features/stations/station_form_screen.dart';
import 'package:washify/features/station/models/station.dart';
import 'package:washify/features/services/services_screen.dart';
import 'package:washify/features/services/vehicle_categories_screen.dart';
import 'package:washify/features/services/service_definitions_screen.dart';
import 'package:washify/features/services/offers_screen.dart';
import 'package:washify/features/services/models/offer.dart';
import 'package:washify/features/hr/screens/hr_dashboard_screen.dart';
import 'package:washify/features/tickets/models/ticket.dart';
import 'package:washify/features/products/products_screen.dart';
import 'package:washify/features/stock/stock_screen.dart';
import 'package:washify/features/stock/stock_entry_screen.dart';
import 'package:washify/features/tickets/tickets_screen.dart';
import 'package:washify/features/tickets/new_ticket_screen.dart';
import 'package:washify/features/wallet/wallet_screen.dart';
import 'package:washify/features/payroll/payroll_screen.dart';
import 'package:washify/features/stations/patron_station_settings_screen.dart';
import 'package:washify/features/caisse/screens/patron_caisse_screen.dart';
import 'package:washify/features/caisse/screens/daily_recap_screen.dart';

import 'package:washify/features/inventory/inventory_history_screen.dart';
import 'package:washify/features/inventory/inventory_form_screen.dart';
import 'package:washify/features/inventory/inventory_report_screen.dart';
// Multi-Role Dashboards
import 'package:washify/features/dashboard/multi_role_dashboards.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final userState = ref.watch(currentUserProvider);

  return GoRouter(
    initialLocation: '/login',
    observers: [AuditNavigatorObserver(ref)],
    redirect: (context, state) {
      final isLoggedIn = userState != null;
      final isLoggingIn = state.matchedLocation == '/login';

      if (!isLoggedIn) {
        return isLoggingIn ? null : '/login';
      }

      final roles = userState.roles;

      if (isLoggingIn) {
        if (roles.contains(UserRole.admin)) return '/admin';
        if (roles.contains(UserRole.clientB2B)) return '/client-b2b';

        final isPatron = roles.contains(UserRole.patron);
        final isWorker = roles.contains(UserRole.ouvrier);
        final isCashier = roles.contains(UserRole.caissier);

        if (roles.length > 1) {
          if (isPatron && isWorker && isCashier) return '/patron-worker-cashier';
          if (isPatron && isCashier) return '/patron-cashier';
          if (isPatron && isWorker) return '/patron-worker';
          if (isWorker && isCashier) return '/worker-cashier';
        }

        if (isPatron) return '/patron';
        if (isCashier) return '/cashier';
        if (isWorker) return '/worker';
      }

      // Role-based route guards
      final path = state.matchedLocation;
      if (path.startsWith('/admin') && !roles.contains(UserRole.admin)) return '/login';
      if (path.startsWith('/client-b2b') && !roles.contains(UserRole.clientB2B)) return '/login';
      
      // We check if the path starts with a base role path, and only restrict if they DON'T have that role
      if (path == '/patron' || path.startsWith('/patron/')) {
        if (!roles.contains(UserRole.patron)) return '/login';
      }
      if (path == '/cashier' || path.startsWith('/cashier/')) {
        if (!roles.contains(UserRole.caissier) && !roles.contains(UserRole.patron)) return '/login';
      }
      if (path == '/worker' || path.startsWith('/worker/')) {
        if (!roles.contains(UserRole.ouvrier)) return '/login';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      // Multi-role portal routes
      GoRoute(
        path: '/patron-worker-cashier',
        builder: (context, state) => const PatronWorkerCashierDashboard(),
      ),
      GoRoute(
        path: '/patron-cashier',
        builder: (context, state) => const PatronCashierDashboard(),
      ),
      GoRoute(
        path: '/patron-worker',
        builder: (context, state) => const PatronWorkerDashboard(),
      ),
      GoRoute(
        path: '/worker-cashier',
        builder: (context, state) => const WorkerCashierDashboard(),
      ),
      // Admin Routes
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminDashboard(),
        routes: [
          GoRoute(
            path: 'stations/create',
            builder: (context, state) => const StationFormScreen(),
          ),
          GoRoute(
            path: 'stations/edit',
            builder: (context, state) {
              final station = state.extra as Station?;
              return StationFormScreen(station: station);
            },
          ),
          GoRoute(
            path: 'stations',
            builder: (context, state) => const StationsScreen(),
          ),
          GoRoute(
            path: 'audit',
            builder: (context, state) => const AuditApplicationScreen(),
          ),
        ],
      ),
      // Patron Routes (Can be accessed directly or via portal)
      GoRoute(
        path: '/patron',
        builder: (context, state) => const PatronDashboard(),
        routes: [
          GoRoute(
            path: 'employees',
            builder: (context, state) => const EmployeesScreen(),
          ),
          GoRoute(
            path: 'hr',
            builder: (context, state) => const HRDashboardScreen(),
          ),
          GoRoute(
            path: 'services',
            builder: (context, state) => const ServicesScreen(),
          ),
          GoRoute(
            path: 'vehicle-categories',
            builder: (context, state) => const VehicleCategoriesScreen(),
          ),
          GoRoute(
            path: 'service-definitions',
            builder: (context, state) => const ServiceDefinitionsScreen(),
          ),
          GoRoute(
            path: 'offers',
            builder: (context, state) => const OffersScreen(),
          ),
          GoRoute(
            path: 'clients',
            builder: (context, state) => const ClientsScreen(),
          ),
          GoRoute(
            path: 'products',
            builder: (context, state) => const ProductsScreen(),
          ),
          GoRoute(
            path: 'stock',
            builder: (context, state) => const StockScreen(),
            routes: [
              GoRoute(
                path: 'entry',
                builder: (context, state) => const StockEntryScreen(),
              ),
            ],
          ),
           GoRoute(
             path: 'settings',
             builder: (context, state) => const PatronStationSettingsScreen(),
           ),
           GoRoute(
             path: 'caisse',
             builder: (context, state) => const PatronCaisseScreen(),
           ),
           GoRoute(
             path: 'daily-recap',
             builder: (context, state) => const DailyRecapScreen(),
           ),
            GoRoute(
              path: 'payroll',
              builder: (context, state) => const PayrollScreen(),
            ),
            GoRoute(
              path: 'tickets/new',
              builder: (context, state) {
                final editTicket = state.extra as Ticket?;
                return NewTicketScreen(editTicket: editTicket);
              },
            ),
          GoRoute(
            path: 'inventory',
            builder: (context, state) => const InventoryHistoryScreen(),
            routes: [
              GoRoute(
                path: 'new',
                builder: (context, state) => const InventoryFormScreen(),
              ),
              GoRoute(
                path: 'report/:id',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return InventoryReportScreen(inventoryId: id);
                },
              ),
            ],
          ),
        ],
      ),
      // Cashier Routes
      GoRoute(
        path: '/cashier',
        builder: (context, state) => const CashierDashboard(),
        routes: [
          GoRoute(
            path: 'tickets/new',
            builder: (context, state) {
              final editTicket = state.extra as Ticket?;
              return NewTicketScreen(editTicket: editTicket);
            },
          ),
          GoRoute(
            path: 'tickets',
            builder: (context, state) => const TicketsScreen(),
          ),
          GoRoute(
            path: 'stock',
            builder: (context, state) => const StockScreen(),
            routes: [
              GoRoute(
                path: 'entry',
                builder: (context, state) => const StockEntryScreen(),
              ),
            ],
          ),
        ],
      ),
      // Worker Routes
      GoRoute(
        path: '/worker',
        builder: (context, state) => const WorkerDashboard(),
        routes: [
          GoRoute(
            path: 'wallet',
            builder: (context, state) => const WalletScreen(),
          ),
        ],
      ),
      // B2B Client Portal Route
      GoRoute(
        path: '/client-b2b',
        builder: (context, state) => const B2BClientDashboardScreen(),
      ),
    ],
  );
});

