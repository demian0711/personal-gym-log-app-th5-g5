import '../models/workout_guide.dart';

class WorkoutGuideService {
  static MuscleGroup muscleGroupChest = MuscleGroup(
    id: 'chest',
    name: 'Chest',
    imagePath: 'assets/images/chest.png',
    description: 'Exercises focused on building a strong chest.',
  );

  static MuscleGroup muscleGroupBack = MuscleGroup(
    id: 'back',
    name: 'Back',
    imagePath: 'assets/images/back.png',
    description: 'Exercises focused on back width and thickness.',
  );

  static MuscleGroup muscleGroupShoulders = MuscleGroup(
    id: 'shoulders',
    name: 'Shoulders',
    imagePath: 'assets/images/shoulders.png',
    description: 'Exercises focused on the deltoids.',
  );

  static MuscleGroup muscleGroupBiceps = MuscleGroup(
    id: 'biceps',
    name: 'Biceps',
    imagePath: 'assets/images/biceps.png',
    description: 'Exercises focused on the biceps and arm strength.',
  );

  static MuscleGroup muscleGroupLegs = MuscleGroup(
    id: 'legs',
    name: 'Legs',
    imagePath: 'assets/images/legs.png',
    description: 'Exercises focused on quads, hamstrings, and calves.',
  );

  static MuscleGroup muscleGroupAbs = MuscleGroup(
    id: 'abs',
    name: 'Abs',
    imagePath: 'assets/images/abs.png',
    description: 'Exercises focused on the core and abdominal muscles.',
  );

