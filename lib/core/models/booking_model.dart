enum BookingStatus { pending, ongoing, completed, cancelled }

class BookingModel {
  final String id; // Backend ID (_id)
  final String bookingId; // Display ID (PHxxxx)
  final String serviceId;
  final String serviceName;
  final String date;
  final String time;
  final String location;
  final String? providerName;
  final String? providerPhone;
  final String? providerProfession;

  final String customerName;
  final String customerPhone;
  final double price;
  final double totalAmount;
  final String paymentStatus;
  final String paymentMode;
  final String description;
  final List<String> jobProofImages;
  final String? completionNotes;
  final String? otp;
  BookingStatus status;
  bool isCompleteClicked;
  bool isOTPRequested;
  bool isVerified;

  BookingModel({
    required this.id,
    required this.bookingId,
    required this.serviceId,
    required this.serviceName,
    required this.date,
    required this.time,
    required this.location,
    required this.customerName,
    required this.customerPhone,
    required this.price,
    this.totalAmount = 0,
    this.paymentStatus = 'PENDING',
    this.paymentMode = 'CASH',
    this.description = '',
    this.jobProofImages = const [],
    this.completionNotes,
    this.otp,
    this.status = BookingStatus.pending,
    this.isCompleteClicked = false,
    this.isOTPRequested = false,
    this.isVerified = false,
    this.providerName,
    this.providerPhone,
    this.providerProfession,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    // Parse nested objects
    final serviceIdx = json['serviceId'];
    final customerIdx = json['customerId'];
    final locationIdx = json['location'];
    final providerIdx = json['providerId'];

    String serviceName = 'Unknown Service';
    String serviceIdStr = '';
    if (serviceIdx is Map) {
      serviceName = serviceIdx['name'] ?? 'Unknown Service';
      serviceIdStr = serviceIdx['_id'] ?? '';
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
    if (customerIdx is Map) {
      customerName = customerIdx['name'] ?? 'Unknown';
      customerPhone = customerIdx['phone'] ?? '';
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
    if (locationIdx is Map) {
      if (locationIdx.containsKey('address')) {
        address = locationIdx['address'] ?? 'Unknown Location';
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
    );
  }

  static BookingStatus _parseStatus(String? status) {
    if (status == null) return BookingStatus.pending;
    switch (status.toUpperCase()) {
      case 'ASSIGNED':
      case 'PENDING':
        return BookingStatus.pending;
      case 'ACCEPTED':
      case 'ONGOING':
        return BookingStatus.ongoing;
      case 'COMPLETED':
        return BookingStatus.completed;
      case 'CANCELLED':
        return BookingStatus.cancelled;
      default:
        return BookingStatus.pending;
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
  }) {
    return BookingModel(
      id: id ?? this.id,
      bookingId: bookingId ?? this.bookingId,
      serviceId: serviceId ?? this.serviceId,
      serviceName: serviceName ?? this.serviceName,
      date: date ?? this.date,
      time: time ?? this.time,
      location: location ?? this.location,
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
    );
  }
}
