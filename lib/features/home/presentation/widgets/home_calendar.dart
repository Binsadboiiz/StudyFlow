import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../viewmodels/home_viewmodel.dart';

/// Widget hiển thị phần Lịch (Calendar) ở nửa trên của màn hình Home.
class HomeCalendar extends StatelessWidget {
  const HomeCalendar({super.key});

  @override
  Widget build(BuildContext context) {
    // Consumer lắng nghe sự thay đổi từ HomeViewModel. 
    // Mỗi khi viewmodel gọi notifyListeners(), đoạn builder này sẽ chạy lại để cập nhật UI.
    return Consumer<HomeViewModel>(
      builder: (context, viewModel, child) {
        return TableCalendar(
          // Giới hạn ngày hiển thị nhỏ nhất và lớn nhất của lịch
          firstDay: DateTime.utc(2020, 10, 16),
          lastDay: DateTime.utc(2030, 3, 14),
          // Ngày đang được focus để lịch hiển thị đúng tuần/tháng hiện tại
          focusedDay: viewModel.focusedDate,
          
          // Logic để xác định xem một ngày bất kỳ trên lịch có phải là ngày "đang được chọn" hay không
          selectedDayPredicate: (day) {
            return isSameDay(viewModel.selectedDate, day);
          },
          
          // Sự kiện xảy ra khi người dùng ấn vào một ngày trên lịch
          onDaySelected: (selectedDay, focusedDay) {
            // Chỉ cập nhật nếu người dùng chọn một ngày mới (khác ngày đang chọn hiện tại)
            if (!isSameDay(viewModel.selectedDate, selectedDay)) {
              // Gọi hàm trong ViewModel để xử lý đổi ngày và load data
              viewModel.onDaySelected(selectedDay, focusedDay);
            }
          },
          
          // Thiết lập hiển thị mặc định là dạng Tuần (Week) cho gọn gàng
          calendarFormat: CalendarFormat.month, 
          // Cho phép các tùy chọn chuyển đổi định dạng (Tuần, 2 tuần, Tháng)
          availableCalendarFormats: const {
            CalendarFormat.month: 'Month',
            CalendarFormat.twoWeeks: '2 Weeks',
            CalendarFormat.week: 'Week',
          },
          
          // Tùy chỉnh phần Header (tháng, nút chuyển định dạng)
          headerStyle: const HeaderStyle(
            formatButtonVisible: true,
            titleCentered: true,
          ),
          
          // Tùy chỉnh giao diện màu sắc cho lịch
          calendarStyle: CalendarStyle(
            // Giao diện cho ngày "Hôm nay" (today) - màu xanh mờ
            todayDecoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            // Giao diện cho ngày "Đang được chọn" (selected) - màu xanh đậm
            selectedDecoration: const BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}
