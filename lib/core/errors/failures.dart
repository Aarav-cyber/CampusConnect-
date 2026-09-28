class Failure {
  final String message;
  final int? statusCode;

  const Failure({required this.message, this.statusCode});

  @override
  String toString() => message;
}

class NetworkFailure extends Failure {
  const NetworkFailure({super.message = 'Unable to connect to CampusConnect network. Check your internet connection.'});
}

class ServerFailure extends Failure {
  const ServerFailure({super.message = 'Server encountered an issue. Please try again later.', super.statusCode});
}

class AuthFailure extends Failure {
  const AuthFailure({super.message = 'Invalid credentials or session expired. Please sign in again.'});
}
