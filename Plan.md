# Dự án StudyFlow - Quản lý thời gian biểu & Học tập thông minh

## 1. Định hướng dự án
StudyFlow là một ứng dụng di động đa nền tảng (iOS/Android) hỗ trợ người dùng quản lý thời gian biểu, nhắc nhở công việc, thống kê tiến độ học tập và tích hợp AI để tối ưu hóa lộ trình cá nhân. 
Ứng dụng sử dụng kiến trúc Backend hiện đại với .NET, Database kết hợp (Firebase + PostgreSQL), và sẵn sàng cho các công nghệ AI (Vector Search với Gemini).

## 2. Công nghệ sử dụng
### Frontend (Mobile App)
- **Framework**: Flutter
- **Architecture**: Clean Architecture (Data - Domain - Presentation)
- **State Management**: BLoC / Cubit (hoặc Provider, tùy chọn)
- **Local Storage / Offline Sync**: Isar hoặc SQLite (Cho cơ chế Offline-First, có thể thêm vào sau)

### Backend (API Server)
- **Framework**: .NET 8 Web API
- **Architecture**: Clean Architecture
- **Authentication**: Firebase Admin SDK (Verify ID Token)
- **ORM**: Entity Framework Core

### Database & AI (Hybrid Database)
- **Auth & User Info**: Firebase Authentication
- **Core Database**: PostgreSQL (với extension `pgvector` để lưu trữ Vector)
- **AI Engine**: Google Gemini API (Tạo Embeddings và Chat / Phân tích dữ liệu)

### Gợi ý Hosting (Miễn phí cho giai đoạn phát triển)
- **.NET API**: **Azure App Service (Gói F1)** (Hoàn toàn miễn phí, support rất tốt cho .NET) hoặc Render.
- **PostgreSQL**: **Supabase** (Cung cấp gói Free tier hào phóng, đặc biệt là CÓ SẴN extension `pgvector` cực kỳ dễ set up cho AI).

## 3. Các chức năng chính (Features)
- **Authentication**: Đăng nhập/Đăng ký qua Firebase (Email/Password, Google).
- **Quản lý thời gian biểu (Schedule & Calendar)**: Tạo, chỉnh sửa lịch học, tích hợp Google Calendar.
- **Quản lý công việc (Task & Note)**: Tạo task, ghi chú (có khả năng tạo thư mục để lưu).
- **Focus Mode**: Chế độ tập trung (Pomodoro, đếm ngược).
- **Thống kê (Analytics)**: Biểu đồ theo dõi số giờ học, số task hoàn thành.
- **Gamification & Streak**: 
  - Hệ thống Streak (chuỗi ngày học). Nhắc nhở khi Streak sắp mất.
  - Daily target, Hệ thống XP/Level, Study Pet (Thú cưng học tập lớn lên theo XP).
- **Quét tài liệu bài tập (Scan)**: OCR nhận diện chữ từ ảnh chụp bài tập -> Convert thành Note/Task.
- **AI Recommendation (Tính năng nâng cao)**: 
  - Dùng Gemini API phân tích thói quen, lịch sử học tập.
  - Dựa trên cơ sở dữ liệu Vector (pgvector) để gợi ý sắp xếp thời gian biểu hoặc đưa ra lời khuyên tối ưu.

## 4. Kiến trúc Dự án (Architecture)

### 4.1. Kiến trúc thư mục Frontend (Flutter)
Áp dụng Clean Architecture chia module theo feature (Feature-first):
```text
lib/
├── core/
│   ├── network/       # Dio/HTTP client, Interceptors (gắn Firebase Token)
│   ├── local_db/      # Setup Isar/SQLite
│   ├── theme/, utils/, constants/
│
├── features/
│   ├── auth/          # Xử lý login Firebase -> Lấy ID Token
│   ├── task/          # Quản lý Task
│   │   ├── data/      # API calls, Local DB calls
│   │   ├── domain/    # Entities, Usecases, Repository interfaces
│   │   ├── presentation/ # Screens, Widgets, State (BLoC)
│   ├── schedule/
│   ├── analytics/
│   ├── gamification/
│
└── main.dart
```

