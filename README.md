# Block Blast Lite

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
