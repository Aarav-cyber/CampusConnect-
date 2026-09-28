import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../errors/failures.dart';
import '../storage/local_storage_service.dart';

class ApiClient {
  final http.Client _client;

  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  Future<Map<String, String>> _headers() async {
    final token = await LocalStorageService.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<dynamic> get(String endpoint, {Map<String, String>? queryParams}) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint').replace(
        queryParameters: queryParams,
      );
      final response = await _client.get(uri, headers: await _headers()).timeout(
            const Duration(seconds: 10),
          );
      return _processResponse(response);
    } on SocketException {
      throw const NetworkFailure();
    } on http.ClientException {
      throw const NetworkFailure();
    }
  }

  Future<dynamic> post(String endpoint, {Map<String, dynamic>? body}) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      final response = await _client
          .post(
            uri,
            headers: await _headers(),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(const Duration(seconds: 10));
      return _processResponse(response);
    } on SocketException {
      throw const NetworkFailure();
    } on http.ClientException {
      throw const NetworkFailure();
    }
  }

  Future<dynamic> put(String endpoint, {Map<String, dynamic>? body}) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      final response = await _client
          .put(
            uri,
            headers: await _headers(),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(const Duration(seconds: 10));
      return _processResponse(response);
    } on SocketException {
      throw const NetworkFailure();
    } on http.ClientException {
      throw const NetworkFailure();
    }
  }

  Future<dynamic> delete(String endpoint) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      final response = await _client
          .delete(uri, headers: await _headers())
          .timeout(const Duration(seconds: 10));
      return _processResponse(response);
    } on SocketException {
      throw const NetworkFailure();
    } on http.ClientException {
      throw const NetworkFailure();
    }
  }

  dynamic _processResponse(http.Response response) {
    dynamic body;
    try {
      body = jsonDecode(response.body);
    } catch (_) {
      body = response.body;
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    } else if (response.statusCode == 401) {
      throw const AuthFailure();
    } else {
      final errMsg = (body is Map && body['error'] != null)
          ? body['error'].toString()
          : 'Request failed with status code ${response.statusCode}';
      throw ServerFailure(message: errMsg, statusCode: response.statusCode);
    }
  }
}
