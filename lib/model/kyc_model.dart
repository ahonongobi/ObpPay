class KycItem {
  final String type;
  final String status;

  KycItem({required this.type, required this.status});

  factory KycItem.fromJson(Map<String, dynamic>? json, String type) {
    if (json == null) {
      return KycItem(type: type, status: "missing");
    }
    return KycItem(
      type: type,
      status: json["status"] ?? "pending",
    );
  }
}
