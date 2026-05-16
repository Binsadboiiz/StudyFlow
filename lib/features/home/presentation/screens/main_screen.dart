import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studyflow/features/home/presentation/screens/home_screen.dart';
import 'package:studyflow/features/task/presentation/screens/task_screen.dart';
import 'package:studyflow/features/task/domain/entities/task.dart';
import 'package:studyflow/features/task/presentation/viewmodels/task_viewmodel.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const TaskScreen(),
    const Center(child: Text('Bookmarks', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
    const Center(child: Text('Settings', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Cho phép nội dung tràn xuống dưới BottomAppBar
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskModal(context),
        backgroundColor: const Color(0xFF2E7D32), 
        shape: const CircleBorder(),
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 10.0, // Khoảng cách lõm xuống
        color: Colors.white,
        elevation: 10,
        shadowColor: Colors.black45,
        child: SizedBox(
          height: 65,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Nhóm icon bên trái
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildNavItem(icon: Icons.dashboard_outlined, index: 0),
                    _buildNavItem(icon: Icons.article_outlined, index: 1),
                  ],
                ),
              ),
              // Khoảng trống ở giữa cho FloatingActionButton
              const SizedBox(width: 48),
              // Nhóm icon bên phải
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildNavItem(icon: Icons.bookmark_border_rounded, index: 2),
                    _buildNavItem(icon: Icons.settings_outlined, index: 3),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Hàm tạo từng nút trong BottomAppBar kèm animation
  Widget _buildNavItem({required IconData icon, required int index}) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: SizedBox(
        height: double.infinity,
        width: 50,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon với hiệu ứng phóng to khi được chọn
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutBack,
              transform: Matrix4.identity()..scale(isSelected ? 1.2 : 1.0),
              child: Icon(
                icon,
                color: isSelected ? const Color(0xFF2E7D32) : Colors.grey.shade400,
                size: 26,
              ),
            ),
            const SizedBox(height: 6),
            // Chấm tròn nhỏ hiển thị bên dưới khi được chọn (Animation xuất hiện)
            AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: isSelected ? 1.0 : 0.0,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: isSelected ? 6 : 0,
                height: isSelected ? 6 : 0,
                decoration: const BoxDecoration(
                  color: Color(0xFF2E7D32),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Hàm hiển thị Modal thêm Task mới
  void _showAddTaskModal(BuildContext context) {
    final titleController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Để modal đẩy lên khi bàn phím xuất hiện
      backgroundColor: Colors.transparent, // Làm nền trong suốt để bo góc đẹp hơn
      builder: (context) {
        return SingleChildScrollView(
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom, // Tránh bàn phím che
              left: 20,
              right: 20,
              top: 24,
            ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Thanh kéo nhỏ ở trên cùng (UI UX hiện đại)
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Add new task',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: titleController,
                autofocus: true, // Tự động mở bàn phím
                decoration: InputDecoration(
                  hintText: 'What do you want to do...?',
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () async {
                    if (titleController.text.trim().isEmpty) return;
                    
                    final vm = context.read<TaskViewmodel>();
                    final task = Task(
                      id: DateTime.now().millisecondsSinceEpoch,
                      title: titleController.text.trim(),
                      description: "",
                      date: DateTime.now(),
                    );
                    
                    await vm.addTask(task);
                    if (context.mounted) {
                      Navigator.pop(context); // Đóng modal sau khi thêm xong
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Added new task!'),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: Color(0xFF2E7D32),
                        ),
                      );
                    }
                  },
                  child: const Text('Add now', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
          ),
        );
      },
    );
  }
}
