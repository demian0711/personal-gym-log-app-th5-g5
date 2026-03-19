# Personal Gym Log App - TH5

Skeleton project cho bài thực hành nhóm môn Phát triển ứng dụng di động (Flutter).

## Mục tiêu của repo này

- Là bộ khung gốc để cả nhóm chia nhánh và phát triển.
- Chỉ cung cấp cấu trúc chuẩn, chưa triển khai đầy đủ tính năng.

## Cấu trúc thư mục chính

- lib/models: Data models (Workout, Exercise, ExerciseSet)
- lib/screens: Màn hình chính theo module
- lib/widgets: Widget dùng chung
- lib/providers: State management (Provider)
- lib/services: Local storage/API services
- lib/core: Theme, constants, routes

## Gợi ý phân nhánh

- member1/core-db-architecture
- member2/dashboard-ui
- member3/templates-history-ui
- member4/active-workout-state
- member5/timer-settings-notifications

## Chạy dự án

```bash
flutter pub get
flutter run
```