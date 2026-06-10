import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:studyflow/core/theme/app_colors.dart';
import 'package:studyflow/core/theme/app_theme.dart';
import 'package:studyflow/core/widgets/glass_card.dart';
import 'package:studyflow/features/gamification/data/models/pet_model.dart';
import 'package:studyflow/features/gamification/presentation/viewmodels/gamification_viewmodel.dart';
import 'package:studyflow/features/gamification/presentation/viewmodels/pet_viewmodel.dart';
import 'package:studyflow/l10n/app_localizations.dart';

import 'package:studyflow/shared/widgets/loading/pet_skeleton.dart';

/// Tab chăm sóc và nuôi dưỡng Thú cưng học tập (Study Pet).
class PetTab extends StatefulWidget {
  const PetTab({super.key});

  @override
  State<PetTab> createState() => _PetTabState();
}

class _PetTabState extends State<PetTab> {
  // Biến điều khiển hoạt cảnh
  bool _isEating = false;
  bool _isPlaying = false;

  // Biến nhập liệu khi nhận nuôi Pet
  final _nameController = TextEditingController();
  String _selectedPetType = 'Cat'; // Mặc định là Mèo

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PetViewModel>().fetchPet();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  /// Tính điểm EXP yêu cầu để Pet thăng cấp
  int _getPetRequiredXp(int level) {
    return (50 * math.pow(level, 1.2)).round();
  }

