import 'package:flutter/material.dart';
import 'package:washify/core/localization/app_localizations.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:washify/core/theme/app_theme.dart';
import 'package:washify/features/hr/screens/planification_screen.dart';
import 'package:washify/features/hr/screens/shifts_management_screen.dart';
import 'package:washify/features/hr/screens/attendance_screen.dart';
import 'package:washify/features/hr/screens/payroll_management_screen.dart';
import 'package:washify/features/hr/screens/rendement_report_screen.dart';

class HRDashboardScreen extends ConsumerStatefulWidget {
  const HRDashboardScreen({super.key});

  @override
  ConsumerState<HRDashboardScreen> createState() => _HRDashboardScreenState();
}

class _HRDashboardScreenState extends ConsumerState<HRDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ressources Humaines'.tr),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryBlue,
          unselectedLabelColor: Theme.of(context).brightness == Brightness.dark ? Colors.white54 : Colors.black54,
          indicatorColor: AppTheme.primaryBlue,
          isScrollable: true,
          tabs: [
            Tab(icon: Icon(Icons.event_available), text: 'Planification'),
            Tab(icon: Icon(Icons.check_circle_outline), text: 'Pointage'),
            Tab(icon: Icon(Icons.payment), text: 'Salaires & Avances'),
            Tab(icon: Icon(Icons.schedule), text: 'Shifts'),
            Tab(icon: Icon(Icons.bar_chart), text: 'Rendement'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          PlanificationScreen(),
          AttendanceScreen(),
          PayrollManagementScreen(),
          ShiftsManagementScreen(),
          RendementReportScreen(),
        ],
      ),
    );
  }
}
