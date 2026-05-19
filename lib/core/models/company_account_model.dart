import 'user_model.dart';

class CompanyAccountModel {
  final String id;
  final String accountName;
  final String upiId;
  final String qrCode;
  final String phoneNumber;
  final String image;
  final bool isActive;
  final BankDetails bankDetails;

  CompanyAccountModel({
    required this.id,
    required this.accountName,
    required this.upiId,
    required this.qrCode,
    required this.phoneNumber,
    required this.image,
    required this.isActive,
    required this.bankDetails,
  });

  factory CompanyAccountModel.fromJson(Map<String, dynamic> json) {
    return CompanyAccountModel(
      id: json['_id'] ?? '',
      accountName: json['accountName'] ?? '',
      upiId: json['upiId'] ?? '',
      qrCode: json['qrCode'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      image: json['image'] ?? '',
      isActive: json['isActive'] ?? false,
      bankDetails: json['bankDetails'] != null
          ? BankDetails.fromJson(json['bankDetails'])
          : const BankDetails(),
    );
  }
}
