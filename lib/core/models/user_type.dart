enum UserType {
  customer,
  serviceBoy;

  String get displayName {
    switch (this) {
      case UserType.customer:
        return 'User';
      case UserType.serviceBoy:
        return 'Service Boy';
    }
  }

  String get description {
    switch (this) {
      case UserType.customer:
        return 'Book services as a customer';
      case UserType.serviceBoy:
        return 'Provide services to customers';
    }
  }
}
