class MediaConstraints {
  static const List<String> supportedImageFormats = [
    'image/jpeg',
    'image/png',
    'image/webp',
  ];

  static const List<String> supportedVideoFormats = [
    'video/mp4',
    'video/webm',
    'video/quicktime', // for iOS camera
  ];

  static const int maxImageSizeInBytes = 5 * 1024 * 1024; // 5MB
  static const int maxVideoSizeInBytes = 50 * 1024 * 1024; // 50MB
}
