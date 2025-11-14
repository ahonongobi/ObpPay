class UserModel {
  String fullName;
  String obpayId;
  String phone;
  int points;

  UserModel({
    required this.fullName,
    required this.obpayId,
    required this.phone,
    required this.points,
  });

  bool get isEligible => points >= 50; // Condition d'éligibilité
}
