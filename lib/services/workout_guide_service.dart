import '../models/workout_guide.dart';

class WorkoutGuideService {
  static MuscleGroup muscleGroupChest = MuscleGroup(
    id: 'chest',
    name: 'Nguc',
    imagePath: 'assets/images/chest.png',
    description: 'Cac bai tap tap trung vao co nguc',
  );

  static MuscleGroup muscleGroupBack = MuscleGroup(
    id: 'back',
    name: 'Lung',
    imagePath: 'assets/images/back.png',
    description: 'Cac bai tap tap trung vao co lung',
  );

  static MuscleGroup muscleGroupShoulders = MuscleGroup(
    id: 'shoulders',
    name: 'Vai',
    imagePath: 'assets/images/shoulders.png',
    description: 'Cac bai tap tap trung vao co vai',
  );

  static MuscleGroup muscleGroupBiceps = MuscleGroup(
    id: 'biceps',
    name: 'Canh tay',
    imagePath: 'assets/images/biceps.png',
    description: 'Cac bai tap tap trung vao canh tay',
  );

  static MuscleGroup muscleGroupLegs = MuscleGroup(
    id: 'legs',
    name: 'Chan',
    imagePath: 'assets/images/legs.png',
    description: 'Cac bai tap tap trung vao co chan',
  );

  static MuscleGroup muscleGroupAbs = MuscleGroup(
    id: 'abs',
    name: 'Bung',
    imagePath: 'assets/images/abs.png',
    description: 'Cac bai tap tap trung vao co bung',
  );

  static MuscleGroup muscleGroupForearms = MuscleGroup(
    id: 'forearms',
    name: 'Co cang tay',
    imagePath: 'assets/images/forearms.png',
    description: 'Cac bai tap tap trung vao co cang tay',
  );

  static final List<MuscleGroup> muscleGroups = [
    muscleGroupChest,
    muscleGroupBack,
    muscleGroupShoulders,
    muscleGroupBiceps,
    muscleGroupLegs,
    muscleGroupAbs,
    muscleGroupForearms,
  ];

