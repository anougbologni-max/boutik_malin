import 'package:flutter/material.dart';

import '../utils/constants.dart';
import 'dashboard_screen.dart';
import 'history_screen.dart';
import 'product_list_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _tabs = const [
    DashboardScreen(),
    ProductListScreen(),
    HistoryScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _tabs),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey.shade500,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined, size: 24),
            activeIcon: Icon(Icons.dashboard, size: 28),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined, size: 24),
            activeIcon: Icon(Icons.inventory_2, size: 28),
            label: 'Produits',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined, size: 24),
            activeIcon: Icon(Icons.history, size: 28),
            label: 'Historique',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined, size: 24),
            activeIcon: Icon(Icons.settings, size: 28),
            label: 'Paramètres',
          ),
        ],
      ),
    );
  }
}
