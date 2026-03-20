# Hướng Dẫn Cấu Hình Firebase Realtime Database

## ✅ Credentials Đã Được Cập Nhật

Tôi đã cập nhật `lib/firebase_options.dart` với thông tin Firebase thực tế của bạn:
```
Project ID: gymapp-7d586
Database URL: https://gymapp-7d586.firebasedatabase.app
```

## 🔧 Bước Tiếp Theo: Setup Realtime Database Rules

**⚠️ ĐỌC NGAY: Bất kỳ app Firebase nào cũng cần Rules để hoạt động!**

### Bước 1: Đăng nhập Firebase Console
Vào: https://console.firebase.google.com

### Bước 2: Chọn Project
Chọn project `gymapp-7d586`

### Bước 3: Vào Realtime Database
1. Từ menu bên trái, chọn **Build** → **Realtime Database**
2. Nếu chưa có database, click **Create Database**
   - Chọn location (mặc định được)
   - Bật **Test Mode** để kiểm tra nhanh (⚠️ CHỈ CHO TEST)
   - Click **Enable**

### Bước 4: Thiết lập Rules (QUAN TRỌNG)

1. Click vào tab **Rules**
2. Xóa tất cả rules hiện tại
3. Sao chép-dán code này:

```json
{
  "rules": {
    "users": {
      "$uid": {
        "templates": {
          ".read": true,
          ".write": true,
          ".indexOn": ["date"]
        },
        "workoutLogs": {
          ".read": true,
          ".write": true,
          ".indexOn": ["date"]
        }
      }
    }
  }
}
```

4. Click **Publish** (nút xanh góc trên bên phải)

### 📝 Giải Thích Rules Này

- `true`: Cho phép **mọi người** đọc/ghi (CHỈ DÙNG TRONG TEST)
- `.indexOn`: Tối ưu tìm kiếm theo ngày
- Cấu trúc: `users/{userId}/templates/` và `users/{userId}/workoutLogs/`

## ⚠️ Bảo Mật Cho Production

Sau khi kiểm tra xong, thay đổi rules này:

```json
{
  "rules": {
    "users": {
      "$uid": {
        "templates": {
          ".read": "$uid === auth.uid",
          ".write": "$uid === auth.uid"
        },
        "workoutLogs": {
          ".read": "$uid === auth.uid",
          ".write": "$uid === auth.uid"
        }
      }
    }
  }
}
```

Điều này chỉ cho phép user authenticated mỗi người xem dữ liệu của chính họ.

## 🧪 Kiểm Tra Kết Nối

Sau khi setup rules:

1. Build app lại:
   ```
   flutter clean
   flutter pub get
   flutter run
   ```

2. Mở app
3. Vào **Templates → Training Guide**
4. Chọn một bài tập, bấm **"Add to Template"**
5. Mở **Firebase Console → Realtime Database → Data**
6. Kiểm tra xem dữ liệu xuất hiện ở:
   ```
   users/
   └── default_user/
       └── templates/
           └── [template_id]/
   ```

## 🔗 Helpful Resources

- Firebase Rules Guide: https://firebase.google.com/docs/database/security
- Test thử Rules: Trong Firebase Console có **Simulate** button
- Debug: Kiểm tra **Rules Playground** để xem tại sao rule failed

## Nếu Bị Lỗi "Permission Denied"

Nguyên nhân: Rules chưa cho phép truy cập

Giải pháp:
1. Kiểm tra lại rules trong Firebase Console
2. Đảm bảo rules đã **Publish**
3. Refresh app
4. Nếu vẫn lỗi, sử dụng Test Mode (rules là `true`)

## 📊 Cấu Trúc Dữ Liệu Sau Setup

Khi add template qua app, data sẽ trông như:

```json
{
  "users": {
    "default_user": {
      "templates": {
        "template-id-xyz": {
          "id": "template-id-xyz",
          "title": "Push Day",
          "date": 1710950400000,
          "exercises": [...]
        }
      },
      "workoutLogs": {
        "log-id-xyz": {
          "id": "log-id-xyz",
          "title": "Push Day - 20/3/2026",
          "date": 1710950400000,
          "exercises": [...]
        }
      }
    }
  }
}
```

## ✅ Kiểm Tra Danh Sách

- [ ] Vào Firebase Console
- [ ] Chọn project `gymapp-7d586`
- [ ] Vào **Realtime Database**
- [ ] Tab **Rules**, xóa rules cũ
- [ ] Paste rules mới từ trên
- [ ] Click **Publish**
- [ ] Đợi 1-2 giây xác nhận
- [ ] Làm sạch app: `flutter clean && flutter pub get`
- [ ] Chạy app: `flutter run`
- [ ] Test thêm template
- [ ] Kiểm tra Firebase Console → Data để xem dữ liệu mới

## Câu Hỏi Thường Gặp

**Q: "Tại sao data không xuất hiện?"**
- A: Rules chưa được publish, hoặc chưa setup database

**Q: "Tôi muốn xóa all test data?"**
- A: Trong Firebase Console, chọn node root, click delete

**Q: "Làm sao để lấy lại data nếu xóa nhầm?"**
- A: Firebase không có backup tự động. Hãy cẩn thận với data quan trọng!

**Q: "Sync hoạt động offline không?"**
- A: Có! Local data được lưu trong Hive, sync khi online

---

**Sau khi setup Rules xong, app sẽ tự động đồng bộ!** 🎉
