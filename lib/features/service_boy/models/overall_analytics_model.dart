class OverallAnalyticsModel {
  final int totalBookings;
  final double totalRevenue;
  final int totalServices;
  final List<CategoryServiceCount> servicesByCategory;
  final List<CategoryBookingCount> bookingsByCategory;

  OverallAnalyticsModel({
    required this.totalBookings,
    required this.totalRevenue,
    required this.totalServices,
    required this.servicesByCategory,
    required this.bookingsByCategory,
  });

  factory OverallAnalyticsModel.fromJson(Map<String, dynamic> json) {
    return OverallAnalyticsModel(
      totalBookings: json['totalBookings'] ?? 0,
      totalRevenue: (json['totalRevenue'] ?? 0.0).toDouble(),
      totalServices: json['totalServices'] ?? 0,
      servicesByCategory:
          (json['totalServicesByCategory'] as List? ?? [])
              .map((i) => CategoryServiceCount.fromJson(i))
              .toList(),
      bookingsByCategory:
          (json['bookingCountByCategory'] as List? ?? [])
              .map((i) => CategoryBookingCount.fromJson(i))
              .toList(),
    );
  }
}

class CategoryServiceCount {
  final int serviceCount;
  final String categoryId;
  final String categoryName;

  CategoryServiceCount({
    required this.serviceCount,
    required this.categoryId,
    required this.categoryName,
  });

  factory CategoryServiceCount.fromJson(Map<String, dynamic> json) {
    return CategoryServiceCount(
      serviceCount: json['serviceCount'] ?? 0,
      categoryId: json['categoryId'] ?? '',
      categoryName: json['categoryName'] ?? '',
    );
  }
}

class CategoryBookingCount {
  final int bookingCount;
  final String categoryId;
  final String categoryName;

  CategoryBookingCount({
    required this.bookingCount,
    required this.categoryId,
    required this.categoryName,
  });

  factory CategoryBookingCount.fromJson(Map<String, dynamic> json) {
    return CategoryBookingCount(
      bookingCount: json['bookingCount'] ?? 0,
      categoryId: json['categoryId'] ?? '',
      categoryName: json['categoryName'] ?? '',
    );
  }
}
