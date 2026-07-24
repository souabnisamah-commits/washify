import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'tabs/audit_dashboard_tab.dart';
import 'tabs/audit_journal_tab.dart';
import 'tabs/user_status_tab.dart';
import 'tabs/user_history_tab.dart';

class AuditApplicationScreen extends ConsumerStatefulWidget {
  const AuditApplicationScreen({super.key});

  @override
  ConsumerState<AuditApplicationScreen> createState() => _AuditApplicationScreenState();
}

class _AuditApplicationScreenState extends ConsumerState<AuditApplicationScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
        title: const Text('Audit Application'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Vue Panoramique'),
            Tab(icon: Icon(Icons.bug_report), text: 'Journal Audit'),
            Tab(icon: Icon(Icons.people), text: 'État Utilisateur'),
            Tab(icon: Icon(Icons.history_edu), text: 'Historique Utilisateur'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          AuditDashboardTab(),
          AuditJournalTab(),
          UserStatusTab(),
          UserHistoryTab(),
        ],
      ),
    );
  }
}
