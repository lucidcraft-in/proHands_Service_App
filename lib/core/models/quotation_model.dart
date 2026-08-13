enum QuotationStatus {
  requested,
  assignedToTechnician,
  quotationGiven,
  adminVerified,
  rejected,
  converted,
  accepted,
  expired,
  created,
  unknown,
}

extension QuotationStatusExtension on QuotationStatus {
  String toBackendString() {
    switch (this) {
      case QuotationStatus.requested:
        return 'QUOTATION_REQUESTED';
      case QuotationStatus.assignedToTechnician:
        return 'ASSIGNED_TO_TECHNICIAN';
      case QuotationStatus.quotationGiven:
        return 'QUOTATION_GIVEN';
      case QuotationStatus.adminVerified:
        return 'ADMIN_VERIFIED';
      case QuotationStatus.rejected:
        return 'QUOTATION_REJECTED';
      case QuotationStatus.converted:
        return 'CONVERTED';
      case QuotationStatus.accepted:
        return 'QUOTATION_ACCEPTED';
      case QuotationStatus.expired:
        return 'EXPIRED';
      case QuotationStatus.created:
        return 'CREATED';
      default:
        return 'UNKNOWN';
    }
  }

  static QuotationStatus fromBackendString(String? statusStr) {
    switch (statusStr) {
      case 'QUOTATION_REQUESTED':
        return QuotationStatus.requested;
      case 'ASSIGNED_TO_TECHNICIAN':
        return QuotationStatus.assignedToTechnician;
      case 'QUOTATION_GIVEN':
        return QuotationStatus.quotationGiven;
      case 'ADMIN_VERIFIED':
        return QuotationStatus.adminVerified;
      case 'QUOTATION_REJECTED':
        return QuotationStatus.rejected;
      case 'CONVERTED':
        return QuotationStatus.converted;
      case 'QUOTATION_ACCEPTED':
        return QuotationStatus.accepted;
      case 'EXPIRED':
        return QuotationStatus.expired;
      case 'CREATED':
        return QuotationStatus.created;
      default:
        return QuotationStatus.unknown;
    }
  }

  String getDisplayStatus(bool isTechnician) {
    switch (this) {
      case QuotationStatus.requested:
        return 'Requested';
      case QuotationStatus.assignedToTechnician:
        return isTechnician ? 'Assigned' : 'Pending Admin';
      case QuotationStatus.quotationGiven:
        return isTechnician ? 'Estimate Sent' : 'Pending Admin';
      case QuotationStatus.adminVerified:
        return 'Verified by Admin';
      case QuotationStatus.rejected:
        return 'Rejected';
      case QuotationStatus.converted:
        return 'Converted to Booking';
      case QuotationStatus.accepted:
        return 'Accepted';
      case QuotationStatus.expired:
        return 'Expired';
      case QuotationStatus.created:
        return 'Created';
      default:
        return 'Unknown';
    }
  }
}

class QuotationLocation {
  final String locationName;
  final String city;
  final double latitude;
  final double longitude;

  QuotationLocation({
    required this.locationName,
    required this.city,
    required this.latitude,
    required this.longitude,
  });

  factory QuotationLocation.fromJson(Map<String, dynamic> json) {
    return QuotationLocation(
      locationName: json['location_name'] ?? json['address'] ?? '',
      city: json['city'] ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'location_name': locationName,
      'city': city,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

class TechnicianImage {
  final String id;
  final String url;

  TechnicianImage({required this.id, required this.url});

  factory TechnicianImage.fromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      return TechnicianImage(
        id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
        url: json['url']?.toString() ?? '',
      );
    } else if (json is String) {
      return TechnicianImage(id: '', url: json);
    }
    return TechnicianImage(id: '', url: '');
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'url': url};
  }
}

class RequestedTechnician {
  final String? id;
  final String technicianId;
  final String name;
  final String? phone;
  final String? email;
  final String? status;
  final String? profilePhoto;
  final double? rating;
  final double? amount;
  final String currency;
  final List<String> notes;
  final List<TechnicianImage> images;
  final String? submittedAt;

  RequestedTechnician({
    this.id,
    required this.technicianId,
    required this.name,
    this.phone,
    this.email,
    this.status,
    this.profilePhoto,
    this.rating,
    this.amount,
    this.currency = 'INR',
    this.notes = const [],
    this.images = const [],
    this.submittedAt,
  });

  String? get image => profilePhoto ?? (images.isNotEmpty ? images.first.url : null);

