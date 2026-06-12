class FlashcardModel {
  final String id;
  final String question;
  final String answer;
  final String flashcardSetId;
  final DateTime createdAt;

  FlashcardModel({
    required this.id,
    required this.question,
    required this.answer,
    required this.flashcardSetId,
    required this.createdAt,
  });

  factory FlashcardModel.fromJson(Map<String, dynamic> json) {
    return FlashcardModel(
      id: json['id'] ?? json['Id'] ?? '',
      question: json['question'] ?? json['Question'] ?? '',
      answer: json['answer'] ?? json['Answer'] ?? '',
      flashcardSetId: json['flashcardSetId'] ?? json['FlashcardSetId'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? json['CreatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class FlashcardSetModel {
  final String id;
  final String title;
  final String? targetDocumentId;
  final DateTime createdAt;
  final List<FlashcardModel> flashcards;

  FlashcardSetModel({
    required this.id,
    required this.title,
    this.targetDocumentId,
    required this.createdAt,
    required this.flashcards,
  });

  factory FlashcardSetModel.fromJson(Map<String, dynamic> json) {
    var rawList = json['flashcards'] ?? json['Flashcards'] ?? [];
    List<FlashcardModel> cards = (rawList as List)
        .map((e) => FlashcardModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return FlashcardSetModel(
      id: json['id'] ?? json['Id'] ?? '',
      title: json['title'] ?? json['Title'] ?? '',
      targetDocumentId: json['targetDocumentId'] ?? json['TargetDocumentId'],
      createdAt: DateTime.parse(json['createdAt'] ?? json['CreatedAt'] ?? DateTime.now().toIso8601String()),
      flashcards: cards,
    );
  }
}
