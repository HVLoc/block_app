# Phát hành Blocks lên Google Play

- Tên hiển thị trên thiết bị: **Blocks**.
- Tên đề xuất trên cửa hàng: **Blocks** (chưa xác minh tên trên cửa hàng).
- Application ID / namespace: `vn.lochv.locblocks`.
- Phiên bản đầu tiên: `1.0.0`, versionCode `1` trong `pubspec.yaml`.
- compileSdk / targetSdk lấy từ Flutter đang chọn; Flutter 3.47.0 hiện đặt cả hai là 36.

## Icon

- Ảnh AI gốc: `branding/blocks-icon-source.png`.
- Icon cửa hàng 512×512: `branding/blocks-play-store-512.png`.
- Icon Android đã được thay ở cả năm mật độ mdpi đến xxxhdpi.
- Sinh bằng công cụ imagegen tích hợp; prompt lưu ở `branding/ICON_PROMPT.txt`.
- Ảnh AI không bảo đảm quyền sở hữu độc quyền hoặc tự động miễn mọi vấn đề bản quyền.

## Khóa ký

Bản release dùng upload key riêng, không dùng debug key:

- `android/upload-keystore.jks`: khóa upload, alias `locblocks`.
- `android/key.properties`: đường dẫn khóa và mật khẩu ngẫu nhiên.

Cả hai file đã được loại trừ bởi `android/.gitignore`. Sao lưu cả hai vào nơi
riêng có bảo vệ; không commit, không gửi qua chat và không tạo lại khóa cho mỗi
bản cập nhật. Thông tin trong chứng chỉ là LocHV, quốc gia VN.

Trên máy build khác, khôi phục hai file này trước khi tạo bản release.
Trong Play Console, cấu hình Play App Signing theo hướng dẫn của Google;
khóa upload dùng để ký AAB trước khi tải lên.

## Build

Chạy tại thư mục dự án, dùng JDK 21. Nếu dùng FVM:

```powershell
fvm flutter doctor -v
fvm flutter pub get
fvm flutter build appbundle --release
```

Kết quả: `build/app/outputs/bundle/release/app-release.aab`.

Mỗi bản cập nhật cần tăng versionCode, ví dụ đổi `version: 1.0.0+1` thành
`version: 1.0.1+2` trong `pubspec.yaml`, rồi build lại.

## Trước khi gửi duyệt

1. Kiểm tra tên ứng dụng và icon Blocks trên thiết bị; chuẩn bị ảnh chụp
   màn hình và ảnh cửa hàng.
2. Tạo ứng dụng trong Play Console, đối chiếu package `vn.lochv.locblocks`.
   Chốt ID trước lần tải đầu; ID này xác định ứng dụng cho các bản cập nhật.
3. Chuẩn bị email hỗ trợ và trang chính sách quyền riêng tư công khai.
4. Hoàn thành App content, Data safety, phân loại nội dung, đối tượng người
   dùng và khai báo quảng cáo theo đúng bản build thực tế.
   Mã nguồn hiện kiểm tra chưa thấy SDK quảng cáo/analytics hoặc tài khoản;
   điểm và tiến trình được lưu cục bộ. Cần rà lại nếu thêm SDK mới.
5. Tải AAB lên kênh thử nghiệm, kiểm tra trên thiết bị thật và xem báo cáo
   kiểm tra trước khi phát hành. Thực hiện yêu cầu kiểm thử của tài khoản
   được Play Console hiển thị trước khi đăng ký production.
6. Kiểm tra yêu cầu target API và các cảnh báo tương thích hiện hành trong
   Play Console. Build thành công không đồng nghĩa đã được Google duyệt.

Không tự động nâng Gradle/AGP/Kotlin trong thay đổi này; đây là cấu hình
đã chạy được trên máy. Cảnh báo phiên bản cần được xử lý trong lần nâng
cấp toolchain riêng có kiểm thử.
