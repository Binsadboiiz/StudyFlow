import 'package:flutter/material.dart';
import 'package:studyflow/core/widgets/glass_card.dart';
import 'package:studyflow/shared/widgets/loading/skeleton.dart';

/// A premium skeleton loading widget matching the PetTab layout.
class PetSkeleton extends StatelessWidget {
  const PetSkeleton({super.key});

  @override
  Widget build(BuildContext context) {

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Column(
        children: [
          // Upper main card: Level, egg/avatar circle, name, subtext
          GlassCard(
            padding: const EdgeInsets.all(24),
            borderRadius: 24,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Skeleton(
                      width: 80,
                      height: 24,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    Skeleton(
                      width: 80,
                      height: 24,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Skeleton(
                  width: 140,
                  height: 140,
                  borderRadius: BorderRadius.all(Radius.circular(70)),
                ),
                const SizedBox(height: 20),
                const Skeleton(
                  width: 130,
                  height: 24,
                ),
                const SizedBox(height: 8),
                const Skeleton(
                  width: 170,
                  height: 14,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Lower card: hunger and exp status progress bars
          GlassCard(
            padding: const EdgeInsets.all(20),
            borderRadius: 24,
            child: Column(
              children: [
                // hunger stat
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Skeleton(
                          width: 18,
                          height: 18,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        const SizedBox(width: 8),
                        const Skeleton(width: 60, height: 16),
                      ],
                    ),
                    const Skeleton(width: 50, height: 16),
                  ],
                ),
                const SizedBox(height: 10),
                Skeleton(
                  width: double.infinity,
                  height: 10,
                  borderRadius: BorderRadius.circular(8),
                ),
                const SizedBox(height: 24),

                // exp stat
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Skeleton(
                          width: 18,
                          height: 18,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        const SizedBox(width: 8),
                        const Skeleton(width: 110, height: 16),
                      ],
                    ),
                    const Skeleton(width: 50, height: 16),
                  ],
                ),
                const SizedBox(height: 10),
                Skeleton(
                  width: double.infinity,
                  height: 10,
                  borderRadius: BorderRadius.circular(8),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Bottom Action buttons
          Row(
            children: [
              Expanded(
                child: Skeleton(
                  height: 52,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Skeleton(
                  height: 52,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}
