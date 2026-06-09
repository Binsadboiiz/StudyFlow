import 'package:flutter/material.dart';
import 'package:studyflow/core/widgets/glass_card.dart';
import 'package:studyflow/shared/widgets/loading/skeleton.dart';

/// A premium skeleton loading widget matching the LeaderboardTab layout.
class LeaderboardSkeleton extends StatelessWidget {
  const LeaderboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Sort choice chip placeholders
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Skeleton(
                width: 90,
                height: 32,
                borderRadius: BorderRadius.circular(20),
              ),
              Skeleton(
                width: 110,
                height: 32,
                borderRadius: BorderRadius.circular(20),
              ),
              Skeleton(
                width: 80,
                height: 32,
                borderRadius: BorderRadius.circular(20),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        const SizedBox(height: 16),

        // Podium Top 3 placeholders
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Rank 2 (Left)
            _buildPodiumSkeleton(56, 75, theme),
            const SizedBox(width: 16),
            // Rank 1 (Center)
            _buildPodiumSkeleton(72, 95, theme),
            const SizedBox(width: 16),
            // Rank 3 (Right)
            _buildPodiumSkeleton(56, 70, theme),
          ],
        ),
        const SizedBox(height: 20),

        // Rest of the list items
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 100),
            itemCount: 4,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: GlassCard(
                  borderRadius: 16,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  child: Row(
                    children: [
                      // Rank number placeholder
                      const Skeleton(
                        width: 20,
                        height: 14,
                      ),
                      const SizedBox(width: 16),
                      // Avatar placeholder
                      const Skeleton(
                        width: 40,
                        height: 40,
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      const SizedBox(width: 12),
                      // Name & username placeholders
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Skeleton(width: 100, height: 14),
                            SizedBox(height: 6),
                            Skeleton(width: 60, height: 10),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Right metric info placeholder
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Skeleton(
                            width: 50,
                            height: 18,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          const SizedBox(height: 4),
                          const Skeleton(width: 40, height: 12),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPodiumSkeleton(double avatarSize, double height, ThemeData theme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Avatar circle
        Skeleton(
          width: avatarSize,
          height: avatarSize,
          borderRadius: BorderRadius.all(Radius.circular(avatarSize / 2)),
        ),
        const SizedBox(height: 8),
        // Name
        const Skeleton(width: 70, height: 12),
        const SizedBox(height: 6),
        // Metric tag
        const Skeleton(width: 50, height: 10),
        const SizedBox(height: 8),
        // Podium block
        Container(
          width: 85,
          height: height,
          decoration: BoxDecoration(
            color: theme.brightness == Brightness.dark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.03),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            border: Border.all(
              color: theme.brightness == Brightness.dark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.black.withValues(alpha: 0.05),
            ),
          ),
          child: const Center(
            child: Skeleton(width: 20, height: 28),
          ),
        ),
      ],
    );
  }
}
