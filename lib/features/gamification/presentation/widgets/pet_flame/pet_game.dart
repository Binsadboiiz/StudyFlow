import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class PetGame extends FlameGame {
  final String petType;
  final String evolutionStage;
  
  SpriteAnimationComponent? petComponent;
  late SpriteAnimation idleAnimation;
  late SpriteAnimation jumpAnimation;

  PetGame({
    required this.petType,
    required this.evolutionStage,
  });

  @override
  Color backgroundColor() => const Color(0x00000000); // Transparent background

  @override
  Future<void> onLoad() async {
    // Đường dẫn ảnh (Flame tự mặc định gốc là assets/images/)
    final petFolder = 'pets/${petType.toLowerCase()}';
    final idleSpriteSheetPath = '$petFolder/IdleCatttt.png';
    final jumpSpriteSheetPath = '$petFolder/JumpCattttt.png';

    // Load Idle Animation (6 frames, lặp vô hạn)
    idleAnimation = await loadSpriteAnimation(
      idleSpriteSheetPath,
      SpriteAnimationData.sequenced(
        amount: 6,
        stepTime: 0.15,
        textureSize: Vector2(32, 32),
        loop: true,
      ),
    );

    // Load Jump Animation (13 frames, chạy 1 lần)
    jumpAnimation = await loadSpriteAnimation(
      jumpSpriteSheetPath,
      SpriteAnimationData.sequenced(
        amount: 13,
        stepTime: 0.1,
        textureSize: Vector2(32, 32),
        loop: false,
      ),
    );

    petComponent = SpriteAnimationComponent()
      ..animation = idleAnimation
      ..size = Vector2(150, 150) // Phóng to Sprite cho rõ nét trên UI
      ..anchor = Anchor.center
      ..position = size / 2; // Căn giữa màn hình Flame

    add(petComponent!);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (isLoaded && petComponent != null) {
      petComponent!.position = size / 2;
    }
  }

  void playJumpAnimation() {
    if (petComponent == null) return;
    petComponent!.animation = jumpAnimation;
    petComponent!.animationTicker?.reset();
    petComponent!.animationTicker?.onComplete = () {
      // Quay về trạng thái idle sau khi jump xong
      petComponent!.animation = idleAnimation;
    };
  }
}
