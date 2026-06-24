import 'dart:math';
import 'package:flutter/material.dart';
import 'package:studyflow/features/flashcard/data/models/flashcard_model.dart';
import 'package:studyflow/l10n/app_localizations.dart';

class FlashcardStudyScreen extends StatefulWidget {
  final FlashcardSetModel flashcardSet;
  const FlashcardStudyScreen({super.key, required this.flashcardSet});

  @override
  State<FlashcardStudyScreen> createState() => _FlashcardStudyScreenState();
}

class _FlashcardStudyScreenState extends State<FlashcardStudyScreen> {
  int _currentIndex = 0;
  bool _isFlipped = false;
  int _rememberedCount = 0;
  int _forgottenCount = 0;

  void _flipCard() {
    setState(() {
      _isFlipped = !_isFlipped;
    });
  }

  void _markAs(bool remembered) {
    setState(() {
      if (remembered) {
        _rememberedCount++;
      } else {
        _forgottenCount++;
      }
      _isFlipped = false;
      _currentIndex++;
    });
  }

  void _reset() {
    setState(() {
      _currentIndex = 0;
      _isFlipped = false;
      _rememberedCount = 0;
      _forgottenCount = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final list = widget.flashcardSet.flashcards;
    final isFinished = _currentIndex >= list.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.flashcardSet.title, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: isFinished
            ? _buildSummaryScreen(list.length)
            : _buildStudyScreen(list[_currentIndex], list.length),
      ),
    );
  }

  Widget _buildSummaryScreen(int total) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_outline, size: 80, color: Colors.green),
            const SizedBox(height: 24),
            Text(
              AppLocalizations.of(context)!.flashcardStudyFinished,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildSummaryRow(AppLocalizations.of(context)!.flashcardSummaryTotal, '$total', Colors.blue),
                    const Divider(),
                    _buildSummaryRow(AppLocalizations.of(context)!.flashcardSummaryRemembered, '$_rememberedCount', Colors.green),
                    const Divider(),
                    _buildSummaryRow(AppLocalizations.of(context)!.flashcardSummaryForgotten, '$_forgottenCount', Colors.red),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                  label: Text(AppLocalizations.of(context)!.tutorialBack),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _reset,
                  icon: const Icon(Icons.replay),
                  label: Text(AppLocalizations.of(context)!.flashcardReplay),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildStudyScreen(FlashcardModel card, int total) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Thanh tiến trình
          LinearProgressIndicator(
            value: (_currentIndex) / total,
            backgroundColor: Colors.grey.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
          ),
          const SizedBox(height: 12),
          Text(
            'Thẻ ${_currentIndex + 1} / $total',
            style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          // Thẻ lật 3D
          Expanded(
            child: GestureDetector(
              onTap: _flipCard,
              child: TweenAnimationBuilder(
                tween: Tween<double>(begin: 0, end: _isFlipped ? 180 : 0),
                duration: const Duration(milliseconds: 300),
                builder: (context, double val, child) {
                  // Xoay thẻ theo chiều Y
                  final isBack = val >= 90;
                  return Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001) // perspective
                      ..rotateY(val * pi / 180),
                    child: isBack
                        ? Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()..rotateY(pi),
                            child: _buildCardFace(card.answer, isBack: true),
                          )
                        : _buildCardFace(card.question, isBack: false),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 32),
          // Các nút hành động
          if (!_isFlipped)
            Text(
              AppLocalizations.of(context)!.flashcardFlipHint,
              style: const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _markAs(false),
                  icon: const Icon(Icons.close, color: Colors.white),
                  label: Text(AppLocalizations.of(context)!.flashcardSummaryForgotten, style: const TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _markAs(true),
                  icon: const Icon(Icons.check, color: Colors.white),
                  label: Text(AppLocalizations.of(context)!.flashcardSummaryRemembered, style: const TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildCardFace(String text, {required bool isBack}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isBack 
            ? (isDark ? const Color(0xFF1E293B) : const Color(0xFFEFF6FF))
            : (isDark ? const Color(0xFF151D24) : Colors.white),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isBack 
              ? Colors.blue.withOpacity(0.5) 
              : Colors.grey.withOpacity(0.2),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(32),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isBack ? Icons.help_outline : Icons.school_outlined,
                color: isBack ? Colors.blue : Theme.of(context).colorScheme.primary,
                size: 32,
              ),
              const SizedBox(height: 20),
              Text(
                isBack ? 'ANSWER' : 'QUESTION',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: isBack ? Colors.blue : Colors.grey,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
