import 'package:flutter/material.dart';
import 'package:studyflow/core/widgets/glass_card.dart';
import 'package:studyflow/shared/widgets/loading/skeleton.dart';

/// A premium skeleton loading widget matching the BadgesTab layout.
class BadgeSkeleton extends StatelessWidget {
  const BadgeSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 100),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemCount: 9, // Placeholders for 9 badges
      itemBuilder: (context, index) {
        return GlassCard(
          borderRadius: 20,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Shimmer circle icon placeholder
              const Skeleton(
                width: 52,
                height: 52,
                borderRadius: BorderRadius.all(Radius.circular(26)),
              ),
              const SizedBox(height: 12),
              // Badge name placeholder
              const Skeleton(
                width: 64,
                height: 12,
              ),
              const SizedBox(height: 6),
              // Locked/Unlocked tag placeholder
              Skeleton(
                width: 48,
                height: 12,
                borderRadius: BorderRadius.circular(8),
              ),
            ],
          ),
        );
      },
    );
  }
}
