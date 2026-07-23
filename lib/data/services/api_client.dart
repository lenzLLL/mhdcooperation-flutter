import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

/// Appelle l'API MhD (Next.js) en s'authentifiant avec le jeton Firebase de
/// l'utilisateur courant. Le mobile n'écrit plus dans Firestore : le serveur
/// est seul à décider des montants et des statuts.
class ApiClient {
  String get _baseUrl => dotenv.env['MHD_API_BASE_URL'] ?? '';

  Future<Map<String, String>> _headers() async {
    final token = await FirebaseAuth.instance.currentUser?.getIdToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> post(String path, Map<String, dynamic> body) async {
    final res = await http.post(
      Uri.parse('$_baseUrl$path'),
      headers: await _headers(),
      body: jsonEncode(body),
    );
    final decoded = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode >= 400) {
      // L'API relaie le message de K-Pay : le remonter tel quel, sinon
      // l'utilisateur ne sait pas quoi corriger.
      throw ApiException(decoded['error']?.toString() ?? 'Une erreur est survenue.');
    }
    return decoded;
  }

  Future<Map<String, dynamic>> get(String path) async {
    final res = await http.get(Uri.parse('$_baseUrl$path'), headers: await _headers());
    final decoded = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode >= 400) {
      throw ApiException(decoded['error']?.toString() ?? 'Une erreur est survenue.');
    }
    return decoded;
  }
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}
