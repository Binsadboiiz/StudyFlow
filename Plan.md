# Kế hoạch & Tài liệu Kiến trúc Dự án StudyFlow

Tài liệu này trình bày chi tiết về kiến trúc hiện tại, các chức năng cốt lõi và mô hình thực thể dữ liệu đang được áp dụng trong hệ sinh thái **StudyFlow**.

---

## 1. Kiến trúc Hệ thống (System Architecture)

Dự án StudyFlow áp dụng mô hình client-server hiện đại, phân tách rõ ràng trách nhiệm giữa ứng dụng di động (Frontend) và máy chủ API (Backend).

```mermaid
graph TD
    subgraph Client (Mobile App)
        Presentation[Presentation Layer: Screens & Widgets]
        ViewModel[ViewModel Layer: State & UI Logic]
        Domain[Domain Layer: UseCases & Entity Interfaces]
        Data_Client[Data Layer: API Client & Local Storage]
    end

    subgraph Server (Backend API)
        Controller[API Controllers]
        Service[Service Layer: Business Logic]
        EFCore[Entity Framework Core]
        Worker[Background Hosted Services]
    end

    subgraph Database & Cloud
        PostgreSQL[(PostgreSQL DB)]
        FirebaseAuth[Firebase Auth]
    end

    %% Client Interactions
    Presentation -->|Observes State| ViewModel
    ViewModel -->|Invokes| Domain
    Domain -->|Calls Repository| Data_Client

    %% Client to Server & Cloud
    Data_Client -->|HTTP Requests / Auth Token| Controller
    Data_Client -->|SDK Auth| FirebaseAuth
    Controller -->|Validates JWT| FirebaseAuth

    %% Server Interactions
    Controller -->|Invokes| Service
    Service -->|Uses ORM| EFCore
    EFCore -->|Queries & Updates| PostgreSQL
    Worker -->|Processes Actions| Service
```

### 1.1. Kiến trúc Frontend (Flutter)
Ứng dụng di động sử dụng kiến trúc **Clean Architecture** được tổ chức theo hướng **Feature-First** (chia thư mục theo từng tính năng độc lập). Mỗi tính năng (Feature) trong thư mục `lib/features/` được chia làm 3 lớp chính:
*   **Data Layer:** Chịu trách nhiệm tương tác với nguồn dữ liệu ngoài (gọi API bằng HTTP, kết nối cơ sở dữ liệu cục bộ).
*   **Domain Layer:** Chứa các thực thể kinh doanh (Entities) và các Cách sử dụng (UseCases) định nghĩa các luồng nghiệp vụ thuần túy của ứng dụng, không phụ thuộc vào framework UI.
*   **Presentation Layer:** Chứa giao diện người dùng (Screens, Widgets) và các **ViewModel** làm nhiệm vụ quản lý trạng thái.
*   **Giải pháp Quản lý trạng thái (State Management):** Sử dụng thư viện **Provider** (`ChangeNotifierProvider`, `Consumer`) để quản lý và phản hồi dữ liệu thay đổi trên UI một cách hiệu quả, tránh việc vẽ lại màn hình không cần thiết.

### 1.2. Kiến trúc Backend (.NET Web API)
API Server được thiết kế theo kiến trúc phân tầng (Layered Architecture) trong một dự án C# duy nhất:
*   **Controllers:** Tiếp nhận các yêu cầu HTTP từ client, kiểm tra tính hợp lệ của Firebase JWT Token trong header.
*   **Services:** Chứa logic nghiệp vụ cốt lõi (Business Logic) xử lý bài toán về tính điểm, thăng cấp thú cưng, giới hạn bộ nhớ quét tài liệu.
*   **Data (EF Core):** Sử dụng Entity Framework Core làm ORM kết nối tới cơ sở dữ liệu PostgreSQL. Tự động kiểm tra và thực thi các tệp Migration (`dbContext.Database.Migrate()`) ngay khi ứng dụng khởi chạy.
*   **Background Services (Hosted Services):** Chạy ngầm trong hệ thống để thực hiện các nhiệm vụ tự động (nhắc nhở lịch trình, dọn dẹp thùng rác định kỳ).

---

## 2. Các Chức năng Cốt lõi (Features)

1.  **Đăng nhập & Đăng ký (Auth):** Xác thực người dùng qua Firebase Authentication (Email/Password, Google Sign-In). Backend xác thực lại thông qua Firebase JWT Token để bảo mật tài nguyên API.
2.  **Quản lý Công việc & Thời gian biểu (Task & Schedule):** Tạo lập, cập nhật, xóa các đầu việc học tập. Tích hợp lịch tuần/tháng sinh động thông qua `Table Calendar`.
3.  **Chế độ tập trung (Focus Mode):** Đồng hồ đếm ngược Pomodoro hỗ trợ người dùng rèn luyện sự tập trung. Kết quả của mỗi phiên được đồng bộ lên máy chủ để tính điểm.
4.  **Hệ thống Thú cưng học tập (Study Pet Gamification):** Tích hợp **Flame Game Engine** trên di động để nuôi thú cưng ảo. Khi hoàn thành task hoặc tập trung học, người dùng tích lũy XP giúp thú cưng thăng cấp và thay đổi trạng thái hoạt động.
5.  **Quét tài liệu OCR (Scan Document):** Quét ảnh tài liệu học tập, nhận diện chữ tự động bằng **Google ML Kit**. Hệ thống hỗ trợ nén ảnh, cắt/xoay ảnh trước khi lưu trữ, phân phối tài liệu vào Thùng rác (Trash) khi xóa tạm và kiểm soát dung lượng bộ nhớ.
6.  **Thống kê & Đồ thị (Analytics):** Trực quan hóa kết quả học tập, tổng thời gian tập trung và tỷ lệ hoàn thành task của người dùng dưới dạng biểu đồ tròn/cột bằng thư viện `FL Chart`.
7.  **Hệ thống Thông báo (Notification):** Lập lịch gửi thông báo nhắc nhở học tập cục bộ trên thiết bị theo múi giờ địa phương, kết hợp dịch vụ quét dữ liệu ngầm từ backend.