### 4.2. Kiến trúc thư mục Backend (.NET)
Sử dụng Clean Architecture chia thành các layer:
```text
StudyFlowBackend/
├── Core (Domain Layer)      # Entities (User, Task, Note), Exceptions, Interfaces
├── Application Layer        # UseCases (Services/CQRS), DTOs, Validation
├── Infrastructure Layer     # EF Core DbContext, PostgreSQL config, Firebase Admin SDK, Gemini AI Service
└── API Layer (Presentation) # Controllers, JWT Middleware (nhận Firebase Token)
```

## 5. Workflow: Xác thực & Xử lý Dữ liệu

### 5.1. Authentication Flow
1. User đăng nhập trên App (Flutter) thông qua Firebase SDK.
2. Firebase trả về một `ID Token`.
3. Flutter gửi `ID Token` lên endpoint đăng nhập/đồng bộ của .NET API (Kèm trong header `Authorization: Bearer <ID_Token>`).
4. .NET dùng Firebase Admin SDK để kiểm tra tính hợp lệ của token. Nếu hợp lệ, lấy `uid` và lưu/cập nhật thông tin User vào bảng `Users` trên PostgreSQL.
5. Các API gọi sau này (như lấy danh sách Task) cũng đều phải kèm `ID Token` này để backend biết ai đang request.

### 5.2. Offline-First & Batch Sync (Cơ chế đồng bộ)
*Cách thức để triển khai cơ chế bạn thấy "hay và hiệu quả":*
1. **Lưu Local Trước**: Bất cứ khi nào tạo/sửa/xóa Task, Flutter lưu xuống Local DB (Isar/SQLite) trước, đồng thời đánh dấu field `isSynced = false`. UI cập nhật phản hồi lập tức cho người dùng, mang lại trải nghiệm siêu mượt.
2. **Background Sync**: Sử dụng package như `workmanager` trên Flutter. Khi máy có Internet, một background worker chạy ngầm, query các bản ghi có `isSynced = false` và gửi lên API của .NET qua endpoint `/api/sync/batch` (Dạng mảng dữ liệu).
3. **Phản hồi & Cập nhật**: .NET nhận mảng, update vào PostgreSQL (có thể dùng Transaction để đảm bảo tính nhất quán) rồi trả về 200 OK. Flutter nhận kết quả và đổi trạng thái các bản ghi đó thành `isSynced = true`.

### 5.3. AI Recommendation & Vector Search (Gemini)
1. **Tạo Vector (Embeddings)**: Mỗi khi người dùng tạo/nhập text (Ghi chú, Task, Mục tiêu), Backend .NET gọi **Gemini API (Embedding Model)** để mã hóa văn bản đó thành một chuỗi mảng số thực (Vector).
2. **Lưu trữ**: Lưu chuỗi Vector này vào bảng trong PostgreSQL ở một cột có kiểu `vector` (sử dụng `pgvector` extension).
3. **Tìm kiếm & Gợi ý (RAG)**: 
   - Khi user hỏi AI: "Tuần này tôi nên ưu tiên làm bài tập nào trước dựa trên lịch sử học của tôi?"
   - .NET gửi câu hỏi này qua Gemini API để lấy Vector câu hỏi.
   - Query PostgreSQL để tìm các Vector có độ tương đồng cao nhất (Cosine Similarity), trích xuất ra các Task/Note phù hợp.
   - Gửi nội dung Task/Note đó làm Context cho Gemini Chat API (Prompt: Dựa vào các task đang có sau đây, hãy gợi ý lịch học tối ưu cho user...). Gemini sẽ tạo ra câu trả lời tự nhiên.