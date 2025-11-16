class UserModel {
  final String fullName;
  final String phone;
  final String obpayId;
  final int points;
  final bool isEligible;
  final double balance;
  final String currency;

  UserModel({
    required this.fullName,
    required this.phone,
    required this.obpayId,
    required this.points,
    required this.isEligible,
    required this.balance,
    required this.currency,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final wallet = json["wallet"];

    final double balance = wallet != null
        ? double.tryParse(wallet["balance"].toString()) ?? 0.0
        : 0.0;
    return UserModel(
      fullName: json["name"] ?? "",
      phone: json["phone"] ?? "",
      obpayId: json["obp_id"] ?? "",
      points: balance.toInt(),
      isEligible:  balance >= 50,
      balance: balance, currency: wallet["currency"]
    );
  }

  factory UserModel.empty() => UserModel(
    fullName: "",
    phone: "",
    obpayId: "",
    points: 0,
    isEligible: false,
    balance: 0,
    currency: ""
  );

  UserModel copyWith({
    String? fullName,
    String? phone,
    String? obpayId,
    int? points,
    bool? isEligible,
    double? balance,
    String? currency,
  }) {
    return UserModel(
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      obpayId: obpayId ?? this.obpayId,
      points: points ?? this.points,
      isEligible: isEligible ?? this.isEligible,
      balance: balance ?? this.balance,
      currency: currency ?? this.currency,
    );
  }
}