---

## 3. Mô hình Thực thể Dữ liệu (Database Models)

Hệ thống quản lý dữ liệu tập trung thông qua cơ sở dữ liệu PostgreSQL. Các bảng dữ liệu chính (được ánh xạ qua Entity Framework Core) bao gồm:

### 3.1. Thực thể Người dùng (`User`)
Lưu trữ thông tin hồ sơ và tiến trình tích lũy học tập của người dùng.
*   `Id` (Khóa chính): Đồng bộ với UID của Firebase Auth.
*   `DisplayName`, `Email`, `PhotoUrl`: Thông tin cá nhân.
*   `Points` (Điểm tích lũy): Dùng để xếp hạng và mua vật phẩm cho thú cưng.
*   `Xp` (Kinh nghiệm tích lũy): Thể hiện mức độ nỗ lực học tập của bản thân.
*   `Level` (Cấp độ hiện tại): Tăng lên dựa trên điểm XP.
*   `CurrentStreak`, `LongestStreak`: Ghi nhận chuỗi ngày học liên tục.
*   `LastActive`: Lần cuối người dùng tương tác để tính Streak.
*   `FeaturedBadgeId` (Khóa ngoại): Huy hiệu được chọn để hiển thị nổi bật trên trang cá nhân.

### 3.2. Thực thể Công việc (`StudyTask`)
Quản lý các nhiệm vụ cần thực hiện của người dùng.
*   `Id` (Khóa chính): Mã định danh duy nhất của công việc.
*   `Title`, `Description`: Tiêu đề và nội dung công việc.
*   `DueDate`: Hạn chót hoàn thành.
*   `Priority`: Độ ưu tiên (Thấp, Trung bình, Cao).
*   `IsCompleted`: Trạng thái hoàn thành công việc.
*   `UserId` (Khóa ngoại): Liên kết đến người dùng sở hữu công việc này.

### 3.3. Thực thể Phiên tập trung (`FocusSession`)
Lưu trữ lịch sử sử dụng đồng hồ Pomodoro.
*   `Id` (Khóa chính): Định danh phiên.
*   `StartTime`, `EndTime`: Thời gian bắt đầu và kết thúc của phiên tập trung.
*   `DurationInMinutes`: Tổng số phút thực tế tập trung.
*   `IsCompleted`: Phiên tập trung có bị hủy giữa chừng hay không.
*   `UserId` (Khóa ngoại): Liên kết đến người dùng thực hiện tập trung.

### 3.4. Thực thể Thú cưng học tập (`StudyPet`)
Quản lý trạng thái thú cưng ảo của từng người dùng (quan hệ 1-1 với `User`).
*   `Id` (Khóa chính): Định danh thú cưng.
*   `Name`: Tên thú cưng do người dùng đặt.
*   `Level`, `Xp`: Cấp độ và kinh nghiệm hiện tại của thú cưng (pet phát triển song hành cùng người dùng).
*   `PetType`: Chủng loại thú cưng (ví dụ: Mèo, Chó, Thỏ...).
*   `Status`: Trạng thái hiện tại của pet (Đang ngủ, Học bài, Vui chơi, Đói...).
*   `UserId` (Khóa ngoại): Liên kết duy nhất tới một tài khoản người dùng.

### 3.5. Thực thể Tài liệu đã quét (`ScannedDocument`)
Quản lý tài liệu OCR đã lưu trữ của người dùng.
*   `Id` (Khóa chính): Định danh tài liệu.
*   `Title`: Tiêu đề tài liệu.
*   `RawText`: Đoạn văn bản thu được sau khi chạy nhận diện chữ OCR.
*   `ImageUrl`: Liên kết lưu trữ hình ảnh tài liệu đã quét.
*   `FileSizeInBytes`: Dung lượng file hình ảnh để tính toán quota lưu trữ.
*   `IsDeleted`: Trạng thái xóa tạm (Soft delete) phục vụ tính năng Thùng rác.
*   `DeletedAt`: Thời gian tài liệu bị đưa vào thùng rác (để tự động xóa vĩnh viễn sau 30 ngày).
*   `UserId` (Khóa ngoại): Liên kết tới người dùng tải lên tài liệu.

### 3.6. Thực thể Huy hiệu (`Badge` & `UserBadge`)
Thiết lập hệ thống thành tựu (Quan hệ Nhiều - Nhiều giữa `User` và `Badge`).
*   **`Badge` (Thực thể tĩnh):**
    *   `Id`: Mã huy hiệu.
    *   `Name`, `Description`: Tên và mô tả cách đạt được huy hiệu.
    *   `IconUrl`: Hình ảnh đại diện cho huy hiệu.
*   **`UserBadge` (Thực thể liên kết):**
    *   `UserId` (Khóa ngoại): Người dùng nhận huy hiệu.
    *   `BadgeId` (Khóa ngoại): Huy hiệu được mở khóa.
    *   `UnlockedAt`: Ngày giờ mở khóa huy hiệu.