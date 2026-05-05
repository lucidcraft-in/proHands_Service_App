import 'review_model.dart';

enum BookingStatus {
  open,
  assigned,
  accepted,
  reached, // ongoing
  reassignRequested,
  closedByCustomer,
  closed,
  completed,
  commissionPaymentPending,
  cancelled,
  cancelRequested,
  delayRequested,
  delayRejected,
}

extension BookingStatusExtension on BookingStatus {
  String getDisplayStatus(bool isTechnician) {
    switch (this) {
      case BookingStatus.open:
        return "Open";
      case BookingStatus.assigned:
        return "Assigned";
      case BookingStatus.accepted:
        return "Accepted";
      case BookingStatus.reached:
        return "Ongoing";
      case BookingStatus.closedByCustomer:
      case BookingStatus.commissionPaymentPending:
        return isTechnician
            ? "Work Complete & Commission Pending"
            : "Completed";
      case BookingStatus.closed:
        return isTechnician ? "Work Closed" : "Completed";
      case BookingStatus.completed:
        return "Completed";
      case BookingStatus.cancelled:
        return "Cancelled";
      case BookingStatus.cancelRequested:
        return "Cancel Requested";
      case BookingStatus.reassignRequested:
        return "Reassign Requested";
      case BookingStatus.delayRequested:
        return "Delay Requested";
      case BookingStatus.delayRejected:
        return "Delay Rejected";
    }
  }
}

class BookingModel {
  final String id; // Backend ID (_id)
  final String bookingId; // Display ID (PHxxxx)
  final String serviceId;
  final String serviceName;
  final String date;
  final String time;
  final String location;
  final List<double>? coordinates;
  final String? providerName;
  final String? providerPhone;
  final String? providerProfession;
  final String? categoryId;

  final String customerName;
  final String customerPhone;
  final int customerPoints;
  final double price;
  final double totalAmount;
  final String paymentStatus;
  final String paymentMode;
  final String description;
  final List<String> jobProofImages;
  final String? completionNotes;
  final String? otp;
  final ReviewModel? review;
  BookingStatus status;
  bool isCompleteClicked;
  bool isOTPRequested;
  bool isVerified;

  final String? delayTime;
  final String? delayNote;
  final double additionalAmount;
  final String? additionalNote;
  final String? reassignReason;
  final String? assignedBy;
  final int redeemedPoints;
  final double pointsValue;
  final double adminCommission;
  final bool isAdminCommissionCollected;
  final String commissionPaymentMode;
  final bool isPointsIncremented;

