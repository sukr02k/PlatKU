import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_kendaraanku_app/core/constants/colors.dart';
import 'package:flutter_kendaraanku_app/core/utils/image_helper.dart';
import 'package:flutter_kendaraanku_app/data/local/auth_local_datasource.dart';
import 'package:flutter_kendaraanku_app/data/local/demo_data_seeder.dart';
import 'package:flutter_kendaraanku_app/data/repositories/auth_repository.dart';
import 'package:flutter_kendaraanku_app/data/repositories/fuel_log_repository.dart';
import 'package:flutter_kendaraanku_app/data/repositories/service_log_repository.dart';
import 'package:flutter_kendaraanku_app/data/repositories/vehicle_document_repository.dart';
import 'package:flutter_kendaraanku_app/data/repositories/vehicle_repository.dart';
import 'package:flutter_kendaraanku_app/presentation/auth/pages/login_page.dart';
import 'package:flutter_kendaraanku_app/presentation/blocs/vehicle/vehicle_bloc.dart';
import 'package:flutter_kendaraanku_app/presentation/blocs/vehicle/vehicle_event.dart';
import 'package:flutter_kendaraanku_app/presentation/blocs/vehicle/vehicle_state.dart';
import 'package:flutter_kendaraanku_app/presentation/profile/pages/about_page.dart';
import 'package:flutter_kendaraanku_app/presentation/profile/pages/backup_page.dart';
import 'package:flutter_kendaraanku_app/presentation/profile/pages/edit_profile_page.dart';
import 'package:flutter_kendaraanku_app/presentation/profile/pages/help_page.dart';
import 'package:flutter_kendaraanku_app/presentation/profile/pages/language_page.dart';
import 'package:flutter_kendaraanku_app/presentation/profile/pages/privacy_page.dart';
import 'package:flutter_kendaraanku_app/presentation/profile/pages/security_page.dart';
import 'package:flutter_kendaraanku_app/presentation/profile/pages/terms_page.dart';
import 'package:flutter_kendaraanku_app/presentation/profile/pages/theme_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _userName = '';
  String _userEmail = '';
  String? _userImagePath;
  int _memberSinceYear = DateTime.now().year;
  int _totalTransactions = 0;
  int _totalDocuments = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final authDatasource = AuthLocalDatasource();
    final name = await authDatasource.getUserName();
    final email = await authDatasource.getUserEmail();
    final userId = await authDatasource.getUserId();
    String? imagePath = await authDatasource.getUserImagePath();

    int memberYear = DateTime.now().year;
    int txCount = 0;
    int docCount = 0;

    if (userId != null) {
      final userRes = await AuthRepository().getUserById(userId);
      userRes.fold((_) {}, (user) {
        memberYear = user.createdAt.year;
        if (user.imagePath != null && user.imagePath!.isNotEmpty) {
          imagePath = user.imagePath;
        }
      });

      final vehiclesRes = await VehicleRepository().getByUser(userId);
      final vehicles = vehiclesRes.getOrElse(() => []);
      final fuelRepo = FuelLogRepository();
      final serviceRepo = ServiceLogRepository();
      for (final v in vehicles) {
        if (v.id == null) continue;
        final fuels = (await fuelRepo.getByVehicle(v.id!)).getOrElse(() => []);
        final services =
            (await serviceRepo.getByVehicle(v.id!)).getOrElse(() => []);
        txCount += fuels.length + services.length;
      }

      final docs = (await VehicleDocumentRepository().getByUser(userId))
          .getOrElse(() => []);
      docCount = docs.length;
    }

    if (mounted) {
      setState(() {
        _userName = name ?? 'Pengguna';
        _userEmail = email ?? '-';
        _userImagePath = imagePath;
        _memberSinceYear = memberYear;
        _totalTransactions = txCount;
        _totalDocuments = docCount;
        _isLoading = false;
      });
    }
  }

  String _getInitials(String name) {
    final words = name.trim().split(RegExp(r'\s+'));
    if (words.isEmpty) return '?';
    if (words.length == 1) return words[0][0].toUpperCase();
    return '${words[0][0]}${words[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<VehicleBloc, VehicleState>(
      listener: (_, state) {
        if (state is VehicleLoaded) {
          _loadUserData();
        }
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
          backgroundColor: AppColors.bg,
          body: SingleChildScrollView(
            child: Column(
              children: [
                _buildHeroHeader(),
                _buildProfileCard(),
                const SizedBox(height: 18),
                _buildSettingsGroup('AKUN', _accountRows()),
                _buildSettingsGroup('PREFERENSI', _preferenceRows()),
                _buildSettingsGroup('LAINNYA', _otherRows()),
                _buildLogoutButton(),
                _buildVersionText(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.heroGradientVertical,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Stack(
        children: [
          // Decorative circle
          Positioned(
            right: -60,
            top: -40,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.10),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 60),
              child: Center(
                child: Text(
                  'Profil Saya',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    final vehicleState = context.watch<VehicleBloc>().state;
    final vehicleCount =
        vehicleState is VehicleLoaded ? vehicleState.vehicles.length : 0;

    return Transform.translate(
      offset: const Offset(0, -42),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: _isLoading
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(),
                  ),
                )
              : Column(
                  children: [
                    // Avatar + info
                    Row(
                      children: [
                        GestureDetector(
                          onTap: _userImagePath != null &&
                                  File(_userImagePath!).existsSync()
                              ? () => ImageHelper.showFullScreenImage(
                                    context,
                                    file: File(_userImagePath!),
                                    title: 'Foto Profil - $_userName',
                                  )
                              : null,
                          child: Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: AppColors.primarySoft,
                              borderRadius: BorderRadius.circular(20),
                              border:
                                  Border.all(color: AppColors.surface, width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.08),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(17),
                              child: _userImagePath != null &&
                                      File(_userImagePath!).existsSync()
                                  ? Image.file(
                                      File(_userImagePath!),
                                      fit: BoxFit.cover,
                                      width: 64,
                                      height: 64,
                                    )
                                  : Center(
                                      child: Text(
                                        _getInitials(_userName),
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.primaryStrong,
                                        ),
                                      ),
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _userName,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.text,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _userEmail,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  color: AppColors.textMuted,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.tintAmberBg,
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.star,
                                        size: 12,
                                        color: AppColors.tintAmberFg),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Member Sejak $_memberSinceYear',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.tintAmberFg,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    // Stats
                    Container(
                      margin: const EdgeInsets.only(top: 16),
                      padding: const EdgeInsets.only(top: 16),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: AppColors.divider, width: 1),
                        ),
                      ),
                      child: Row(
                        children: [
                          _buildStat('$vehicleCount', 'Kendaraan'),
                          Container(
                            width: 1,
                            height: 28,
                            color: AppColors.divider,
                          ),
                          _buildStat('$_totalTransactions', 'Transaksi'),
                          Container(
                            width: 1,
                            height: 28,
                            color: AppColors.divider,
                          ),
                          _buildStat('$_totalDocuments', 'Dokumen'),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildStat(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsGroup(String title, List<_SettingsRow> rows) {
    return Transform.translate(
      offset: const Offset(0, -24),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMuted,
                  letterSpacing: 0.44,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: List.generate(rows.length, (index) {
                  final row = rows[index];
                  final isLast = index == rows.length - 1;
                  return Column(
                    children: [
                      _buildSettingsRowWidget(row),
                      if (!isLast)
                        Padding(
                          padding: EdgeInsets.only(left: 60),
                          child:
                              Divider(height: 1, color: AppColors.divider),
                        ),
                    ],
                  );
                }),
              ),
            ),
            const SizedBox(height: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsRowWidget(_SettingsRow row) {
    return GestureDetector(
      onTap: row.onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: row.tintBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(row.icon, size: 18, color: row.tintFg),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    row.title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                    ),
                  ),
                  if (row.subtitle != null) ...[
                    const SizedBox(height: 1),
                    Text(
                      row.subtitle!,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(Icons.chevron_right,
                size: 20, color: AppColors.textSoft),
          ],
        ),
      ),
    );
  }

  List<_SettingsRow> _accountRows() {
    return [
      _SettingsRow(
        tintBg: AppColors.tintBlueBg,
        tintFg: AppColors.tintBlueFg,
        icon: Icons.person_outline,
        title: 'Informasi Pribadi',
        subtitle: 'Nama, email, telepon',
        onTap: () async {
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (_) => EditProfilePage(
                currentName: _userName,
                currentEmail: _userEmail,
                currentImagePath: _userImagePath,
              ),
            ),
          );
          if (result == true) {
            _loadUserData();
          }
        },
      ),
      _SettingsRow(
        tintBg: AppColors.tintMintBg,
        tintFg: AppColors.tintMintFg,
        icon: Icons.shield_outlined,
        title: 'Keamanan',
        subtitle: 'Kata sandi & tips keamanan',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SecurityPage()),
        ),
      ),
    ];
  }

  List<_SettingsRow> _preferenceRows() {
    return [
      _SettingsRow(
        tintBg: AppColors.tintLavenderBg,
        tintFg: AppColors.tintLavenderFg,
        icon: Icons.palette_outlined,
        title: 'Tema Warna',
        subtitle: 'Terang, Gelap, atau ikuti sistem',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ThemePage()),
        ),
      ),
      _SettingsRow(
        tintBg: AppColors.tintAmberBg,
        tintFg: AppColors.tintAmberFg,
        icon: Icons.language,
        title: 'Bahasa',
        subtitle: 'Indonesia',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const LanguagePage()),
        ),
      ),
      _SettingsRow(
        tintBg: AppColors.tintBlueBg,
        tintFg: AppColors.tintBlueFg,
        icon: Icons.cloud_outlined,
        title: 'Backup Database',
        subtitle: 'Kelola backup & restore',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const BackupPage()),
        ),
      ),
      _SettingsRow(
        tintBg: AppColors.tintPeachBg,
        tintFg: AppColors.tintPeachFg,
        icon: Icons.bolt_rounded,
        title: 'Muat Ulang Data Demo',
        subtitle: 'Reset & isi garasi contoh (2 kendaraan + riwayat 6 bln)',
        onTap: () async {
          final vehicleBloc = context.read<VehicleBloc>();
          final messenger = ScaffoldMessenger.of(context);
          final userId = await DemoDataSeeder.seedAndLogin();
          if (!mounted) return;
          vehicleBloc.add(LoadVehicles(userId));
          await _loadUserData();
          messenger.showSnackBar(
            SnackBar(
              content: Text(
                'Garasi Demo berhasil dimuat ulang!',
                style: GoogleFonts.plusJakartaSans(color: Colors.white),
              ),
              backgroundColor: AppColors.primary,
            ),
          );
        },
      ),
      _SettingsRow(
        tintBg: AppColors.tintRoseBg,
        tintFg: AppColors.tintRoseFg,
        icon: Icons.delete_sweep_outlined,
        title: 'Reset / Kosongkan Garasi',
        subtitle: 'Hapus seluruh data kendaraan, BBM, servis & dokumen',
        onTap: _confirmResetGarage,
      ),
    ];
  }

  Future<void> _confirmResetGarage() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          'Kosongkan Garasi?',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Seluruh data kendaraan, catatan BBM, riwayat servis, dan dokumen pada akun ini akan dihapus permanen agar Anda bisa mulai dari awal.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            color: AppColors.textMuted,
            height: 1.45,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Batal',
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.textSoft,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Ya, Kosongkan',
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.danger,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;
    final vehicleBloc = context.read<VehicleBloc>();
    final messenger = ScaffoldMessenger.of(context);
    final userId = await AuthLocalDatasource().getUserId();
    if (userId == null) return;

    await DemoDataSeeder.clearUserGarage(userId);
    if (!mounted) return;
    vehicleBloc.add(LoadVehicles(userId));
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          'Garasi berhasil dikosongkan.',
          style: GoogleFonts.plusJakartaSans(color: Colors.white),
        ),
        backgroundColor: AppColors.danger,
      ),
    );
  }

  List<_SettingsRow> _otherRows() {
    return [
      _SettingsRow(
        tintBg: AppColors.tintMintBg,
        tintFg: AppColors.tintMintFg,
        icon: Icons.help_outline,
        title: 'Bantuan & FAQ',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const HelpPage()),
        ),
      ),
      _SettingsRow(
        tintBg: AppColors.tintLavenderBg,
        tintFg: AppColors.tintLavenderFg,
        icon: Icons.gavel_rounded,
        title: 'Syarat & Ketentuan',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const TermsPage()),
        ),
      ),
      _SettingsRow(
        tintBg: AppColors.tintBlueBg,
        tintFg: AppColors.tintBlueFg,
        icon: Icons.privacy_tip_outlined,
        title: 'Kebijakan Privasi',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PrivacyPage()),
        ),
      ),
      _SettingsRow(
        tintBg: AppColors.tintPeachBg,
        tintFg: AppColors.tintPeachFg,
        icon: Icons.star_outline,
        title: 'Beri Rating',
        onTap: () => _showRatingDialog(),
      ),
      _SettingsRow(
        tintBg: AppColors.tintAmberBg,
        tintFg: AppColors.tintAmberFg,
        icon: Icons.info_outline,
        title: 'Tentang Aplikasi',
        subtitle: 'Versi 1.1.0',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AboutPage()),
        ),
      ),
    ];
  }

  void _showRatingDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Beri Rating',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                5,
                (i) => Icon(Icons.star,
                    color: AppColors.tintAmberFg, size: 36),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Terima kasih telah menggunakan MotoVault!',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.textMuted,
                fontSize: 13,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Tutup',
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.textSoft,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Transform.translate(
      offset: const Offset(0, -24),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        child: GestureDetector(
          onTap: () async {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: Text(
                  'Keluar',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                content: Text(
                  'Apakah Anda yakin ingin keluar?',
                  style: GoogleFonts.plusJakartaSans(),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: Text(
                      'Batal',
                      style: GoogleFonts.plusJakartaSans(
                        color: AppColors.textSoft,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: Text(
                      'Keluar',
                      style: GoogleFonts.plusJakartaSans(
                        color: AppColors.danger,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            );
            if (confirm == true && mounted) {
              await AuthLocalDatasource().clearSession();
              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (route) => false,
                );
              }
            }
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border.all(color: AppColors.border, width: 1.5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                'Keluar',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.danger,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVersionText() {
    return Transform.translate(
      offset: const Offset(0, -24),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Center(
          child: Text(
            'MotoVault v1.1.0',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              color: AppColors.textSoft,
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingsRow {
  final Color tintBg;
  final Color tintFg;
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  _SettingsRow({
    required this.tintBg,
    required this.tintFg,
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
  });
}
