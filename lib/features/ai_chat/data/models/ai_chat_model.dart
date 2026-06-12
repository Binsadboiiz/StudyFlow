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
      role: json['role'] ?? json['Role'] ?? '',
      content: json['content'] ?? json['Content'] ?? '',
    );
  }
}

class FlashcardSuggestionModel {
  final String question;
  final String answer;

  FlashcardSuggestionModel({required this.question, required this.answer});

  factory FlashcardSuggestionModel.fromJson(Map<String, dynamic> json) {
    return FlashcardSuggestionModel(
      question: json['question'] ?? json['Question'] ?? '',
      answer: json['answer'] ?? json['Answer'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'question': question,
        'answer': answer,
      };
}

class AiActionSuggestionModel {
  final String actionType;
  final String title;
  final String description;
  final DateTime? dueDate;
  final String? startTime;
  final String? endTime;
  final String? date;
  final List<FlashcardSuggestionModel>? flashcards;

  AiActionSuggestionModel({
    required this.actionType,
    required this.title,
    required this.description,
    this.dueDate,
    this.startTime,
    this.endTime,
    this.date,
    this.flashcards,
  });

  factory AiActionSuggestionModel.fromJson(Map<String, dynamic> json) {
    DateTime? parsedDue;
    if (json['dueDate'] != null || json['DueDate'] != null) {
      try {
        parsedDue = DateTime.parse(json['dueDate'] ?? json['DueDate']);
      } catch (_) {}
    }
    var rawCards = json['flashcards'] ?? json['Flashcards'];
    List<FlashcardSuggestionModel>? cards;
    if (rawCards != null && rawCards is List) {
      cards = (rawCards)
          .map((e) => FlashcardSuggestionModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return AiActionSuggestionModel(
      actionType: json['actionType'] ?? json['ActionType'] ?? '',
      title: json['title'] ?? json['Title'] ?? '',
      description: json['description'] ?? json['Description'] ?? '',
      dueDate: parsedDue,
      startTime: json['startTime'] ?? json['StartTime'],
      endTime: json['endTime'] ?? json['EndTime'],
      date: json['date'] ?? json['Date'],
      flashcards: cards,
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
