import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:washify/core/localization/app_localizations.dart';
import 'package:washify/core/theme/app_theme.dart';
import 'package:washify/providers/auth_provider.dart';
import 'package:washify/providers/employee_provider.dart';
import 'package:washify/providers/caisse_provider.dart';
import 'package:washify/features/caisse/models/cash_session.dart';
import 'package:washify/features/caisse/models/cash_movement.dart';
import 'package:washify/features/employees/models/employee.dart';
import 'package:washify/core/constants/user_roles.dart';

class PatronCaisseScreen extends ConsumerStatefulWidget {
  const PatronCaisseScreen({super.key});

  @override
  ConsumerState<PatronCaisseScreen> createState() => _PatronCaisseScreenState();
}

class _PatronCaisseScreenState extends ConsumerState<PatronCaisseScreen> {
  final _initialBalanceController = TextEditingController();
  final _finalBalanceController = TextEditingController();
  final _movementAmountController = TextEditingController();
  final _movementReasonController = TextEditingController();

  bool _isSaving = false;
  Employee? _selectedEmployeeForAdvance;
  String _movementType = 'out'; // 'in' or 'out'
  String _outType = 'depense'; // 'depense' or 'acompte'

  @override
  void dispose() {
    _initialBalanceController.dispose();
    _finalBalanceController.dispose();
    _movementAmountController.dispose();
    _movementReasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final activeSessionAsync = ref.watch(activeSessionProvider);
    final historyAsync = ref.watch(sessionsHistoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Gestion de Caisse'.tr),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.primaryBlue, AppTheme.accentCyan],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: activeSessionAsync.when(
        data: (session) {
          if (session == null) {
            return _buildClosedCaisseView(user.name);
          }
          return _buildOpenCaisseView(session, user.name);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Erreur active session: $e'.tr)),
      ),
    );
  }

