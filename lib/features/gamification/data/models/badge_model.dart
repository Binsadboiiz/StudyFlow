/// Model đại diện cho thông tin một huy hiệu (Achievement Badge).
class BadgeModel {
  final String id;
  final String name;
  final String description;
  final String iconUrl;
  final String metricType;
  final int thresholdValue;
  final bool isUnlocked;
  final DateTime? earnedAt;

  BadgeModel({
    required this.id,
    required this.name,
    required this.description,
    required this.iconUrl,
    required this.metricType,
    required this.thresholdValue,
    required this.isUnlocked,
    this.earnedAt,
  });

  /// Factory chuyển đổi từ JSON map.
  factory BadgeModel.fromJson(Map<String, dynamic> json) {
    return BadgeModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      iconUrl: json['iconUrl'] ?? '',
      metricType: json['metricType'] ?? '',
      thresholdValue: json['thresholdValue'] ?? 0,
      isUnlocked: json['isUnlocked'] ?? false,
      earnedAt: json['earnedAt'] != null 
          ? DateTime.parse(json['earnedAt']) 
          : null,
    );
  }

  /// Chuyển đổi thành JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'iconUrl': iconUrl,
      'metricType': metricType,
      'thresholdValue': thresholdValue,
      'isUnlocked': isUnlocked,
      'earnedAt': earnedAt?.toIso8601String(),
    };
  }
}
