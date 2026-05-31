class FocusSessionModel {
  final String id;
  final String userId;
  final DateTime startTime;
  final DateTime endTime;
  final int durationMinutes;
  final String mode;
  final DateTime createdAt;

  FocusSessionModel({
    required this.id,
    required this.userId,
    required this.startTime,
    required this.endTime,
    required this.durationMinutes,
    required this.mode,
    required this.createdAt,
  });

  factory FocusSessionModel.fromJson(Map<String, dynamic> json) {
    return FocusSessionModel(
      id: json['id'],
      userId: json['userId'],
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      durationMinutes: json['durationMinutes'],
      mode: json['mode'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'durationMinutes': durationMinutes,
      'mode': mode,
    };
  }
}

class DailyFocusHeatmapModel {
  final DateTime date;
  final int totalMinutes;

  DailyFocusHeatmapModel({
    required this.date,
    required this.totalMinutes,
  });

  factory DailyFocusHeatmapModel.fromJson(Map<String, dynamic> json) {
    return DailyFocusHeatmapModel(
      date: DateTime.parse(json['date']),
      totalMinutes: json['totalMinutes'],
    );
  }
}
