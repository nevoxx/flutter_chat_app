import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../models/server_info.dart';
import '../models/user.dart';
import '../models/connected_user.dart';
import '../models/message.dart';
import '../models/join_voice_dto.dart';
import './storage_service.dart';

// Provider for ApiService
final apiServiceProvider = Provider<ApiService>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return ApiService(storage);
});

class ApiService {
  final StorageService _storage;

  ApiService(this._storage);

  Future<String> _getBaseUrl() async {
    final url = await _storage.getServerUrl();
    if (url == null) {
      throw Exception('No server URL configured');
    }
    return url;
  }

  Future<String?> _getToken() async {
    return await _storage.getAccessToken();
  }

  Map<String, String> _getHeaders(String? token) {
    final headers = {'Content-Type': 'application/json'};

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  Future<ServerInfo> fetchServerInfo() async {
    final baseUrl = await _getBaseUrl();
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

  Future<List<ConnectedUser>> fetchUsers() async {
    final baseUrl = await _getBaseUrl();
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
          .map(
            (item) => ConnectedUser.fromJson(item as Map<String, dynamic>),
          )
          .toList();
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized - Invalid or expired token');
    } else {
      throw Exception('Failed to fetch users: ${response.statusCode}');
    }
  }

  Future<List<Message>> fetchMessages(String channelId) async {
    final baseUrl = await _getBaseUrl();
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

  Future<User> fetchCurrentUser() async {
    final baseUrl = await _getBaseUrl();
    final token = await _getToken();

    if (token == null) {
      throw Exception('No access token found');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/auth/me'),
      headers: _getHeaders(token),
    );

    if (response.statusCode == 200) {
      try {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return User.fromJson(data);
      } catch (e) {
        // Log the response body for debugging
        throw Exception(
          'Failed to parse user data: $e\nResponse body: ${response.body}',
        );
      }
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized - Invalid or expired token');
    } else {
      throw Exception(
        'Failed to fetch current user: ${response.statusCode}\nResponse: ${response.body}',
      );
    }
  }

  Future<JoinVoiceDto> joinVoice(String channelId) async {
    final baseUrl = await _getBaseUrl();
    final token = await _getToken();

    if (token == null) {
      throw Exception('No access token found');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/channels/$channelId/join-voice'),
      headers: _getHeaders(token),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return JoinVoiceDto.fromJson(data);
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized - Invalid or expired token');
    } else {
      throw Exception('Failed to join voice: ${response.statusCode}');
    }
  }

  Future<void> leaveVoice() async {
    final baseUrl = await _getBaseUrl();
    final token = await _getToken();

    if (token == null) {
      throw Exception('No access token found');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/leave-voice'),
      headers: _getHeaders(token),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      if (response.statusCode == 401) {
        throw Exception('Unauthorized - Invalid or expired token');
      } else {
        throw Exception('Failed to leave voice: ${response.statusCode}');
      }
    }
  }
}
