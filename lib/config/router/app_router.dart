import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:washify/core/constants/user_roles.dart';
import 'package:washify/providers/auth_provider.dart';

// Screens
import 'package:washify/features/auth/login_screen.dart';
import 'package:washify/features/dashboard/admin_dashboard.dart';
import 'package:washify/features/dashboard/patron_dashboard.dart';
import 'package:washify/features/dashboard/cashier_dashboard.dart';
import 'package:washify/features/dashboard/worker_dashboard.dart';

// Child Screens
import 'package:washify/features/stations/stations_screen.dart';
import 'package:washify/features/employees/employees_screen.dart';
import 'package:washify/features/services/services_screen.dart';
import 'package:washify/features/products/products_screen.dart';
import 'package:washify/features/stock/stock_screen.dart';
import 'package:washify/features/tickets/tickets_screen.dart';
import 'package:washify/features/tickets/new_ticket_screen.dart';
import 'package:washify/features/wallet/wallet_screen.dart';
import 'package:washify/features/payroll/payroll_screen.dart';
import 'package:washify/features/audit/audit_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final userState = ref.watch(currentUserProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isLoggedIn = userState != null;
      final isLoggingIn = state.matchedLocation == '/login';

      if (!isLoggedIn) {
        return isLoggingIn ? null : '/login';
      }

      if (isLoggingIn) {
        switch (userState.role) {
          case UserRole.admin:
            return '/admin';
          case UserRole.patron:
            return '/patron';
          case UserRole.caissier:
            return '/cashier';
          case UserRole.ouvrier:
            return '/worker';
        }
      }

      // Role-based route guards
      final path = state.matchedLocation;
      if (path.startsWith('/admin') && userState.role != UserRole.admin) {
        return '/login';
      }
      if (path.startsWith('/patron') && userState.role != UserRole.patron) {
        return '/login';
      }
      if (path.startsWith('/cashier') && userState.role != UserRole.caissier) {
        return '/login';
      }
      if (path.startsWith('/worker') && userState.role != UserRole.ouvrier) {
        return '/login';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      // Admin Routes
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminDashboard(),
        routes: [
          GoRoute(
            path: 'stations',
            builder: (context, state) => const StationsScreen(),
          ),
          GoRoute(
            path: 'audit',
            builder: (context, state) => const AuditScreen(),
          ),
        ],
      ),
      // Patron Routes
      GoRoute(
        path: '/patron',
        builder: (context, state) => const PatronDashboard(),
        routes: [
          GoRoute(
            path: 'employees',
            builder: (context, state) => const EmployeesScreen(),
          ),
          GoRoute(
            path: 'services',
            builder: (context, state) => const ServicesScreen(),
          ),
          GoRoute(
            path: 'products',
            builder: (context, state) => const ProductsScreen(),
          ),
          GoRoute(
            path: 'stock',
            builder: (context, state) => const StockScreen(),
          ),
          GoRoute(
            path: 'payroll',
            builder: (context, state) => const PayrollScreen(),
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
            builder: (context, state) => const NewTicketScreen(),
          ),
          GoRoute(
            path: 'tickets',
            builder: (context, state) => const TicketsScreen(),
          ),
          GoRoute(
            path: 'stock',
            builder: (context, state) => const StockScreen(),
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
    ],
  );
});
