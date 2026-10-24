import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/user_model.dart';

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}

class UserService {
  static const String _baseUrl = 'https://reqres.in/api';

  // Jika server membalas 401/403, daftar gratis di reqres.in lalu isi API key di sini.
  static const String _apiKey = '';

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (_apiKey.isNotEmpty) 'x-api-key': _apiKey,
  };

  Future<http.Response> _send(
      Future<http.Response> Function() request,
      List<int> okCodes,
      ) async {
    try {
      final res = await request().timeout(const Duration(seconds: 10));
      if (!okCodes.contains(res.statusCode)) {
        throw ApiException(
            'Server mengembalikan error (status ${res.statusCode}).');
      }
      return res;
    } on SocketException {
      throw ApiException(
          'Tidak ada koneksi internet. Periksa jaringan lalu coba lagi.');
    } on TimeoutException {
      throw ApiException('Permintaan melebihi batas waktu. Coba lagi.');
    } on http.ClientException {
      throw ApiException(
          'Tidak ada koneksi internet atau server tidak dapat dijangkau. Periksa jaringan lalu coba lagi.');
    } on FormatException {
      throw ApiException('Format respons dari server tidak valid.');
    }
  }

  // GET
  Future<List<UserModel>> getUsers({int page = 1}) async {
    final res = await _send(
          () => http.get(Uri.parse('$_baseUrl/users?page=$page'),
          headers: _headers),
      [200],
    );
    try {
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      final list = body['data'] as List<dynamic>;
      return list
          .map((e) => UserModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      throw ApiException('Format data dari server tidak valid.');
    }
  }

  // POST
  Future<UserModel> createUser(UserModel user) async {
    final res = await _send(
          () => http.post(Uri.parse('$_baseUrl/users'),
          headers: _headers, body: jsonEncode(user.toJson())),
      [200, 201],
    );
    try {
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      return UserModel(
        id: int.tryParse(body['id'].toString()),
        email: user.email,
        firstName: user.firstName,
        lastName: user.lastName,
        avatar: user.avatar,
      );
    } catch (_) {
      throw ApiException('Format respons dari server tidak valid.');
    }
  }

  // PUT
  Future<UserModel> updateUser(UserModel user) async {
    if (user.id == null) throw ApiException('ID user tidak ditemukan.');
    await _send(
          () => http.put(Uri.parse('$_baseUrl/users/${user.id}'),
          headers: _headers, body: jsonEncode(user.toJson())),
      [200],
    );
    return user;
  }

  // DELETE (reqres membalas 204 No Content saat berhasil)
  Future<void> deleteUser(int id) async {
    await _send(
          () => http.delete(Uri.parse('$_baseUrl/users/$id'), headers: _headers),
      [200, 204],
    );
  }
}