import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ApiInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint('REQUEST[${options.method}] => PATH: ${options.path}');
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint('RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint('ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}');
    
    String errorMsg = 'Something went wrong';
    if (err.type == DioExceptionType.connectionTimeout || 
        err.type == DioExceptionType.receiveTimeout) {
      errorMsg = 'Connection timed out. Please check your internet connection.';
    } else if (err.type == DioExceptionType.badResponse) {
      if (err.response?.statusCode == 401) {
        errorMsg = 'Unauthorized. Please check your API Key.';
      } else if (err.response?.statusCode == 404) {
        errorMsg = 'Resource not found.';
      } else {
        errorMsg = 'Server error: ${err.response?.statusCode}';
      }
    } else if (err.type == DioExceptionType.connectionError) {
      errorMsg = 'No internet connection.';
    }

    // Log the user-friendly error message
    debugPrint('Detailed Error: $errorMsg');
    
    super.onError(err, handler);
  }
}
