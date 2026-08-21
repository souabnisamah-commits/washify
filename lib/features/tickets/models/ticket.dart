import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:washify/core/utils/json_utils.dart';

part 'ticket.freezed.dart';
part 'ticket.g.dart';

enum TicketStatus {
  @JsonValue('en_attente')
  enAttente('en_attente'),
  @JsonValue('paye')
  paye('paye'),
  @JsonValue('annule')
  annule('annule'),
  @JsonValue('efface')
  efface('efface'),
  @JsonValue('rembourse')
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
class TicketService with _$TicketService {
  const factory TicketService({
    required String serviceId,
    required String serviceName,
    required double price,
  }) = _TicketService;

  factory TicketService.fromJson(Map<String, dynamic> json) => _$TicketServiceFromJson(json);
}

@freezed
class Ticket with _$Ticket {
  const Ticket._();

  const factory Ticket({
    required String id,                 // Firestore Document ID
    @JsonKey(readValue: readTenantId) required String tenantId,           // stationId
    required String ticketNumber,       // N°:XXX-DDMMYY-HH:MM (e.g. ST-station-XXX-DDMMYY-HH:MM) or as requested N°:XXX-DDMMYY-HH:MM
    required String createdBy,          // Creator (Worker or Cashier)
    String? paidBy,                     // Paid cashier
    String? approvedBy,                 // Approver
    required TicketStatus status,       // en_attente, paye, rembourse, annule, efface
    required double montant,            // Total ticket amount
    required Map<String, dynamic> snapshotPrice, // Anti-fraud snapshot of service prices
    @Default([]) List<String> photosAvant, // Photos before wash
    @Default([]) List<String> photosApres, // Photos after wash
    String? vehiclePlate,
    String? vehicleCategoryId, // Added to map to Category ID for doses
    String? vehicleType,       // Category Name
    String? vehicleBrand,
    String? vehicleModel,
    String? clientId,          // B2B client account ID
    String? clientName,
    String? clientPhone,
    String? paymentMethod,     // Espèces, TPE, Compte Client
    String? assignedWorkerId,
    String? assignedWorkerName,
    String? serviceId,
    String? serviceName,
    @Default([]) List<TicketService> servicesSelected,
    @Default([]) List<TicketProduct> productsUsed,
    required DateTime createdAt,
    required DateTime updatedAt,

    // New fields for Moquettes & Soft Delete
    @Default('vehicule') String operationType, // 'vehicule' or 'moquette'
    double? carpetMeters,
    double? carpetUnitPrice,
    double? discountAmount,
    String? discountReason,
    String? deletedBy,
    DateTime? deletedAt,
    String? deleteReason,
  }) = _Ticket;

  factory Ticket.fromJson(Map<String, dynamic> json) => _$TicketFromJson(json);

  List<TicketService> get allServices {
    if (servicesSelected.isNotEmpty) return servicesSelected;
    if (serviceId != null && serviceName != null) {
      return [
        TicketService(
          serviceId: serviceId!,
          serviceName: serviceName!,
          price: snapshotPrice['price']?.toDouble() ?? montant,
        )
      ];
    }
    return [];
  }

  double get totalAmount => montant;
  double get commissionAmount => 0.0;
  String get stationId => tenantId;
  String get stationName => "";
  String? get workerId => createdBy;
  String? get workerName => createdBy;
  String? get cashierId => paidBy;
  String? get cashierName => paidBy;
  String? get notes => "";
  DateTime? get startedAt => createdAt;
  DateTime? get completedAt => updatedAt;
}
