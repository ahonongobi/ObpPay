class UserModel {
  final String fullName;
  final String phone;
  final String email;
  final String obpayId;
  final int points;
  final bool isEligible;
  final double balance;
  final String currency;
  final int score;
  final String registeredAt;
  String avatarUrl;
  final String cvv;
  UserModel({
    required this.fullName,
    required this.phone,
    required this.email,
    required this.obpayId,
    required this.points,
    required this.isEligible,
    required this.balance,
    required this.currency,
    required this.score,
    required this.registeredAt,
    required this.avatarUrl,
    required this.cvv,

  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final wallet = json["wallet"];

    final double balance = wallet != null
        ? double.tryParse(wallet["balance"].toString()) ?? 0.0
        : 0.0;
    return UserModel(
      fullName: json["name"] ?? "",
      phone: json["phone"] ?? "",
      email: json["email"] ?? "",
      obpayId: json["obp_id"] ?? "",
      points: balance.toInt(),
      isEligible:  json["score"] >= 500,
      balance: balance, currency: wallet["currency"],
      score: json["score"],
      registeredAt: json["created_at"],
      avatarUrl: json["avatar_url"],
      cvv: json["card_cvv"],
    );
  }

  factory UserModel.empty() => UserModel(
    fullName: "",
    phone: "",
    email: "",
    obpayId: "",
    points: 0,
    isEligible: false,
    balance: 0,
    currency: "",
    score: 0,
    registeredAt: "",
    avatarUrl: "",
    cvv: "",
  );

  UserModel copyWith({
    String? fullName,
    String? phone,
    String? email,
    String? obpayId,
    int? points,
    bool? isEligible,
    double? balance,
    String? currency,
    int? score,
    String? registeredAt,
    String? avatarUrl,
    String? cvv,
  }) {
    return UserModel(
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      obpayId: obpayId ?? this.obpayId,
      points: points ?? this.points,
      isEligible: isEligible ?? this.isEligible,
      balance: balance ?? this.balance,
      currency: currency ?? this.currency,
      score: score ?? this.score,
      registeredAt: registeredAt ?? this.registeredAt,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      cvv: cvv ?? this.cvv,
    );
  }
}
