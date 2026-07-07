import 'package:flutter/material.dart';
import 'package:washify/core/localization/app_localizations.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:washify/core/theme/app_theme.dart';
import 'package:washify/providers/auth_provider.dart';
import 'package:washify/providers/wallet_provider.dart';
import 'package:washify/providers/employee_provider.dart';
import 'package:washify/features/wallet/models/wallet.dart';
import 'package:intl/intl.dart';

class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    if (user == null) return Scaffold(body: Center(child: CircularProgressIndicator()));

    final employeeAsync = ref.watch(employeeByUserIdProvider(user.id));

    return Scaffold(
      appBar: AppBar(
        title: Text('Mon Portefeuille'.tr),
      ),
      body: employeeAsync.when(
        loading: () => Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Erreur: $e'.tr)),
        data: (employee) {
          if (employee == null) {
            return Center(child: Text('Profil employé introuvable.'.tr));
          }
          final transactionsAsync = ref.watch(walletTransactionsProvider(employee.id));
          final walletAsync = ref.watch(walletStreamProvider(employee.id));

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Wallet Banner
          walletAsync.when(
            data: (wallet) {
              final balance = wallet?.balance ?? 0;
              return Container(
                margin: EdgeInsets.all(16),
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                ),
                child: Column(
                  children: [
                    Text('Solde Actuel', style: TextStyle(color: Colors.white70, fontSize: 14)),
                    SizedBox(height: 8),
                    Text(
                      '${balance.toStringAsFixed(2)} DT',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              );
            },
            loading: () => Center(child: CircularProgressIndicator()),
            error: (e, s) => Text('Erreur: $e'.tr),
          ),

          // Transactions Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: Text(
              'Historique des Transactions',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),

          // Transactions List
          Expanded(
            child: transactionsAsync.when(
              data: (list) {
                if (list.isEmpty) {
                  return Center(
                    child: Text('Aucune transaction trouvée.', style: TextStyle(color: AppTheme.textHint)),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final tx = list[index];
                    final dateStr = DateFormat('dd/MM/yyyy HH:mm').format(tx.createdAt);
                    final isCredit = tx.type == WalletTransactionType.bonus || tx.type == WalletTransactionType.gainTicket || tx.type == WalletTransactionType.salaireJour;

                    return Card(
                      margin: EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isCredit ? AppTheme.successGreen.withValues(alpha: 0.15) : AppTheme.errorRed.withValues(alpha: 0.15),
                          child: Icon(
                            isCredit ? Icons.add : Icons.remove,
                            color: isCredit ? AppTheme.successGreen : AppTheme.errorRed,
                          ),
                        ),
                        title: Text(tx.description, style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(dateStr),
                        trailing: Text(
                          '${isCredit ? "+" : "-"}${tx.amount.toStringAsFixed(2)} DT',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: isCredit ? AppTheme.successGreen : AppTheme.errorRed,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => Center(child: CircularProgressIndicator()),
              error: (e, s) => Center(child: Text('Erreur: $e'.tr)),
            ),
          ),
        ],
      );
    },
    ),
    );
  }
}