  BookingModel({
    required this.id,
    required this.bookingId,
    required this.serviceId,
    required this.serviceName,
    required this.date,
    required this.time,
    required this.location,
    this.coordinates,
    required this.customerName,
    required this.customerPhone,
    required this.customerPoints,
    required this.price,
    this.totalAmount = 0,
    this.paymentStatus = 'PENDING',
    this.paymentMode = 'CASH',
    this.description = '',
    this.jobProofImages = const [],
    this.completionNotes,
    this.otp,
    this.status = BookingStatus.open,
    this.isCompleteClicked = false,
    this.isOTPRequested = false,
    this.isVerified = false,
    this.providerName,
    this.providerPhone,
    this.providerProfession,
    this.review,
    this.delayTime,
    this.delayNote,
    this.categoryId,
    this.additionalAmount = 0,
    this.additionalNote,
    this.reassignReason,
    this.assignedBy,
    this.redeemedPoints = 0,
    this.pointsValue = 0,
    this.adminCommission = 0.0,
    this.isAdminCommissionCollected = false,
    this.commissionPaymentMode = 'CASH',
    this.isPointsIncremented = false,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    // Parse nested objects
    final serviceIdx = json['serviceId'];
    final customerIdx = json['customerId'];
    final locationIdx = json['location'];
    final providerIdx = json['providerId'];
    String? categoryId = json['categoryId'] ?? json['category_id'];

    String serviceName = 'Unknown Service';
    String serviceIdStr = '';
    if (serviceIdx is Map) {
      serviceName = serviceIdx['name'] ?? 'Unknown Service';
      serviceIdStr = serviceIdx['_id'] ?? '';
      categoryId ??=
          serviceIdx['categoryId'] ??
          serviceIdx['category']?['_id'] ??
          serviceIdx['category'];
    } else if (serviceIdx is String) {
      serviceIdStr = serviceIdx;
    }

    if (serviceIdStr.isEmpty &&
        json['category'] != null &&
        json['category'] is Map) {
      serviceName = json['category']['name'] ?? 'Unknown Service';
    }

    String customerName = 'Unknown';
    String customerPhone = '';
    int customerPoints = 0;
    if (customerIdx is Map) {
      customerName = customerIdx['name'] ?? 'Unknown';
      customerPhone = customerIdx['phone'] ?? '';
      customerPoints = customerIdx['points'] ?? 0;
    }

    String? providerName;
    String? providerPhone;
    String? providerProfession;

    if (providerIdx is Map) {
      providerName = providerIdx['name'];
      providerPhone = providerIdx['phone'];
      providerProfession = providerIdx['profession'];
    }

    String address = 'Unknown Location';
    List<double>? coordinates;

    if (locationIdx is Map) {
      address =
          locationIdx['location_name'] ??
          locationIdx['address'] ??
          'Unknown Location';
      if (locationIdx.containsKey('coordinates') &&
          locationIdx['coordinates'] is List) {
        coordinates = List<double>.from(
          (locationIdx['coordinates'] as List).map(
            (e) => (e as num).toDouble(),
          ),
        );
      }
    } else if (locationIdx is String) {
      address = locationIdx;
    }

    // Date formatting (assuming ISO string)
    String dateStr = json['date'] ?? '';
    if (dateStr.isNotEmpty) {
      try {
        final date = DateTime.parse(dateStr);
        dateStr =
            "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
      } catch (_) {}
    }

    // Time formatting
    String timeStr = json['time'] ?? '';

    return BookingModel(
      id: json['_id'] ?? '',
      bookingId: json['bookingId'] ?? '',
      serviceId: serviceIdStr,
      serviceName: serviceName,
      date: dateStr,
      time: timeStr,
      location: address,
      coordinates: coordinates,
      customerName: customerName,
      customerPhone: customerPhone,
      price: (json['price'] ?? 0).toDouble(),
      totalAmount: (json['totalAmount'] ?? json['price'] ?? 0).toDouble(),
      paymentStatus: json['paymentStatus'] ?? 'PENDING',
      paymentMode: json['paymentMode'] ?? 'CASH',
      description: json['description'] ?? '',
      jobProofImages: List<String>.from(json['jobProofImages'] ?? []),
      completionNotes: json['completionNotes'],
      otp: json['otp']?.toString(),
      status: _parseStatus(json['status']),
      isVerified: json['isVerified'] ?? false,
      isOTPRequested:
          (json['otp'] != null && json['otp'].toString().isNotEmpty),
      providerName: providerName,
      providerPhone: providerPhone,
      providerProfession: providerProfession,
      customerPoints: customerPoints,
      review:
          json['review'] != null ? ReviewModel.fromJson(json['review']) : null,
      delayTime: json['delayTime'],
      delayNote: json['delayNote'],
      categoryId: categoryId,
      additionalAmount: (json['additionalAmount'] ?? 0).toDouble(),
      additionalNote: json['additionalNote'],
      reassignReason: json['reassignReason'],
      assignedBy: json['assignedBy'],
      redeemedPoints: json['redeemedPoints'] ?? 0,
      pointsValue: (json['pointsValue'] ?? 0).toDouble(),
      adminCommission: (json['adminCommission'] ?? 0).toDouble(),
      isAdminCommissionCollected: json['isAdminCommissionCollected'] ?? false,
      commissionPaymentMode: json['commissionPaymentMode'] ?? 'CASH',
      isPointsIncremented: json['isPointsIncremented'] ?? false,
    );
  }

  static BookingStatus _parseStatus(String? status) {
    print("status: $status");
    print("------------------------------");
    if (status == null) return BookingStatus.open;
    switch (status.toUpperCase()) {
      case 'OPEN':
        return BookingStatus.open;
      case 'ASSIGNED':
      case 'PENDING':
        return BookingStatus.assigned;
      case 'REASSIGN_REQUESTED':
        return BookingStatus.reassignRequested;
      case 'ACCEPTED':
        return BookingStatus.accepted;
      case 'REACHED':
      case 'ONGOING':
        return BookingStatus.reached;
      case 'CLOSED_BY_CUSTOMER':
        return BookingStatus.closedByCustomer;
      case 'COMMISSION_PAYMENT_PENDING':
        return BookingStatus.commissionPaymentPending;
      case 'CLOSED':
        return BookingStatus.closed;
      case 'COMPLETED':
        return BookingStatus.completed;
      case 'CANCELLED':
        return BookingStatus.cancelled;
      case 'CANCEL_REQUESTED':
        return BookingStatus.cancelRequested;
      case 'DELAY_REQUESTED':
        return BookingStatus.delayRequested;
      case 'DELAY_REJECTED':
        return BookingStatus.delayRejected;
      default:
        return BookingStatus.open;
    }
  }

  BookingModel copyWith({
    String? id,
    String? bookingId,
    String? serviceId,
    String? serviceName,
    String? date,
    String? time,
    String? location,
    List<double>? coordinates,
    String? customerName,
    String? customerPhone,
    double? price,
    double? totalAmount,
    String? paymentStatus,
    String? paymentMode,
    String? description,
    List<String>? jobProofImages,
    String? completionNotes,
    String? otp,
    BookingStatus? status,
    bool? isCompleteClicked,
    bool? isOTPRequested,
    bool? isVerified,
    String? providerName,
    String? providerPhone,
    String? providerProfession,
    ReviewModel? review,
    String? delayTime,
    String? delayNote,
    String? categoryId,
    double? additionalAmount,
    String? additionalNote,
    String? reassignReason,
    String? assignedBy,
    int? redeemedPoints,
    double? pointsValue,
    double? adminCommission,
    bool? isAdminCommissionCollected,
    String? commissionPaymentMode,
    bool? isPointsIncremented,
    int? customerPoints,
  }) {
    return BookingModel(
      id: id ?? this.id,
      bookingId: bookingId ?? this.bookingId,
      serviceId: serviceId ?? this.serviceId,
      serviceName: serviceName ?? this.serviceName,
      date: date ?? this.date,
      time: time ?? this.time,
      location: location ?? this.location,
      coordinates: coordinates ?? this.coordinates,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      price: price ?? this.price,
      totalAmount: totalAmount ?? this.totalAmount,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentMode: paymentMode ?? this.paymentMode,
      description: description ?? this.description,
      jobProofImages: jobProofImages ?? this.jobProofImages,
      completionNotes: completionNotes ?? this.completionNotes,
      otp: otp ?? this.otp,
      status: status ?? this.status,
      isCompleteClicked: isCompleteClicked ?? this.isCompleteClicked,
      isOTPRequested: isOTPRequested ?? this.isOTPRequested,
      isVerified: isVerified ?? this.isVerified,
      providerName: providerName ?? this.providerName,
      providerPhone: providerPhone ?? this.providerPhone,
      providerProfession: providerProfession ?? this.providerProfession,
      review: review ?? this.review,
      delayTime: delayTime ?? this.delayTime,
      delayNote: delayNote ?? this.delayNote,
      categoryId: categoryId ?? this.categoryId,
      additionalAmount: additionalAmount ?? this.additionalAmount,
      additionalNote: additionalNote ?? this.additionalNote,
      reassignReason: reassignReason ?? this.reassignReason,
      assignedBy: assignedBy ?? this.assignedBy,
      redeemedPoints: redeemedPoints ?? this.redeemedPoints,
      pointsValue: pointsValue ?? this.pointsValue,
      adminCommission: adminCommission ?? this.adminCommission,
      isAdminCommissionCollected:
          isAdminCommissionCollected ?? this.isAdminCommissionCollected,
      commissionPaymentMode:
          commissionPaymentMode ?? this.commissionPaymentMode,
      isPointsIncremented: isPointsIncremented ?? this.isPointsIncremented,
      customerPoints: customerPoints ?? this.customerPoints,
    );
  }
}
