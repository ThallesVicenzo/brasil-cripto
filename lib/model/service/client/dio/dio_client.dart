import 'package:dio/dio.dart';

import '../../../../app_injector.dart';
import '../../../../l10n/global_app_localizations.dart';
import '../client_http.dart';
import '../client_http_exception.dart';
import '../client_http_request.dart';

class DioClient implements ClientHttp {
  late Dio _dio;

  Dio get dio => _dio;

  DioClient({BaseOptions? baseOptions}) {
    _dio = Dio(baseOptions);
    _dio.interceptors.addAll([
      LogInterceptor(requestBody: true, responseBody: true),
    ]);
  }

  Map<String, dynamic> _addDefaultQueryParameters(
    Map<String, dynamic>? queryParameters,
  ) {
    final defaultParams = {
      'vs_currency': sl<GlobalAppLocalizations>().current.currency,
    };

    if (queryParameters != null) {
      return {...defaultParams, ...queryParameters};
    }

    return defaultParams;
  }

  @override
  Future<ClientHttpRequest<T>> delete<T>(
    String path, {
    data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: _addDefaultQueryParameters(queryParameters),
        options: Options(headers: headers),
      );
      return _dioResponseConverter<T>(response);
    } on DioException catch (e) {
      throw ClientHttpException(
        path: path,
        error: e.response?.statusMessage,
        statusCode: e.response?.statusCode,
        message: e.response?.statusMessage,
        response: _dioErrorResponseConverter(e.response),
        queryParameters: queryParameters,
        requestData: data,
      );
    }
  }

  @override
  Future<ClientHttpRequest<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: _addDefaultQueryParameters(queryParameters),
        options: Options(headers: headers),
      );
      return _dioResponseConverter<T>(response);
    } on DioException catch (e) {
      throw ClientHttpException(
        path: path,
        error: e.response?.statusMessage,
        statusCode: e.response?.statusCode,
        message: e.response?.statusMessage,
        response: _dioErrorResponseConverter(e.response),
        queryParameters: queryParameters,
      );
    }
  }

  @override
  Future<ClientHttpRequest<T>> patch<T>(
    String path, {
    data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    try {
      final response = await _dio.patch(
        path,
        data: data,
        queryParameters: _addDefaultQueryParameters(queryParameters),
        options: Options(headers: headers),
      );
      return _dioResponseConverter<T>(response);
    } on DioException catch (e) {
      throw ClientHttpException(
        path: path,
        error: e.response?.statusMessage,
        statusCode: e.response?.statusCode,
        message: e.response?.statusMessage,
        response: _dioErrorResponseConverter(e.response),
        queryParameters: queryParameters,
        requestData: data,
      );
    }
  }

  @override
  Future<ClientHttpRequest<T>> post<T>(
    String path, {
    data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: _addDefaultQueryParameters(queryParameters),
        options: Options(headers: headers),
      );
      return _dioResponseConverter<T>(response);
    } on DioException catch (e) {
      throw ClientHttpException(
        path: path,
        error: e.response?.statusMessage,
        statusCode: e.response?.statusCode,
        message: e.response?.statusMessage,
        response: _dioErrorResponseConverter(e.response),
        queryParameters: queryParameters,
        requestData: data,
      );
    }
  }

  @override
  Future<ClientHttpRequest<T>> put<T>(
    String path, {
    data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: _addDefaultQueryParameters(queryParameters),
        options: Options(headers: headers),
      );
      return _dioResponseConverter<T>(response);
    } on DioException catch (e) {
      throw ClientHttpException(
        path: path,
        error: e.response?.statusMessage,
        statusCode: e.response?.statusCode,
        message: e.response?.statusMessage,
        response: _dioErrorResponseConverter(e.response),
        queryParameters: queryParameters,
        requestData: data,
      );
    }
  }

  @override
  Future<ClientHttpRequest<T>> request<T>(
    String path, {
    data,
    required String method,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    try {
      final response = await _dio.request(
        path,
        data: data,
        queryParameters: _addDefaultQueryParameters(queryParameters),
        options: Options(headers: headers, method: method),
      );
      return _dioResponseConverter<T>(response);
    } on DioException catch (e) {
      throw ClientHttpException(
        path: path,
        error: e.response?.statusMessage,
        statusCode: e.response?.statusCode,
        message: e.response?.statusMessage,
        response: _dioErrorResponseConverter(e.response),
        queryParameters: queryParameters,
        requestData: data,
      );
    }
  }

  ClientHttpRequest? _dioErrorResponseConverter(Response? response) {
    return ClientHttpRequest(
      data: response?.data,
      statusCode: response?.statusCode,
      statusMessage: response?.statusMessage,
    );
  }

  ClientHttpRequest<T> _dioResponseConverter<T>(Response response) {
    return ClientHttpRequest<T>(
      data: response.data,
      statusCode: response.statusCode,
      statusMessage: response.statusMessage,
    );
  }
}
