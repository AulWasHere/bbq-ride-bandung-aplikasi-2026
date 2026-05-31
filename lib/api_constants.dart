// ============================================================
// 🌐 KONFIGURASI API TERPUSAT - BBQ RIDE '26
// ============================================================
// File ini berisi semua URL dan endpoint API yang digunakan
// oleh aplikasi Flutter. Ubah di sini saja jika server pindah.
//
// 📌 LIVE SERVER: bbqridebandung.my.id (cPanel Shared Hosting)
// 📌 LOCAL DEBUG : http://10.0.2.2:8000 (Emulator → XAMPP)
//                  http://192.168.x.x/backend-bbqride/public
// ============================================================

class ApiConstants {
  // ─────────────────────────────────────────────────────
  // BASE URL UTAMA (Ganti ini saat pindah server)
  // ─────────────────────────────────────────────────────
  // ✅ LIVE SERVER (Aktif)
  static const String baseUrl = 'https://bbqridebandung.my.id';

  // ❌ LOCAL XAMPP (Non-aktifkan dengan comment jika pakai live)
  // static const String baseUrl = 'http://10.0.2.2:8000';
  // static const String baseUrl = 'http://192.168.100.29/backend-bbqride/public';

  // ─────────────────────────────────────────────────────
  // API ENDPOINTS
  // ─────────────────────────────────────────────────────
  static const String loginUrl = '$baseUrl/api/login';
  static const String katalogUrl = '$baseUrl/api/katalog';
  static const String crowdStatusUrl = '$baseUrl/api/crowd-status';
  static const String scanTiketUrl = '$baseUrl/api/scan-tiket';

  // ─────────────────────────────────────────────────────
  // ASSET & IMAGE URLS
  // ─────────────────────────────────────────────────────
  static const String logoUrl = '$baseUrl/images/logo-bbq.png';

  /// Menghasilkan URL lengkap untuk gambar dari database.
  /// Jika path sudah berupa URL lengkap (http/https), langsung dikembalikan.
  /// Jika path relatif (misal: 'images/katalog/xxx.jpg'), digabung dengan baseUrl.
  static String getImageUrl(String? pathGambar) {
    if (pathGambar == null || pathGambar.isEmpty) {
      return ''; // Biar errorBuilder di Image.network yang menangani
    }
    if (pathGambar.startsWith('http')) {
      return pathGambar; // Sudah URL lengkap, langsung pakai
    }
    return '$baseUrl/$pathGambar';
  }

  // ─────────────────────────────────────────────────────
  // HEADER DEFAULT (agar Laravel selalu return JSON)
  // ─────────────────────────────────────────────────────
  static const Map<String, String> defaultHeaders = {
    'Accept': 'application/json',
  };
}
