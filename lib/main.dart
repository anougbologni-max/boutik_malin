import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/product_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/stock_movement_provider.dart';
import 'screens/home_screen.dart';
import 'services/database_service.dart';
import 'services/notification_service.dart';
import 'utils/constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.instance.initialize();
  runApp(const BoutikMalinApp());
}

class BoutikMalinApp extends StatelessWidget {
  const BoutikMalinApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ProductProvider(DatabaseService.instance)..loadAll(),
        ),
        ChangeNotifierProxyProvider<ProductProvider, StockMovementProvider>(
          create: (_) => StockMovementProvider(DatabaseService.instance)..loadMovements(),
          update: (_, productProvider, stockMovementProvider) =>
              stockMovementProvider!..attachProductProvider(productProvider),
        ),
        ChangeNotifierProvider(create: (_) => SettingsProvider()..load()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, child) {
          return MaterialApp(
            title: 'Boutik Malin',
            debugShowCheckedModeBanner: false,
            themeMode: settings.darkMode ? ThemeMode.dark : ThemeMode.light,
            theme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.light,
              scaffoldBackgroundColor: AppColors.background,
              colorScheme: ColorScheme.fromSeed(
                seedColor: AppColors.primary,
                primary: AppColors.primary,
                secondary: AppColors.accent,
              ),
              appBarTheme: const AppBarTheme(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.dark,
              scaffoldBackgroundColor: const Color(0xFF121212),
              colorScheme: ColorScheme.fromSeed(
                seedColor: AppColors.primary,
                brightness: Brightness.dark,
                primary: AppColors.primary,
                secondary: AppColors.accent,
              ),
              appBarTheme: const AppBarTheme(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
