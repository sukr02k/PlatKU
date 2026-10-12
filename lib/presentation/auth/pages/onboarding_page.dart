import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_kendaraanku_app/core/constants/colors.dart';
import 'package:flutter_kendaraanku_app/data/local/auth_local_datasource.dart';
import 'package:flutter_kendaraanku_app/data/local/demo_data_seeder.dart';
import 'package:flutter_kendaraanku_app/presentation/blocs/vehicle/vehicle_bloc.dart';
import 'package:flutter_kendaraanku_app/presentation/blocs/vehicle/vehicle_event.dart';
import 'package:flutter_kendaraanku_app/presentation/home/pages/main_navigation_page.dart';
import 'register_page.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});
  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _seedingDemo = false;

  final List<_OnboardingData> _pages = [
    _OnboardingData(
      icon: Icons.shield_rounded,
      gradientColors: [
        AppColors.primaryStrong,
        AppColors.primary,
        AppColors.accent,
      ],
      title: 'Garasi Digital MotoVault',
      description:
          'Catat servis, konsumsi BBM, dokumen STNK/Pajak, dan semua riwayat kendaraan dalam satu brankas pintar.',
    ),
    _OnboardingData(
      icon: Icons.notifications_active_rounded,
      gradientColors: [const Color(0xFF0D9488), const Color(0xFF10B981)],
      title: 'Pengingat Servis & Pajak',
      description:
          'Pantau otomatis jadwal servis berkala, odometer terkini, hingga masa berlaku STNK, Pajak, dan SIM.',
    ),
    _OnboardingData(
      icon: Icons.bar_chart_rounded,
      gradientColors: [const Color(0xFFD97706), const Color(0xFFF59E0B)],
      title: 'Analitik & Laporan PDF/CSV',
      description:
          'Visualisasi tren pengeluaran bulanan, OCR scan struk SPBU, dan ekspor laporan siap cetak kapan saja.',
    ),
  ];

  Future<void> _enterDemoMode() async {
    if (_seedingDemo) return;
    setState(() => _seedingDemo = true);
    final userId = await DemoDataSeeder.seedAndLogin();
    if (!mounted) return;
    context.read<VehicleBloc>().add(LoadVehicles(userId));
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const MainNavigationPage()),
      (route) => false,
    );
  }

  Future<void> _goToNext() async {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      final authLocal = AuthLocalDatasource();
      await authLocal.setFirstTimeDone();
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const RegisterPage()),
      );
    }
  }

  void _goToPrev() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _skip() async {
    final authLocal = AuthLocalDatasource();
    await authLocal.setFirstTimeDone();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const RegisterPage()),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Color(0xFFF8FAFC),
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 20, top: 12),
                child: TextButton(
                  onPressed: _skip,
                  child: Text(
                    'Lewati',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
              ),
            ),

            // PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Illustration card
                        Container(
                          constraints: const BoxConstraints(maxWidth: 320),
                          height: 260,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: page.gradientColors,
                            ),
                            borderRadius: BorderRadius.circular(32),
                          ),
                          child: Center(
                            child: Icon(
                              page.icon,
                              size: 80,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ),
                        const SizedBox(height: 36),

                        // Title
                        Text(
                          page.title,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: AppColors.text,
                            letterSpacing: -0.48,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Description
                        Text(
                          page.description,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textMuted,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Dot indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (index) {
                final isActive = index == _currentPage;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: isActive ? 24 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.primary : AppColors.border,
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),

            // Bottom buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  // Kembali button (hidden on first page)
                  Expanded(
                    child: _currentPage > 0
                        ? OutlinedButton(
                            onPressed: _goToPrev,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.text,
                              side: const BorderSide(color: AppColors.border),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: Text(
                              'Kembali',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                  if (_currentPage > 0) const SizedBox(width: 12),

                  // Lanjut / Mulai button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _goToNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        _currentPage == _pages.length - 1 ? 'Mulai' : 'Lanjut',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: TextButton.icon(
                onPressed: _seedingDemo ? null : _enterDemoMode,
                icon: const Icon(
                  Icons.bolt_rounded,
                  size: 18,
                  color: AppColors.primary,
                ),
                label: Text(
                  _seedingDemo
                      ? 'Menyiapkan Garasi Demo...'
                      : 'Masuk Mode Demo Instan (Data Contoh)',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _OnboardingData {
  final IconData icon;
  final List<Color> gradientColors;
  final String title;
  final String description;

  _OnboardingData({
    required this.icon,
    required this.gradientColors,
    required this.title,
    required this.description,
  });
}
