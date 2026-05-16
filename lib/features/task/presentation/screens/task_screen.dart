import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studyflow/features/task/domain/entities/task.dart';
import 'package:studyflow/features/task/presentation/viewmodels/task_viewmodel.dart';

/// Màn hình quản lý các công việc (Task).
/// Đây là View trong kiến trúc MVVM, chỉ làm nhiệm vụ hiển thị và nhận tương tác từ người dùng.
class TaskScreen extends StatefulWidget{
  const TaskScreen({ super.key });

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  // Controller để lấy nội dung từ ô nhập liệu (TextField)
  final titleController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Dùng Future.microtask để đảm bảo context đã sẵn sàng trước khi gọi ViewModel.
    // Lấy danh sách Task của ngày hôm nay khi vừa mở màn hình.
    Future.microtask(() {
      context.read<TaskViewmodel>().loadTask(DateTime.now());
    });
  }

  @override
  Widget build(BuildContext context) {
    // context.watch() giúp UI tự động lắng nghe và vẽ lại mỗi khi ViewModel gọi notifyListeners()
    final vm = context.watch<TaskViewmodel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Task"),
      ),
      body: Column(
        children: [
          // Khu vực nhập liệu và nút thêm Task mới
          Padding(padding: const EdgeInsets.all(2),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    hintText: "Enter your task...",
                  ),
                )
              ),
              IconButton(
                onPressed: () async {
                  // Tạo một đối tượng Task mới từ nội dung TextField
                  final task = Task(
                    id: DateTime.now().millisecondsSinceEpoch, // Dùng timestamp làm ID tạm thời
                    title: titleController.text, 
                    description: "", 
                    date: DateTime.now(),
                  );

                  // Gọi ViewModel để xử lý logic thêm Task
                  await vm.addTask(task);

                  // Xóa trắng ô nhập sau khi thêm thành công
                  titleController.clear();
                },
                icon: const Icon(Icons.add)
               ),
            ],
           ),
          ),
          // Khu vực danh sách các Task hiển thị bên dưới
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(
                top: 8,
                bottom: 100, // Thêm khoảng trống dưới cùng để không bị che bởi BottomAppBar
              ),
              itemCount: vm.tasks.length,
              itemBuilder: (context, index) {
                final task = vm.tasks[index];

                return ListTile(
                  // Nút Checkbox để đánh dấu hoàn thành
                  leading: Checkbox(
                    value: task.isCompleted, 
                    onChanged: (__) {
                      vm.toggleTask(task);
                    }
                  ),
                  title: Text(task.title),
                  // Nút thùng rác để xóa Task
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      vm.deleteTask(task.id, task.date);
                    }, 
                  ),
                );
              },
            )
          ),
        ],
      ),
    );
  }
}