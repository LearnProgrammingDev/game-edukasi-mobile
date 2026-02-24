import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/node.dart';

class NodeService {
  Future<Map<String, String>> get _authHeaders async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Ambil semua node + koneksi untuk render peta
  Future<Map<String, dynamic>> getNodes() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.nodes),
        headers: await _authHeaders,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final nodes = (data['nodes'] as List)
            .map((n) => Node.fromJson(n))
            .toList();
        final connections = (data['connections'] as List)
            .map((c) => NodeConnection.fromJson(c))
            .toList();
        return {'success': true, 'nodes': nodes, 'connections': connections};
      }
      return {'success': false, 'message': 'Gagal memuat roadmap'};
    } catch (e) {
      return {'success': false, 'message': 'Koneksi gagal!'};
    }
  }

  // Ambil detail 1 node (isi materi + daftar kuis)
  Future<Map<String, dynamic>> getNodeDetail(int id) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.nodeDetail(id)),
        headers: await _authHeaders,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'node': Node.fromJson(data['node'])};
      }
      return {
        'success': false,
        'message': 'Node tidak ditemukan atau masih terkunci',
      };
    } catch (e) {
      return {'success': false, 'message': 'Koneksi gagal!'};
    }
  }

  // Tambahkan method ini di dalam class NodeService
  Future<Map<String, dynamic>> completeMateri(int nodeId) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/nodes/$nodeId/complete'),
        headers: await _authHeaders,
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, ...data};
      }
      return {'success': false, 'message': data['message']};
    } catch (e) {
      return {'success': false, 'message': 'Koneksi gagal!'};
    }
  }
}
