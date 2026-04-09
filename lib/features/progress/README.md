# Progress Module

Module `progress` cung cấp các widget và công cụ để xử lý chụp ảnh trong ứng dụng.

## Cấu trúc

```
lib/features/progress/
├── presentation/
│   ├── widgets/
│   │   ├── photo_capture_widget.dart    # Widget chụp ảnh tái sử dụng
│   │   └── index.dart                   # Export file
│   └── index.dart
├── index.dart
└── README.md
```

## Thành phần chính

### PhotoCaptureWidget

Widget reusable để chụp ảnh với tùy chọn ghi chú.

#### Cách sử dụng cơ bản:

```dart
import 'package:personal_gym_log_app/features/progress/index.dart';

PhotoCaptureWidget(
  title: 'Chụp ảnh tiến độ',
  subtitle: 'Theo dõi sự thay đổi cơ thể',
  onPhotoUploaded: (message) {
    print('Ảnh upload thành công');
  },
)
```

#### Tham số:

| Tham số | Kiểu | Mặc định | Mô tả |
|--------|------|---------|-------|
| `title` | String | 'Thêm ảnh tiến độ' | Tiêu đề widget |
| `subtitle` | String | 'Theo dõi sự thay đổi cơ thể của bạn qua từng ngày luyện tập' | Mô tả phụ |
| `cameraButtonLabel` | String | 'Chụp ảnh' | Nhãn nút camera |
| `galleryButtonLabel` | String | 'Thư viện' | Nhãn nút thư viện |
| `noteLabel` | String | 'Ghi chú (tuỳ chọn)' | Nhãn trường ghi chú |
| `noteHint` | String | 'VD: Tăng cơ bắp, giảm mỡ, v.v' | Gợi ý cho trường ghi chú |
| `onPhotoUploaded` | Function? | null | Callback khi upload thành công |
| `onError` | Function? | null | Callback khi có lỗi |
| `showImagePreview` | bool | false | Hiện ảnh preview sau chọn |

#### Ví dụ nâng cao:

```dart
PhotoCaptureWidget(
  title: 'Tải ảnh bài tập',
  subtitle: 'Chọn ảnh từ camera hoặc thư viện',
  cameraButtonLabel: 'Dùng Camera',
  galleryButtonLabel: 'Từ Thư Viện',
  noteLabel: 'Ghi chú bài tập',
  noteHint: 'Ví dụ: 10 cái, 3 bộ',
  showImagePreview: true,
  onPhotoUploaded: (message) {
    // Xử lý upload thành công
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Tải lên thành công')),
    );
  },
  onError: (error) {
    // Xử lý lỗi
    print('Lỗi: $error');
  },
)
```

## Yêu cầu Provider

Widget sử dụng `ProgressPhotoProvider` từ feature `progress_photos`:

```dart
// Đảm bảo provider được khai báo
ChangeNotifierProvider(
  create: (_) => ProgressPhotoProvider(),
)
```

## Intergration với ProgressPhotosScreen

Module này được tách ra từ `ProgressPhotosScreen` để tái sử dụng. `ProgressPhotosScreen` bây giờ sử dụng `PhotoCaptureWidget`:

```dart
// Trong progress_photos_screen.dart
PhotoCaptureWidget(
  onPhotoUploaded: (message) {
    // Optional: Xử lý sau khi upload thành công
  },
)
```

## Tính năng

- ✅ Chụp ảnh từ camera
- ✅ Chọn ảnh từ thư viện
- ✅ Ghi chú ảnh (tuỳ chọn)
- ✅ Hiển thị trạng thái upload
- ✅ Xử lý lỗi
- ✅ Preview ảnh (tuỳ chọn)
- ✅ Tùy chỉnh văn bản/nhãn hết sức linh hoạt

## Lưu ý

1. Widget yêu cầu `ProgressPhotoProvider` được cung cấp qua `Provider`
2. Các quyền camera và thư viện ảnh phải được cấu hình trong Android/iOS config
3. Image quality mặc định là 85 để cân bằng giữa chất lượng và kích thước file
