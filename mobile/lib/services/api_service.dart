import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants.dart';

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

class ApiService {
  final Dio _dio;

  ApiService() : _dio = Dio(BaseOptions(baseUrl: AppConstants.apiBaseUrl, connectTimeout: const Duration(seconds: 5), receiveTimeout: const Duration(seconds: 5)));

  Future<Map<String, dynamic>?> recognizeFrame(String base64Image) async {
    try {
      final response = await _dio.post(
        AppConstants.recognizeFrameEndpoint,
        data: {'image_base64': base64Image},
      );
      if (response.statusCode == 200) {
        return response.data;
      }
    } catch (e) {
      print('API Error: $e');
      // Return null or throw exception based on error handling strategy
    }
    return null;
  }

  Future<List<dynamic>> textToSign(String text) async {
    try {
      final response = await _dio.post(
        AppConstants.textToSignEndpoint,
        queryParameters: {'text': text},
      );
      if (response.statusCode == 200) {
        return response.data['sequence'] ?? [];
      }
    } catch (e) {
      print('API Error: $e');
    }
    return [];
  }
}
