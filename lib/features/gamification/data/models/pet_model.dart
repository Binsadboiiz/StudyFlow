/// Model đại diện cho thông tin Thú cưng học tập (Study Pet).
class PetModel {
  final String id;
  final String userId;
  final String name;
  final String petType;
  final int level;
  final double exp;
  final String evolutionStage;
  final int hunger;
  final DateTime lastFedTime;
  final DateTime createdAt;

  PetModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.petType,
    required this.level,
    required this.exp,
    required this.evolutionStage,
    required this.hunger,
    required this.lastFedTime,
    required this.createdAt,
  });

  factory PetModel.fromJson(Map<String, dynamic> json) {
    return PetModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      name: json['name'] ?? '',
      petType: json['petType'] ?? '',
      level: (json['level'] as num?)?.toInt() ?? 1,
      exp: (json['exp'] as num?)?.toDouble() ?? 0.0,
      evolutionStage: json['evolutionStage'] ?? 'Egg',
      hunger: (json['hunger'] as num?)?.toInt() ?? 100,
      lastFedTime: json['lastFedTime'] != null 
          ? DateTime.parse(json['lastFedTime']) 
          : DateTime.now(),
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
    );
  }

  /// Chuyển đổi thành JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'petType': petType,
      'level': level,
      'exp': exp,
      'evolutionStage': evolutionStage,
      'hunger': hunger,
      'lastFedTime': lastFedTime.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  PetModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? petType,
    int? level,
    double? exp,
    String? evolutionStage,
    int? hunger,
    DateTime? lastFedTime,
    DateTime? createdAt,
  }) {
    return PetModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      petType: petType ?? this.petType,
      level: level ?? this.level,
      exp: exp ?? this.exp,
      evolutionStage: evolutionStage ?? this.evolutionStage,
      hunger: hunger ?? this.hunger,
      lastFedTime: lastFedTime ?? this.lastFedTime,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
