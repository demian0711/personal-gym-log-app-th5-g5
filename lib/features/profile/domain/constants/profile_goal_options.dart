class ProfileGoalOptions {
  static const String fatLoss = 'Giảm mỡ';
  static const String muscleGain = 'Tăng cơ';
  static const String maintenance = 'Duy trì vóc dáng';
  static const String strengthGain = 'Tăng sức mạnh';

  static const List<String> labels = [
    fatLoss,
    muscleGain,
    maintenance,
    strengthGain,
  ];

  static const String defaultGoal = maintenance;

  static String normalize(String? rawGoal) {
    final value = (rawGoal ?? '').trim().toLowerCase();
    if (value.isEmpty) return defaultGoal;

    if (value == 'giảm mỡ' || value == 'giam mo' || value == 'fat loss') {
      return fatLoss;
    }

    if (value == 'tăng cơ' || value == 'tang co' || value == 'muscle gain') {
      return muscleGain;
    }

    if (value == 'duy trì' ||
        value == 'duy tri' ||
        value == 'duy trì vóc dáng' ||
        value == 'duy tri voc dang' ||
        value == 'maintenance') {
      return maintenance;
    }

    if (value == 'tăng sức mạnh' ||
        value == 'tang suc manh' ||
        value == 'strength gain') {
      return strengthGain;
    }

    return labels.firstWhere(
      (goal) => goal.toLowerCase() == value,
      orElse: () => defaultGoal,
    );
  }
}
