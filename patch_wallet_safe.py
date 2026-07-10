import os

path = 'lib/features/wallet/wallet_screen.dart'
with open(path, 'r', encoding='utf-8') as f:
    code = f.read()

# Let's replace the list builder logic safely
target = """                  itemBuilder: (context, index) {
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
                  },"""

replacement = """                  itemBuilder: (context, index) {
                    try {
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
                    } catch (e) {
                      return Card(
                        margin: EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          title: Text('Erreur transaction'),
                        ),
                      );
                    }
                  },"""

if target in code:
    code = code.replace(target, replacement)
else:
    print("WARNING: target not found in wallet_screen.dart")

with open(path, 'w', encoding='utf-8') as f:
    f.write(code)
print("wallet patched")
