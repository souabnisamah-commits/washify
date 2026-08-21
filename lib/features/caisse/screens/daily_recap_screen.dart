import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:washify/core/localization/app_localizations.dart';
import 'package:washify/core/theme/app_theme.dart';
import 'package:washify/providers/auth_provider.dart';
import 'package:washify/providers/employee_provider.dart';
import 'package:washify/providers/ticket_provider.dart';
import 'package:washify/providers/caisse_provider.dart';
import 'package:washify/providers/station_provider.dart';
import 'package:washify/features/hr/models/shift.dart';
import 'package:washify/features/hr/providers/hr_provider.dart';
import 'package:washify/features/tickets/models/ticket.dart';
import 'package:washify/features/caisse/models/cash_session.dart';
import 'package:washify/features/caisse/models/cash_movement.dart';

class DailyRecapScreen extends ConsumerStatefulWidget {
  const DailyRecapScreen({super.key});

  @override
  ConsumerState<DailyRecapScreen> createState() => _DailyRecapScreenState();
}

class _DailyRecapScreenState extends ConsumerState<DailyRecapScreen> {
  DateTime _selectedDate = DateTime.now();
  String _selectedShiftId = 'all'; // 'all' or shift.id

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    if (user == null || user.stationId == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final shiftsAsync = ref.watch(shiftsStreamProvider(user.tenantId));
    final sessionsAsync = ref.watch(sessionsHistoryProvider);

    // Calculate dates range for tickets
    final startOfDay = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, 0, 0, 0);
    final endOfDay = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, 23, 59, 59);

    final ticketsAsync = ref.watch(ticketsByDateRangeProvider((
      stationId: user.stationId!,
      startDate: startOfDay,
      endDate: endOfDay,
    )));

    return Scaffold(
      appBar: AppBar(
        title: Text('Tableau Récap Journalier'.tr),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Date & Shift Filters Card
            _buildFiltersCard(shiftsAsync),
            const SizedBox(height: 16),

            ticketsAsync.when(
              data: (allTickets) {
                return sessionsAsync.when(
                  data: (allSessions) {
                    // Filter sessions for selected date
                    final daySessions = allSessions.where((s) {
                      return s.openingDate.year == _selectedDate.year &&
                             s.openingDate.month == _selectedDate.month &&
                             s.openingDate.day == _selectedDate.day;
                    }).toList();

                    return shiftsAsync.when(
                      data: (shifts) {
                        final Shift? selectedShift = _selectedShiftId == 'all'
                            ? null
                            : shifts.firstWhere((s) => s.id == _selectedShiftId);

                        // Helper to match shift
                        bool matchesShift(DateTime time) {
                          if (selectedShift == null) return true;
                          
                          final startParts = selectedShift.startTime.split(':');
                          final endParts = selectedShift.endTime.split(':');
                          if (startParts.length != 2 || endParts.length != 2) return false;
                          
                          final startHour = int.parse(startParts[0]);
                          final startMin = int.parse(startParts[1]);
                          final endHour = int.parse(endParts[0]);
                          final endMin = int.parse(endParts[1]);
                          
                          final dtMinutes = time.hour * 60 + time.minute;
                          final startMinutes = startHour * 60 + startMin;
                          final endMinutes = endHour * 60 + endMin;
                          
                          if (startMinutes <= endMinutes) {
                            return dtMinutes >= startMinutes && dtMinutes < endMinutes;
                          } else {
                            return dtMinutes >= startMinutes || dtMinutes < endMinutes;
                          }
                        }

                        // Filtered tickets
                        final tickets = allTickets.where((t) => matchesShift(t.updatedAt)).toList();

                        // Calculations
                        double cashRevenue = 0.0;
                        double b2bRevenue = 0.0;
                        double cardRevenue = 0.0;

                        for (final ticket in tickets) {
                          if (ticket.status == TicketStatus.paye) {
                            if (ticket.paymentMethod == 'cash') {
                              cashRevenue += ticket.montant;
                            } else if (ticket.paymentMethod == 'compte_client') {
                              b2bRevenue += ticket.montant;
                            } else {
                              cardRevenue += ticket.montant;
                            }
                          }
                        }

                        // Fond de caisse initial
                        double initialCash = 0.0;
                        if (daySessions.isNotEmpty) {
                          initialCash = daySessions.fold(0.0, (sum, s) => sum + s.initialBalance);
                        }

                        // Fetch movements for day sessions
                        return _buildMovementsAndSummary(
                          context,
                          daySessions,
                          matchesShift,
                          initialCash,
                          cashRevenue,
                          b2bRevenue,
                          cardRevenue,
                          tickets,
                          selectedShift,
                        );
                      },
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (e, s) => Text('Erreur shifts: $e'.tr),
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, s) => Text('Erreur sessions caisse: $e'.tr),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Text('Erreur tickets: $e'.tr),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFiltersCard(AsyncValue<List<Shift>> shiftsAsync) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.withValues(alpha: 0.1), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filtres de recherche'.tr,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() {
                          _selectedDate = picked;
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(DateFormat('dd/MM/yyyy').format(_selectedDate)),
                          const Icon(Icons.calendar_today, color: AppTheme.primaryBlue, size: 20),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: shiftsAsync.when(
                    data: (shifts) {
                      return DropdownButtonFormField<String>(
                        value: _selectedShiftId,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: [
                          DropdownMenuItem(value: 'all', child: Text('Tous les shifts'.tr)),
                          ...shifts.map((s) => DropdownMenuItem(
                            value: s.id,
                            child: Text(s.name),
                          )),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _selectedShiftId = val;
                            });
                          }
                        },
                      );
                    },
                    loading: () => const SizedBox(height: 48, child: Center(child: CircularProgressIndicator())),
                    error: (e, s) => Text('Erreur'.tr),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMovementsAndSummary(
    BuildContext context,
    List<CashSession> sessions,
    bool Function(DateTime) matchesShift,
    double initialCash,
    double cashRevenue,
    double b2bRevenue,
    double cardRevenue,
    List<Ticket> tickets,
    Shift? selectedShift,
  ) {
    if (sessions.isEmpty) {
      return Column(
        children: [
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.warningOrange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Icon(Icons.warning_amber_rounded, color: AppTheme.warningOrange, size: 48),
                const SizedBox(height: 12),
                Text(
                  'Aucune session de caisse ouverte pour cette date.'.tr,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.warningOrange),
                ),
              ],
            ),
          ),
        ],
      );
    }

    // Stream cash movements for all sessions of the day
    return Consumer(
      builder: (context, ref, child) {
        // Since sessionMovementsProvider is family, we can watch them and combine
        final List<CashMovement> allMovements = [];
        bool isLoading = false;

        for (final session in sessions) {
          final movementsAsync = ref.watch(sessionMovementsProvider(session.id));
          movementsAsync.when(
            data: (movements) {
              allMovements.addAll(movements.where((m) => matchesShift(m.createdAt)));
            },
            loading: () => isLoading = true,
            error: (e, s) {},
          );
        }

        if (isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        // Calculations for movements
        double inMovementsSum = 0.0;
        double outMovementsSum = 0.0;
        double workerAdvancesSum = 0.0;

        final List<CashMovement> detailsIn = [];
        final List<CashMovement> detailsOut = [];
        final List<CashMovement> workerAdvances = [];

        for (final movement in allMovements) {
          if (movement.type == 'in') {
            inMovementsSum += movement.amount;
            detailsIn.add(movement);
          } else {
            outMovementsSum += movement.amount;
            detailsOut.add(movement);
            if (movement.reason.contains('Acompte') || movement.employeeId != null) {
              workerAdvancesSum += movement.amount;
              workerAdvances.add(movement);
            }
          }
        }

        final double expectedFinalCash = initialCash + cashRevenue + inMovementsSum - outMovementsSum;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Copy recap button
            ElevatedButton.icon(
              onPressed: () => _copyRecapToClipboard(
                initialCash,
                cashRevenue,
                b2bRevenue,
                cardRevenue,
                inMovementsSum,
                outMovementsSum,
                workerAdvancesSum,
                expectedFinalCash,
                tickets,
                allMovements,
                selectedShift,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.copy_all),
              label: Text('Copier le rapport journalier'.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 16),

            // Financial Summary Card (Glassmorphism inspired)
            _buildFinancialSummaryCard(
              initialCash,
              cashRevenue,
              b2bRevenue,
              cardRevenue,
              inMovementsSum,
              outMovementsSum,
              workerAdvancesSum,
              expectedFinalCash,
            ),
            const SizedBox(height: 16),

            // Tickets Section
            _buildSectionTitle('Tickets de la période'.tr),
            const SizedBox(height: 8),
            _buildTicketsList(tickets),
            const SizedBox(height: 16),

            // Movements Section
            _buildSectionTitle('Mouvements de Caisse'.tr),
            const SizedBox(height: 8),
            _buildMovementsList(allMovements),
          ],
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppTheme.primaryBlue,
      ),
    );
  }

  Widget _buildFinancialSummaryCard(
    double initialCash,
    double cashRevenue,
    double b2bRevenue,
    double cardRevenue,
    double cashInMovements,
    double cashOutMovements,
    double workerAdvances,
    double expectedFinalCash,
  ) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.2), width: 1),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Colors.grey.shade900, Colors.grey.shade800],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Caisse Finale Attendue'.tr,
                  style: const TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w600),
                ),
                Text(
                  '${expectedFinalCash.toStringAsFixed(2)} DT',
                  style: const TextStyle(color: AppTheme.successGreen, fontSize: 26, fontWeight: FontWeight.w900),
                ),
              ],
            ),
            const Divider(color: Colors.white24, height: 24, thickness: 1),
            _buildSummaryRow('Fond de caisse initial'.tr, initialCash, isBold: false),
            const SizedBox(height: 8),
            _buildSummaryRow('Recettes Espèces (Cash)'.tr, cashRevenue, isBold: false, valueColor: AppTheme.successGreen),
            const SizedBox(height: 8),
            _buildSummaryRow('Recettes Compte B2B'.tr, b2bRevenue, isBold: false, valueColor: AppTheme.accentCyan),
            const SizedBox(height: 8),
            _buildSummaryRow('Recettes Carte / Wallet'.tr, cardRevenue, isBold: false),
            const SizedBox(height: 8),
            _buildSummaryRow('Total Mouvements Entrées'.tr, cashInMovements, isBold: false, valueColor: AppTheme.successGreen),
            const SizedBox(height: 8),
            _buildSummaryRow('Total Mouvements Sorties'.tr, cashOutMovements, isBold: false, valueColor: AppTheme.errorRed),
            const SizedBox(height: 8),
            _buildSummaryRow('Dont Acomptes Ouvriers'.tr, workerAdvances, isBold: false, indent: true),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    double value, {
    required bool isBold,
    Color? valueColor,
    bool indent = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(left: indent ? 16.0 : 0.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isBold ? Colors.white : Colors.white70,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: indent ? 13 : 14,
            ),
          ),
          Text(
            '${value.toStringAsFixed(2)} DT',
            style: TextStyle(
              color: valueColor ?? Colors.white,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              fontSize: indent ? 13 : 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketsList(List<Ticket> tickets) {
    if (tickets.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('Aucun ticket validé'.tr, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade600)),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tickets.length,
      itemBuilder: (context, index) {
        final ticket = tickets[index];
        final isCarpet = ticket.operationType == 'moquette';
        final isDeleted = ticket.status == TicketStatus.efface;

        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: Icon(
              isCarpet ? Icons.grid_view : Icons.directions_car,
              color: isDeleted ? AppTheme.errorRed : AppTheme.primaryBlue,
            ),
            title: Text(
              '${ticket.ticketNumber} - ${ticket.vehiclePlate}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                decoration: isDeleted ? TextDecoration.lineThrough : null,
              ),
            ),
            subtitle: Text(
              '${ticket.serviceName}\n${'Laveur:'.tr} ${ticket.assignedWorkerName ?? 'N/A'.tr} | ${'Paiement:'.tr} ${ticket.paymentMethod?.tr}',
              style: TextStyle(
                decoration: isDeleted ? TextDecoration.lineThrough : null,
              ),
            ),
            trailing: Text(
              '${ticket.montant.toStringAsFixed(1)} DT',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDeleted ? AppTheme.errorRed : AppTheme.successGreen,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMovementsList(List<CashMovement> movements) {
    if (movements.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('Aucun mouvement de caisse'.tr, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade600)),
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
  }

  void _copyRecapToClipboard(
    double initialCash,
    double cashRevenue,
    double b2bRevenue,
    double cardRevenue,
    double cashInMovements,
    double cashOutMovements,
    double workerAdvances,
    double expectedFinalCash,
    List<Ticket> tickets,
    List<CashMovement> movements,
    Shift? selectedShift,
  ) {
    final buffer = StringBuffer();
    final dateStr = DateFormat('dd/MM/yyyy').format(_selectedDate);
    final shiftStr = selectedShift != null ? selectedShift.name : 'Tous les shifts'.tr;

    buffer.writeln('📋 *RAPPORT JOURNALIER WASHIFY* 📋');
    buffer.writeln('📅 Date : $dateStr');
    buffer.writeln('⏱️ Shift : $shiftStr');
    buffer.writeln('-----------------------------------');
    buffer.writeln('💵 *FOND DE CAISSE INITIAL* : ${initialCash.toStringAsFixed(2)} DT');
    buffer.writeln('📥 *Recettes Espèces (Cash)* : +${cashRevenue.toStringAsFixed(2)} DT');
    buffer.writeln('🏢 *Recettes Compte B2B* : ${b2bRevenue.toStringAsFixed(2)} DT');
    buffer.writeln('💳 *Recettes Autre (Carte/Wallet)* : ${cardRevenue.toStringAsFixed(2)} DT');
    buffer.writeln('📥 *Total Entrées Caisse* : +${cashInMovements.toStringAsFixed(2)} DT');
    buffer.writeln('📤 *Total Sorties Caisse* : -${cashOutMovements.toStringAsFixed(2)} DT');
    buffer.writeln('👉 *Dont Acomptes Ouvriers* : -${workerAdvances.toStringAsFixed(2)} DT');
    buffer.writeln('-----------------------------------');
    buffer.writeln('💰 *SOLDE DE CAISSE ATTENDU* : *${expectedFinalCash.toStringAsFixed(2)} DT*');
    buffer.writeln('-----------------------------------');

    if (tickets.isNotEmpty) {
      buffer.writeln('\n🚗 *TICKETS VALIDÉS* :');
      for (final t in tickets) {
        if (t.status == TicketStatus.paye) {
          buffer.writeln('- ${t.ticketNumber} | ${t.vehiclePlate} | ${t.montant.toStringAsFixed(1)} DT (${t.paymentMethod?.tr})');
        } else if (t.status == TicketStatus.efface) {
          buffer.writeln('- ~${t.ticketNumber} | ${t.vehiclePlate} | ${t.montant.toStringAsFixed(1)} DT~ (EFFACÉ)');
        }
      }
    }

    if (movements.isNotEmpty) {
      buffer.writeln('\n💸 *MOUVEMENTS DE CAISSE* :');
      for (final m in movements) {
        final typeSymbol = m.type == 'in' ? '+' : '-';
        buffer.writeln('- $typeSymbol${m.amount.toStringAsFixed(1)} DT : ${m.reason} (${m.performedBy})');
      }
    }

    Clipboard.setData(ClipboardData(text: buffer.toString())).then((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Rapport copié dans le presse-papiers !'.tr)),
      );
    });
  }
}
