# Blocks

## Tiêu chuẩn UI/UX

Đã tích hợp [UI UX Pro Max](https://github.com/nextlevelbuilder/ui-ux-pro-max-skill)
riêng cho dự án tại `.agents/skills/ui-ux-pro-max/` (giấy phép MIT và nguồn
upstream được lưu cùng skill). Codex có thể tự nhận skill ở lượt làm việc
tiếp theo khi mở đúng thư mục dự án này.

Trước khi sửa giao diện Flutter, đọc `SKILL.md` của skill và
`design-system/blocks/MASTER.md`. Đây là chuẩn đã chọn riêng cho Blocks:
Material 3 tối, nút chạm 48dp, khoảng cách 4/8dp, hỗ trợ chữ lớn,
giảm chuyển động và nhãn hỗ trợ đọc màn hình.

Ngoài kéo thả, có thể chạm chọn một khối rồi chạm ô muốn đặt góc trên trái.
Chạm lại khối đang chọn để hủy chọn. Thao tác sai vị trí giữ nguyên khối để
người chơi thử lại. Quy tắc tính điểm và định dạng lưu ván chơi không đổi.

Tra cứu hướng dẫn theo stack Flutter bằng Python 3:

```powershell
python .agents/skills/ui-ux-pro-max/scripts/search.py "semantics text scaling" --stack flutter
```

Skill là công cụ phát triển cục bộ, không được đóng gói vào ứng dụng.
Các thay đổi ở lượt này chưa được build thành AAB mới.

## Chủ đề khối

Nhấn nút bảng màu cạnh nút chơi lại để chọn **Cổ điển**, **Hình học** hoặc
**Trái cây**. Mỗi thẻ có hình xem trước; lựa chọn được lưu tự động bằng khóa
`blocks_theme` và được khôi phục khi mở lại app. Chủ đề chỉ đổi cách vẽ,
không thay đổi màu nhận diện khối, luật chơi, điểm hoặc tiến trình.

Các biểu tượng được vẽ trực tiếp bằng Canvas, không cần ảnh hay dependency
mới. Board, vùng xem trước khi thả, dock và khối đang kéo dùng chung bộ vẽ.
Nếu lưu thất bại, bộ chọn báo lỗi và giữ chủ đề trước đó để người chơi thử lại.
Chức năng áp dụng cho bản game Flutter ở `lib/main.dart`.

Game xếp khối Flutter, tổ chức theo `FLUTTER_STANDARDS.md` v2.1.

## Cấu trúc

```text
lib/
  main.dart                      # Khởi tạo Flutter, orientation, preferences
  main_2.dart                    # Entry point cho bản WebView cũ
  app.dart                       # GetMaterialApp
  core/
    errors/                      # AppException, sealed Result<T>
    theme/app_colors.dart        # Màu sắc tập trung
  routes/
    app_routes.dart              # Tên route
    app_pages.dart               # GetPage + Binding
  features/
    game/
      data/
        datasources/             # SharedPreferences, các key bb_*
        models/                  # DTO và JSON code generated
        repositories/            # GameRepositoryImpl
      domain/
        entities/                # Piece, GameState, GameMove, history, constants
        repositories/            # Interface GameRepository
        services/game_rules.dart # Luật đặt khối, combo, xóa hàng/cột
        usecases/                # Mỗi hành động có một execute()
      presentation/
        bindings/                # DI theo route, Get.lazyPut
        controllers/             # UI state, kéo thả, hiệu ứng, gọi UseCase
        models/                  # Tọa độ kéo và popup điểm, phụ thuộc Flutter
        pages/                   # Scaffold màn hình game
        widgets/                 # Board, dock, header, animation, painter riêng
    web_game/
      presentation/              # Binding, controller và page của bản WebView
```

Controller gọi UseCase; UseCase phụ thuộc interface Repository. Luật chơi nằm
trong domain thuần Dart; repository điều phối luật chơi và local data source.
Binding là nơi lắp ráp implementation với interface; page/widget không import
data layer, không tự đăng ký dependency và không truy cập SharedPreferences.
Controller được giải phóng theo vòng đời route. Không có singleton service mới.

## Chạy và kiểm tra

Yêu cầu Dart >= 3.11 theo `pubspec.yaml`. Bản refactor được kiểm tra với
Flutter 3.44.7 và các dependency trong `pubspec.lock`.

```sh
flutter pub get
dart run build_runner build
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test --coverage
flutter run
flutter run -t lib/main_2.dart
```

Commit các file `*.g.dart` được sinh bởi build_runner. Màu sắc dùng `AppColors`;
widget tương tác chính có Key ổn định cho reset, restart và kéo từng slot.

## Tương thích và phạm vi

- Giữ các key `bb_best`, `bb_history`, `bb_active`, định dạng JSON `m`/`c` của
  khối, giới hạn lịch sử 25 ván và công thức tính điểm/combo.
- Dữ liệu board/history JSON lỗi được khôi phục về trạng thái hợp lệ;
  lỗi lưu trữ trả về `Failure` để controller hiển thị.
- Hủy kéo trả khối về dock. Thả khối chờ kiểm tra hover cuối cùng; reset bị
  khóa khi đang đặt khối để tránh thay đổi ván giữa hiệu ứng xóa dòng.
- Board co theo chiều cao khả dụng để tránh overflow trên viewport thấp.
- Bản WebView vẫn sử dụng `assets/block.html`; không thay đổi HTML hoặc luật
  chơi JavaScript của bản này.
- Áp dụng `very_good_analysis`; chỉ tắt yêu cầu dartdoc cho mọi public member.
  Public API trong repository/usecase vẫn có dartdoc theo tiêu chuẩn.
- Chưa tích hợp monitoring/logger/Sentry hoặc package nội bộ `sds_gen`.
  Các phần này cần cấu hình/provider và nguồn package nội bộ; không thuộc
  thay đổi tách file. Đường dẫn asset WebView hiện tại được giữ nguyên.

17 test bao phủ UseCase success/failure, state của controller, luật tính điểm,
giao hàng/cột, reset, game over, khôi phục JSON cũ/lỗi, kéo thả và widget.
Chưa chạy trên thiết bị Android/iOS hoặc kiểm tra WebView trên thiết bị thật.
