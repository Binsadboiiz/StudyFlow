import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:studyflow/features/ai_chat/presentation/providers/ai_chat_provider.dart';
import 'package:studyflow/features/ai_chat/data/models/ai_chat_model.dart';
import 'package:studyflow/features/task/presentation/viewmodels/task_viewmodel.dart';
import 'package:studyflow/features/task/domain/entities/task.dart';
import 'package:studyflow/features/schedule/presentation/viewmodels/schedule_viewmodel.dart';
import 'package:studyflow/features/home/presentation/viewmodels/home_viewmodel.dart';
import 'package:studyflow/l10n/app_localizations.dart';
import 'package:studyflow/core/services/notification/app_notification.dart';
import 'package:studyflow/core/services/notification/notification_type.dart';
import 'package:studyflow/core/services/notification/notification_service.dart';
import 'package:studyflow/features/flashcard/presentation/providers/flashcard_provider.dart';
import 'package:studyflow/features/flashcard/presentation/screens/flashcard_study_screen.dart';
import 'package:studyflow/core/services/network_connection_service.dart';
import 'package:studyflow/core/widgets/offline_feature_blocker.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  List<AiActionSuggestionModel> _latestSuggestions = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<AiChatProvider>();
      provider.loadChatHistory().then((_) {
        if (mounted) {
          _scrollToBottom();
          if (provider.errorMessage != null) {
            NotificationService.instance.show(
              AppNotification(
                message: provider.errorMessage!,
                type: NotificationType.error,
              ),
            );
            provider.clearError();
          }
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 150), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutQuad,
        );
      }
    });
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    _focusNode.requestFocus();
    
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
        NotificationService.instance.show(
          AppNotification(
            message: provider.errorMessage!,
            type: NotificationType.error,
          ),
        );
        provider.clearError();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AiChatProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;
    final connectionService = context.watch<NetworkConnectionService>();

    if (!connectionService.isOnline) {
      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(AppLocalizations.of(context)!.aiChatTitle),
        ),
        body: OfflineFeatureBlocker(
          featureName: AppLocalizations.of(context)!.aiChatTitle,
          child: const SizedBox.shrink(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.auto_awesome_rounded, color: primaryColor, size: 20),
            ).animate(onPlay: (controller) => controller.repeat(reverse: true))
             .shimmer(duration: 1.5.seconds, color: primaryColor.withOpacity(0.4)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.aiChatTitle,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    AppLocalizations.of(context)!.aiChatRequestsRemaining(provider.dailyRequestsRemaining),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: Colors.redAccent.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.delete_sweep_outlined, color: Colors.redAccent, size: 22),
              onPressed: () {
                _showClearDialog(provider);
              },
              tooltip: AppLocalizations.of(context)!.clearAll,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          if (provider.dailyRequestsRemaining <= 0)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.orangeAccent.withOpacity(0.15),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Colors.orangeAccent, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context)!.aiChatDailyLimitReached,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.orangeAccent,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(),
          Expanded(
            child: provider.messages.isEmpty && !provider.isLoading
                ? _buildEmptyState(isDark)
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    itemCount: provider.messages.length + (provider.isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == provider.messages.length) {
                        return _buildThinkingBubble(isDark, primaryColor)
                            .animate()
                            .fadeIn(duration: 250.ms)
                            .slideY(begin: 0.1, end: 0, curve: Curves.easeOut);
                      }
                      final msg = provider.messages[index];
                      final isUser = msg.role == 'user';
                      return _buildChatBubble(msg, isUser, isDark, primaryColor)
                          .animate()
                          .fadeIn(duration: 300.ms)
                          .slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuad);
                    },
                  ),
          ),
          if (_latestSuggestions.isNotEmpty) 
            _buildSuggestionsWidget(primaryColor, isDark)
                .animate()
                .fadeIn(duration: 250.ms)
                .slideY(begin: 0.2, end: 0, curve: Curves.easeOut),
          _buildInputArea(provider.isLoading, primaryColor, isDark),
        ],
      ),
    );
  }

  void _showClearDialog(AiChatProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.aiChatClearConfirm),
        content: const Text('Do you want to permanently clear the conversation history? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () {
              provider.clearConversation();
              setState(() {
                _latestSuggestions.clear();
              });
              Navigator.pop(context);
            },
            child: const Text('Clear', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    final theme = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [theme.colorScheme.primary.withOpacity(0.15), theme.colorScheme.secondary.withOpacity(0.05)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(Icons.auto_awesome, size: 56, color: theme.colorScheme.primary),
            ).animate().scale(delay: 100.ms, duration: 400.ms, curve: Curves.easeOutBack),
            const SizedBox(height: 24),
            Text(
              AppLocalizations.of(context)!.aiChatEmptyStateTitle,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 12),
            Text(
              AppLocalizations.of(context)!.aiChatEmptyStateSubtitle,
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6), height: 1.4),
            ).animate().fadeIn(delay: 350.ms),
            const SizedBox(height: 32),
            _buildSamplePromptCard("Arrange a study session for tomorrow afternoon"),
            const SizedBox(height: 12),
            _buildSamplePromptCard("Add a reminder to scan history notes next Monday"),
          ],
        ),
      ),
    );
  }

  Widget _buildSamplePromptCard(String text) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () {
        _controller.text = text;
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.chat_bubble_outline_rounded, size: 18, color: Theme.of(context).colorScheme.primary.withOpacity(0.7)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Colors.grey.shade400),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildChatBubble(ChatMessageModel msg, bool isUser, bool isDark, Color primaryColor) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              margin: const EdgeInsets.only(right: 8, top: 4),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.auto_awesome, size: 14, color: primaryColor),
            ),
          ],
          Flexible(
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: isUser
                    ? LinearGradient(
                        colors: [primaryColor, primaryColor.withOpacity(0.85)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isUser
                    ? null
                    : (isDark ? const Color(0xFF1E293B) : Colors.white),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isUser ? 20 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 20),
                ),
                border: !isUser
                    ? Border.all(
                        color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                        width: 1.2,
                      )
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isUser ? 0.08 : 0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
              child: Text(
                msg.content,
                style: TextStyle(
                  color: isUser ? Colors.white : (isDark ? Colors.grey.shade100 : Colors.black87),
                  fontSize: 14.5,
                  height: 1.45,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThinkingBubble(bool isDark, Color primaryColor) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(right: 8, top: 4),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.auto_awesome, size: 14, color: primaryColor),
          ),
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(20),
              ),
              border: Border.all(
                color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                width: 1.2,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.grey),
                ),
                const SizedBox(width: 10),
                Text(
                  AppLocalizations.of(context)!.aiChatThinking,
                  style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionsWidget(Color primaryColor, bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        border: Border(top: BorderSide(color: isDark ? Colors.grey.shade900 : Colors.grey.shade200)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.assistant_outlined, size: 16, color: primaryColor),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)!.aiChatActionSuggestions,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: _latestSuggestions.map((action) {
                final isTask = action.actionType == 'CREATE_TASK';
                final isFlashcard = action.actionType == 'CREATE_FLASHCARD_SET';
                IconData actionIcon = Icons.calendar_today_rounded;
                String actionPrefix = AppLocalizations.of(context)!.aiChatSchedulePrefix;
                if (isTask) {
                  actionIcon = Icons.checklist_rounded;
                  actionPrefix = AppLocalizations.of(context)!.aiChatTaskPrefix;
                } else if (isFlashcard) {
                  actionIcon = Icons.style_rounded;
                  actionPrefix = AppLocalizations.of(context)!.aiChatFlashcardPrefix;
                }
                return Container(
                  width: 250,
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            actionIcon,
                            size: 14,
                            color: primaryColor,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            actionPrefix,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        action.title, 
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (action.description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          action.description,
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            onPressed: () {
                              setState(() {
                                _latestSuggestions.remove(action);
                              });
                            },
                            child: Text(
                              AppLocalizations.of(context)!.aiChatDismiss, 
                              style: TextStyle(color: Colors.grey.shade500, fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: () => _executeSuggestion(action),
                            child: Text(
                              AppLocalizations.of(context)!.aiChatAccept,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ],
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
    if (action.actionType == 'CREATE_FLASHCARD_SET') {
      final flashcardProvider = context.read<FlashcardProvider>();
      if (action.flashcards == null || action.flashcards!.isEmpty) {
        NotificationService.instance.show(
          AppNotification(
            message: "Suggested action has no flashcards.",
            type: NotificationType.error,
          ),
        );
        return;
      }

      final List<Map<String, String>> cards = action.flashcards!
          .map((card) => {
                'question': card.question,
                'answer': card.answer,
              })
          .toList();

      try {
        final newSet = await flashcardProvider.createFlashcardSet(action.title, cards);
        if (newSet != null && mounted) {
          NotificationService.instance.show(
            AppNotification(
              message: AppLocalizations.of(context)!.flashcardGenerateSuccess,
              type: NotificationType.success,
            ),
          );
          setState(() {
            _latestSuggestions.remove(action);
          });
          // Navigate to FlashcardStudyScreen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FlashcardStudyScreen(flashcardSet: newSet),
            ),
          );
        } else if (mounted) {
          NotificationService.instance.show(
            AppNotification(
              message: flashcardProvider.errorMessage ?? "Failed to create flashcard set.",
              type: NotificationType.error,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          NotificationService.instance.show(
            AppNotification(
              message: e.toString(),
              type: NotificationType.error,
            ),
          );
        }
      }
      return;
    }

    final taskVm = context.read<TaskViewmodel>();
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
      id: '',
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
        // Ensure task list shows the correct date where the new task was added
        await taskVm.selectDate(taskDate);
        
        if (!mounted) return;

        // Refresh schedule and home screens
        context.read<ScheduleViewmodel>().loadWeekTasks();
        context.read<HomeViewModel>().refreshTasks();
        
        NotificationService.instance.show(
          AppNotification(
            message: AppLocalizations.of(context)!.aiChatAddedSuccess(action.title),
            type: NotificationType.success,
          ),
        );
        setState(() {
          _latestSuggestions.remove(action);
        });
      }
    } catch (e) {
      if (mounted) {
        NotificationService.instance.show(
          AppNotification(
            message: AppLocalizations.of(context)!.aiChatAddFailed(e.toString()),
            type: NotificationType.error,
          ),
        );
      }
    }
  }

  Widget _buildInputArea(bool isLoading, Color primaryColor, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        border: Border(top: BorderSide(color: isDark ? Colors.grey.shade900 : Colors.grey.shade200)),
      ),
      child: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                    width: 1,
                  ),
                ),
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  enabled: !isLoading,
                  maxLines: 5,
                  minLines: 1,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                  style: TextStyle(
                    fontSize: 14.5,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.aiChatInputHint,
                    hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: isLoading ? Colors.grey.shade300 : primaryColor,
                shape: BoxShape.circle,
                boxShadow: [
                  if (!isLoading)
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                ],
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                onPressed: isLoading ? null : _send,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