  // View when caisse is closed (no active session)
  Widget _buildClosedCaisseView(String patronName) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Elegant state card
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: AppTheme.errorRed.withValues(alpha: 0.2), width: 1),
            ),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [Colors.red.shade900.withValues(alpha: 0.1), Colors.red.shade800.withValues(alpha: 0.05)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  const Icon(Icons.lock_outline, color: AppTheme.errorRed, size: 64),
                  const SizedBox(height: 16),
                  Text(
                    'La caisse est actuellement fermée'.tr,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.errorRed),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Vous devez ouvrir la caisse avec un solde initial pour commencer à enregistrer les mouvements.'.tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Open caisse form
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Ouvrir la Caisse'.tr,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.primaryBlue),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _initialBalanceController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Fond de caisse initial (DT) *'.tr,
                      prefixIcon: const Icon(Icons.account_balance_wallet_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _isSaving ? null : () => _handleOpenSession(patronName),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.successGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isSaving
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text('Confirmer l\'ouverture'.tr, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // History header
          Text(
            'Historique des sessions'.tr,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.primaryBlue),
          ),
          const SizedBox(height: 12),
          _buildSessionsHistoryList(),
        ],
      ),
    );
  }

  // View when caisse is open (active session exists)
  Widget _buildOpenCaisseView(CashSession session, String patronName) {
    final double calculatedCash = session.initialBalance + session.totalCashIn - session.totalCashOut;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Open state overview card
          Card(
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [Colors.grey.shade900, Colors.grey.shade800],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.lock_open, color: AppTheme.successGreen, size: 24),
                          const SizedBox(width: 8),
                          Text(
                            'Caisse Ouverte'.tr,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
                          ),
                        ],
                      ),
                      Text(
                        'Depuis : ${DateFormat('dd/MM HH:mm').format(session.openingDate)}',
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.white24, height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Solde de caisse actuel'.tr,
                        style: const TextStyle(color: Colors.white70, fontSize: 15),
                      ),
                      Text(
                        '${calculatedCash.toStringAsFixed(2)} DT',
                        style: const TextStyle(color: AppTheme.successGreen, fontSize: 28, fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMiniStat('Fond initial'.tr, session.initialBalance),
                      _buildMiniStat('Total Entrées'.tr, session.totalCashIn, color: AppTheme.successGreen),
                      _buildMiniStat('Total Sorties'.tr, session.totalCashOut, color: AppTheme.errorRed),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Actions Row
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showMovementDialog(context, 'in', patronName),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.successGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.add),
                  label: Text('Alimenter'.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showMovementDialog(context, 'out', patronName),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.errorRed,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.remove),
                  label: Text('Sortie / Acompte'.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () => _showCloseCaisseDialog(context, calculatedCash, session, patronName),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.warningOrange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.lock),
            label: Text('Clôturer la Caisse'.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 24),

          // Current session movements
          Text(
            'Mouvements de la session'.tr,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.primaryBlue),
          ),
          const SizedBox(height: 12),
          _buildSessionMovementsList(session.id),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, double value, {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 12)),
        const SizedBox(height: 4),
        Text(
          '${value.toStringAsFixed(1)} DT',
          style: TextStyle(
            color: color ?? Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  // Open session handler
  void _handleOpenSession(String patronName) async {
    final balance = double.tryParse(_initialBalanceController.text.trim());
    if (balance == null || balance < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez saisir un solde initial valide'.tr)),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final repo = ref.read(caisseRepositoryProvider);
      await repo.openSession(balance, patronName);
      _initialBalanceController.clear();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Caisse ouverte avec succès'.tr)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e'.tr)),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // Dialog for adding movement (In/Out)
  void _showMovementDialog(BuildContext context, String type, String patronName) {
    setState(() {
      _movementType = type;
      _outType = 'depense';
      _selectedEmployeeForAdvance = null;
      _movementAmountController.clear();
      _movementReasonController.clear();
    });

    final employeesAsync = ref.read(employeesStreamProvider(ref.read(currentUserProvider)!.tenantId));

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (stContext, setDialogState) {
            return AlertDialog(
              title: Text(type == 'in' ? 'Alimenter la Caisse'.tr : 'Enregistrer une Sortie'.tr),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (type == 'out') ...[
                      // Choice between advance (acompte) and general expense
                      SegmentedButton<String>(
                        segments: [
                          ButtonSegment(value: 'depense', label: Text('Dépense'.tr)),
                          ButtonSegment(value: 'acompte', label: Text('Acompte'.tr)),
                        ],
                        selected: {_outType},
                        onSelectionChanged: (val) {
                          setDialogState(() {
                            _outType = val.first;
                            if (_outType == 'acompte') {
                              _movementReasonController.text = 'Acompte ouvrier';
                            } else {
                              _movementReasonController.clear();
                            }
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      if (_outType == 'acompte') ...[
                        // Worker Selection
                        employeesAsync.when(
                          data: (employees) {
                            final workers = employees.where((e) =>
                              e.isActive &&
                              (e.roles.contains(UserRole.ouvrier) ||
                               e.roles.any((r) => r.value == 'ouvrier' || r.name == 'ouvrier'))
                            ).toList();
                            final displayList = workers.isNotEmpty ? workers : employees.where((e) => e.isActive).toList();
                            return DropdownButtonFormField<Employee>(
                              value: _selectedEmployeeForAdvance,
                              hint: Text('Sélectionner l\'ouvrier *'.tr),
                              items: displayList.map((e) => DropdownMenuItem(
                                value: e,
                                child: Text('${e.prenom} ${e.nom}'.trim().isNotEmpty ? '${e.prenom} ${e.nom}'.trim() : e.phone),
                              )).toList(),
                              onChanged: (val) {
                                setDialogState(() {
                                  _selectedEmployeeForAdvance = val;
                                  if (val != null) {
                                    _movementReasonController.text = 'Acompte ouvrier : ${val.name}';
                                  }
                                });
                              },
                            );
                          },
                          loading: () => const CircularProgressIndicator(),
                          error: (e, s) => Text('Erreur employés'.tr),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ],
                    TextFormField(
                      controller: _movementAmountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Montant (DT) *'.tr,
                        prefixIcon: const Icon(Icons.monetization_on_outlined),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _movementReasonController,
                      decoration: InputDecoration(
                        labelText: 'Motif / Description *'.tr,
                        prefixIcon: const Icon(Icons.rate_review_outlined),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text('Annuler'.tr),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: type == 'in' ? AppTheme.successGreen : AppTheme.errorRed,
                  ),
                  onPressed: () => _handleAddMovement(dialogContext, patronName),
                  child: Text('Confirmer'.tr),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Handle adding movement
  void _handleAddMovement(BuildContext dialogContext, String patronName) async {
    final amount = double.tryParse(_movementAmountController.text.trim());
    final reason = _movementReasonController.text.trim();

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez saisir un montant valide'.tr)),
      );
      return;
    }

    if (reason.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez saisir le motif'.tr)),
      );
      return;
    }

    if (_movementType == 'out' && _outType == 'acompte' && _selectedEmployeeForAdvance == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez sélectionner l\'ouvrier'.tr)),
      );
      return;
    }

    setState(() => _isSaving = true);
    Navigator.pop(dialogContext); // Close dialog

    try {
      final repo = ref.read(caisseRepositoryProvider);
      
      final movement = CashMovement(
        id: '',
        stationId: '',
        sessionId: '',
        amount: amount,
        type: _movementType,
        reason: reason,
        employeeId: _movementType == 'out' && _outType == 'acompte' ? _selectedEmployeeForAdvance?.id : null,
        employeeName: _movementType == 'out' && _outType == 'acompte' ? _selectedEmployeeForAdvance?.name : null,
        performedBy: patronName,
        createdAt: DateTime.now(),
      );

      await repo.addMovement(movement);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Mouvement enregistré avec succès'.tr)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e'.tr)),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // Dialog for closing caisse
  void _showCloseCaisseDialog(BuildContext context, double expectedCash, CashSession session, String patronName) {
    _finalBalanceController.clear();
    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (stContext, setDialogState) {
            final finalVal = double.tryParse(_finalBalanceController.text.trim()) ?? 0.0;
            final discrepancy = finalVal - expectedCash;

            return AlertDialog(
              title: Text('Clôturer la caisse'.tr),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '${'Solde attendu en caisse :'.tr} ${expectedCash.toStringAsFixed(2)} DT',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _finalBalanceController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Espèces réelles comptées (DT) *'.tr,
                      prefixIcon: const Icon(Icons.payments_outlined),
                    ),
                    onChanged: (_) => setDialogState(() {}),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Écart de caisse :'.tr),
                      Text(
                        '${discrepancy >= 0 ? "+" : ""}${discrepancy.toStringAsFixed(2)} DT',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: discrepancy == 0
                              ? Colors.grey
                              : (discrepancy > 0 ? AppTheme.successGreen : AppTheme.errorRed),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text('Annuler'.tr),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.warningOrange),
                  onPressed: () => _handleCloseSession(dialogContext, session.id, expectedCash, patronName),
                  child: Text('Clôturer'.tr),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Handle closing session
  void _handleCloseSession(BuildContext dialogContext, String sessionId, double expectedCash, String patronName) async {
    final finalBalance = double.tryParse(_finalBalanceController.text.trim());
    if (finalBalance == null || finalBalance < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez saisir le montant réel compté'.tr)),
      );
      return;
    }

    setState(() => _isSaving = true);
    Navigator.pop(dialogContext); // Close dialog

    try {
      final repo = ref.read(caisseRepositoryProvider);
      await repo.closeSession(sessionId, finalBalance, patronName);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Caisse clôturée avec succès'.tr)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e'.tr)),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // Stream current movements list
  Widget _buildSessionMovementsList(String sessionId) {
    final movementsAsync = ref.watch(sessionMovementsProvider(sessionId));

    return movementsAsync.when(
      data: (movements) {
        if (movements.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Aucun mouvement enregistré dans cette session.'.tr,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: movements.length,
          itemBuilder: (context, index) {
            final m = movements[index];
            final isIn = m.type == 'in';

            return Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: Icon(
                  isIn ? Icons.arrow_downward : Icons.arrow_upward,
                  color: isIn ? AppTheme.successGreen : AppTheme.errorRed,
                ),
                title: Text(
                  m.reason,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '${'Par :'.tr} ${m.performedBy} | ${DateFormat('HH:mm').format(m.createdAt)}',
                ),
                trailing: Text(
                  '${isIn ? "+" : "-"}${m.amount.toStringAsFixed(1)} DT',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isIn ? AppTheme.successGreen : AppTheme.errorRed,
                  ),
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Text('Erreur chargement mouvements: $e'.tr),
    );
  }

  // Stream sessions history list
  Widget _buildSessionsHistoryList() {
    final historyAsync = ref.watch(sessionsHistoryProvider);

    return historyAsync.when(
      data: (sessions) {
        // filter out the currently active one (which is shown in main card)
        final closedSessions = sessions.where((s) => s.status == 'closed').toList();

        if (closedSessions.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Aucune session fermée enregistrée.'.tr,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: closedSessions.length,
          itemBuilder: (context, index) {
            final s = closedSessions[index];
            final dateStr = DateFormat('dd/MM/yyyy').format(s.openingDate);

            return Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: const Icon(Icons.history_toggle_off, color: Colors.grey),
                title: Text(
                  'Session du $dateStr'.tr,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '${'Fond initial:'.tr} ${s.initialBalance.toStringAsFixed(1)} DT | ${'Clôture:'.tr} ${s.finalBalance?.toStringAsFixed(1)} DT\n${'Par :'.tr} ${s.openedBy}',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showSessionDetailsModal(context, s),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Text('Erreur historique caisse: $e'.tr),
    );
  }

  // Modal to show details of past session and its movements list
  void _showSessionDetailsModal(BuildContext context, CashSession session) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) {
        final dateStr = DateFormat('dd/MM/yyyy').format(session.openingDate);
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Détails Session - $dateStr'.tr,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: AppTheme.primaryBlue),
                  ),
                  const Divider(height: 24),
                  _buildModalDetailRow('Ouvert par :'.tr, session.openedBy),
                  _buildModalDetailRow('Clôturé par :'.tr, session.closedBy ?? 'N/A'.tr),
                  _buildModalDetailRow('Fond initial :'.tr, '${session.initialBalance.toStringAsFixed(2)} DT'),
                  _buildModalDetailRow('Total Entrées :'.tr, '+${session.totalCashIn.toStringAsFixed(2)} DT', color: AppTheme.successGreen),
                  _buildModalDetailRow('Total Sorties :'.tr, '-${session.totalCashOut.toStringAsFixed(2)} DT', color: AppTheme.errorRed),
                  _buildModalDetailRow('Clôture Réelle :'.tr, '${session.finalBalance?.toStringAsFixed(2)} DT', isBold: true),
                  const Divider(height: 32),
                  Text(
                    'Mouvements de la session'.tr,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primaryBlue),
                  ),
                  const SizedBox(height: 12),
                  _buildSessionMovementsList(session.id),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildModalDetailRow(String label, String value, {Color? color, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade700, fontSize: 14)),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: color ?? Colors.black87,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