  factory RequestedTechnician.fromJson(Map<String, dynamic> json) {
    final techData = json['technicianId'];
    String techId = '';
    String? techName;
    String? techPhone;
    String? techEmail;
    String? techPhoto;
    double? techRating;

    if (techData is Map<String, dynamic>) {
      techId = techData['_id'] ?? '';
      techName = techData['name'];
      techPhone = techData['phone'];
      techEmail = techData['email'];
      techPhoto = techData['profilePhoto'] ?? techData['image'];
      techRating = (techData['rating'] as num?)?.toDouble();
    } else if (techData is String) {
      techId = techData;
    } else {
      techId = json['_id'] ?? '';
    }

    // Parse images
    List<TechnicianImage> parsedImages = [];
    if (json['images'] is List) {
      parsedImages = (json['images'] as List)
          .map((img) => TechnicianImage.fromJson(img))
          .where((img) => img.url.isNotEmpty)
          .toList();
    }

    // Parse notes
    List<String> parsedNotes = [];
    if (json['notes'] is List) {
      parsedNotes = (json['notes'] as List)
          .map((n) => n.toString())
          .where((n) => n.isNotEmpty)
          .toList();
    } else if (json['notes'] is String && (json['notes'] as String).isNotEmpty) {
      parsedNotes = [(json['notes'] as String)];
    }

    return RequestedTechnician(
      id: json['_id'],
      technicianId: techId,
      name: json['name'] ?? techName ?? '',
      phone: json['phone'] ?? techPhone,
      email: json['email'] ?? techEmail,
      status: json['status'],
      profilePhoto: techPhoto ?? json['profilePhoto'] ?? json['image'],
      rating: techRating ?? (json['rating'] as num?)?.toDouble(),
      amount: (json['amount'] as num?)?.toDouble(),
      currency: json['currency'] ?? 'INR',
      notes: parsedNotes,
      images: parsedImages,
      submittedAt: json['submittedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'technicianId': technicianId,
      'name': name,
      'phone': phone,
      'email': email,
      'status': status,
      'profilePhoto': profilePhoto,
      'rating': rating,
      'amount': amount,
      'currency': currency,
      'notes': notes,
      'images': images.map((i) => i.toJson()).toList(),
      'submittedAt': submittedAt,
    };
  }
}

class QuotationModel {
  final String id;
  final String quotationId;
  final QuotationStatus status;
  final String customerId;
  final String? customerName;
  final String? customerPhone;
  final String serviceId;
  final String? serviceName;
  final QuotationLocation location;
  final String? description;
  final String? notes;
  final double? amount;
  final String? technicianNote;
  final List<String> attachments;
  final List<RequestedTechnician> requestedTechnicians;
  final String? providerId;
  final String? createdAt;
  final String? updatedAt;

  QuotationModel({
    required this.id,
    required this.quotationId,
    required this.status,
    required this.customerId,
    this.customerName,
    this.customerPhone,
    required this.serviceId,
    this.serviceName,
    required this.location,
    this.description,
    this.notes,
    this.amount,
    this.technicianNote,
    required this.attachments,
    this.requestedTechnicians = const [],
    this.providerId,
    this.createdAt,
    this.updatedAt,
  });

  factory QuotationModel.fromJson(Map<String, dynamic> json) {
    final serviceData = json['serviceId'];
    print(json['attachments']);
    String? sName;
    String sId = '';
    if (serviceData is Map<String, dynamic>) {
      sId = serviceData['_id'] ?? '';
      sName = serviceData['name'];
    } else if (serviceData is String) {
      sId = serviceData;
    }

    final customerData = json['customerId'];
    String? cName;
    String? cPhone;
    String cId = '';
    if (customerData is Map<String, dynamic>) {
      cId = customerData['_id'] ?? '';
      cName = customerData['name'];
      cPhone = customerData['phone'];
    } else if (customerData is String) {
      cId = customerData;
    }

    final notesData = json['notes'];
    String? parsedNotes;
    if (notesData is List) {
      parsedNotes = notesData
          .map((item) {
            if (item is Map && item.containsKey('note')) {
              return item['note']?.toString() ?? '';
            }
            return item?.toString() ?? '';
          })
          .where((note) => note.isNotEmpty)
          .join('\n');
    } else if (notesData is String) {
      parsedNotes = notesData;
    }
    print(json['status']);
    return QuotationModel(
      id: json['_id'] ?? '',
      quotationId: json['quotationId'] ?? '',
      status: QuotationStatusExtension.fromBackendString(json['status']),
      customerId: cId,
      customerName: cName ?? json['customerName'],
      customerPhone: cPhone ?? json['customerPhone'],
      serviceId: sId,
      serviceName: sName ?? json['serviceName'],
      location:
          json['location'] != null
              ? QuotationLocation.fromJson(json['location'])
              : QuotationLocation(
                locationName: '',
                city: '',
                latitude: 0.0,
                longitude: 0.0,
              ),
      description: json['description'],
      notes: parsedNotes,
      amount: (json['amount'] as num?)?.toDouble(),
      technicianNote: json['technicianNote'],
      attachments:
          json['attachments'] != null
              ? List<String>.from(json['attachments'])
              : const [],
      requestedTechnicians: json['requestedTechnicians'] != null
          ? (json['requestedTechnicians'] as List)
              .map((t) => RequestedTechnician.fromJson(t))
              .toList()
          : const [],
      providerId:
          json['providerId'] is Map
              ? (json['providerId']['_id'] ?? '')
              : json['providerId'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'quotationId': quotationId,
      'status': status.toBackendString(),
      'customerId': customerId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'serviceId': serviceId,
      'serviceName': serviceName,
      'location': location.toJson(),
      'description': description,
      'notes': notes,
      'amount': amount,
      'technicianNote': technicianNote,
      'attachments': attachments,
      'requestedTechnicians': requestedTechnicians.map((t) => t.toJson()).toList(),
      'providerId': providerId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
