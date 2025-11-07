import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../models/server_info.dart';
import '../models/user.dart';
import '../models/message.dart';

class ApiService {
  static const String baseUrl = 'https://api.blubber.me';
  final _storage = const FlutterSecureStorage();

  Future<String?> _getToken() async {
    return await _storage.read(key: 'accessToken');
  }

  Map<String, String> _getHeaders(String? token) {
    final headers = {
      'Content-Type': 'application/json',
    };
    
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    
    return headers;
  }

  Future<ServerInfo> fetchServerInfo() async {
    final token = await _getToken();
    
    if (token == null) {
      throw Exception('No access token found');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/serverinfo'),
      headers: _getHeaders(token),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return ServerInfo.fromJson(data);
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized - Invalid or expired token');
    } else {
      throw Exception('Failed to fetch server info: ${response.statusCode}');
    }
  }

  Future<List<User>> fetchUsers() async {
    final token = await _getToken();
    
    if (token == null) {
      throw Exception('No access token found');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/users'),
      headers: _getHeaders(token),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List<dynamic>;
      return data
          .map((item) => User.fromJson(item as Map<String, dynamic>))
          .toList();
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized - Invalid or expired token');
    } else {
      throw Exception('Failed to fetch users: ${response.statusCode}');
    }
  }

  Future<List<Message>> fetchMessages(String channelId) async {
    final token = await _getToken();
    
    if (token == null) {
      throw Exception('No access token found');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/channels/$channelId/messages/'),
      headers: _getHeaders(token),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List<dynamic>;
      return data
          .map((item) => Message.fromJson(item as Map<String, dynamic>))
          .toList();
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized - Invalid or expired token');
    } else {
      throw Exception('Failed to fetch messages: ${response.statusCode}');
    }
  }
}

