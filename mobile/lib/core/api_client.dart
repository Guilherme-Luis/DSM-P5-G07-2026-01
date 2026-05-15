import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

class ApiClient {
  final String baseUrl;
  final Future<String?> Function()? tokenProvider;

  ApiClient({required this.baseUrl, this.tokenProvider});

  Future<Map<String, String>> _headers({bool json = true}) async {
    final headers = <String, String>{};
    if (json) headers['Content-Type'] = 'application/json';

    final token = tokenProvider == null ? null : await tokenProvider!.call();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  Future<dynamic> get(String path) async {
    final response = await http.get(
      Uri.parse('$baseUrl$path'),
      headers: await _headers(),
    );
    return _decodeResponse(response);
  }

  Future<dynamic> post(String path, {Map<String, dynamic>? body}) async {
    final response = await http.post(
      Uri.parse('$baseUrl$path'),
      headers: await _headers(),
      body: jsonEncode(body ?? {}),
    );
    return _decodeResponse(response);
  }

  Future<dynamic> postMultipart(String path, Map<String, String> fields, {File? file, String fileField = 'image'}) async {
    return multipartRequest('POST', path, fields, file: file, fileField: fileField);
  }

  Future<dynamic> multipartRequest(String method, String path, Map<String, String> fields, {File? file, String fileField = 'image'}) async {
    final uri = Uri.parse('$baseUrl$path');
    final request = http.MultipartRequest(method, uri);

    request.headers.addAll(await _headers(json: false));
    request.fields.addAll(fields);
    
    if (file != null) {
      final String? mimeType = lookupMimeType(file.path);
      final contentType = mimeType != null ? MediaType.parse(mimeType) : MediaType('image', 'jpeg');

      request.files.add(await http.MultipartFile.fromPath(
        fileField, 
        file.path,
        contentType: contentType,
      ));
    }
    
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    return _decodeResponse(response);
  }

  Future<dynamic> put(String path, {Map<String, dynamic>? body}) async {
    final response = await http.put(
      Uri.parse('$baseUrl$path'),
      headers: await _headers(),
      body: jsonEncode(body ?? {}),
    );
    return _decodeResponse(response);
  }

  Future<dynamic> patch(String path, {Map<String, dynamic>? body}) async {
    final response = await http.patch(
      Uri.parse('$baseUrl$path'),
      headers: await _headers(),
      body: body != null ? jsonEncode(body) : null,
    );
    return _decodeResponse(response);
  }

  Future<dynamic> delete(String path) async {
    final response = await http.delete(
      Uri.parse('$baseUrl$path'),
      headers: await _headers(),
    );
    return _decodeResponse(response);
  }

  dynamic _decodeResponse(http.Response response) {
    final String responseBody = response.body.trim();

    if (response.statusCode >= 500) {
       throw 'Erro interno do servidor (HTTP ${response.statusCode})';
    }

    try {
      final body = responseBody.isNotEmpty ? jsonDecode(responseBody) : null;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return body;
      }

      throw body is Map && body['message'] != null
          ? body['message']
          : 'Erro ${response.statusCode}: ${response.reasonPhrase}';
    } catch (e) {
      if (e is FormatException) throw 'Resposta inválida do servidor.';
      rethrow;
    }
  }
}
