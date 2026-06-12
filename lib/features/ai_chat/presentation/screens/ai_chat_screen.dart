import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studyflow/features/ai_chat/presentation/providers/ai_chat_provider.dart';
import 'package:studyflow/features/ai_chat/data/models/ai_chat_model.dart';
import 'package:studyflow/features/task/presentation/viewmodels/task_viewmodel.dart';
import 'package:studyflow/features/task/domain/entities/task.dart';
import 'package:studyflow/l10n/app_localizations.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<AiActionSuggestionModel> _latestSuggestions = [];

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    
    setState(() {
      _latestSuggestions.clear();
    });

    final provider = context.read<AiChatProvider>();
    _scrollToBottom();
    
    final response = await provider.sendMessage(text);
    _scrollToBottom();

    if (response != null && response.suggestedActions.isNotEmpty) {
      setState(() {
        _latestSuggestions = response.suggestedActions;
      });
    }

    if (provider.errorMessage != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage!),
            backgroundColor: Colors.redAccent,
          ),
        );
        provider.clearError();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AiChatProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context)!.aiChatTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text(
              AppLocalizations.of(context)!.aiChatRequestsRemaining(provider.dailyRequestsRemaining),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            onPressed: () {
              provider.clearConversation();
              setState(() {
                _latestSuggestions.clear();
              });
            },
            tooltip: AppLocalizations.of(context)!.clearAll,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: provider.messages.isEmpty
                ? _buildEmptyState(isDark)
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: provider.messages.length,
                    itemBuilder: (context, index) {
                      final msg = provider.messages[index];
                      final isUser = msg.role == 'user';
                      return _buildChatBubble(msg, isUser, isDark, primaryColor);
                    },
                  ),
          ),
          if (provider.isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: primaryColor),
                  ),
                  const SizedBox(width: 8),
                  Text(AppLocalizations.of(context)!.aiChatThinking, style: const TextStyle(fontSize: 13, color: Colors.grey)),
                ],
              ),
            ),
          if (_latestSuggestions.isNotEmpty) _buildSuggestionsWidget(primaryColor, isDark),
          _buildInputArea(provider.isLoading, primaryColor, isDark),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.chat_bubble_outline, size: 48, color: Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(height: 24),
            Text(
              AppLocalizations.of(context)!.aiChatEmptyStateTitle,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              AppLocalizations.of(context)!.aiChatEmptyStateSubtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatBubble(ChatMessageModel msg, bool isUser, bool isDark, Color primaryColor) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isUser
              ? primaryColor
              : (isDark ? const Color(0xFF1E293B) : const Color(0xFFE5E7EB)),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 0),
            bottomRight: Radius.circular(isUser ? 0 : 16),
          ),
        ),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        child: Text(
          msg.content,
          style: TextStyle(
            color: isUser ? Colors.white : (isDark ? Colors.white : Colors.black87),
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestionsWidget(Color primaryColor, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.2))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome_outlined, size: 16, color: primaryColor),
              const SizedBox(width: 8),
              Text(AppLocalizations.of(context)!.aiChatActionSuggestions, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _latestSuggestions.map((action) {
                return Card(
                  margin: const EdgeInsets.only(right: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          action.actionType == 'CREATE_TASK' 
                              ? AppLocalizations.of(context)!.aiChatTaskPrefix 
                              : AppLocalizations.of(context)!.aiChatSchedulePrefix,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(action.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 2),
                        Text(
                          action.description.isNotEmpty ? action.description : 'Tự động tạo bởi AI',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _latestSuggestions.remove(action);
                                });
                              },
                              child: Text(AppLocalizations.of(context)!.aiChatDismiss, style: const TextStyle(color: Colors.grey)),
                            ),
                            ElevatedButton(
                              onPressed: () => _executeSuggestion(action),
                              child: Text(AppLocalizations.of(context)!.aiChatAccept),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _executeSuggestion(AiActionSuggestionModel action) async {
    final taskVm = context.read<TaskViewmodel>();
    
    // Tạo Task Entity
    final now = DateTime.now();
    DateTime taskDate = action.dueDate ?? now;
    if (action.date != null) {
      try {
        taskDate = DateTime.parse(action.date!);
      } catch (_) {}
    }

    DateTime? startTime;
    if (action.startTime != null) {
      try {
        final parts = action.startTime!.split(':');
        startTime = DateTime(taskDate.year, taskDate.month, taskDate.day, int.parse(parts[0]), int.parse(parts[1]));
      } catch (_) {}
    }

    DateTime? endTime;
    if (action.endTime != null) {
      try {
        final parts = action.endTime!.split(':');
        endTime = DateTime(taskDate.year, taskDate.month, taskDate.day, int.parse(parts[0]), int.parse(parts[1]));
      } catch (_) {}
    }

    final newTask = Task(
      id: '', // Backend/Firebase tự tạo UUID
      title: action.title,
      description: action.description,
      date: taskDate,
      startTime: startTime,
      endTime: endTime,
      isCompleted: false,
    );

    try {
      await taskVm.addTask(newTask);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.aiChatAddedSuccess(action.title)),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          _latestSuggestions.remove(action);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.aiChatAddFailed(e.toString())),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Widget _buildInputArea(bool isLoading, Color primaryColor, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF151D24) : Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.2))),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                enabled: !isLoading,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.aiChatInputHint,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  fillColor: isDark ? const Color(0xFF1F2937) : const Color(0xFFF3F4F6),
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _send(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(Icons.send, color: primaryColor),
              onPressed: isLoading ? null : _send,
            ),
          ],
        ),
      ),
    );
  }
}
