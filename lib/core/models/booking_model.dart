enum BookingStatus { pending, ongoing, completed, cancelled }

class BookingModel {
  final String id;
  final String serviceName;
  final String date;
  final String time;
  final String location;
  BookingStatus status;
  bool isCompleteClicked;
  bool isOTPRequested;
  bool isVerified;

  BookingModel({
    required this.id,
    required this.serviceName,
    required this.date,
    required this.time,
    required this.location,
    this.status = BookingStatus.pending,
    this.isCompleteClicked = false,
    this.isOTPRequested = false,
    this.isVerified = false,
  });

  BookingModel copyWith({
    String? id,
    String? serviceName,
    String? date,
    String? time,
    String? location,
    BookingStatus? status,
    bool? isCompleteClicked,
    bool? isOTPRequested,
    bool? isVerified,
  }) {
    return BookingModel(
      id: id ?? this.id,
      serviceName: serviceName ?? this.serviceName,
      date: date ?? this.date,
      time: time ?? this.time,
      location: location ?? this.location,
      status: status ?? this.status,
      isCompleteClicked: isCompleteClicked ?? this.isCompleteClicked,
      isOTPRequested: isOTPRequested ?? this.isOTPRequested,
      isVerified: isVerified ?? this.isVerified,
    );
  }
}
