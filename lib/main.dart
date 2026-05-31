import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'dart:ui';
import 'dart:async';
import 'api_constants.dart';

// --- PALET WARNA KUSTOM CULT PREMIUM (CYBER GARAGE THEME) ---
const Color bgGelap = Color(0xFF070709); // Hitam Bengkel Kustom ultra gelap
const Color panelGelap = Color(0xFF121215); // Panel Kaca Abu-abu Gelap
const Color kuningEmas = Color(0xFFFFB300); // Amber Gold Pijar
const Color merahGlow = Color(0xFFE11D48); // Rose Red Neon Accent
const Color teksPutih = Color(0xFFF4F4F5); // Off-White Primary
const Color teksRedup = Color(0xFFA1A09A); // Muted Zinc Secondary

void main() {
  runApp(
    const MaterialApp(home: SplashScreen(), debugShowCheckedModeBanner: false),
  );
}

// --- GLOBAL WIDGET: MESH BACKGROUND GLOW ---
Widget _buildMeshBackground(BuildContext context) {
  return Stack(
    children: [
      Positioned(
        top: -120,
        right: -100,
        child: Container(
          width: 320,
          height: 320,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: kuningEmas.withOpacity(0.09),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 90, sigmaY: 90),
            child: Container(color: Colors.transparent),
          ),
        ),
      ),
      Positioned(
        bottom: -100,
        left: -80,
        child: Container(
          width: 300,
          height: 300,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: merahGlow.withOpacity(0.07),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 90, sigmaY: 90),
            child: Container(color: Colors.transparent),
          ),
        ),
      ),
    ],
  );
}

