import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

// API service for HTTP requests
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String? _token;

  // Set authentication token
  void setToken(String? token) {
    _token = token;
  }

  // Get base URL
  String get baseUrl => Constants.baseUrl;

  // Get headers with authentication
  Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }

    return headers;
  }

  // GET request
  Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      print('API GET Request: $url'); // Debug log
      
      final response = await http.get(
        url,
        headers: _headers,
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout. Please check your internet connection.');
        },
      );

      print('API Response Status: ${response.statusCode}'); // Debug log
      return _handleResponse(response);
    } on http.ClientException catch (e) {
      print('Network Error: $e'); // Debug log
      throw Exception('Cannot connect to server. Please check:\n1. Backend server is running\n2. Your device and computer are on the same network\n3. IP address is correct: $baseUrl');
    } catch (e) {
      print('Error: $e'); // Debug log
      if (e.toString().contains('Failed host lookup') || 
          e.toString().contains('Network is unreachable')) {
        throw Exception('Cannot reach server at $baseUrl\nPlease check your network connection.');
      }
      throw Exception('Network error: $e');
    }
  }

  // POST request
  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      print('API POST Request: $url'); // Debug log
      print('API POST Body: $body'); // Debug log
      
      final response = await http.post(
        url,
        headers: _headers,
        body: jsonEncode(body),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout. Please check your internet connection.');
        },
      );

      print('API Response Status: ${response.statusCode}'); // Debug log
      print('API Response Body: ${response.body}'); // Debug log
      return _handleResponse(response);
    } on http.ClientException catch (e) {
      print('Network Error: $e'); // Debug log
      throw Exception('Cannot connect to server. Please check:\n1. Backend server is running\n2. Your device and computer are on the same network\n3. IP address is correct: $baseUrl');
    } catch (e) {
      print('Error: $e'); // Debug log
      if (e.toString().contains('Failed host lookup') || 
          e.toString().contains('Network is unreachable')) {
        throw Exception('Cannot reach server at $baseUrl\nPlease check your network connection.');
      }
      throw Exception('Network error: $e');
    }
  }

  // PATCH request
  Future<Map<String, dynamic>> patch(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      print('API PATCH Request: $url'); // Debug log
      
      final response = await http.patch(
        url,
        headers: _headers,
        body: jsonEncode(body),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout. Please check your internet connection.');
        },
      );

      print('API Response Status: ${response.statusCode}'); // Debug log
      return _handleResponse(response);
    } on http.ClientException catch (e) {
      print('Network Error: $e'); // Debug log
      throw Exception('Cannot connect to server. Please check:\\n1. Backend server is running\\n2. Your device and computer are on the same network\\n3. IP address is correct: $baseUrl');
    } catch (e) {
      print('Error: $e'); // Debug log
      if (e.toString().contains('Failed host lookup') || 
          e.toString().contains('Network is unreachable')) {
        throw Exception('Cannot reach server at $baseUrl\\nPlease check your network connection.');
      }
      throw Exception('Network error: $e');
    }
  }

  // DELETE request
  Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      print('API DELETE Request: $url'); // Debug log
      
      final response = await http.delete(
        url,
        headers: _headers,
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout. Please check your internet connection.');
        },
      );

      print('API Response Status: ${response.statusCode}'); // Debug log
      return _handleResponse(response);
    } on http.ClientException catch (e) {
      print('Network Error: $e'); // Debug log
      throw Exception('Cannot connect to server. Please check:\n1. Backend server is running\n2. Your device and computer are on the same network\n3. IP address is correct: $baseUrl');
    } catch (e) {
      print('Error: $e'); // Debug log
      if (e.toString().contains('Failed host lookup') || 
          e.toString().contains('Network is unreachable')) {
        throw Exception('Cannot reach server at $baseUrl\nPlease check your network connection.');
      }
      throw Exception('Network error: $e');
    }
  }

  // POST request with multipart/form-data (for file uploads)
  Future<Map<String, dynamic>> postMultipart(
    String endpoint,
    Map<String, String> fields,
    Map<String, String> files,
  ) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      print('API POST Multipart Request: $url'); // Debug log
      
      final request = http.MultipartRequest('POST', url);
      
      // Add authorization header if token exists
      if (_token != null) {
        request.headers['Authorization'] = 'Bearer $_token';
      }
      
      // Add text fields
      request.fields.addAll(fields);
      
      // Add files
      for (final entry in files.entries) {
        final file = await http.MultipartFile.fromPath(
          entry.key,
          entry.value,
        );
        request.files.add(file);
      }
      
      print('API Multipart Fields: ${request.fields}'); // Debug log
      print('API Multipart Files: ${request.files.map((f) => f.field)}'); // Debug log
      
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          throw Exception('Request timeout. Please check your internet connection.');
        },
      );
      
      final response = await http.Response.fromStream(streamedResponse);
      
      print('API Response Status: ${response.statusCode}'); // Debug log
      print('API Response Body: ${response.body}'); // Debug log
      
      return _handleResponse(response);
    } on http.ClientException catch (e) {
      print('Network Error: $e'); // Debug log
      throw Exception('Cannot connect to server. Please check:\n1. Backend server is running\n2. Your device and computer are on the same network\n3. IP address is correct: $baseUrl');
    } catch (e) {
      print('Error: $e'); // Debug log
      if (e.toString().contains('Failed host lookup') || 
          e.toString().contains('Network is unreachable')) {
        throw Exception('Cannot reach server at $baseUrl\nPlease check your network connection.');
      }
      throw Exception('Network error: $e');
    }
  }

  // Handle HTTP response
  Map<String, dynamic> _handleResponse(http.Response response) {
    final statusCode = response.statusCode;
    
    try {
      final responseBody = jsonDecode(response.body) as Map<String, dynamic>;

      if (statusCode >= 200 && statusCode < 300) {
        return responseBody;
      } else {
        final errorMessage = responseBody['message'] as String? ??
            'An error occurred. Please try again.';
        throw Exception(errorMessage);
      }
    } catch (e) {
      // If JSON parsing fails, return a generic error
      if (e is FormatException) {
        throw Exception('Invalid response from server. Status: $statusCode');
      }
      rethrow;
    }
  }
}
