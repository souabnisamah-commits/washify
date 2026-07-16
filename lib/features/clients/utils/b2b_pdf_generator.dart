import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:washify/features/clients/models/client.dart';
import 'package:washify/features/clients/models/client_payment.dart';
import 'package:washify/features/station/models/station.dart';
import 'package:washify/features/tickets/models/ticket.dart';

class B2BPdfGenerator {
  static final _currencyFormat = NumberFormat.currency(locale: 'fr_FR', symbol: 'DT');
  static final _dateFormat = DateFormat('dd/MM/yyyy HH:mm');
  static final _dateOnlyFormat = DateFormat('dd/MM/yyyy');

  /// Génère le PDF "Détail du Solde à Payer"
  static Future<Uint8List> generateUnpaidBalanceReport({
    required Station station,
    required Client client,
    required List<Ticket> unpaidTickets,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          return [
            _buildHeader(station: station, title: 'Relevé de Compte B2B', subtitle: 'Détail du solde à payer'),
            pw.SizedBox(height: 20),
            _buildClientInfo(client),
            pw.SizedBox(height: 20),
            _buildBalanceSummary(client.currentBalance),
            pw.SizedBox(height: 20),
            pw.Text(
              'Détail des tickets impayés :',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
            ),
            pw.SizedBox(height: 10),
            _buildUnpaidTicketsTable(unpaidTickets),
            pw.SizedBox(height: 30),
            _buildFooter(),
          ];
        },
      ),
    );

    return pdf.save();
  }

  /// Génère le PDF "Historique des Opérations"
  static Future<Uint8List> generatePaymentHistoryReport({
    required Station station,
    required Client client,
    required DateTime startDate,
    required DateTime endDate,
    required List<ClientPayment> payments,
    required List<Ticket> consumedTickets,
  }) async {
    final pdf = pw.Document();

    final totalConsumed = consumedTickets.fold<double>(0, (sum, t) => sum + t.montant);
    final totalPaid = payments.fold<double>(0, (sum, p) => sum + p.amount);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          return [
            _buildHeader(
              station: station,
              title: 'Historique de Compte B2B',
              subtitle: 'Période du ${_dateOnlyFormat.format(startDate)} au ${_dateOnlyFormat.format(endDate)}',
            ),
            pw.SizedBox(height: 20),
            _buildClientInfo(client),
            pw.SizedBox(height: 20),
            
            // Financial Summary for Period
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey400),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                color: PdfColors.grey100,
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Total Consommé : ${_currencyFormat.format(totalConsumed)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.red800)),
                      pw.SizedBox(height: 4),
                      pw.Text('Total Réglé : ${_currencyFormat.format(totalPaid)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.green800)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('Solde Actuel Client', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
                      pw.Text(_currencyFormat.format(client.currentBalance), style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
                    ]
                  )
                ]
              )
            ),
            
            pw.SizedBox(height: 20),

            if (payments.isNotEmpty) ...[
              pw.Text('Paiements effectués :', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
              pw.SizedBox(height: 10),
              _buildPaymentsTable(payments),
              pw.SizedBox(height: 20),
            ],

            if (consumedTickets.isNotEmpty) ...[
              pw.Text('Tickets consommés :', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
              pw.SizedBox(height: 10),
              _buildConsumedTicketsTable(consumedTickets),
            ],

            pw.SizedBox(height: 30),
            _buildFooter(),
          ];
        },
      ),
    );

    return pdf.save();
  }

  // --- Composants réutilisables ---

  static pw.Widget _buildHeader({required Station station, required String title, required String subtitle}) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Station de Lavage ${station.name}', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#0284c7'))), // primaryBlue approx
            pw.SizedBox(height: 4),
            pw.Text('MF : ${station.matriculeFiscale}', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey800)),
            pw.SizedBox(height: 2),
            pw.Text('Tél : ${station.phone}', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey800)),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(title, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 4),
            pw.Text(subtitle, style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey600)),
            pw.Text('Édité le : ${_dateFormat.format(DateTime.now())}', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildClientInfo(Client client) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Informations Client', style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
              pw.SizedBox(height: 4),
              pw.Text(client.companyName, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
              pw.SizedBox(height: 2),
              pw.Text('Responsable : ${client.contactName}'),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text('Téléphone : ${client.phone}'),
              pw.SizedBox(height: 2),
              pw.Text('Matricule : ${client.taxId.isNotEmpty ? client.taxId : "N/A"}'),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildBalanceSummary(double balance) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: balance > 0 ? PdfColors.red50 : PdfColors.green50,
        border: pw.Border.all(color: balance > 0 ? PdfColors.red200 : PdfColors.green200),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('Solde Restant à Payer :', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.Text(
            _currencyFormat.format(balance),
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
              color: balance > 0 ? PdfColors.red700 : PdfColors.green700,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildUnpaidTicketsTable(List<Ticket> tickets) {
    if (tickets.isEmpty) {
      return pw.Text('Aucun ticket impayé.', style: const pw.TextStyle(fontStyle: pw.FontStyle.italic));
    }

    final headers = ['Date', 'Véhicule', 'Service', 'Montant'];
    final data = tickets.map((t) {
      return [
        _dateFormat.format(t.createdAt),
        t.vehiclePlate ?? 'N/A',
        t.serviceName ?? 'Multiple',
        _currencyFormat.format(t.montant),
      ];
    }).toList();

    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: data,
      border: pw.TableBorder.all(color: PdfColors.grey300),
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
      headerDecoration: pw.BoxDecoration(color: PdfColor.fromHex('#0284c7')),
      cellPadding: const pw.EdgeInsets.all(6),
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerLeft,
        2: pw.Alignment.centerLeft,
        3: pw.Alignment.centerRight,
      },
    );
  }

  static pw.Widget _buildConsumedTicketsTable(List<Ticket> tickets) {
    final headers = ['Date', 'Véhicule', 'Service', 'Statut', 'Montant'];
    final data = tickets.map((t) {
      return [
        _dateFormat.format(t.createdAt),
        t.vehiclePlate ?? 'N/A',
        t.serviceName ?? 'Multiple',
        t.status == TicketStatus.paye ? 'Payé' : 'Non payé',
        _currencyFormat.format(t.montant),
      ];
    }).toList();

    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: data,
      border: pw.TableBorder.all(color: PdfColors.grey300),
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey600),
      cellPadding: const pw.EdgeInsets.all(6),
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerLeft,
        2: pw.Alignment.centerLeft,
        3: pw.Alignment.center,
        4: pw.Alignment.centerRight,
      },
    );
  }

  static pw.Widget _buildPaymentsTable(List<ClientPayment> payments) {
    final headers = ['Date', 'Méthode', 'Référence', 'Responsable', 'Montant'];
    final data = payments.map((p) {
      return [
        _dateFormat.format(p.paymentDate),
        p.paymentMethod,
        p.reference ?? '-',
        p.createdBy,
        _currencyFormat.format(p.amount),
      ];
    }).toList();

    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: data,
      border: pw.TableBorder.all(color: PdfColors.grey300),
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
      headerDecoration: pw.BoxDecoration(color: PdfColor.fromHex('#10b981')), // successGreen
      cellPadding: const pw.EdgeInsets.all(6),
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerLeft,
        2: pw.Alignment.centerLeft,
        3: pw.Alignment.centerLeft,
        4: pw.Alignment.centerRight,
      },
    );
  }

  static pw.Widget _buildFooter() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Divider(color: PdfColors.grey400),
        pw.SizedBox(height: 8),
        pw.Text('Document généré par l\'application Washify', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
      ],
    );
  }
}