  @override
  Widget build(BuildContext context) {
    final petVm = context.watch<PetViewModel>();
    final gamificationVm = context.watch<GamificationViewModel>();
    final theme = Theme.of(context);
    final ext = theme.extension<AppThemeExtension>()!;

    if (petVm.isLoadingPet) {
      return const PetSkeleton();
    }

    final pet = petVm.pet;

    if (pet == null) {
      // 1. GIAO DIỆN NHẬN NUÔI PET
      return _buildAdoptionScreen(context, petVm, theme, ext);
    }

    // 2. GIAO DIỆN CHĂM SÓC PET CHÍNH
    final requiredXp = _getPetRequiredXp(pet.level);
    final expProgress = (pet.exp / requiredXp).clamp(0.0, 1.0);
    final hungerProgress = (pet.hunger / 100.0).clamp(0.0, 1.0);
    final coins = gamificationVm.summary?.coins ?? 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Column(
        children: [
          // Thẻ hiển thị hình ảnh Pet động
          GlassCard(
            padding: const EdgeInsets.all(24),
            borderRadius: 24,
            child: Column(
              children: [
                // Thanh Level Pet
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.purpleAccent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.pets_rounded, color: Colors.purpleAccent, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '${AppLocalizations.of(context)!.level} ${pet.level}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.purpleAccent,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getStageLabel(context, pet.evolutionStage),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.accent,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Biểu diễn Pet hoạt họa (Dùng Emoji kèm Animate)
                SizedBox(
                  height: 180,
                  child: Center(
                    child: _buildPetEmojiWidget(pet)
                        .animate(
                          target: _isEating ? 1 : 0,
                          onComplete: (_) => setState(() => _isEating = false),
                        )
                        .shake(duration: 800.ms, hz: 6, curve: Curves.easeInOut)
                        .animate(
                          target: _isPlaying ? 1 : 0,
                          onComplete: (_) => setState(() => _isPlaying = false),
                        )
                        .scale(duration: 800.ms, curve: Curves.bounceOut)
                        .animate(onPlay: (controller) => controller.repeat(reverse: true))
                        .slideY(begin: 0.05, end: -0.05, duration: 1.5.seconds, curve: Curves.easeInOut),
                  ),
                ),

                const SizedBox(height: 16),
                // Tên Pet
                Text(
                  pet.name,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppLocalizations.of(context)!.petCompanion,
                  style: TextStyle(
                    fontSize: 12,
                    color: ext.subtext,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Thẻ hiển thị chỉ số Sức khỏe & Điểm EXP của Pet
          GlassCard(
            padding: const EdgeInsets.all(20),
            borderRadius: 24,
            child: Column(
              children: [
                // Chỉ số đói (Hunger)
                _buildStatProgress(
                  label: AppLocalizations.of(context)!.hunger,
                  valueStr: '${pet.hunger}/100',
                  progress: hungerProgress,
                  color: _getHungerColor(pet.hunger),
                  icon: Icons.cookie_rounded,
                ),
                const SizedBox(height: 20),
                // Chỉ số EXP Pet
                _buildStatProgress(
                  label: AppLocalizations.of(context)!.petRequiredXp,
                  valueStr: '${pet.exp.toInt()}/$requiredXp',
                  progress: expProgress,
                  color: Colors.purpleAccent,
                  icon: Icons.star_rounded,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Các hành động cho Pet ăn / Vui chơi
          Row(
            children: [
              // 1. Cho ăn
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: petVm.isActionInProgress ? null : () => _handleFeed(petVm, gamificationVm),
                    icon: const Icon(Icons.cookie_rounded, color: Colors.white),
                    label: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.feed,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        Text(
                          AppLocalizations.of(context)!.feedCost(coins),
                          style: const TextStyle(fontSize: 9, color: Colors.white70),
                        ),
                      ],
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orangeAccent,
                      disabledBackgroundColor: Colors.orangeAccent.withValues(alpha: 0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // 2. Chơi đùa
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: petVm.isActionInProgress ? null : () => _handlePlay(petVm),
                    icon: const Icon(Icons.sports_esports_rounded, color: Colors.white),
                    label: Text(
                      AppLocalizations.of(context)!.play,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      disabledBackgroundColor: AppColors.accent.withValues(alpha: 0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          if (petVm.errorMessage != null) ...[
            const SizedBox(height: 16),
            Text(
              petVm.errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],
          
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  /// Cho Pet ăn bánh quy
  void _handleFeed(PetViewModel petVm, GamificationViewModel gamificationVm) async {
    setState(() {
      _isEating = true;
    });
    final success = await petVm.feedPet();
    if (success) {
      // Đồng bộ ví xu từ Gamification Summary
      gamificationVm.fetchSummary();
    }
  }

  /// Chơi cùng Pet
  void _handlePlay(PetViewModel petVm) async {
    setState(() {
      _isPlaying = true;
    });
    await petVm.playWithPet();
  }

  /// Render Widget Emoji cho Pet tương ứng loại và giai đoạn tiến hóa
  Widget _buildPetEmojiWidget(PetModel pet) {
    // Nếu là quả trứng (EvolutionStage == 'Egg')
    if (pet.evolutionStage == 'Egg') {
      return const Text(
        '🥚',
        style: TextStyle(fontSize: 90),
      );
    }

    // Xác định emoji cơ sở
    String petEmoji = '🐱';
    if (pet.petType == 'Dog') petEmoji = '🐶';
    if (pet.petType == 'Panda') petEmoji = '🐼';

    double scale = 1.0;
    List<Widget> overlays = [];

    if (pet.evolutionStage == 'Baby') {
      scale = 0.7; // Thú sơ sinh nhỏ bé
      overlays.add(
        const Positioned(
          bottom: 0,
          right: 0,
          child: Text('🍼', style: TextStyle(fontSize: 24)),
        ),
      );
    } else if (pet.evolutionStage == 'Adult') {
      scale = 1.3; // Thú trưởng thành to lớn
      overlays.add(
        const Positioned(
          top: -10,
          left: 20,
          child: Text('👑', style: TextStyle(fontSize: 28)), // Vương miện oai phong
        ),
      );
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Transform.scale(
          scale: scale,
          child: Text(
            petEmoji,
            style: const TextStyle(fontSize: 96),
          ),
        ),
        ...overlays,
      ],
    );
  }

  /// Đọc nhãn giai đoạn tiến hóa tiếng Việt
  /// Đọc nhãn giai đoạn tiến hóa
  String _getStageLabel(BuildContext context, String stage) {
    switch (stage) {
      case 'Egg': return AppLocalizations.of(context)!.eggEvolution;
      case 'Baby': return AppLocalizations.of(context)!.babyEvolution;
      case 'Teen': return AppLocalizations.of(context)!.teenEvolution;
      case 'Adult': return AppLocalizations.of(context)!.adultEvolution;
      default: return stage;
    }
  }

  /// Đọc màu cho thanh Hunger
  Color _getHungerColor(int hunger) {
    if (hunger < 30) return Colors.redAccent;
    if (hunger < 70) return Colors.orangeAccent;
    return AppColors.accent;
  }

  Widget _buildStatProgress({
    required String label,
    required String valueStr,
    required double progress,
    required Color color,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 18),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            Text(
              valueStr,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 10,
            backgroundColor: color.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  /// GIAO DIỆN NHẬN NUÔI PET
  Widget _buildAdoptionScreen(BuildContext context, PetViewModel petVm, ThemeData theme, AppThemeExtension ext) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 12),
          const Text(
            '🥚',
            style: TextStyle(fontSize: 90),
          )
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .scale(duration: 1.5.seconds, curve: Curves.bounceOut),
          const SizedBox(height: 20),
          Text(
            AppLocalizations.of(context)!.dontHavePet,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.adoptPetDesc,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: ext.subtext),
          ),
          const SizedBox(height: 32),
          
          GlassCard(
            padding: const EdgeInsets.all(20),
            borderRadius: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Nhập tên
                Text(
                  AppLocalizations.of(context)!.nameYourPet,
                  style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  style: TextStyle(color: theme.colorScheme.onSurface),
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.enterPetNameHint,
                    hintStyle: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                    filled: true,
                    fillColor: theme.brightness == Brightness.dark ? Colors.white12 : Colors.black12,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 20),

                // 2. Chọn loại Pet
                Text(
                  AppLocalizations.of(context)!.choosePetEgg,
                  style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildPetOption('Cat', '🐱 ${AppLocalizations.of(context)!.cat}', theme),
                    _buildPetOption('Dog', '🐶 ${AppLocalizations.of(context)!.dog}', theme),
                    _buildPetOption('Panda', '🐼 ${AppLocalizations.of(context)!.panda}', theme),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: petVm.isActionInProgress ? null : () => _handleAdopt(petVm),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: petVm.isActionInProgress
                  ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.white))
                  : Text(
                      AppLocalizations.of(context)!.adoptNowBtn,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPetOption(String type, String label, ThemeData theme) {
    final isSelected = _selectedPetType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPetType = type;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.accent : theme.dividerColor.withValues(alpha: 0.5),
            width: 2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? AppColors.accent : theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  void _handleAdopt(PetViewModel petVm) async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.pleaseGivePetName), backgroundColor: Colors.redAccent),
      );
      return;
    }

    final success = await petVm.adoptPet(name, _selectedPetType);
    if (success) {
      _nameController.clear();
      // Tải lại Pet
      petVm.fetchPet();
    }
  }
}
