import 'package:freezed_annotation/freezed_annotation.dart';

part 'ticket.freezed.dart';
part 'ticket.g.dart';

enum TicketStatus {
  enAttente('en_attente'),
  paye('paye'),
  rembourse('rembourse');

  const TicketStatus(this.value);
  final String value;

  static TicketStatus fromString(String value) {
    return TicketStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => TicketStatus.enAttente,
    );
  }
}

@freezed
class TicketProduct with _$TicketProduct {
  const TicketProduct._();

  const factory TicketProduct({
    required String productId,
    required String productName,
    required int quantity,
    required double unitPrice,
  }) = _TicketProduct;

  factory TicketProduct.fromJson(Map<String, dynamic> json) => _$TicketProductFromJson(json);

  double get total => quantity * unitPrice;
}

@freezed
class Ticket with _$Ticket {
  const Ticket._();

  const factory Ticket({
    required String id,                 // Firestore Document ID
    required String tenantId,           // stationId
    required String ticketNumber,       // ST-{station}-{date}-{heure}-{random}
    required String createdBy,          // Creator (Worker or Cashier)
    String? paidBy,                     // Paid cashier
    String? approvedBy,                 // Approver
    required TicketStatus status,       // en_attente, paye, rembourse
    required double montant,            // Total ticket amount
    required Map<String, dynamic> snapshotPrice, // Anti-fraud snapshot of service prices
    @Default([]) List<String> photosAvant, // Photos before wash
    @Default([]) List<String> photosApres, // Photos after wash
    String? vehiclePlate,
    String? vehicleType,
    String? serviceId,
    String? serviceName,
    @Default([]) List<TicketProduct> productsUsed,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Ticket;

  factory Ticket.fromJson(Map<String, dynamic> json) => _$TicketFromJson(json);

  double get totalAmount => montant;
  double get commissionAmount => 0.0;
  String get stationId => tenantId;
  String get stationName => "";
  String? get workerId => createdBy;
  String? get workerName => createdBy;
  String? get cashierId => paidBy;
  String? get cashierName => paidBy;
  String get paymentMethod => "cash";
  String? get notes => "";
  DateTime? get startedAt => createdAt;
  DateTime? get completedAt => updatedAt;
}
