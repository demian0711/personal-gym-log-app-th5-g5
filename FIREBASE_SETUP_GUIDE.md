# Firebase Setup Guide (Flutter + Auth + Firestore)

Tài liệu này hướng dẫn từ đầu cho dự án **Personal Gym Log**.

## 1) Tạo Firebase Project

1. Vào Firebase Console: https://console.firebase.google.com
2. Chọn **Create a project**.
3. Đặt tên project (ví dụ: `personal-gym-log`).
4. Có thể tắt Google Analytics ở bước đầu để setup nhanh.
5. Nhấn **Create project**.

## 2) Thêm Android App vào Firebase

1. Trong project Firebase, chọn biểu tượng Android (**Add app**).
2. Nhập **Android package name** đúng với app:
   - `com.example.personal_gym_log_app_th5_g5`
3. Có thể nhập app nickname (tùy chọn).
4. Nhấn **Register app**.
5. Tải file `google-services.json`.
6. Đặt file vào đúng vị trí:
   - `android/app/google-services.json`

## 3) Cấu hình Gradle cho Firebase

Dự án hiện đã cấu hình sẵn đúng hướng Flutter Gradle mới:

- `android/settings.gradle.kts` đã có plugin:
  - `com.google.gms.google-services`
- `android/app/build.gradle.kts` đã áp dụng:
  - `id("com.google.gms.google-services")`

Nếu bạn tạo project mới, luôn đảm bảo 2 điểm trên có mặt.

## 4) Bật Authentication

### 4.1 Email/Password

1. Firebase Console → **Authentication** → **Get started**.
2. Mở tab **Sign-in method**.
3. Bật provider **Email/Password**.
4. Save.

### 4.2 Google Sign-In

1. Cũng ở **Sign-in method**, bật **Google**.
2. Chọn email support.
3. Save.

### 4.3 SHA-1/SHA-256 cho Android (quan trọng cho Google Sign-In)

1. Chạy lệnh lấy SHA-1 debug:
   - Windows: dùng `gradlew signingReport` trong thư mục `android`.
2. Vào Firebase Console → Project settings → Android app.
3. Thêm SHA-1 (và SHA-256 nếu có).
4. Tải lại `google-services.json` nếu Firebase yêu cầu và thay vào `android/app/`.

## 5) Bật Cloud Firestore

1. Firebase Console → **Firestore Database**.
2. Chọn **Create database**.
3. Chọn **Start in production mode**.
4. Chọn region gần bạn nhất.
5. Create.

## 6) Cài package Flutter cần thiết

Trong `pubspec.yaml`, dự án dùng:

- `firebase_core`
- `firebase_auth`
- `cloud_firestore`
- `google_sign_in`

Sau khi sửa package, chạy:

```bash
flutter pub get
```

## 7) Firebase hoạt động trong app như thế nào?

Luồng tổng quát:

1. `main.dart` gọi `Firebase.initializeApp(...)` để khởi tạo SDK.
2. `AuthProvider` lắng nghe `authStateChanges()` từ Firebase Auth.
3. Khi user login/register thành công:
   - Firebase Auth trả user (`uid`, `email`, `displayName`...).
   - App upsert hồ sơ vào Firestore `users/{uid}`.
4. Các module khác dùng `uid` làm khóa dữ liệu người dùng.
5. Firestore bật persistence để hỗ trợ offline cache và đồng bộ lại khi online.

---

## 8) Firestore NoSQL structure đề xuất theo đề cương

### Collection cấp cao

- `users/{userId}`
- `workouts/{workoutId}`
- `progress_photos/{photoId}`

### Ví dụ document

`users/{userId}`

```json
{
  "uid": "abc123",
  "email": "user@gmail.com",
  "displayName": "Phat",
  "photoUrl": "https://...",
  "authProvider": "google",
  "createdAt": "serverTimestamp",
  "updatedAt": "serverTimestamp"
}
```

`workouts/{workoutId}`

```json
{
  "userId": "abc123",
  "date": "2026-04-06T08:00:00Z",
  "title": "Push Day",
  "totalVolume": 12500,
  "exercises": [
    {
      "name": "Bench Press",
      "sets": [
        {"weight": 80, "reps": 8}
      ]
    }
  ],
  "createdAt": "serverTimestamp",
  "updatedAt": "serverTimestamp"
}
```

`progress_photos/{photoId}`

```json
{
  "userId": "abc123",
  "imageUrl": "https://res.cloudinary.com/...",
  "capturedAt": "2026-04-06T08:30:00Z",
  "note": "Week 4 check-in",
  "createdAt": "serverTimestamp"
}
```

## 9) Query Firestore cơ bản (NoSQL)

- Lấy toàn bộ workout của 1 user:
  - filter theo `where('userId', isEqualTo: uid)`
- Sắp xếp theo ngày mới nhất:
  - `orderBy('date', descending: true)`
- Lấy 1 workout gần nhất:
  - thêm `limit(1)`
- Lấy progress photos theo user + thời gian:
  - `where('userId', isEqualTo: uid).orderBy('capturedAt', descending: true)`

Lưu ý: khi kết hợp `where + orderBy`, Firestore có thể yêu cầu tạo index (Console sẽ cung cấp link tự động).

## 10) Rules Firestore mẫu (bản cơ bản)

```txt
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }

    match /workouts/{workoutId} {
      allow read, write: if request.auth != null
        && request.resource.data.userId == request.auth.uid;
      allow read: if request.auth != null
        && resource.data.userId == request.auth.uid;
    }

    match /progress_photos/{photoId} {
      allow read, write: if request.auth != null
        && request.resource.data.userId == request.auth.uid;
      allow read: if request.auth != null
        && resource.data.userId == request.auth.uid;
    }
  }
}
```

## 11) Checklist nhanh trước khi chạy app

- `google-services.json` đúng chỗ `android/app/`
- Đã bật Email/Password và Google provider
- Đã thêm SHA-1 cho Android
- Đã tạo Firestore database
- Đã chạy `flutter pub get`
- Chạy app bằng `flutter run`
