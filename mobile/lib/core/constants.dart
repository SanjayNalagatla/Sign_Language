class AppConstants {
  // Use 10.0.2.2 for Android emulator to access localhost, or actual IP for physical device
  static const String apiBaseUrl = 'http://10.0.2.2:8000/api/v1';
  
  static const String recognizeFrameEndpoint = '/recognize/frame';
  static const String textToSignEndpoint = '/text-to-sign';
}
