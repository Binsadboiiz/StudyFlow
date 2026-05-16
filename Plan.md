Phát triển ứng dụng StudyFlow - QUản lý thời gian biểu (Cross-Platform: Flutter)

# Về dự án và ý tưởng ban đầu:
- Tích hợp lịch vào (Google Calendar)
- Có chức năng tạo thời gian biểu và ghi chú
- Focus mode
- Đặt nhắc hẹn
- Biểu đồ thống kê (Analytics)
- Có streak để giữ chuỗi học hằng ngày
    + Daily target
- Nhắc nhở khi Streak sắp kết thúc
- Tạo thư mục để lưu file bài tập
- Chức năng scan bài tập (user chụp hình bài tập và nội dung bài tập sẽ render lên app để người dùng làm trực tiếp và LƯU).
    + 1. User chụp ảnh
    + 2. OCR extract text
    + 3. Convert task/note
    + 4. User Edit
    + 5. Save
    ## Flutter packages:
        - google_mlkit_text_recognition
        - camera
- Tích hợp AI chat box gợi ý sắp sếp thời gian biểu (Nâng cao)
    + OpenAI API
- Gamification: mỗi khi hoàn thành streak sẽ + 50XP (Level System such as Games)
    + Study Pet
    + Ranking
    + Daily mission

- Có widget ở screen home (optional)

# Auth:
- Username / Password
- OAuth 2.0 / JWT local

# Yêu cầu Architecture: 
- Chia các Entities rõ ràng
- Tách logic business và UI 
lib/
│
├── core/
│   ├── constants/
│   ├── theme/
│   ├── utils/
│
├── features/
│
│   ├── auth/
│   │
│   ├── task/
│   │   ├── data/
│   │   ├── domain/
│   │   ├── presentation/
│   │
│   ├── schedule/
│   ├── note/
│   ├── streak/
│   ├── statistics/
│
├── shared/
│
└── main.dart

task/
│
├── data/
│   ├── models/
│   ├── repositories/
│   ├── datasources/
│
├── domain/
│   ├── entities/
│   ├── repositories/
│   ├── usecases/
│
├── presentation/
│   ├── screens/
│   ├── widgets/
│   ├── viewmodels/

# Về Database:
- MySQL / Isar Database : Isar DB để lưu local không cần Internet
- PostgreSQL (optional) có thể realtime => cân nhắc
- Lưu Local storage
- Cloud Sync: 
    + Offline First
    + Khi có Internet sẽ sync server