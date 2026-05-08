class AppValues {
  static const String appVersion = '1.0.0';
  static const String appName = 'MHD Cooperation';

  // API Endpoints
  static const String apiVersion = '/api';

  // Pagination
  static const int defaultPageSize = 10;
  static const int maxPageSize = 50;

  // Timeouts (milliseconds)
  static const int defaultTimeout = 30000;
  static const int uploadTimeout = 120000;

  // Cache Duration (seconds)
  static const int shortCacheDuration = 300; // 5 minutes
  static const int mediumCacheDuration = 1800; // 30 minutes
  static const int longCacheDuration = 86400; // 24 hours

  // Image Sizes
  static const double thumbnailSize = 100;
  static const double smallImageSize = 200;
  static const double mediumImageSize = 400;
  static const double largeImageSize = 800;

  // Spacing
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingExtraLarge = 32.0;

  // Border Radius
  static const double radiusSmall = 4.0;
  static const double radiusMedium = 8.0;
  static const double radiusLarge = 12.0;
  static const double radiusExtraLarge = 16.0;

  // Icon Sizes
  static const double iconSizeSmall = 16.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;
  static const double iconSizeExtraLarge = 48.0;

  // Animation Durations (milliseconds)
  static const int animationDurationShort = 200;
  static const int animationDurationMedium = 300;
  static const int animationDurationLong = 500;

  // Max Lengths
  static const int maxCommentLength = 500;
  static const int maxTestimonyLength = 1000;
  static const int maxChurchNameLength = 100;
  static const int maxDescriptionLength = 500;

  // Storage Keys
  static const String keyToken = 'auth_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyUserId = 'user_id';
  static const String keyCurrentChurch = 'current_church';
  static const String keyCurrentUser = 'current_user';
  static const String keyLanguage = 'language';
  static const String keyThemeMode = 'theme_mode';
  static const String keyCachePrefix = 'cache.';
}
