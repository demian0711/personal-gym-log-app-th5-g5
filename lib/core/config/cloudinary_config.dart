class CloudinaryConfig {
  static const String cloudName = String.fromEnvironment(
    'CLOUDINARY_CLOUD_NAME',
    defaultValue: 'dpd3z6ulx',
  );

  static const String uploadPreset = String.fromEnvironment(
    'CLOUDINARY_UPLOAD_PRESET',
    defaultValue: 'gym_progress_unsigned',
  );

  static const String assetFolder = String.fromEnvironment(
    'CLOUDINARY_ASSET_FOLDER',
    defaultValue: 'personal-gym-log/progress-photos',
  );
}
