import 'package:brasil_cripto/model/service/client/errors/failure.dart';

class GenericFailure extends Failure {
  const GenericFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure([String? message]) : super(message ?? 'Network error');
}

class RateLimitFailure extends Failure {
  final bool hasUpgradeMessage;

  const RateLimitFailure([String? message, this.hasUpgradeMessage = false])
    : super(message ?? 'Rate limit exceeded');
}
