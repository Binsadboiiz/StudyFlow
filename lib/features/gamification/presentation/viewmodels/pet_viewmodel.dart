import 'package:flutter/material.dart';
import 'package:studyflow/features/gamification/data/models/pet_model.dart';
import 'package:studyflow/features/gamification/data/repositories/pet_repository.dart';

/// ViewModel quản lý dữ liệu và các hành động tương tác với thú cưng (Study Pet).
class PetViewModel extends ChangeNotifier {
  final PetRepository petRepository;

  PetModel? _pet;
  bool _isLoadingPet = false;
  bool _isActionInProgress = false;
  String? _errorMessage;

  PetViewModel({required this.petRepository});

  // --- Getters ---
  PetModel? get pet => _pet;
  bool get isLoadingPet => _isLoadingPet;
  bool get isActionInProgress => _isActionInProgress;
  String? get errorMessage => _errorMessage;

  /// Tải thông tin thú cưng của người dùng.
  Future<void> fetchPet() async {
    _isLoadingPet = true;
    _errorMessage = null;
    notifyListeners();

    final result = await petRepository.getPet();
    _pet = result;

    _isLoadingPet = false;
    notifyListeners();
  }

  /// Nhận nuôi một thú cưng mới.
  Future<bool> adoptPet(String name, String petType) async {
    _isActionInProgress = true;
    _errorMessage = null;
    notifyListeners();

    final result = await petRepository.adoptPet(name, petType);
    _isActionInProgress = false;

    if (result != null) {
      _pet = result;
      notifyListeners();
      return true;
    } else {
      _errorMessage = "Pets cannot be adopted. Please try again.";
      notifyListeners();
      return false;
    }
  }

  void updatePetLocally(PetModel newPet) {
    _pet = newPet;
    _errorMessage = null;
    notifyListeners();
  }

  /// Cho thú cưng ăn bánh quy (tiêu tốn 10 coins).
  Future<bool> feedPet() async {
    // Không set _isActionInProgress = true để tránh giật UI do re-build
    final result = await petRepository.feedPet();

    if (result != null) {
      _pet = result;
      notifyListeners();
      return true;
    } else {
      // Bỏ set cứng _errorMessage vì đã xử lý optimistic update ở UI
      return false;
    }
  }

  /// Tương tác/Vui chơi cùng thú cưng.
  Future<bool> playWithPet() async {
    final result = await petRepository.interactPet();

    if (result != null) {
      _pet = result;
      notifyListeners();
      return true;
    } else {
      return false;
    }
  }

  /// Clears pet data in memory upon logout
  void clear() {
    _pet = null;
    _isLoadingPet = false;
    _isActionInProgress = false;
    _errorMessage = null;
    notifyListeners();
  }
}