  static MuscleGroup muscleGroupForearms = MuscleGroup(
    id: 'forearms',
    name: 'Forearms',
    imagePath: 'assets/images/forearms.png',
    description: 'Exercises focused on the forearm and grip strength.',
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
      description: 'Famous exercise for developing chest muscles',
      steps: [
        '1. Lie on a flat bench, face up',
        '2. Grip the barbell shoulder-width apart',
        '3. Unrack and lower to mid-chest',
        '4. Press upward to lockout',
        '5. Repeat',
      ],
      trainingSchedule: '3-4 days/week, 3-4 sets x 6-8 reps',
      benefits: ['Chest development', 'Increased strength', 'Upper body power'],
      tips: [
        'Keep shoulder blades pinned',
        'Control the bar',
        'Avoid bouncing',
      ],
      defaultSets: '3-4',
      defaultReps: '6-8',
      videoId: 'rT7DgVIA-7Y',
    ),
    GuideExercise(
      id: 'incline_dumbbell',
      name: 'Incline Dumbbell Press',
      muscleGroupId: 'chest',
      description: 'Focuses on the upper chest muscles',
      steps: [
        '1. Set bench to 45 degrees',
        '2. Sit with dumbbells at shoulder height',
        '3. Press weights straight up',
        '4. Lower to sides of chest',
        '5. Repeat with control',
      ],
      trainingSchedule: '2-3 days/week, 3 sets x 8-10 reps',
      benefits: [
        'Upper chest growth',
        'Shoulder engagement',
        'Improved muscle symmetry',
      ],
      tips: [
        'Keep dumbbells separated',
        'Don\'t go too deep',
        'Focus on contraction',
      ],
      defaultSets: '3',
      defaultReps: '8-10',
    ),
    GuideExercise(
      id: 'cable_fly',
      name: 'Cable Fly',
      muscleGroupId: 'chest',
      description: 'Isolation exercise for chest definition',
      steps: [
        '1. Stand between cable pulleys',
        '2. Bring handles forward in a hugging motion',
        '3. Squeeze at the peak',
        '4. Slowly open arms back out',
        '5. Repeat',
      ],
      trainingSchedule: '2-3 days/week, 3 sets x 10-12 reps',
      benefits: [
        'Maximum contraction',
        'Mind-muscle connection',
        'Minimal joint strain',
      ],
      tips: ['Slight elbow bend', 'Focus on the squeeze', 'Control the return'],
      defaultSets: '3',
      defaultReps: '10-12',
    ),
    // BACK
    GuideExercise(
      id: 'deadlift',
      name: 'Deadlift',
      muscleGroupId: 'back',
      description: 'Advanced compound movement for back development',
      steps: [
        '1. Feet shoulder-width apart',
        '2. Bend to grip the bar',
        '3. Flat back, look forward',
        '4. Pull bar up to hips',
        '5. Lower with control',
      ],
      trainingSchedule: '2 days/week, 3-4 sets x 5-6 reps',
      benefits: [
        'Full back development',
        'Total body strength',
        'Improved grip',
      ],
      tips: ['Always keep back straight', 'Start light', 'Technical focus'],
      defaultSets: '3-4',
      defaultReps: '5-6',
    ),
    GuideExercise(
      id: 'lat_pulldown',
      name: 'Lat Pulldown',
      muscleGroupId: 'back',
      description: 'Builds width in the lats',
      steps: [
        '1. Sit at the machine',
        '2. Wide overhand grip',
        '3. Pull bar down to upper chest',
        '4. Pause momentarily',
        '5. Slowly return up',
      ],
      trainingSchedule: '3-4 days/week, 3-4 sets x 8-10 reps',
      benefits: ['Wider back', 'Arm strength', 'Better posture'],
      tips: [
        'Don\'t lean too far back',
        'Full range of motion',
        'Don\'t use momentum',
      ],
      defaultSets: '3-4',
      defaultReps: '8-10',
    ),
    GuideExercise(
      id: 'barbell_row',
      name: 'Barbell Row',
      muscleGroupId: 'back',
      description: 'Builds thickness in middle back',
      steps: [
        '1. Bend at hips, keep wide stance',
        '2. Grip barbell overhand',
        '3. Pull bar to mid-stomach',
        '4. Keep back flat',
        '5. Lower with control',
      ],
      trainingSchedule: '2-3 days/week, 3-4 sets x 6-8 reps',
      benefits: [
        'Middle back thickness',
        'Better grip',
        'Lower back stability',
      ],
      tips: ['Back must stay flat', 'Avoid jerking', 'Focus on lats'],
      defaultSets: '3-4',
      defaultReps: '6-8',
    ),
    // SHOULDERS
    GuideExercise(
      id: 'military_press',
      name: 'Military Press',
      muscleGroupId: 'shoulders',
      description: 'Fundamental press for shoulder size',
      steps: [
        '1. Stand tall',
        '2. Bar at shoulder height',
        '3. Press bar straight up',
        '4. Exhale as you push',
        '5. Lower with control',
      ],
      trainingSchedule: '3 days/week, 3-4 sets x 6-8 reps',
      benefits: [
        'Deltoid development',
        'Shoulder stability',
        'Pressing strength',
      ],
      tips: [
        'Avoid excessive back lean',
        'Full lockout',
        'Control the movement',
      ],
      defaultSets: '3-4',
      defaultReps: '6-8',
    ),
    GuideExercise(
      id: 'lateral_raise',
      name: 'Lateral Raise',
      muscleGroupId: 'shoulders',
      description: 'Isolation for side delts',
      steps: [
        '1. Stand upright',
        '2. Slight elbow bend',
        '3. Raise dumbbells out to sides',
        '4. Hold at the top',
        '5. Lower slowly',
      ],
      trainingSchedule: '3-4 days/week, 3 sets x 10-12 reps',
      benefits: ['Side delt growth', 'V-taper look', 'Shoulder aesthetics'],
      tips: ['Lead with elbows', 'Shoulder height maximum', 'Don\'t swing'],
      defaultSets: '3',
      defaultReps: '10-12',
    ),
    GuideExercise(
      id: 'rear_delt_fly',
      name: 'Rear Delt Fly',
      muscleGroupId: 'shoulders',
      description: 'Builds the back of the shoulder',
      steps: [
        '1. Bend over at 90 degrees',
        '2. Slight elbow bend',
        '3. Raise weights out to sides',
        '4. Lower slowly',
        '5. Repeat',
      ],
      trainingSchedule: '3-4 days/week, 3 sets x 10-12 reps',
      benefits: [
        'Rear delt development',
        'Shoulder health',
        'Postural support',
      ],
      tips: ['Keep elbows bent', 'Feel the rear delts', 'Don\'t use your back'],
      defaultSets: '3',
      defaultReps: '10-12',
    ),
    GuideExercise(
      id: 'overhead_press',
      name: 'Overhead Press',
      muscleGroupId: 'shoulders',
      description: 'Vertical pressing movement for overall shoulder mass',
      steps: [
        '1. Standing or seated with back support',
        '2. Grip barbell or dumbbells at shoulder height',
        '3. Press directly upward until arms are locked',
        '4. Lower back to start with control',
        '5. Breathe out on press, in on return',
      ],
      trainingSchedule: '2-3 days/week, 3-4 sets x 8-10 reps',
      benefits: [
        'Shoulder muscle growth',
        'Triceps engagement',
        'Core stability improvement',
      ],
      tips: [
        'Don\'t arch your back excessively',
        'Keep core tight',
        'Full range of motion',
      ],
      defaultSets: '3-4',
      defaultReps: '8-10',
    ),
    // BICEPS
    GuideExercise(
      id: 'barbell_curl',
      name: 'Barbell Curl',
      muscleGroupId: 'biceps',
      description: 'Core exercise for arm size',
      steps: [
        '1. Stand tall',
        '2. Shoulder-width grip',
        '3. Curl bar to shoulders',
        '4. Squeeze for 1 second',
        '5. Lower slowly',
      ],
      trainingSchedule: '3-4 days/week, 3-4 sets x 8-10 reps',
      benefits: ['Bicep peak', 'Grip strength', 'Better curls'],
      tips: ['Keep elbows at sides', 'Don\'t rock body', 'Full stretch'],
      defaultSets: '3-4',
      defaultReps: '8-10',
    ),
    GuideExercise(
      id: 'bicep_curl',
      name: 'Dumbbell Bicep Curl',
      muscleGroupId: 'biceps',
      description: 'Classic arm isolation movement for peak development',
      steps: [
        '1. Stand with feet shoulder-width apart',
        '2. Hold dumbbells with palms facing forward',
        '3. Curl weights toward shoulders, keeping elbows fixed',
        '4. Squeeze biceps at the top',
        '5. Lower slowly to full extension',
      ],
      trainingSchedule: '3-4 days/week, 3 sets x 10-12 reps',
      benefits: [
        'Bicep hypertrophy',
        'Improved arm definition',
        'Grip and forearm strength',
      ],
      tips: [
        'Avoid using momentum',
        'Control the eccentric phase',
        'Full range of motion',
      ],
      defaultSets: '3',
      defaultReps: '10-12',
    ),
    GuideExercise(
      id: 'dumbbell_curl',
      name: 'Dumbbell Curl',
      muscleGroupId: 'biceps',
      description: 'Versatile arm isolation',
      steps: [
        '1. Stand tall',
        '2. Dumbbells in each hand',
        '3. Arms hanging down',
        '4. Curl weights up',
        '5. Lower with control',
      ],
      trainingSchedule: '3-4 days/week, 3 sets x 8-12 reps',
      benefits: [
        'Individual arm work',
        'Longer range of motion',
        'Better shape',
      ],
      tips: ['Can rotate wrists', 'Elbows still', 'No momentum'],
      defaultSets: '3',
      defaultReps: '8-12',
    ),
    GuideExercise(
      id: 'hammer_curl',
      name: 'Hammer Curl',
      muscleGroupId: 'biceps',
      description: 'Builds thickness in arms',
      steps: [
        '1. Stand tall',
        '2. Neutral grip (like a hammer)',
        '3. Curl weights up',
        '4. Pause at top',
        '5. Lower slowly',
      ],
      trainingSchedule: '3-4 days/week, 3 sets x 10-12 reps',
      benefits: ['Brachialis development', 'Forearm strength', 'Thicker arms'],
      tips: ['Keep hammer grip', 'No wrist rotation', 'Control the drop'],
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
      description: 'Isolation exercise targeting hamstrings',
      steps: [
        '1. Lie face down on machine',
        '2. Place heels under padded lever',
        '3. Curl legs toward glutes',
        '4. Hold contraction for 1 second',
        '5. Lower slowly to start',
      ],
      trainingSchedule: '3-4 days/week, 3 sets x 10-12 reps',
      benefits: ['Hamstring growth', 'Improved knee health', 'Leg balance'],
      tips: [
        'Don\'t lift hips',
        'Control the descent',
        'Feel the hamstring stretch',
      ],
      defaultSets: '3',
      defaultReps: '10-12',
    ),
    GuideExercise(
      id: 'calf_raise',
      name: 'Calf Raise',
      muscleGroupId: 'legs',
      description: 'Primary exercise for developing calf muscles',
      steps: [
        '1. Standing or seated on platform',
        '2. Balls of feet on edge',
        '3. Raise heels as high as possible',
        '4. Squeeze at the top',
        '5. Lower heels below platform level',
      ],
      trainingSchedule: '3-4 days/week, 3-4 sets x 15-20 reps',
      benefits: [
        'Stronger calves',
        'Improved ankle stability',
        'Better explosive power',
      ],
      tips: [
        'Full range of motion',
        'Control the bottom stretch',
        'High reps were better for calves',
      ],
      defaultSets: '3-4',
      defaultReps: '15-20',
    ),
    // ABS
    GuideExercise(
      id: 'crunch',
      name: 'Crunch',
      muscleGroupId: 'abs',
      description: 'Classic abdominal isolation',
      steps: [
        '1. Lie on back with knees bent',
        '2. Hands behind head or on chest',
        '3. Lift upper back off floor toward knees',
        '4. Exhale and squeeze abs',
        '5. Lower under control',
      ],
      trainingSchedule: 'Every other day, 3-4 sets x 12-15 reps',
      benefits: ['Abdominal definition', 'Core strength', 'Improved posture'],
      tips: [
        'Don\'t pull on neck',
        'Focus on abdominal contraction',
        'Keep feet flat',
      ],
      defaultSets: '3-4',
      defaultReps: '12-15',
    ),
    GuideExercise(
      id: 'plank',
      name: 'Plank',
      muscleGroupId: 'abs',
      description: 'Isometric move for core stability',
      steps: [
        '1. Face down on floor',
        '2. Prop body on forearms and toes',
        '3. Keep back flat and core tight',
        '4. Hold position steady',
        '5. Breathe normally',
      ],
      trainingSchedule: 'Every other day, 3 sets x 30-60 secs',
      benefits: ['Core strength', 'Improved posture', 'Full body tension'],
      tips: [
        'Don\'t sag your hips',
        'Keep back flat like a table',
        'Squeeze your glutes',
      ],
      defaultSets: '3',
      defaultReps: '30-60s',
    ),
    GuideExercise(
      id: 'leg_raise',
      name: 'Leg Raise',
      muscleGroupId: 'abs',
      description: 'Advanced move for lower abs',
      steps: [
        '1. Lie on back, legs straight',
        '2. Raise legs to 90 degrees',
        '3. Lower slowly until near floor',
        '4. Keep lower back flat',
        '5. Lift back up and repeat',
      ],
      trainingSchedule: '2-3 days/week, 3 sets x 10-12 reps',
      benefits: ['Lower ab focus', 'Hip flexor strength', 'Core control'],
      tips: [
        'Don\'t arch lower back',
        'Keep legs straight',
        'Control the speed',
      ],
      defaultSets: '3',
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

  static GuideExercise? findExerciseByQr(String rawValue) {
    final normalized = rawValue.trim().toLowerCase();
    if (normalized.isEmpty) {
      return null;
    }

    final candidates = <String>{normalized};

    final uri = Uri.tryParse(normalized);
    if (uri != null) {
      final byQuery =
          uri.queryParameters['exercise'] ?? uri.queryParameters['id'];
      if (byQuery != null && byQuery.trim().isNotEmpty) {
        candidates.add(byQuery.trim().toLowerCase());
      }

      final pathSegments = uri.pathSegments;
      if (pathSegments.isNotEmpty) {
        final last = pathSegments.last.trim().toLowerCase();
        if (last.isNotEmpty) {
          candidates.add(last);
        }
      }

      if (uri.host.trim().isNotEmpty) {
        candidates.add(uri.host.trim().toLowerCase());
      }
    }

    final prefixes = [
      'exercise:',
      'exercise/',
      'workout:',
      'workout/',
      'gym://exercise/',
      'gym://workout/',
      'qr:',
    ];

    for (final base in List<String>.from(candidates)) {
      for (final prefix in prefixes) {
        if (base.startsWith(prefix)) {
          final stripped = base.substring(prefix.length).trim();
          if (stripped.isNotEmpty) {
            candidates.add(stripped);
          }
        }
      }
    }

    final expandedCandidates = <String>{};
    for (final candidate in candidates) {
      final value = Uri.decodeComponent(candidate).trim().toLowerCase();
      if (value.isEmpty) {
        continue;
      }
      expandedCandidates.add(value);
      expandedCandidates.add(value.replaceAll(RegExp(r'\s+'), '_'));
      expandedCandidates.add(value.replaceAll('-', '_'));
    }

    for (final exercise in exercises) {
      final byName = exercise.name.toLowerCase().replaceAll(
        RegExp(r'\s+'),
        '_',
      );
      if (expandedCandidates.contains(exercise.id.toLowerCase()) ||
          expandedCandidates.contains(exercise.name.toLowerCase()) ||
          expandedCandidates.contains(byName)) {
        return exercise;
      }
    }

    return null;
  }

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
