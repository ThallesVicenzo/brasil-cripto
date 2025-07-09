import 'dart:convert';

class ErrorRequest {
  int? httpStatusCode;
  int? status;
  String? message;

  ErrorRequest({
    this.httpStatusCode,
    this.status,
    this.message,
  });

  String? get messageWithCode {
    if (httpStatusCode != null && message != null) {
      return '$message - $httpStatusCode';
    }
    return message;
  }

  bool isNull() {
    return httpStatusCode == null && status == null && message == null;
  }

  bool containsMessageError(String messageError) {
    messageError = messageError.trim().toLowerCase();
    return message?.trim().toLowerCase().contains(messageError) ?? false;
  }

  factory ErrorRequest.fromIdentifyError(Map<String, dynamic>? json) {
    try {
      if (json == null) {
        return ErrorRequest();
      }
      Map httpBody = {};

      final bodyText = json['http_body'].toString();
      if (bodyText.isNotEmpty) {
        httpBody = bodyText.isNotEmpty ? jsonDecode(bodyText) : {};
      }
      return ErrorRequest(
        httpStatusCode: json['http_status_code'],
        status: httpBody['status'],
        message: httpBody["message"].toString(),
      );
    } catch (e) {
      return ErrorRequest();
    }
  }

  factory ErrorRequest.fromGenericError(dynamic json) {
    if (json is! Map) {
      return ErrorRequest();
    } else {
      try {
        if (json.isEmpty) {
          return ErrorRequest();
        }
        final keyError =
            json.keys.where((key) => key.toString().startsWith('error_'));
        if (keyError.isNotEmpty) {
          return ErrorRequest.fromIdentifyError(json[keyError.first]);
        } else {
          return ErrorRequest();
        }
      } catch (e) {
        return ErrorRequest();
      }
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'http_status_code': httpStatusCode,
      'status': status,
      'message': message,
    };
  }

  @override
  String toString() {
    return 'ErrorResponse(httpStatusCode: $httpStatusCode, \n'
        'status: $status, \n'
        'message: $message) \n';
  }
}
