# Huong Dan Tap Luyện - Workout Guide Feature

## Overview
Thanh cong them phan huong dan tap luyện theo nhom co vao phan templates. Tinh nang nay cung cap kiến thuc chi tiet ve 7 nhom co chinh va cac bai tap tuong ung.

## Features

### 1. **7 Main Muscle Groups (Nhom Co Chinh)**
- Nguc (Chest)
- Lung (Back)
- Vai (Shoulders)
- Canh tay (Biceps)
- Chan (Legs)
- Bung (Abs)
- Co cang tay (Forearms)

### 2. **Menu Structure**

#### Tab 1: My Templates
- Quan ly cac template bai tap cua rieng ban
- Tao, chinh sua, xoa template
- Tim kiem template
- Them bai tap vao template

#### Tab 2: Training Guide
- Danh sach 7 nhom co voi icon va mo ta
- Mau sac gradient cho moi nhom
- Nhan vao nhom de xem chi tiet

### 3. **Muscle Group Screen**
- Grid layout hien thi 7 nhom co
- Moi the hien ten, icon, va mo ta ngan gon
- Mau sac gradient khac nhau
- Nhan de xem danh sach bai tap

### 4. **Exercises Screen**
- Danh sach cac bai tap trong nhom co
- Hien thi default sets va reps
- Card layout voi icon va thong tin chi tiet
- Nhan de xem chi tiet bai tap

### 5. **Exercise Detail Screen**
Chi tiet day du cua moi bai tap:
- **Mo Ta** - Thong tin chi tiet ve bai tap
- **Cac Buoc Thuc Hien** - Huong dan bac tung buoc voi stepper
  - Bac 1, 2, 3, ...
  - Co the nhan vao buoc de xem chi tiet
- **Loi Ich** - Danh sach cac loi ich
  - Bullet points de de doc
- **Meo Vang** - Cac thuat co
  - Card layout voi ikon den (lightbulb)
- **Lich Tap Goi Y** - Huong dan lap lich
  - Hien thi so ngay tuan, so sets va reps
- **Sets and Reps** - Hien thi default values
- **Button "Them vao Tap"** - De them vao danh sach tap

## Data & Content

### Services Created
- `lib/services/workout_guide_service.dart`
  - Chua du lieu 7 nhom co
  - 27 bai tap (3 cho moi nhom)
  - Method tim kiem theo ID

### Models Created
- `lib/models/workout_guide.dart`
  - `MuscleGroup` - Model cho nhom co
  - `GuideExercise` - Model cho bai tap chi tiet

### New Screens Created
1. `lib/screens/templates/muscle_groups_screen.dart`
   - Danh sach 7 nhom co
   
2. `lib/screens/templates/muscle_group_exercises_screen.dart`
   - Danh sach bai tap cua nhom co
   
3. `lib/screens/templates/exercise_detail_screen.dart`
   - Chi tiet bai tap voi huong dan chi tiet

### Modified Files
- `lib/screens/templates/template_screen.dart`
  - Them tab interface
  - Tab 1: "My Templates" - template management
  - Tab 2: "Training Guide" - huong dan tap luyện

## Each Exercise Includes
- **Name** - Ten bai tap (tieng Anh)
- **Description** - Mo ta ngan gon
- **Steps** - 5 buoc chi tiet (Cac Buoc Thuc Hien)
- **Training Schedule** - Goi y lich tap (e.g., "3-4 ngay tuan, 3-4 sets x 6-8 reps")
- **Benefits** - Danh sach 3 loi ich
- **Tips** - Danh sach 4 meo vang
- **Default Sets** - So set mac dinh
- **Default Reps** - So rep mac dinh

## Example Exercises Per Muscle Group

### Chest (3 bai tap)
- Bench Press
- Incline Dumbbell Press
- Cable Fly

### Back (3 bai tap)
- Deadlift
- Lat Pulldown
- Barbell Row

### Shoulders (3 bai tap)
- Military Press
- Lateral Raise
- Rear Delt Fly

### Biceps (3 bai tap)
- Barbell Curl
- Dumbbell Curl
- Hammer Curl

### Legs (3 bai tap)
- Squat
- Leg Press
- Leg Curl

### Abs (3 bai tap)
- Crunch
- Plank
- Leg Raise

### Forearms (3 bai tap)
- Wrist Curl
- Reverse Wrist Curl
- Farmer Carry

## User Flow

1. User tap vao phan Templates trong app
2. Chi thi 2 tab: "My Templates" va "Training Guide"
3. User co the tap vao "Training Guide" tab
4. Hien thi grid 7 nhom co
5. User chon nhom co (e.g., Chest)
6. Hien thi danh sach 3 bai tap (e.g., Bench Press, Incline Press, Cable Fly)
7. User nhan vao bai tap (e.g., Bench Press)
8. Xem chi tiet day du:
   - Mo ta bai tap
   - 5 buoc thuc hien voi stepper
   - Loi ich
   - Meo vang
   - Lich tap goi y
   - So set va rep
9. User co the nhan "Them vao Tap" de them vao danh sach tap

## Technical Details

- **Language**: Dart/Flutter
- **UI Framework**: Material Design 3
- **State Management**: Provider (da co)
- **Data Storage**: Static data trong WorkoutGuideService
- **Color Scheme**: Gradient colors hang nhom co khac nhau
- **Navigation**: Push/Pop voi MaterialRoute
- **Localization**: Vietnamese text (transliterated to ASCII for compatibility)

## Future Enhancements (Optional)
- Add video links cho moi bai tap
- Them custom training plans
- Them notifications cho lap lich
- Them favorites cho bai tap yeu thich
- Add translations for multiple languages
- Them images/videos for each exercise