// --- SPLASH SCREEN ---
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );
    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack),
      ),
    );
    _controller.forward();

    Future.delayed(const Duration(milliseconds: 3500), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgGelap,
      body: Stack(
        children: [
          _buildMeshBackground(context),
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Dynamic BBQ Ride Logo from Server with local fallback
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: kuningEmas.withOpacity(0.03),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: kuningEmas.withOpacity(0.12),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: kuningEmas.withOpacity(0.04),
                            blurRadius: 40,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Image.network(
                        ApiConstants.logoUrl,
                        height: 90,
                        color: teksPutih,
                        colorBlendMode: BlendMode.srcIn,
                        errorBuilder: (c, e, s) => const Icon(
                          Icons.motorcycle,
                          size: 90,
                          color: kuningEmas,
                        ),
                      ),
                    ),
                    const SizedBox(height: 35),
                    const Text(
                      "BBQ RIDE '26",
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        color: teksPutih,
                        letterSpacing: 6,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "BANDUNG KUSTOM CULT SHOW",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: kuningEmas,
                        letterSpacing: 4,
                      ),
                    ),
                    const SizedBox(height: 50),
                    const SizedBox(
                      width: 26,
                      height: 26,
                      child: CircularProgressIndicator(
                        color: kuningEmas,
                        strokeWidth: 2.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- HALAMAN LOGIN ---
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  Future<void> login() async {
    setState(() => isLoading = true);
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.loginUrl),
        headers: ApiConstants.defaultHeaders,
        body: {
          'email': emailController.text,
          'password': passwordController.text,
        },
      );

      // Try decoding JSON safely to handle HTML or raw string responses
      dynamic data;
      try {
        data = json.decode(response.body);
      } catch (_) {
        if (mounted) {
          _showErrorSnackBar(
            "Gagal menghubungi server. Coba lagi nanti.",
          );
        }
        return;
      }

      if (response.statusCode == 200) {
        String role = data['user']['role'];
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MainNavigation(userRole: role),
            ),
          );
        }
      } else {
        if (mounted) {
          _showErrorSnackBar(data['message'] ?? "Email atau Password Salah!");
        }
      }
    } catch (e) {
      print("LOGIN ERROR EXCEPTION: $e");
      if (mounted) {
        _showErrorSnackBar(
          "Gagal terhubung ke server. Periksa koneksi jaringan Anda.",
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: merahGlow,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(18),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgGelap,
      body: Stack(
        children: [
          _buildMeshBackground(context),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 20.0,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Dynamic Header BBQ Logo
                    Image.network(
                      ApiConstants.logoUrl,
                      height: 70,
                      color: teksPutih,
                      colorBlendMode: BlendMode.srcIn,
                      errorBuilder: (c, e, s) => const Icon(
                        Icons.lock_outline,
                        size: 70,
                        color: kuningEmas,
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      "PORTAL ADMIN",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: teksPutih,
                        letterSpacing: 3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "BBQ RIDE GATEWAY ACCESS",
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: kuningEmas,
                        letterSpacing: 3,
                      ),
                    ),
                    const SizedBox(height: 35),

                    // Glassmorphic Card Container
                    ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                        child: Container(
                          padding: const EdgeInsets.all(26),
                          decoration: BoxDecoration(
                            color: panelGelap.withOpacity(0.75),
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.07),
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.5),
                                blurRadius: 40,
                                offset: const Offset(0, 15),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Email Field
                              const Text(
                                "EMAIL ADDRESS",
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: teksRedup,
                                  letterSpacing: 2,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: emailController,
                                style: const TextStyle(
                                  color: teksPutih,
                                  fontSize: 14,
                                ),
                                decoration: InputDecoration(
                                  hintText: "admin@bbqride.com",
                                  hintStyle: const TextStyle(
                                    color: Color(0xFF52525B),
                                    fontSize: 14,
                                  ),
                                  prefixIcon: const Icon(
                                    Icons.alternate_email,
                                    color: kuningEmas,
                                    size: 18,
                                  ),
                                  filled: true,
                                  fillColor: bgGelap.withOpacity(0.8),
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(
                                      color: Colors.white.withOpacity(0.03),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: const BorderSide(
                                      color: kuningEmas,
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 22),

                              // Password Field
                              const Text(
                                "PASSWORD",
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: teksRedup,
                                  letterSpacing: 2,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: passwordController,
                                obscureText: true,
                                style: const TextStyle(
                                  color: teksPutih,
                                  fontSize: 14,
                                ),
                                decoration: InputDecoration(
                                  hintText: "••••••••",
                                  hintStyle: const TextStyle(
                                    color: Color(0xFF52525B),
                                    fontSize: 14,
                                  ),
                                  prefixIcon: const Icon(
                                    Icons.vpn_key_outlined,
                                    color: kuningEmas,
                                    size: 18,
                                  ),
                                  filled: true,
                                  fillColor: bgGelap.withOpacity(0.8),
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(
                                      color: Colors.white.withOpacity(0.03),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: const BorderSide(
                                      color: kuningEmas,
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 32),

                              // Submit Button
                              SizedBox(
                                height: 52,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    gradient: const LinearGradient(
                                      colors: [kuningEmas, Color(0xFFF59E0B)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: kuningEmas.withOpacity(0.35),
                                        blurRadius: 15,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    onPressed: isLoading ? null : login,
                                    child: isLoading
                                        ? const SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(
                                              color: bgGelap,
                                              strokeWidth: 2.5,
                                            ),
                                          )
                                        : const Text(
                                            "MASUK KE DASHBOARD",
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w900,
                                              letterSpacing: 1.5,
                                              color: bgGelap,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- NAVIGASI UTAMA (FLOATING GLASSMORPHIC NAV BAR) ---
class MainNavigation extends StatefulWidget {
  final String userRole;
  const MainNavigation({super.key, required this.userRole});
  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = [
      const BerandaPage(),
      const KatalogPage(),
      const InfoEventPage(),
    ];
    final List<Map<String, dynamic>> menuItems = [
      {'icon': Icons.home_outlined, 'label': 'Beranda'},
      {'icon': Icons.motorcycle_outlined, 'label': 'Katalog'},
      {'icon': Icons.info_outline, 'label': 'Info Event'},
    ];

    if (widget.userRole == 'admin') {
      children.insert(2, const ScannerPage());
      menuItems.insert(2, {'icon': Icons.qr_code_scanner, 'label': 'Scanner'});
    }

    return Scaffold(
      backgroundColor: bgGelap,
      body: Stack(
        children: [
          // Screen Content with bottom padding to avoid nav bar overlap
          Padding(
            padding: const EdgeInsets.only(bottom: 50),
            child: children[_currentIndex],
          ),

          // Floating Bottom Glassmorphic Navigation Bar
          Positioned(
            left: 20,
            right: 20,
            bottom: 24,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: panelGelap.withOpacity(0.82),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.06),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(menuItems.length, (index) {
                      final item = menuItems[index];
                      final isSelected = _currentIndex == index;
                      return GestureDetector(
                        onTap: () => setState(() => _currentIndex = index),
                        behavior: HitTestBehavior.opaque,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 18,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? kuningEmas.withOpacity(0.12)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                item['icon'],
                                color: isSelected ? kuningEmas : teksRedup,
                                size: 22,
                              ),
                              if (isSelected) ...[
                                const SizedBox(width: 8),
                                Text(
                                  item['label'],
                                  style: const TextStyle(
                                    color: teksPutih,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- HALAMAN BERANDA / HOME (DYNAMIC CAROUSEL & LIVE CROWD SAFETY) ---
class BerandaPage extends StatefulWidget {
  const BerandaPage({super.key});
  @override
  State<BerandaPage> createState() => _BerandaPageState();
}

class _BerandaPageState extends State<BerandaPage> {
  int totalDalamAcara = 0;
  int kapasitasMaksimal = 500;
  double persentase = 0.0;
  String statusKepadatan = "Mendapatkan status...";
  String colorCode = "hijau";
  bool isCrowdLoading = true;

  List featuredMotors = [];
  bool isCarouselLoading = true;
  late PageController _pageController;
  int _activePage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    fetchCrowdStatus();
    fetchFeaturedMotors();

    // Auto play timer for carousel
    _timer = Timer.periodic(const Duration(seconds: 4), (Timer timer) {
      if (featuredMotors.isNotEmpty) {
        if (_activePage < featuredMotors.length - 1) {
          _activePage++;
        } else {
          _activePage = 0;
        }
        if (_pageController.hasClients) {
          _pageController.animateToPage(
            _activePage,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOutCubic,
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> fetchCrowdStatus() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConstants.crowdStatusUrl),
        headers: ApiConstants.defaultHeaders,
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          totalDalamAcara = data['total_dalam_acara'] ?? 0;
          kapasitasMaksimal = data['kapasitas_maksimal'] ?? 500;
          persentase = (data['persentase'] is int)
              ? (data['persentase'] as int).toDouble()
              : (data['persentase'] ?? 0.0);
          statusKepadatan = data['status_kepadatan'] ?? "Area Aman & Kondusif";
          colorCode = data['color_code'] ?? "hijau";
          isCrowdLoading = false;
        });
      }
    } catch (e) {
      setState(() => isCrowdLoading = false);
    }
  }

  Future<void> fetchFeaturedMotors() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConstants.katalogUrl),
        headers: ApiConstants.defaultHeaders,
      );
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        setState(() {
          // Take the latest 4 motors
          featuredMotors = data.reversed.take(4).toList();
          isCarouselLoading = false;
        });
      }
    } catch (e) {
      setState(() => isCarouselLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Dynamic status color for Glowing Crowd Control
    Color statusColor = const Color(0xFF10B981); // Green default
    if (colorCode == "merah") {
      statusColor = merahGlow;
    } else if (colorCode == "kuning") {
      statusColor = kuningEmas;
    }

    return Scaffold(
      backgroundColor: bgGelap,
      body: Stack(
        children: [
          _buildMeshBackground(context),
          SafeArea(
            child: RefreshIndicator(
              color: bgGelap,
              backgroundColor: kuningEmas,
              onRefresh: () async {
                await fetchCrowdStatus();
                await fetchFeaturedMotors();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 15, 20, 110),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // HEADER SECTION
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "HELLO, BUILDER!",
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: kuningEmas,
                                letterSpacing: 2.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "BBQ RIDE '26",
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: teksPutih,
                                letterSpacing: 1.5,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                        // Mini Logo
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: panelGelap,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.04),
                            ),
                          ),
                          child: Image.network(
                            ApiConstants.logoUrl,
                            height: 28,
                            color: teksPutih,
                            colorBlendMode: BlendMode.srcIn,
                            errorBuilder: (c, e, s) => const Icon(
                              Icons.motorcycle,
                              size: 22,
                              color: kuningEmas,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),

                    // LIVE CROWD CONTROL INDICATOR (GLOWING STATUS CARD)
                    const Text(
                      "LIVE CROWD SAFETY CONTROL",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: kuningEmas,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            color: panelGelap.withOpacity(0.75),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: statusColor.withOpacity(0.15),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: statusColor.withOpacity(0.04),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: isCrowdLoading
                              ? const Center(
                                  child: SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: kuningEmas,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                )
                              : Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        // Animated pulsing dot + Status text
                                        Row(
                                          children: [
                                            // Glowing pulse dot
                                            _CrowdPulseDot(color: statusColor),
                                            const SizedBox(width: 12),
                                            Text(
                                              statusKepadatan.toUpperCase(),
                                              style: TextStyle(
                                                color: statusColor,
                                                fontWeight: FontWeight.w900,
                                                fontSize: 14,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                        // Ratio indicator
                                        Text(
                                          "$totalDalamAcara / $kapasitasMaksimal",
                                          style: const TextStyle(
                                            color: teksPutih,
                                            fontWeight: FontWeight.w900,
                                            fontSize: 14,
                                            letterSpacing: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 18),
                                    // Custom Neon Progress Bar
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Container(
                                        height: 8,
                                        color: bgGelap,
                                        child: Stack(
                                          children: [
                                            // Active glow bar
                                            FractionallySizedBox(
                                              widthFactor: (persentase / 100)
                                                  .clamp(0.02, 1.0),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      statusColor.withOpacity(
                                                        0.6,
                                                      ),
                                                      statusColor,
                                                    ],
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: statusColor
                                                          .withOpacity(0.5),
                                                      blurRadius: 5,
                                                      spreadRadius: 1,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          "Kapasitas Tritan Point",
                                          style: TextStyle(
                                            color: teksRedup,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          "${persentase.toStringAsFixed(1)}% Terisi",
                                          style: TextStyle(
                                            color: statusColor,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // FEATURED KATALOG CAROUSEL
                    const Text(
                      "FEATURED KUSTOM MOTORCYCLES",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: kuningEmas,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    isCarouselLoading
                        ? Container(
                            height: 200,
                            decoration: BoxDecoration(
                              color: panelGelap,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: kuningEmas,
                              ),
                            ),
                          )
                        : featuredMotors.isEmpty
                        ? Container(
                            height: 200,
                            decoration: BoxDecoration(
                              color: panelGelap,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.04),
                              ),
                            ),
                            child: const Center(
                              child: Text(
                                "Belum ada motor di katalog.",
                                style: TextStyle(
                                  color: teksRedup,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          )
                        : Column(
                            children: [
                              SizedBox(
                                height: 200,
                                child: PageView.builder(
                                  controller: _pageController,
                                  itemCount: featuredMotors.length,
                                  onPageChanged: (page) {
                                    setState(() => _activePage = page);
                                  },
                                  itemBuilder: (context, pagePosition) {
                                    final motor = featuredMotors[pagePosition];
                                    String urlFoto = ApiConstants.getImageUrl(
                                        motor['gambar_kendaraan']?.toString());
                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                DetailMotorPage(
                                                  motor: motor,
                                                  url: urlFoto,
                                                ),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: panelGelap,
                                          borderRadius: BorderRadius.circular(
                                            24,
                                          ),
                                          border: Border.all(
                                            color: Colors.white.withOpacity(
                                              0.04,
                                            ),
                                            width: 1.2,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.3,
                                              ),
                                              blurRadius: 15,
                                              offset: const Offset(0, 8),
                                            ),
                                          ],
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            22,
                                          ),
                                          child: Stack(
                                            fit: StackFit.expand,
                                            children: [
                                              Image.network(
                                                urlFoto,
                                                fit: BoxFit.cover,
                                                errorBuilder: (c, e, s) =>
                                                    Container(
                                                      color: const Color(
                                                        0xFF1E1E22,
                                                      ),
                                                      child: const Icon(
                                                        Icons.broken_image,
                                                        color: teksRedup,
                                                      ),
                                                    ),
                                              ),
                                              // Rich bottom-up dark gradient overlay
                                              Container(
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      Colors.black.withOpacity(
                                                        0.8,
                                                      ),
                                                      Colors.black.withOpacity(
                                                        0.3,
                                                      ),
                                                      Colors.transparent,
                                                    ],
                                                    begin:
                                                        Alignment.bottomCenter,
                                                    end: Alignment.topCenter,
                                                  ),
                                                ),
                                              ),
                                              // Text Details Overlay
                                              Positioned(
                                                bottom: 18,
                                                left: 20,
                                                right: 20,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  children: [
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Text(
                                                            (motor['nama_pembuat'] ??
                                                                    '')
                                                                .toUpperCase(),
                                                            style:
                                                                const TextStyle(
                                                                  color:
                                                                      teksPutih,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w900,
                                                                  fontSize: 16,
                                                                  letterSpacing:
                                                                      0.5,
                                                                ),
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                          const SizedBox(
                                                            height: 4,
                                                          ),
                                                          Text(
                                                            (motor['jenis_kendaraan'] ??
                                                                    'Kustom')
                                                                .toUpperCase(),
                                                            style:
                                                                const TextStyle(
                                                                  color:
                                                                      kuningEmas,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 10,
                                                                  letterSpacing:
                                                                      1.5,
                                                                ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    const Icon(
                                                      Icons
                                                          .arrow_forward_ios_rounded,
                                                      color: kuningEmas,
                                                      size: 16,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 12),
                              // Indicator Dots
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(featuredMotors.length, (
                                  index,
                                ) {
                                  final isSelected = _activePage == index;
                                  return AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    width: isSelected ? 20 : 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? kuningEmas
                                          : teksRedup.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  );
                                }),
                              ),
                            ],
                          ),
                    const SizedBox(height: 30),

                    // QUICK NAVIGATION ACTIONS
                    const Text(
                      "QUICK GARAGE OPTIONS",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: kuningEmas,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildQuickButton(
                            context: context,
                            icon: Icons.motorcycle_rounded,
                            label: "Katalog Motor",
                            desc: "Lihat karya modifikasi",
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text(
                                    "Gunakan menu bilah navigasi bawah untuk membuka Katalog!",
                                  ),
                                  duration: const Duration(seconds: 2),
                                  backgroundColor: panelGelap,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _buildQuickButton(
                            context: context,
                            icon: Icons.calendar_month_rounded,
                            label: "Jadwal Event",
                            desc: "Timeline & Guest Stars",
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text(
                                    "Gunakan menu bilah navigasi bawah untuk membuka Info Event!",
                                  ),
                                  duration: const Duration(seconds: 2),
                                  backgroundColor: panelGelap,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String desc,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: panelGelap,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.04)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: kuningEmas.withOpacity(0.07),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: kuningEmas, size: 22),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(
                color: teksPutih,
                fontWeight: FontWeight.w900,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              desc,
              style: const TextStyle(
                color: teksRedup,
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// --- SUB-WIDGET: GLOWING PULSE DOT FOR LIVE CROWD ---
class _CrowdPulseDot extends StatefulWidget {
  final Color color;
  const _CrowdPulseDot({required this.color});
  @override
  State<_CrowdPulseDot> createState() => _CrowdPulseDotState();
}

class _CrowdPulseDotState extends State<_CrowdPulseDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _animation = Tween<double>(
      begin: 0.35,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color.withOpacity(_animation.value),
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(0.6),
                blurRadius: 10 * _animation.value,
                spreadRadius: 2 * _animation.value,
              ),
            ],
          ),
        );
      },
    );
  }
}

// --- HALAMAN KATALOG (2-COLUMN PREMIUM GRID) ---
class KatalogPage extends StatefulWidget {
  const KatalogPage({super.key});
  @override
  State<KatalogPage> createState() => _KatalogPageState();
}

class _KatalogPageState extends State<KatalogPage> {
  List allData = [];
  List filteredData = [];
  bool isLoading = true;
  TextEditingController searchController = TextEditingController();

  String selectedCategory = 'Semua';
  final List<String> categories = [
    'Semua',
    'Chopper',
    'Bobber',
    'Tracker',
    'Cafe Racer',
  ];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConstants.katalogUrl),
        headers: ApiConstants.defaultHeaders,
      );
      if (response.statusCode == 200) {
        setState(() {
          allData = json.decode(response.body);
          applyFilters();
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  void applyFilters() {
    String query = searchController.text.toLowerCase();
    setState(() {
      filteredData = allData.where((item) {
        final nama = item['nama_pembuat'].toString().toLowerCase();
        final jenis = item['jenis_kendaraan'].toString().toLowerCase();
        final matchSearch = nama.contains(query) || jenis.contains(query);
        final matchCategory =
            selectedCategory == 'Semua' ||
            jenis.contains(selectedCategory.toLowerCase());
        return matchSearch && matchCategory;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgGelap,
      appBar: AppBar(
        title: Image.network(
          ApiConstants.logoUrl,
          height: 38,
          color: teksPutih,
          colorBlendMode: BlendMode.srcIn,
          errorBuilder: (c, e, s) => const Text(
            "BBQ RIDE EXHIBITION",
            style: TextStyle(fontWeight: FontWeight.w900, color: teksPutih),
          ),
        ),
        backgroundColor: bgGelap,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: merahGlow),
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
            ),
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(125),
          child: Container(
            color: bgGelap,
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Column(
              children: [
                // Floating Style Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: SizedBox(
                    height: 48,
                    child: TextField(
                      controller: searchController,
                      onChanged: (value) => applyFilters(),
                      style: const TextStyle(color: teksPutih, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: "Cari Builder atau Tipe Motor...",
                        hintStyle: const TextStyle(
                          color: Color(0xFF52525B),
                          fontSize: 13,
                        ),
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          color: kuningEmas,
                          size: 20,
                        ),
                        filled: true,
                        fillColor: panelGelap.withOpacity(0.6),
                        contentPadding: const EdgeInsets.all(0),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: Colors.white.withOpacity(0.04),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: kuningEmas,
                            width: 1.2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Categories Horizontal Scroll List
                SizedBox(
                  height: 38,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final isSelected = selectedCategory == categories[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(
                            categories[index],
                            style: TextStyle(
                              color: isSelected ? bgGelap : kuningEmas,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: kuningEmas,
                          backgroundColor: panelGelap.withOpacity(0.5),
                          side: BorderSide(
                            color: isSelected
                                ? kuningEmas
                                : kuningEmas.withOpacity(0.15),
                            width: 1,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          onSelected: (selected) {
                            setState(() {
                              selectedCategory = categories[index];
                              applyFilters();
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        color: bgGelap,
        backgroundColor: kuningEmas,
        onRefresh: fetchData,
        child: isLoading
            ? const Center(child: CircularProgressIndicator(color: kuningEmas))
            : filteredData.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.motorcycle_outlined,
                      size: 65,
                      color: teksRedup.withOpacity(0.3),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Karya modifikasi belum ditemukan",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: teksRedup.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              )
            : GridView.builder(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.74,
                ),
                itemCount: filteredData.length,
                itemBuilder: (context, index) {
                  var motor = filteredData[index];
                  String urlFoto = ApiConstants.getImageUrl(
                      motor['gambar_kendaraan']?.toString());

                  return GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            DetailMotorPage(motor: motor, url: urlFoto),
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: panelGelap,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.04),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Card Image with custom borders
                          Expanded(
                            flex: 5,
                            child: Hero(
                              tag: motor['id'].toString(),
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(20),
                                ),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Image.network(
                                      urlFoto,
                                      fit: BoxFit.cover,
                                      errorBuilder: (c, e, s) => Container(
                                        color: const Color(0xFF1E1E22),
                                        child: const Icon(
                                          Icons.broken_image_outlined,
                                          color: teksRedup,
                                        ),
                                      ),
                                    ),
                                    // Elegant Dark Bottom Gradient on Image
                                    Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.transparent,
                                            Colors.black.withOpacity(0.4),
                                          ],
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // Card Details info
                          Expanded(
                            flex: 4,
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    motor['nama_pembuat'] ?? '',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: teksPutih,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: kuningEmas.withOpacity(0.07),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: kuningEmas.withOpacity(0.15),
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      motor['jenis_kendaraan'] ?? '',
                                      style: const TextStyle(
                                        color: kuningEmas,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                  const Align(
                                    alignment: Alignment.bottomRight,
                                    child: Icon(
                                      Icons.arrow_right_alt_rounded,
                                      size: 16,
                                      color: kuningEmas,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

// --- HALAMAN DETAIL MOTOR (PARALLAX SHEET DESIGN) ---
class DetailMotorPage extends StatelessWidget {
  final dynamic motor;
  final String url;
  const DetailMotorPage({super.key, required this.motor, required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgGelap,
      body: Stack(
        children: [
          // Hero Image Header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 380,
            child: Hero(
              tag: motor['id'].toString(),
              child: Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: const Color(0xFF1E1E22),
                  child: const Icon(
                    Icons.broken_image,
                    size: 80,
                    color: teksRedup,
                  ),
                ),
              ),
            ),
          ),

          // Image Dark Shadow Overlay
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 380,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.5),
                    Colors.transparent,
                    bgGelap.withOpacity(0.95),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          // Scrollable Information Content
          Positioned.fill(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(top: 300),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: bgGelap,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle Bar Decorator
                    Center(
                      child: Container(
                        width: 45,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),

                    // Main Title Builder
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            motor['nama_pembuat'] ?? '',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: teksPutih,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: kuningEmas.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: kuningEmas.withOpacity(0.2),
                              width: 1.2,
                            ),
                          ),
                          child: Text(
                            motor['jenis_kendaraan'] ?? '',
                            style: const TextStyle(
                              color: kuningEmas,
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Divider(color: Color(0xFF1E1E22), thickness: 1.5),
                    const SizedBox(height: 20),

                    // Specifications Matrix (Premium Grid layout)
                    const Text(
                      "MODIFICATION MATRIX",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: kuningEmas,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildSpecCard(
                            Icons.motorcycle_rounded,
                            "Style Class",
                            motor['jenis_kendaraan'] ?? "Custom",
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildSpecCard(
                            Icons.person_outline_rounded,
                            "Lead Builder",
                            motor['nama_pembuat'] ?? "Unknown",
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),

                    // Description Panel
                    const Text(
                      "BUILDER STATEMENT & HISTORY",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: kuningEmas,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: panelGelap,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.03),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        motor['deskripsi_karya'] ??
                            "Tidak ada deskripsi tambahan untuk karya modifikasi ini.",
                        style: const TextStyle(
                          fontSize: 14.5,
                          height: 1.7,
                          color: Color(0xFFD4D4D8),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    const SizedBox(height: 80), // bottom margin
                  ],
                ),
              ),
            ),
          ),

          // Floating Circular Back Button
          Positioned(
            top: 45,
            left: 20,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.08)),
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      color: teksPutih,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecCard(IconData icon, String title, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: panelGelap,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.03)),
      ),
      child: Row(
        children: [
          Icon(icon, color: kuningEmas, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: teksRedup,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    color: teksPutih,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- HALAMAN SCANNER (SCI-FI LASER ANIMATED SCREEN) ---
class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});
  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  bool isScanning = true;

  Future<void> prosesScan(String code) async {
    setState(() => isScanning = false);
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.scanTiketUrl),
        headers: ApiConstants.defaultHeaders,
        body: {'kode_tiket': code},
      );

      dynamic data;
      try {
        data = json.decode(response.body);
      } catch (_) {
        if (mounted) {
          _notif(
            "KONEKSI ERROR",
            "Respon server tidak valid. Coba lagi nanti.",
            merahGlow,
          );
        }
        return;
      }

      if (mounted) {
        _notif(
          data['success'] ? "ACCESS GRANTED" : "ACCESS DENIED",
          data['message'] ?? "Gagal memproses tiket",
          data['success'] ? const Color(0xFF10B981) : merahGlow,
        );
      }
    } catch (e) {
      if (mounted) {
        _notif("KONEKSI ERROR", "Koneksi ke server terputus! Periksa jaringan Anda.", merahGlow);
      }
    }
  }

  void _notif(String title, String msg, Color color) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: panelGelap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: color, width: 2),
        ),
        title: Row(
          children: [
            Icon(
              title.contains("GRANTED")
                  ? Icons.check_circle_outline
                  : Icons.cancel_outlined,
              color: color,
              size: 26,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          msg,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: teksPutih,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: bgGelap,
              backgroundColor: color,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => isScanning = true);
            },
            child: const Text(
              "OK",
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgGelap,
      appBar: AppBar(
        title: const Text(
          "TICKET CHECKER",
          style: TextStyle(
            color: teksPutih,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
        backgroundColor: bgGelap,
        centerTitle: true,
        elevation: 0,
      ),
      body: isScanning
          ? Stack(
              children: [
                MobileScanner(
                  onDetect: (capture) {
                    final String code = capture.barcodes.first.rawValue ?? '';
                    if (code.isNotEmpty) {
                      prosesScan(code);
                    }
                  },
                ),

                // Sci-fi Hud Scanner Reticle
                Center(
                  child: Container(
                    width: 260,
                    height: 260,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: kuningEmas.withOpacity(0.35),
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Stack(
                      children: [
                        // Animated glowing laser line inside reticle
                        const GlowingLaserLine(),

                        // Corner Borders
                        Positioned(
                          top: 0,
                          left: 0,
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: const BoxDecoration(
                              border: Border(
                                top: BorderSide(color: kuningEmas, width: 5),
                                left: BorderSide(color: kuningEmas, width: 5),
                              ),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: const BoxDecoration(
                              border: Border(
                                top: BorderSide(color: kuningEmas, width: 5),
                                right: BorderSide(color: kuningEmas, width: 5),
                              ),
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(20),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: kuningEmas, width: 5),
                                left: BorderSide(color: kuningEmas, width: 5),
                              ),
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(20),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: kuningEmas, width: 5),
                                right: BorderSide(color: kuningEmas, width: 5),
                              ),
                              borderRadius: BorderRadius.only(
                                bottomRight: Radius.circular(20),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Aiming Guideline HUD Card
                Positioned(
                  bottom: 100,
                  left: 20,
                  right: 20,
                  child: Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 22,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: bgGelap.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: kuningEmas.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.qr_code_2_rounded,
                                color: kuningEmas,
                                size: 20,
                              ),
                              SizedBox(width: 10),
                              Text(
                                "TEMPATKAN BARCODE / QR DI TENGAH BINGKAI",
                                style: TextStyle(
                                  color: kuningEmas,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
          : const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: kuningEmas),
                  SizedBox(height: 20),
                  Text(
                    "Memproses Scan Tiket...",
                    style: TextStyle(
                      color: teksRedup,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

// --- SUB-WIDGET: SCI-FI LASER SCANNER ANIMATED LINE ---
class GlowingLaserLine extends StatefulWidget {
  const GlowingLaserLine({super.key});
  @override
  State<GlowingLaserLine> createState() => _GlowingLaserLineState();
}

class _GlowingLaserLineState extends State<GlowingLaserLine>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.03, end: 0.95).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Positioned(
          top: 250 * _animation.value,
          left: 10,
          right: 10,
          child: Container(
            height: 3,
            decoration: BoxDecoration(
              color: kuningEmas,
              boxShadow: [
                BoxShadow(
                  color: kuningEmas.withOpacity(0.9),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// --- HALAMAN INFO EVENT (GLOWING JADWAL & COUNTDOWN) ---
class InfoEventPage extends StatefulWidget {
  const InfoEventPage({super.key});
  @override
  State<InfoEventPage> createState() => _InfoEventPageState();
}

class _InfoEventPageState extends State<InfoEventPage> {
  late Timer _countdownTimer;
  Duration _timeLeft = Duration.zero;
  final DateTime _targetDate = DateTime(
    2026,
    6,
    12,
    9,
    0,
    0,
  ); // 12 Juni 2026, 09:00 WIB
  int selectedDay = 1; // 1 for Day 1, 2 for Day 2, 3 for Day 3

  final List<Map<String, dynamic>> scheduleDay1 = [
    {
      'time': '09:00',
      'title': 'Open Gate & Registration',
      'desc': 'Registrasi pengunjung dan pembukaan gerbang Tritan Point.',
      'icon': Icons.meeting_room_rounded,
    },
    {
      'time': '10:30',
      'title': 'Talkshow: Kustom Culture Movement',
      'desc': 'Bincang inspiratif bersama para Builder nasional.',
      'icon': Icons.chat_bubble_outline_rounded,
    },
    {
      'time': '13:00',
      'title': 'Kustom Showcase Exhibition',
      'desc': 'Pameran motor modifikasi retro & classic.',
      'icon': Icons.motorcycle_rounded,
    },
    {
      'time': '16:00',
      'title': 'Retro Riding & Safety talk',
      'desc': 'Edukasi berkendara aman dengan roda dua kustom.',
      'icon': Icons.health_and_safety_outlined,
    },
    {
      'time': '19:30',
      'title': 'Live Music Performance',
      'desc': 'Penampilan band lokal pengiring malam pertama.',
      'icon': Icons.music_note_rounded,
    },
  ];

  final List<Map<String, dynamic>> scheduleDay2 = [
    {
      'time': '09:00',
      'title': 'Gate Open: Showcase Day 2',
      'desc': 'Pembukaan gerbang hari kedua pameran kustom.',
      'icon': Icons.meeting_room_rounded,
    },
    {
      'time': '11:00',
      'title': 'BBQ Gathering & Food trucks',
      'desc': 'Kumpul komunitas, pesta barbeque, dan aneka food trucks.',
      'icon': Icons.restaurant_rounded,
    },
    {
      'time': '14:00',
      'title': 'Talkshow: Cafe Racer vs Bratstyle',
      'desc': 'Bedah estetika dua aliran modifikasi legendaris.',
      'icon': Icons.psychology_outlined,
    },
    {
      'time': '16:30',
      'title': 'Engine Sound Battle Showcase',
      'desc': 'Adu merdu suara mesin motor modifikasi.',
      'icon': Icons.volume_up_rounded,
    },
    {
      'time': '19:00',
      'title': 'Special Guest Performance & DJ',
      'desc': 'Malam puncak keseruan musik dan lighting show.',
      'icon': Icons.music_video_rounded,
    },
  ];

  final List<Map<String, dynamic>> scheduleDay3 = [
    {
      'time': '09:00',
      'title': 'Gate Open: Final Day',
      'desc': 'Hari penutupan BBQ Ride Exhibition 2026.',
      'icon': Icons.meeting_room_rounded,
    },
    {
      'time': '11:30',
      'title': 'Talkshow: Future of Custom Cult',
      'desc': 'Masa depan modifikasi lokal di kancah internasional.',
      'icon': Icons.rocket_launch_outlined,
    },
    {
      'time': '14:00',
      'title': 'Kustom Cult Awarding Ceremony',
      'desc': 'Pemberian penghargaan untuk motor modifikasi terbaik.',
      'icon': Icons.emoji_events_rounded,
    },
    {
      'time': '17:00',
      'title': 'Live Garage Build Session',
      'desc': 'Demo modifikasi motor langsung di lokasi.',
      'icon': Icons.build_circle_rounded,
    },
    {
      'time': '19:00',
      'title': 'Closing Ceremony & Music Band',
      'desc': 'Penutupan resmi acara BBQ Ride 2026.',
      'icon': Icons.celebration_rounded,
    },
  ];

  @override
  void initState() {
    super.initState();
    calculateTimeLeft();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      calculateTimeLeft();
    });
  }

  void calculateTimeLeft() {
    final now = DateTime.now();
    final difference = _targetDate.difference(now);
    if (mounted) {
      setState(() {
        _timeLeft = difference.isNegative ? Duration.zero : difference;
      });
    }
  }

  @override
  void dispose() {
    _countdownTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Breakdown Time Left
    int days = _timeLeft.inDays;
    int hours = _timeLeft.inHours % 24;
    int minutes = _timeLeft.inMinutes % 60;
    int seconds = _timeLeft.inSeconds % 60;

    List<Map<String, dynamic>> activeSchedule = scheduleDay1;
    if (selectedDay == 2) {
      activeSchedule = scheduleDay2;
    } else if (selectedDay == 3) {
      activeSchedule = scheduleDay3;
    }

    return Scaffold(
      backgroundColor: bgGelap,
      appBar: AppBar(
        title: const Text(
          "INFO EVENT",
          style: TextStyle(
            color: teksPutih,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
        backgroundColor: bgGelap,
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 110),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Event Main Banner Card
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [merahGlow, kuningEmas],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: merahGlow.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Image.network(
                    ApiConstants.logoUrl,
                    height: 52,
                    color: bgGelap,
                    colorBlendMode: BlendMode.srcIn,
                    errorBuilder: (c, e, s) =>
                        const Icon(Icons.motorcycle, size: 52, color: bgGelap),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "BBQ RIDE 2026",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: bgGelap,
                      letterSpacing: 2.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    "VINTAGE & KUSTOM MOTORCYCLE SHOW",
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: bgGelap,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),

            // LIVE EVENT COUNTDOWN (DIGITAL GLOW BLOCKS)
            const Text(
              "COUNTDOWN TO GATES OPEN",
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: kuningEmas,
                letterSpacing: 2,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCountdownBox(days.toString().padLeft(2, '0'), "HARI"),
                _buildCountdownBox(hours.toString().padLeft(2, '0'), "JAM"),
                _buildCountdownBox(minutes.toString().padLeft(2, '0'), "MENIT"),
                _buildCountdownBox(seconds.toString().padLeft(2, '0'), "DETIK"),
              ],
            ),
            const SizedBox(height: 30),

            // EVENT VENUE & DETAILS CARDS
            Row(
              children: [
                Expanded(
                  child: _buildVenueCard(
                    Icons.location_on_rounded,
                    "LOKASI ACARA",
                    "PRABUWANGI PARK, BANDUNG",
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildVenueCard(
                    Icons.calendar_month_rounded,
                    "WAKTU ACARA",
                    "12 - 13 JUNI 2026",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // INTERACTIVE EVENT AGENDA / SCHEDULE TIMELINE
            const Text(
              "EVENT AGENDA & TIMELINE",
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: kuningEmas,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 12),

            // Days Tab Selector (2 Days)
            Row(
              children: List.generate(2, (index) {
                final dayNum = index + 1;
                final isSelected = selectedDay == dayNum;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => selectedDay = dayNum),
                    child: Container(
                      margin: EdgeInsets.only(right: index == 1 ? 0 : 8),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? kuningEmas : panelGelap,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? kuningEmas
                              : Colors.white.withOpacity(0.04),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          "HARI 0$dayNum",
                          style: TextStyle(
                            color: isSelected ? bgGelap : teksRedup,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),

            // Vertical Timeline List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: activeSchedule.length,
              itemBuilder: (context, index) {
                final agenda = activeSchedule[index];
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Timeline indicator line + circle
                    Column(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: kuningEmas,
                            boxShadow: [
                              BoxShadow(
                                color: kuningEmas.withOpacity(0.5),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                        ),
                        if (index != activeSchedule.length - 1)
                          Container(
                            width: 2,
                            height: 75,
                            color: Colors.white.withOpacity(0.06),
                          ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    // Timeline Card
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: panelGelap,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.03),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: kuningEmas.withOpacity(0.06),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                agenda['icon'],
                                color: kuningEmas,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        agenda['time'] + ' WIB',
                                        style: const TextStyle(
                                          color: kuningEmas,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 11,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    agenda['title'],
                                    style: const TextStyle(
                                      color: teksPutih,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    agenda['desc'],
                                    style: const TextStyle(
                                      color: teksRedup,
                                      fontSize: 10.5,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),

            // Branding Footer Slogan
            const Text(
              "VINTAGE - KUSTOM MOTORCYCLE AND CAR SHOW",
              style: TextStyle(
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w900,
                color: kuningEmas,
                fontSize: 10,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            const Text(
              "BANDUNG - INDONESIA",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: teksRedup,
                fontSize: 8,
                letterSpacing: 3,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountdownBox(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      width: 75,
      decoration: BoxDecoration(
        color: panelGelap,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kuningEmas.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(color: kuningEmas.withOpacity(0.04), blurRadius: 10),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: teksPutih,
              fontFamily: 'monospace',
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.bold,
              color: kuningEmas,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVenueCard(IconData icon, String title, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      height: 105,
      decoration: BoxDecoration(
        color: panelGelap,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.03)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: merahGlow, size: 20),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              color: kuningEmas,
              fontSize: 8.5,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 3),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: teksPutih,
                fontSize: 10.5,
                fontWeight: FontWeight.w900,
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
