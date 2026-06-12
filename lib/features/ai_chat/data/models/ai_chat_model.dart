class ChatMessageModel {
  final String role;
  final String content;

  ChatMessageModel({required this.role, required this.content});

  Map<String, dynamic> toJson() => {
        'role': role,
        'content': content,
      };

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      role: json['role'] ?? '',
      content: json['content'] ?? '',
    );
  }
}

class AiActionSuggestionModel {
  final String actionType;
  final String title;
  final String description;
  final DateTime? dueDate;
  final String? startTime;
  final String? endTime;
  final String? date;

  AiActionSuggestionModel({
    required this.actionType,
    required this.title,
    required this.description,
    this.dueDate,
    this.startTime,
    this.endTime,
    this.date,
  });

  factory AiActionSuggestionModel.fromJson(Map<String, dynamic> json) {
    DateTime? parsedDue;
    if (json['dueDate'] != null || json['DueDate'] != null) {
      try {
        parsedDue = DateTime.parse(json['dueDate'] ?? json['DueDate']);
      } catch (_) {}
    }
    return AiActionSuggestionModel(
      actionType: json['actionType'] ?? json['ActionType'] ?? '',
      title: json['title'] ?? json['Title'] ?? '',
      description: json['description'] ?? json['Description'] ?? '',
      dueDate: parsedDue,
      startTime: json['startTime'] ?? json['StartTime'],
      endTime: json['endTime'] ?? json['EndTime'],
      date: json['date'] ?? json['Date'],
    );
  }
}

class ChatResponseModel {
  final String response;
  final int dailyRequestsRemaining;
  final List<AiActionSuggestionModel> suggestedActions;

  ChatResponseModel({
    required this.response,
    required this.dailyRequestsRemaining,
    required this.suggestedActions,
  });

  factory ChatResponseModel.fromJson(Map<String, dynamic> json) {
    var rawActions = json['suggestedActions'] ?? json['SuggestedActions'] ?? [];
    List<AiActionSuggestionModel> actions = (rawActions as List)
        .map((e) => AiActionSuggestionModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return ChatResponseModel(
      response: json['response'] ?? json['Response'] ?? '',
      dailyRequestsRemaining: json['dailyRequestsRemaining'] ?? json['DailyRequestsRemaining'] ?? 0,
      suggestedActions: actions,
    );
  }
}
