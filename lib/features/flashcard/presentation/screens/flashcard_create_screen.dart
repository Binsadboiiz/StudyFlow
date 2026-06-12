import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:studyflow/features/flashcard/presentation/providers/flashcard_provider.dart';
import 'package:studyflow/l10n/app_localizations.dart';
import 'package:studyflow/core/services/notification/app_notification.dart';
import 'package:studyflow/core/services/notification/notification_type.dart';
import 'package:studyflow/core/services/notification/notification_service.dart';

class FlashcardCreateScreen extends StatefulWidget {
  const FlashcardCreateScreen({super.key});

  @override
  State<FlashcardCreateScreen> createState() => _FlashcardCreateScreenState();
}

class _FlashcardCreateScreenState extends State<FlashcardCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final List<Map<String, TextEditingController>> _cards = [];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _addNewCard();
  }

  @override
  void dispose() {
    _titleController.dispose();
    for (var card in _cards) {
      card['question']!.dispose();
      card['answer']!.dispose();
    }
    super.dispose();
  }

  void _addNewCard() {
    setState(() {
      _cards.add({
        'question': TextEditingController(),
        'answer': TextEditingController(),
      });
    });
  }

  void _removeCard(int index) {
    if (_cards.length <= 1) return;
    setState(() {
      final card = _cards.removeAt(index);
      card['question']!.dispose();
      card['answer']!.dispose();
    });
  }

  Future<void> _saveSet() async {
    if (_titleController.text.trim().isEmpty) {
      NotificationService.instance.show(
        AppNotification(
          message: AppLocalizations.of(context)!.flashcardValidationTitle,
          type: NotificationType.error,
        ),
      );
      return;
    }

    if (_cards.isEmpty) {
      NotificationService.instance.show(
        AppNotification(
          message: AppLocalizations.of(context)!.flashcardValidationMinCards,
          type: NotificationType.error,
        ),
      );
      return;
    }

    for (var i = 0; i < _cards.length; i++) {
      if (_cards[i]['question']!.text.trim().isEmpty ||
          _cards[i]['answer']!.text.trim().isEmpty) {
        NotificationService.instance.show(
          AppNotification(
            message: AppLocalizations.of(context)!.flashcardValidationEmptyCard,
            type: NotificationType.error,
          ),
        );
        return;
      }
    }

    setState(() {
      _isSaving = true;
    });

    final provider = context.read<FlashcardProvider>();
    final title = _titleController.text.trim();
    final List<Map<String, String>> cardsData = _cards.map((c) {
      return {
        'question': c['question']!.text.trim(),
        'answer': c['answer']!.text.trim(),
      };
    }).toList();

    final newSet = await provider.createFlashcardSet(title, cardsData);

    setState(() {
      _isSaving = false;
    });

    if (newSet != null) {
      if (mounted) {
        NotificationService.instance.show(
          AppNotification(
            message: AppLocalizations.of(context)!.flashcardGenerateSuccess,
            type: NotificationType.success,
          ),
        );
        Navigator.pop(context);
      }
    } else {
      if (mounted) {
        String errMsg = provider.errorMessage ?? "Failed to create flashcard set.";
        if (errMsg.toLowerCase().contains("limit of 200") || errMsg.toLowerCase().contains("limit of 200")) {
          errMsg = AppLocalizations.of(context)!.flashcardLimitReached;
        }
        NotificationService.instance.show(
          AppNotification(
            message: errMsg,
            type: NotificationType.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.flashcardCreateTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (_isSaving)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _saveSet,
              child: Text(
                AppLocalizations.of(context)!.flashcardSave,
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: TextFormField(
                      controller: _titleController,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.flashcardTitleLabel,
                        hintText: AppLocalizations.of(context)!.flashcardTitleHint,
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _cards.length,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Card #${index + 1}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: primaryColor,
                                    fontSize: 14,
                                  ),
                                ),
                                if (_cards.length > 1)
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                    onPressed: () => _removeCard(index),
                                  ),
                              ],
                            ),
                            const Divider(),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _cards[index]['question'],
                              maxLines: 2,
                              decoration: InputDecoration(
                                labelText: AppLocalizations.of(context)!.flashcardQuestionHint,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _cards[index]['answer'],
                              maxLines: 2,
                              decoration: InputDecoration(
                                labelText: AppLocalizations.of(context)!.flashcardAnswerHint,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(duration: 200.ms).slideY(begin: 0.1, end: 0);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addNewCard,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: Text(AppLocalizations.of(context)!.flashcardAddCard),
      ),
    );
  }
}
