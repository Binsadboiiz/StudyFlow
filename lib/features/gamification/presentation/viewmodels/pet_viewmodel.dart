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

  /// Cho thú cưng ăn bánh quy (tiêu tốn 10 coins).
  Future<bool> feedPet() async {
    _isActionInProgress = true;
    _errorMessage = null;
    notifyListeners();

    final result = await petRepository.feedPet();
    _isActionInProgress = false;

    if (result != null) {
      _pet = result;
      notifyListeners();
      return true;
    } else {
      _errorMessage = "Not enough Coins or system error. Please study more to earn Coins!";
      notifyListeners();
      return false;
    }
  }

  /// Tương tác/Vui chơi cùng thú cưng.
  Future<bool> playWithPet() async {
    _isActionInProgress = true;
    _errorMessage = null;
    notifyListeners();

    final result = await petRepository.interactPet();
    _isActionInProgress = false;

    if (result != null) {
      _pet = result;
      notifyListeners();
      return true;
    } else {
      _errorMessage = "Error occurred while playing with the pet. Please try again.";
      notifyListeners();
      return false;
    }
  }
}