  static final List<GuideExercise> exercises = [
    // CHEST
    GuideExercise(
      id: 'bench_press',
      name: 'Bench Press',
      muscleGroupId: 'chest',
      description: 'Bai tap noi tieng de phat trien co nguc',
      steps: [
        '1. Nam tren ghe tap, mat huong len',
        '2. Tay cam ta ngang vai',
        '3. Day ta len tren dau',
        '4. Ha ta xuong kiem soat',
        '5. Lap lai',
      ],
      trainingSchedule: '3-4 ngay tuan, 3-4 sets x 6-8 reps',
      benefits: ['Phat trien co nguc', 'Tang suc manh', 'Cai thien do ben'],
      tips: ['Giu vai chuan', 'Kiem soat chuyen dong', 'Dam bao lung tiep xuc'],
      defaultSets: '3-4',
      defaultReps: '6-8',
    ),
    GuideExercise(
      id: 'incline_dumbbell',
      name: 'Incline Dumbbell Press',
      muscleGroupId: 'chest',
      description: 'Tap trung vao phan tren co nguc',
      steps: [
        '1. Dieu chinh ghe 45 do',
        '2. Nam voi ta o do cao vai',
        '3. Day ta len tren',
        '4. Ha ta ve phia hai ben',
        '5. Lap lai kiem soat',
      ],
      trainingSchedule: '2-3 ngay tuan, 3 sets x 8-10 reps',
      benefits: [
        'Phat trien phan tren nguc',
        'Tang co vai',
        'Cai thien can doi',
      ],
      tips: ['Giu ta cach nhau', 'Khong qua sau', 'Tap trung co lai'],
      defaultSets: '3',
      defaultReps: '8-10',
    ),
    GuideExercise(
      id: 'cable_fly',
      name: 'Cable Fly',
      muscleGroupId: 'chest',
      description: 'Bai tap isolation cho co nguc',
      steps: [
        '1. Dung giua cable',
        '2. Keo tay vao phia truoc',
        '3. Tao vi tri bay',
        '4. Mo rong tay tro lai',
        '5. Lap lai',
      ],
      trainingSchedule: '2-3 ngay tuan, 3 sets x 10-12 reps',
      benefits: ['Tang su co lai', 'Phat trien ket noi', 'Giam cang thang'],
      tips: ['Canh tay co chut uon', 'Tap trung co lai', 'Kiem soat tro lai'],
      defaultSets: '3',
      defaultReps: '10-12',
    ),
    // BACK
    GuideExercise(
      id: 'deadlift',
      name: 'Deadlift',
      muscleGroupId: 'back',
      description: 'Bai tap nang cao phat trien lung',
      steps: [
        '1. Chan rong ngang vai',
        '2. Cui xuong nam ta',
        '3. Lung thang nhin thang',
        '4. Keo ta len',
        '5. Ha ta kiem soat',
      ],
      trainingSchedule: '2 ngay tuan, 3-4 sets x 5-6 reps',
      benefits: [
        'Phat trien lung toan bo',
        'Tang suc manh',
        'Cai thien quy trinh',
      ],
      tips: ['Luon thang lung', 'Bat dau nhe', 'Tap trung ky thuat'],
      defaultSets: '3-4',
      defaultReps: '5-6',
    ),
    GuideExercise(
      id: 'lat_pulldown',
      name: 'Lat Pulldown',
      muscleGroupId: 'back',
      description: 'Bai tap phat trien lung rong',
      steps: [
        '1. Ngoi o may',
        '2. Nam xa rong',
        '3. Keo xuong',
        '4. Ngung lai',
        '5. Tra lai tu tu',
      ],
      trainingSchedule: '3-4 ngay tuan, 3-4 sets x 8-10 reps',
      benefits: ['Phat trien lung rong', 'Tang suc manh', 'Cai thien tu the'],
      tips: ['Khong keo qua cao', 'Giu hiep co', 'Khong dung tay keo'],
      defaultSets: '3-4',
      defaultReps: '8-10',
    ),
    GuideExercise(
      id: 'barbell_row',
      name: 'Barbell Row',
      muscleGroupId: 'back',
      description: 'Bai tap phat trien lung giua',
      steps: [
        '1. Dung chan rong',
        '2. Cui xuong nam ta',
        '3. Keo ta len',
        '4. Giu lung thang',
        '5. Ha xuong kiem soat',
      ],
      trainingSchedule: '2-3 ngay tuan, 3-4 sets x 6-8 reps',
      benefits: ['Phat trien lung giua', 'Tang suc manh', 'Cai thien tu the'],
      tips: ['Giu lung thang', 'Tranh qua nhieu chan', 'Tap trung lung'],
      defaultSets: '3-4',
      defaultReps: '6-8',
    ),
    // SHOULDERS
    GuideExercise(
      id: 'military_press',
      name: 'Military Press',
      muscleGroupId: 'shoulders',
      description: 'Bai tap co ban cho vai',
      steps: [
        '1. Dung thang',
        '2. Ta ngang vai',
        '3. Day ta len tren',
        '4. Tho ra len cao',
        '5. Ha xuong kiem soat',
      ],
      trainingSchedule: '3 ngay tuan, 3-4 sets x 6-8 reps',
      benefits: ['Phat trien vai', 'Tang suc manh', 'Cai thien on dinh'],
      tips: ['Tranh lui nhieu', 'Giu loi cang', 'Kiem soat chuyen dong'],
      defaultSets: '3-4',
      defaultReps: '6-8',
    ),
    GuideExercise(
      id: 'lateral_raise',
      name: 'Lateral Raise',
      muscleGroupId: 'shoulders',
      description: 'Bai tap isolation cho vai ngoai',
      steps: [
        '1. Dung thang',
        '2. Canh tay uon nhe',
        '3. Nam ta len hai ben',
        '4. Giu vi tri cao',
        '5. Ha xuong tu tu',
      ],
      trainingSchedule: '3-4 ngay tuan, 3 sets x 10-12 reps',
      benefits: ['Phat trien vai ngoai', 'Tao do rong', 'Cai thien hinh dang'],
      tips: ['Canh tay uon cong', 'Nam bang vai', 'Khong dung chan'],
      defaultSets: '3',
      defaultReps: '10-12',
    ),
    GuideExercise(
      id: 'rear_delt_fly',
      name: 'Rear Delt Fly',
      muscleGroupId: 'shoulders',
      description: 'Bai tap phat trien vai sau',
      steps: [
        '1. Cui nguoi 90 do',
        '2. Cam ta duoi nhe',
        '3. Nam len hai ben',
        '4. Ha xuong tu tu',
        '5. Lap lai',
      ],
      trainingSchedule: '3-4 ngay tuan, 3 sets x 10-12 reps',
      benefits: ['Phat trien vai sau', 'Can bang vai', 'Cai thien tu the'],
      tips: ['Canh tay uon cong', 'Cam nhan vai sau', 'Khong dung lung'],
      defaultSets: '3',
      defaultReps: '10-12',
    ),
    // BICEPS
    GuideExercise(
      id: 'barbell_curl',
      name: 'Barbell Curl',
      muscleGroupId: 'biceps',
      description: 'Bai tap co ban phat trien canh tay',
      steps: [
        '1. Dung thang',
        '2. Cam ta ngang vai',
        '3. Uon khuyu tay',
        '4. Giu cao 1 giay',
        '5. Ha xuong tu tu',
      ],
      trainingSchedule: '3-4 ngay tuan, 3-4 sets x 8-10 reps',
      benefits: ['Phat trien canh tay', 'Tang suc manh', 'Tao hinh dang'],
      tips: ['Giu khuyu tay gan than', 'Khong gat nguoi', 'Kiem soat luc ha'],
      defaultSets: '3-4',
      defaultReps: '8-10',
    ),
    GuideExercise(
      id: 'dumbbell_curl',
      name: 'Dumbbell Curl',
      muscleGroupId: 'biceps',
      description: 'Bai tap linh hoat cho canh tay',
      steps: [
        '1. Dung thang',
        '2. Cam ta o hai tay',
        '3. Canh tay duoi doc',
        '4. Uon nam ta',
        '5. Ha xuong kiem soat',
      ],
      trainingSchedule: '3-4 ngay tuan, 3 sets x 8-12 reps',
      benefits: [
        'Phat trien canh tay',
        'Pham vi chuyen dong lon',
        'Lam viec doc lap',
      ],
      tips: ['Co the xoay 45 do', 'Giu khuyu tay', 'Khong gat nguoi'],
      defaultSets: '3',
      defaultReps: '8-12',
    ),
    GuideExercise(
      id: 'hammer_curl',
      name: 'Hammer Curl',
      muscleGroupId: 'biceps',
      description: 'Bai tap cho phan ngoai canh tay',
      steps: [
        '1. Dung thang',
        '2. Cam ta nhu nam bua',
        '3. Uon khuyu tay',
        '4. Giu cao 1 giay',
        '5. Ha xuong tu tu',
      ],
      trainingSchedule: '3-4 ngay tuan, 3 sets x 10-12 reps',
      benefits: [
        'Phat trien co brachioradialis',
        'Tang kich thuoc',
        'Can bang canh tay',
      ],
      tips: ['Giu ban tay bua', 'Khong xoay ban tay', 'Kiem soat chuyen dong'],
      defaultSets: '3',
      defaultReps: '10-12',
    ),
    // LEGS
    GuideExercise(
      id: 'squat',
      name: 'Squat',
      muscleGroupId: 'legs',
      description: 'Bai tap nang cao phat trien chan',
      steps: [
        '1. Dung chan rong',
        '2. Ta sau vai',
        '3. Ha xuong cui',
        '4. Cui cho dui ngang',
        '5. Day len quay lai',
      ],
      trainingSchedule: '2-3 ngay tuan, 3-4 sets x 5-8 reps',
      benefits: ['Phat trien chan', 'Tang suc manh', 'Cai thien can bang'],
      tips: ['Giu lung thang', 'Dau goi khong vuot', 'Bat dau nhe'],
      defaultSets: '3-4',
      defaultReps: '5-8',
    ),
    GuideExercise(
      id: 'leg_press',
      name: 'Leg Press',
      muscleGroupId: 'legs',
      description: 'Bai tap an toan phat trien chan',
      steps: [
        '1. Ngoi o may',
        '2. Chan dat cach nhau',
        '3. Day san ngoai',
        '4. Ha san bang uon',
        '5. Lap lai kiem soat',
      ],
      trainingSchedule: '3-4 ngay tuan, 3-4 sets x 8-10 reps',
      benefits: ['Phat trien chan', 'An toan hon', 'Tai trong cao'],
      tips: ['Chan khong tron', 'Khong khoa goi', 'Lung tiep xuc ghe'],
      defaultSets: '3-4',
      defaultReps: '8-10',
    ),
    GuideExercise(
      id: 'leg_curl',
      name: 'Leg Curl',
      muscleGroupId: 'legs',
      description: 'Bai tap isolation cho dui sau',
      steps: [
        '1. Nam up o may',
        '2. Chan duoi pad',
        '3. Uon khuyu nam',
        '4. Giu vi tri cao',
        '5. Ha xuong tu tu',
      ],
      trainingSchedule: '3-4 ngay tuan, 3 sets x 10-12 reps',
      benefits: ['Phat trien dui sau', 'Can bang chan', 'Giam chan thuong'],
      tips: ['Khong nhac hong', 'Kiem soat ha', 'Cam nhan co lai'],
      defaultSets: '3',
      defaultReps: '10-12',
    ),
    // ABS
    GuideExercise(
      id: 'crunch',
      name: 'Crunch',
      muscleGroupId: 'abs',
      description: 'Bai tap co ban cho co bung',
      steps: [
        '1. Nam ngua',
        '2. Chan gap cach nhau',
        '3. Tay sau dau',
        '4. Cuon co the len',
        '5. Ha xuong kiem soat',
      ],
      trainingSchedule: 'Hang ngay, 3-4 sets x 12-15 reps',
      benefits: ['Phat trien bung', 'Tang suc manh loi', 'Cai thien tu the'],
      tips: ['Khong keo co', 'Cam nhan co lai', 'Kiem soat chuyen dong'],
      defaultSets: '3-4',
      defaultReps: '12-15',
    ),
    GuideExercise(
      id: 'plank',
      name: 'Plank',
      muscleGroupId: 'abs',
      description: 'Bai tap tinh phat trien loi',
      steps: [
        '1. Nam up tren san',
        '2. Ho tro khuyu tay',
        '3. Lung thang',
        '4. Giu tu the',
        '5. Tho binh thuong',
      ],
      trainingSchedule: 'Hang ngay, 3 sets x 30-60s',
      benefits: ['Phat trien loi', 'Cai thien tu the', 'Tang suc manh'],
      tips: ['Giu lung thang', 'Khong ha hong', 'Bat dau 20-30s'],
      defaultSets: '3',
      defaultReps: '30-60s',
    ),
    GuideExercise(
      id: 'leg_raise',
      name: 'Leg Raise',
      muscleGroupId: 'abs',
      description: 'Bai tap nang cao cho bung duoi',
      steps: [
        '1. Nam ngua',
        '2. Chan duoi thang',
        '3. Nam chan len 90 do',
        '4. Ha chan gan san',
        '5. Lap lai kiem soat',
      ],
      trainingSchedule: '3-4 ngay tuan, 3-4 sets x 10-12 reps',
      benefits: [
        'Phat trien bung duoi',
        'Tang suc manh loi',
        'Cai thien tu the',
      ],
      tips: ['Giu lung sat san', 'Khong gat nguoi', 'Kiem soat chuyen dong'],
      defaultSets: '3-4',
      defaultReps: '10-12',
    ),
    // FOREARMS
    GuideExercise(
      id: 'wrist_curl',
      name: 'Wrist Curl',
      muscleGroupId: 'forearms',
      description: 'Bai tap phat trien co cang tay',
      steps: [
        '1. Ngoi cam ta',
        '2. Ban tay quay len',
        '3. Ha ta xuong',
        '4. Nam ta len',
        '5. Lap lai kiem soat',
      ],
      trainingSchedule: '3-4 ngay tuan, 3 sets x 12-15 reps',
      benefits: ['Phat trien cang tay', 'Tang suc manh co', 'Cai thien grip'],
      tips: [
        'Giu canh tay yen',
        'Chi co tay chuyen dong',
        'Kiem soat chuyen dong',
      ],
      defaultSets: '3',
      defaultReps: '12-15',
    ),
    GuideExercise(
      id: 'reverse_wrist_curl',
      name: 'Reverse Wrist Curl',
      muscleGroupId: 'forearms',
      description: 'Bai tap phat trien phia sau cang tay',
      steps: [
        '1. Ngoi cam ta',
        '2. Ban tay quay xuong',
        '3. Nam ta len',
        '4. Ha ta xuong',
        '5. Lap lai kiem soat',
      ],
      trainingSchedule: '3-4 ngay tuan, 3 sets x 12-15 reps',
      benefits: ['Phat trien phia sau', 'Can bang co tay', 'Cai thien grip'],
      tips: ['Giu canh tay', 'Chi co tay chuyen dong', 'Kiem soat cam giac'],
      defaultSets: '3',
      defaultReps: '12-15',
    ),
    GuideExercise(
      id: 'farmer_carry',
      name: 'Farmer Carry',
      muscleGroupId: 'forearms',
      description: 'Bai tap phat trien grip strength',
      steps: [
        '1. Dung thang',
        '2. Cam ta nang',
        '3. Di bo voi ta',
        '4. Giu co loi cang',
        '5. Ha ta lai',
      ],
      trainingSchedule: '3-4 ngay tuan, 3 sets x 30-60m',
      benefits: ['Phat trien grip', 'Tang suc manh loi', 'Phat trien cang tay'],
      tips: ['Giu vai thap', 'Khong guc nguoi', 'Bat dau nhe'],
      defaultSets: '3',
      defaultReps: '30-60m',
    ),
  ];

  static MuscleGroup? getMuscleGroupById(String id) {
    try {
      return muscleGroups.firstWhere((mg) => mg.id == id);
    } catch (e) {
      return null;
    }
  }

  static List<GuideExercise> getExercisesByMuscleGroup(String muscleGroupId) {
    return exercises.where((e) => e.muscleGroupId == muscleGroupId).toList();
  }

  static GuideExercise? getExerciseById(String id) {
    try {
      return exercises.firstWhere((e) => e.id == id);
    } catch (e) {
      return null;
    }
  }
}
