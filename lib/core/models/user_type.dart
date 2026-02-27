enum UserType {
  customer,
  serviceBoy;

  String get displayName {
    switch (this) {
      case UserType.customer:
        return 'CUSTOMER';
      case UserType.serviceBoy:
        return 'SERVICE_BOY';
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

  String get apiValue {
    switch (this) {
      case UserType.customer:
        return 'CUSTOMER';
      case UserType.serviceBoy:
        return 'SERVICE_BOY';
    }
  }
}
