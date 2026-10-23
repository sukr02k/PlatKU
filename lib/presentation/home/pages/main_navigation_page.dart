import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:platku/core/components/bottom_nav.dart';
import 'package:platku/core/constants/colors.dart';
import 'package:platku/core/services/notification_service.dart';
import 'package:platku/data/local/auth_local_datasource.dart';
import 'package:platku/data/repositories/vehicle_repository.dart';
import 'package:platku/presentation/blocs/vehicle/vehicle_bloc.dart';
import 'package:platku/presentation/blocs/vehicle/vehicle_event.dart';
import 'package:platku/presentation/home/pages/home_page.dart';
import 'package:platku/presentation/fuel/pages/fuel_page.dart';
import 'package:platku/presentation/service/pages/service_page.dart';
import 'package:platku/presentation/docs/pages/docs_page.dart';
import 'package:platku/presentation/profile/pages/profile_page.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    NotificationService.instance.requestPermission();
  }

  final List<Widget> _pages = const [
    HomePage(),
    FuelPage(),
    ServicePage(),
    DocsPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final bloc = VehicleBloc(VehicleRepository());
        _loadVehicles(bloc);
        return bloc;
      },
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return;
          if (_currentIndex != 0) {
            setState(() => _currentIndex = 0);
            return;
          }
          await SystemNavigator.pop();
        },
        child: Scaffold(
          backgroundColor: AppColors.bg,
          body: IndexedStack(
            index: _currentIndex,
            children: _pages,
          ),
          bottomNavigationBar: BottomNav(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
          ),
        ),
      ),
    );
  }

  Future<void> _loadVehicles(VehicleBloc bloc) async {
    final userId = await AuthLocalDatasource().getUserId();
    if (userId != null) {
      bloc.add(LoadVehicles(userId));
    }
  }
}
