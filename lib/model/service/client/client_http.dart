import 'client_http_request.dart';

abstract class ClientHttp {
  Future<ClientHttpRequest<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  });

  Future<ClientHttpRequest<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  });

  Future<ClientHttpRequest<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  });

  Future<ClientHttpRequest<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  });

  Future<ClientHttpRequest<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  });

  Future<ClientHttpRequest<T>> request<T>(
    String path, {
    dynamic data,
    required String method,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  });
}
