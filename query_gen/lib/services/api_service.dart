import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class ApiService {
  // ── Troca o IP aqui quando mudar de rede ──────────────────────
  static const _ipLocal = '10.2.0.135';
  static const _porta   = '3005';

  static String get _base => kIsWeb
      ? 'http://localhost:$_porta'
      : 'http://$_ipLocal:$_porta';

  static const _timeout = Duration(seconds: 30);
  static const _timeoutMsg = 'Servidor não respondeu a tempo. Verifique sua conexão.';

  final _auth = AuthService();

  // ── Headers ───────────────────────────────────────────────────

  Map<String, String> get _jsonHeaders => {
        'Content-Type': 'application/json',
      };

  Future<Map<String, String>> get _authHeaders async {
    final token = await _auth.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // ── HTTP helpers com timeout ───────────────────────────────────

  Future<http.Response> _get(Uri uri, {Map<String, String>? headers}) =>
      http.get(uri, headers: headers).timeout(
        _timeout,
        onTimeout: () => throw Exception(_timeoutMsg),
      );

  Future<http.Response> _post(Uri uri,
          {Map<String, String>? headers, Object? body}) =>
      http.post(uri, headers: headers, body: body).timeout(
        _timeout,
        onTimeout: () => throw Exception(_timeoutMsg),
      );

  Future<http.Response> _put(Uri uri,
          {Map<String, String>? headers, Object? body}) =>
      http.put(uri, headers: headers, body: body).timeout(
        _timeout,
        onTimeout: () => throw Exception(_timeoutMsg),
      );

  Future<http.Response> _delete(Uri uri, {Map<String, String>? headers}) =>
      http.delete(uri, headers: headers).timeout(
        _timeout,
        onTimeout: () => throw Exception(_timeoutMsg),
      );

  // ── Parsers ───────────────────────────────────────────────────

  Map<String, dynamic> _parse(http.Response res) {
    late final dynamic data;
    try {
      data = jsonDecode(res.body);
    } on FormatException {
      throw Exception('Resposta inválida do servidor (HTTP ${res.statusCode})');
    }
    if (res.statusCode >= 400) {
      final msg = data is Map
          ? (data['erro'] ?? data['message'] ?? data['error'])?.toString()
          : null;
      throw Exception(msg ?? 'Erro HTTP ${res.statusCode}');
    }
    return data as Map<String, dynamic>;
  }

  List<dynamic> _parseList(http.Response res) {
    if (res.statusCode >= 400) {
      late final dynamic data;
      try {
        data = jsonDecode(res.body);
      } on FormatException {
        throw Exception('Erro HTTP ${res.statusCode}');
      }
      final msg = data is Map
          ? (data['erro'] ?? data['message'] ?? data['error'])?.toString()
          : null;
      throw Exception(msg ?? 'Erro HTTP ${res.statusCode}');
    }
    try {
      return jsonDecode(res.body) as List<dynamic>;
    } on FormatException {
      throw Exception('Resposta inválida do servidor (HTTP ${res.statusCode})');
    }
  }

  // ── Auth ──────────────────────────────────────────────────────

  Future<Map<String, dynamic>> register(
      String email, String senha, String nome) async {
    final res = await _post(
      Uri.parse('$_base/auth/register'),
      headers: _jsonHeaders,
      body: jsonEncode({'email': email, 'senha': senha, 'nome': nome}),
    );
    return _parse(res);
  }

  Future<Map<String, dynamic>> login(String email, String senha) async {
    final res = await _post(
      Uri.parse('$_base/auth/login'),
      headers: _jsonHeaders,
      body: jsonEncode({'email': email, 'senha': senha}),
    );
    return _parse(res);
  }

  // ── Perfil ────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getPerfil() async {
    final res = await _get(
      Uri.parse('$_base/api/perfil'),
      headers: await _authHeaders,
    );
    return _parse(res);
  }

  Future<void> updatePerfil({
    String? nome,
    String? foto,
    String? novaSenha,
  }) async {
    final body = <String, dynamic>{};
    if (nome != null)      body['nome']      = nome;
    if (foto != null)      body['foto']      = foto;
    if (novaSenha != null) body['novaSenha'] = novaSenha;

    final res = await _put(
      Uri.parse('$_base/api/perfil'),
      headers: await _authHeaders,
      body: jsonEncode(body),
    );
    _parse(res);
  }

  // ── Scripts ───────────────────────────────────────────────────

  Future<Map<String, dynamic>> gerarScript(String pergunta) async {
    final res = await _post(
      Uri.parse('$_base/api/gerar-script'),
      headers: await _authHeaders,
      body: jsonEncode({'pergunta': pergunta}),
    );
    return _parse(res);
  }

  // ── Histórico ─────────────────────────────────────────────────

  Future<List<dynamic>> getHistorico() async {
    final res = await _get(
      Uri.parse('$_base/api/historico'),
      headers: await _authHeaders,
    );
    return _parseList(res);
  }

  Future<void> deletarHistorico(int id) async {
    final res = await _delete(
      Uri.parse('$_base/api/historico/$id'),
      headers: await _authHeaders,
    );
    if (res.statusCode >= 400) _parse(res);
  }

  Future<Map<String, dynamic>> getHistoricoDados(int id) async {
    final res = await _get(
      Uri.parse('$_base/api/historico/$id/dados'),
      headers: await _authHeaders,
    );
    return _parse(res);
  }

  // ── Recuperação de senha ──────────────────────────────────────

  Future<void> solicitarRecuperacao(String email) async {
    final res = await _post(
      Uri.parse('$_base/recovery/solicitar'),
      headers: _jsonHeaders,
      body: jsonEncode({'email': email}),
    );
    _parse(res);
  }

  Future<Map<String, dynamic>> verificarToken(
      String email, String token) async {
    final res = await _post(
      Uri.parse('$_base/recovery/verificar'),
      headers: _jsonHeaders,
      body: jsonEncode({'email': email, 'token': token}),
    );
    return _parse(res);
  }

  Future<void> redefinirSenha(int tokenId, String novaSenha) async {
    final res = await _post(
      Uri.parse('$_base/recovery/redefinir'),
      headers: _jsonHeaders,
      body: jsonEncode({'tokenId': tokenId, 'novaSenha': novaSenha}),
    );
    _parse(res);
  }
}
