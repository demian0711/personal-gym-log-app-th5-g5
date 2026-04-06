/// Cloudinary config cho module Progress Photos.
///
/// Không hardcode trực tiếp trong logic upload.
/// Nên truyền qua --dart-define khi chạy app:
/// --dart-define=CLOUDINARY_CLOUD_NAME=xxx
/// --dart-define=CLOUDINARY_UPLOAD_PRESET=xxx
/// --dart-define=CLOUDINARY_API_KEY=xxx (optional cho unsigned preset)
const String kCloudinaryCloudName = String.fromEnvironment(
  'CLOUDINARY_CLOUD_NAME',
  defaultValue: '',
);

const String kCloudinaryUploadPreset = String.fromEnvironment(
  'CLOUDINARY_UPLOAD_PRESET',
  defaultValue: '',
);

const String kCloudinaryApiKey = String.fromEnvironment(
  'CLOUDINARY_API_KEY',
  defaultValue: '',
);
