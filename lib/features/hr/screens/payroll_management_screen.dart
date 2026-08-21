import 'package:flutter/material.dart';
import 'package:washify/core/localization/app_localizations.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:washify/core/theme/app_theme.dart';
import 'package:washify/features/employees/models/employee.dart';
import 'package:washify/providers/employee_provider.dart';
import 'package:washify/providers/auth_provider.dart';

// Since Wallet system exists, we can use it.
import 'package:washify/features/wallet/models/wallet.dart';
import 'package:washify/providers/wallet_provider.dart';

class PayrollManagementScreen extends ConsumerStatefulWidget {
  const PayrollManagementScreen({super.key});

  @override
  ConsumerState<PayrollManagementScreen> createState() => _PayrollManagementScreenState();
}

class _PayrollManagementScreenState extends ConsumerState<PayrollManagementScreen> {
  Future<void> _processTransaction(Employee emp, String type) async {
    final formKey = GlobalKey<FormState>();
    final amountController = TextEditingController();
    final reasonController = TextEditingController();

    String title = 'Avance';
    if (type == 'payout') {
      title = 'Payer Solde (Paiement)';
    } else if (type == 'bonus') {
      title = 'Prime / Gratification';
    }

    final result = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text('$title - ${emp.name}'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Montant (DT) *'.tr,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.monetization_on_outlined),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Requis'.tr;
                  if (double.tryParse(v) == null || double.parse(v) <= 0) return 'Montant invalide'.tr;
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: reasonController,
                decoration: InputDecoration(
                  labelText: type == 'bonus' ? 'Motif (Optionnel)'.tr : 'Motif / Description'.tr,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.description_outlined),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: Text('Annuler'.tr)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: type == 'bonus'
                  ? Colors.purple
                  : (type == 'payout' ? AppTheme.successGreen : AppTheme.primaryBlue),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(c, true);
              }
            },
            child: Text('Valider'.tr),
          ),
        ],
      ),
    );

    if (result == true) {
      final amount = double.tryParse(amountController.text) ?? 0.0;
      if (amount <= 0) return;

      final user = ref.read(currentUserProvider);
      if (user == null) return;

      final repo = ref.read(walletRepositoryProvider);

      try {
        final WalletTransactionType tType = type == 'bonus'
            ? WalletTransactionType.bonus
            : WalletTransactionType.retrait;

        final reasonText = reasonController.text.trim();
        String desc = '';
        if (type == 'bonus') {
          desc = reasonText.isNotEmpty ? 'Prime : $reasonText' : 'Prime octroyée';
        } else if (type == 'payout') {
          desc = reasonText.isNotEmpty ? 'Paiement Salaire : $reasonText' : 'Paiement Salaire';
        } else {
          desc = reasonText.isNotEmpty ? 'Avance : $reasonText' : 'Avance sur salaire';
        }

        await repo.addTransaction(
          WalletTransaction(
            id: '',
            walletId: '',
            userId: emp.id,
            tenantId: user.tenantId,
            type: tType,
            amount: amount,
            balanceBefore: 0,
            balanceAfter: 0,
            description: desc,
            createdAt: DateTime.now(),
          ),
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$title enregistré avec succès'.tr)),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur: $e'.tr)),
          );
        }
      }
    }
  }

  void _showTransactions(Employee emp) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return FutureBuilder<List<WalletTransaction>>(
              future: ref.read(walletRepositoryProvider).getTransactions(emp.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Erreur: ${snapshot.error}'.tr));
                }
                final transactions = snapshot.data ?? [];
                if (transactions.isEmpty) {
                  return Center(child: Text('Aucune transaction trouvée'.tr));
                }
                return Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('Détails des transactions - ${emp.name}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                    const Divider(),
                    Expanded(
                      child: ListView.separated(
                        controller: scrollController,
                        itemCount: transactions.length,
                        separatorBuilder: (_, _) => Divider(),
                        itemBuilder: (context, index) {
                          final t = transactions[index];
                          final date = t.createdAt;
                          final isCredit = t.type == WalletTransactionType.bonus || t.type == WalletTransactionType.gainTicket || t.type == WalletTransactionType.salaireJour;
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: isCredit ? AppTheme.successGreen.withValues(alpha: 0.2) : AppTheme.errorRed.withValues(alpha: 0.2),
                              child: Icon(isCredit ? Icons.arrow_downward : Icons.arrow_upward, color: isCredit ? AppTheme.successGreen : AppTheme.errorRed),
                            ),
                            title: Text(t.description.isNotEmpty ? t.description : t.type.name),
                            subtitle: Text('${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}'),
                            trailing: Text(
                              '${isCredit ? '+' : '-'}${t.amount.toStringAsFixed(2)} DT',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isCredit ? AppTheme.successGreen : AppTheme.errorRed,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    if (user == null || user.tenantId.isEmpty) return Center(child: Text('Aucune station'.tr));

    final employeesAsync = ref.watch(employeesStreamProvider(user.tenantId));

    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Soldes des Employés', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 16),
          Expanded(
            child: employeesAsync.when(
              data: (employees) {
                if (employees.isEmpty) return Center(child: Text('Aucun employé'.tr));
                return ListView.builder(
                  itemCount: employees.length,
                  itemBuilder: (context, index) {
                    final emp = employees[index];
                    // Fetch wallet balance
                    final walletAsync = ref.watch(walletStreamProvider(emp.id));
                    
                    return InkWell(
                      onTap: () => _showTransactions(emp),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        margin: EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.surfaceCard,
                              AppTheme.surfaceCardLight,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 4)),
                          ],
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: AppTheme.accentCyan,
                                      child: Icon(Icons.person, color: Colors.white),
                                    ),
                                    SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(emp.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                                        Text(emp.roles.map((r) => r.name.toUpperCase()).join(' - '), style: TextStyle(color: Colors.grey, fontSize: 12)),
                                      ],
                                    ),
                                  ],
                                ),
                                walletAsync.when(
                                  data: (wallet) {
                                    final balance = wallet?.balance ?? 0.0;
                                    final isNegative = balance < 0;
                                    return Container(
                                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: isNegative ? AppTheme.errorRed.withValues(alpha: 0.2) : AppTheme.successGreen.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: isNegative ? AppTheme.errorRed : AppTheme.successGreen),
                                      ),
                                      child: Text(
                                        '${balance.toStringAsFixed(2)} DT', 
                                        style: TextStyle(
                                          color: isNegative ? AppTheme.errorRed : AppTheme.successGreen,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        )
                                      ),
                                    );
                                  },
                                  loading: () => Text('...', style: TextStyle(color: Colors.white)),
                                  error: (e,s) => Text('Erreur', style: TextStyle(color: AppTheme.errorRed)),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            const Divider(color: Colors.grey),
                            SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                 OutlinedButton.icon(
                                   onPressed: () => _processTransaction(emp, 'advance'),
                                   icon: const Icon(Icons.money_off, size: 16),
                                   label: Text('Avance'.tr),
                                   style: OutlinedButton.styleFrom(
                                     foregroundColor: AppTheme.primaryBlue,
                                     side: const BorderSide(color: AppTheme.primaryBlue),
                                   ),
                                 ),
                                 const SizedBox(width: 8),
                                 OutlinedButton.icon(
                                   onPressed: () => _processTransaction(emp, 'bonus'),
                                   icon: const Icon(Icons.card_giftcard, size: 16),
                                   label: Text('Prime'.tr),
                                   style: OutlinedButton.styleFrom(
                                     foregroundColor: Colors.purple,
                                     side: const BorderSide(color: Colors.purple),
                                   ),
                                 ),
                                 const SizedBox(width: 8),
                                 ElevatedButton.icon(
                                   onPressed: () => _processTransaction(emp, 'payout'),
                                   icon: const Icon(Icons.payments, size: 16),
                                   label: Text('Payer Solde'.tr),
                                   style: ElevatedButton.styleFrom(
                                     backgroundColor: AppTheme.successGreen,
                                     foregroundColor: Colors.white,
                                   ),
                                 ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                );
              },
              loading: () => Center(child: CircularProgressIndicator()),
              error: (e, s) => Text('Erreur: $e'.tr),
            ),
          ),
        ],
      ),
    );
  }
}
