class ApiConfig {
  // Ganti IP ini dengan IP komputer kamu
  // Cari IP dengan: ipconfig (Windows) / ifconfig (Mac/Linux)
  // Jangan pakai localhost atau 127.0.0.1 karena emulator tidak bisa akses
  // static const String baseUrl = 'http://192.168.18.40:8000/api/v1';
  static const String baseUrl = 'http://127.0.0.1:8000/api/v1';

  // Endpoints
  static const String register = '$baseUrl/register';
  static const String login = '$baseUrl/login';
  static const String logout = '$baseUrl/logout';
  static const String profile = '$baseUrl/profile';
  static const String nodes = '$baseUrl/nodes';
  static const String progress = '$baseUrl/progress';

  static String nodeDetail(int id) => '$baseUrl/nodes/$id';
  static String quizAnswer(int quizId) => '$baseUrl/quiz/$quizId/answer';
  static String nodeProgress(int nodeId) => '$baseUrl/progress/$nodeId';
}
