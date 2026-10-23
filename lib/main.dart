import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:platku/core/services/notification_service.dart';
import 'package:platku/core/theme.dart';
import 'package:platku/core/theme_controller.dart';
import 'package:platku/presentation/auth/pages/splash_page.dart';
import 'package:intl/date_symbol_data_local.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  await ThemeController.instance.load();
  await NotificationService.instance.init();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.instance,
      builder: (context, themeMode, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'PlatKU',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,
          builder: (context, child) {
            return _ThemeRebuildWrapper(
              themeMode: themeMode,
              child: child ?? const SizedBox.shrink(),
            );
          },
          home: const SplashPage(),
        );
      },
    );
  }
}

class _ThemeRebuildWrapper extends StatefulWidget {
  final ThemeMode themeMode;
  final Widget child;

  const _ThemeRebuildWrapper({
    required this.themeMode,
    required this.child,
  });

  @override
  State<_ThemeRebuildWrapper> createState() => _ThemeRebuildWrapperState();
}

class _ThemeRebuildWrapperState extends State<_ThemeRebuildWrapper>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    if (widget.themeMode == ThemeMode.system && mounted) {
      _markSubtreeNeedsBuild(context as Element);
    }
  }

  @override
  void didUpdateWidget(covariant _ThemeRebuildWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.themeMode != widget.themeMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _markSubtreeNeedsBuild(context as Element);
        }
      });
    }
  }

  void _markSubtreeNeedsBuild(Element element) {
    element.markNeedsBuild();
    element.visitChildren(_markSubtreeNeedsBuild);
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
