import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter_kendaraanku_app/core/constants/colors.dart';
import 'package:flutter_kendaraanku_app/data/database_helper.dart';
import 'package:flutter_kendaraanku_app/presentation/auth/pages/splash_page.dart';

class BackupPage extends StatefulWidget {
  const BackupPage({super.key});

  @override
  State<BackupPage> createState() => _BackupPageState();
}

class _BackupPageState extends State<BackupPage> {
  static const MethodChannel _backupChannel =
      MethodChannel('com.abdan.motovault/backup');

  List<_BackupFile> _backups = [];
  bool _loading = true;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _loadBackups();
  }

  Future<void> _loadBackups() async {
    setState(() => _loading = true);
    try {
      final dir = await getApplicationDocumentsDirectory();
      final files = dir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.contains('kendaraanku_backup_'))
          .toList();
      files.sort((a, b) =>
          b.statSync().modified.compareTo(a.statSync().modified));

      final list = files.map((f) {
        final stat = f.statSync();
        return _BackupFile(
          file: f,
          modified: stat.modified,
          sizeBytes: stat.size,
        );
      }).toList();

      if (mounted) {
        setState(() {
          _backups = list;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _createBackup() async {
    setState(() => _busy = true);
    try {
      final dbPath = await getDatabasesPath();
      final dbFile = File('$dbPath/kendaraanku.db');
      if (!await dbFile.exists()) {
        _showSnack('Database tidak ditemukan', danger: true);
        return;
      }
      final dir = await getApplicationDocumentsDirectory();
      final ts = DateTime.now().millisecondsSinceEpoch;
      await dbFile.copy('${dir.path}/kendaraanku_backup_$ts.db');
      _showSnack('Backup berhasil dibuat');
      await _loadBackups();
    } catch (e) {
      _showSnack('Gagal backup: $e', danger: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<bool> _isValidSqliteFile(File file) async {
    try {
      if (!await file.exists()) return false;
      final length = await file.length();
      if (length < 100) return false;
      final bytes = await file.openRead(0, 15).expand((b) => b).toList();
      final header = ascii.decode(bytes, allowInvalid: true);
      return header.startsWith('SQLite format 3');
    } catch (_) {
      return false;
    }
  }

  Future<void> _applyRestoreFromFile(File sourceFile) async {
    await DatabaseHelper.getInstance().close();
    final dbPath = await getDatabasesPath();
    final targetPath = '$dbPath/kendaraanku.db';
    final walFile = File('$targetPath-wal');
    final shmFile = File('$targetPath-shm');
    if (await walFile.exists()) await walFile.delete();
    if (await shmFile.exists()) await shmFile.delete();
    await sourceFile.copy(targetPath);
  }

  Future<void> _importExternalBackup() async {
    try {
      final pickedPath =
          await _backupChannel.invokeMethod<String>('pickBackupFile');
      if (pickedPath == null || pickedPath.isEmpty) return;

      final pickedFile = File(pickedPath);
      final isValid = await _isValidSqliteFile(pickedFile);
      if (!isValid) {
        _showSnack(
          'File tidak valid. Pilih file backup database (.db) MotoVault.',
          danger: true,
        );
        return;
      }

      if (!mounted) return;
      final confirm = await _confirmDialog(
        title: 'Impor & Restore Backup?',
        message:
            'File backup valid terdeteksi. File akan disimpan ke riwayat backup dan langsung di-restore ke aplikasi.',
        confirmLabel: 'Impor & Restore',
      );
      if (confirm != true) return;

      setState(() => _busy = true);
      final dir = await getApplicationDocumentsDirectory();
      final ts = DateTime.now().millisecondsSinceEpoch;
      final savedCopy =
          await pickedFile.copy('${dir.path}/kendaraanku_backup_$ts.db');
      await _applyRestoreFromFile(savedCopy);
      await _loadBackups();
      if (mounted) {
        await _showRestoreSuccessDialog();
      }
    } on MissingPluginException {
      _showSnack(
        'Fitur pilih file eksternal hanya tersedia di perangkat Android.',
        danger: true,
      );
    } catch (e) {
      _showSnack('Gagal impor backup: $e', danger: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _restore(_BackupFile b) async {
    final confirm = await _confirmDialog(
      title: 'Restore Backup?',
      message:
          'Data saat ini akan ditimpa dengan isi backup ${_fmtDate(b.modified)}. Lanjutkan?',
      confirmLabel: 'Restore',
    );
    if (confirm != true) return;

    setState(() => _busy = true);
    try {
      await _applyRestoreFromFile(b.file);
      if (mounted) {
        await _showRestoreSuccessDialog();
      }
    } catch (e) {
      _showSnack('Gagal restore: $e', danger: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _showRestoreSuccessDialog() async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.tintMintBg,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_rounded,
                color: AppColors.tintMintFg,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Restore Berhasil',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: AppColors.text,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'Database telah berhasil dipulihkan. Aplikasi akan dimuat ulang ke halaman awal agar seluruh data dan sesi tersinkronisasi sempurna.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            color: AppColors.textMuted,
            height: 1.5,
          ),
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const SplashPage()),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                'Muat Ulang Aplikasi',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _share(_BackupFile b) async {
    try {
      final fileName = b.file.uri.pathSegments.last;
      await Share.shareXFiles(
        [XFile(b.file.path, name: fileName, mimeType: 'application/octet-stream')],
        subject: 'Backup MotoVault · ${_fmtDate(b.modified)}',
        text:
            'Backup database MotoVault ${_fmtDate(b.modified)} (${_fmtSize(b.sizeBytes)}).',
      );
    } catch (e) {
      _showSnack('Gagal kirim: $e', danger: true);
    }
  }

  Future<void> _delete(_BackupFile b) async {
    final confirm = await _confirmDialog(
      title: 'Hapus Backup?',
      message: 'File backup akan dihapus permanen.',
      confirmLabel: 'Hapus',
      destructive: true,
    );
    if (confirm != true) return;

    try {
      await b.file.delete();
      _showSnack('Backup dihapus');
      await _loadBackups();
    } catch (e) {
      _showSnack('Gagal hapus: $e', danger: true);
    }
  }

  Future<bool?> _confirmDialog({
    required String title,
    required String message,
    required String confirmLabel,
    bool destructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title,
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
        content: Text(message,
            style: GoogleFonts.plusJakartaSans(fontSize: 13)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Batal',
                style: GoogleFonts.plusJakartaSans(
                    color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              confirmLabel,
              style: GoogleFonts.plusJakartaSans(
                color: destructive ? AppColors.danger : AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSnack(String msg, {bool danger = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.plusJakartaSans()),
        backgroundColor: danger ? AppColors.danger : AppColors.primary,
      ),
    );
  }

  String _fmtDate(DateTime d) =>
      DateFormat('dd MMM yyyy · HH:mm', 'id_ID').format(d);

  String _fmtSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / 1024 / 1024).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          color: AppColors.text,
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Backup Database',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.text,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.divider),
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildHero(),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: _busy ? null : _createBackup,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: _busy
                          ? AppColors.primary.withValues(alpha: 0.5)
                          : AppColors.primary,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: _busy
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.backup_rounded,
                                    color: Colors.white, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'Buat Backup Sekarang',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: _busy ? null : _importExternalBackup,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.primary,
                        width: 1.4,
                      ),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.file_open_outlined,
                            color: AppColors.primary,
                            size: 19,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Impor File Backup dari HP (.db)',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Text(
                      'RIWAYAT BACKUP',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textMuted,
                        letterSpacing: 0.44,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${_backups.length} file',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSoft,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (_backups.isEmpty) _buildEmpty() else ..._backups.map(_buildItem),
              ],
            ),
    );
  }

  Widget _buildHero() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.cloud_outlined,
                color: Colors.white, size: 26),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Backup Lokal',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Salinan database tersimpan di perangkat Anda',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.tintBlueBg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.folder_open_rounded,
                color: AppColors.tintBlueFg, size: 28),
          ),
          const SizedBox(height: 14),
          Text(
            'Belum ada backup',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tekan tombol di atas untuk membuat\nbackup pertama Anda.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: AppColors.textMuted,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(_BackupFile b) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.tintMintBg,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(Icons.snippet_folder_rounded,
                  color: AppColors.tintMintFg, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _fmtDate(b.modified),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${_fmtSize(b.sizeBytes)} · ${b.file.uri.pathSegments.last}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert_rounded,
                  color: AppColors.textMuted),
              onSelected: (v) {
                if (v == 'share') _share(b);
                if (v == 'restore') _restore(b);
                if (v == 'delete') _delete(b);
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'share',
                  child: Row(
                    children: [
                      Icon(Icons.ios_share_rounded,
                          color: AppColors.text, size: 18),
                      const SizedBox(width: 10),
                      Text('Kirim',
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 13)),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'restore',
                  child: Row(
                    children: [
                      const Icon(Icons.restore_rounded,
                          color: AppColors.primary, size: 18),
                      const SizedBox(width: 10),
                      Text('Restore',
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 13)),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      const Icon(Icons.delete_outline,
                          color: AppColors.danger, size: 18),
                      const SizedBox(width: 10),
                      Text('Hapus',
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 13, color: AppColors.danger)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BackupFile {
  final File file;
  final DateTime modified;
  final int sizeBytes;
  _BackupFile({
    required this.file,
    required this.modified,
    required this.sizeBytes,
  });
}
