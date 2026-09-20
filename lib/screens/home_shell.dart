import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'garden_log_screen.dart';
import 'reward_store_screen.dart';
import 'roll_home_tab.dart';

/// Screen 2 shell: bottom nav bar switching between Roll (Home), Reward
/// Store, and My Garden Log.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  static const _tabs = [
    RollHomeTab(),
    RewardStoreScreen(),
    GardenLogScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(child: IndexedStack(index: _index, children: _tabs)),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.neonMint.withOpacity(0.15))),
        ),
        child: SafeArea(
          top: false,
          child: BottomNavigationBar(
            currentIndex: _index,
            onTap: (i) => setState(() => _index = i),
            backgroundColor: Colors.transparent,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: AppColors.neonMint,
            unselectedItemColor: AppColors.softSage.withOpacity(0.6),
            showUnselectedLabels: true,
            elevation: 0,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.casino_rounded), label: 'Roll'),
              BottomNavigationBarItem(icon: Icon(Icons.storefront_rounded), label: 'Reward Store'),
              BottomNavigationBarItem(icon: Icon(Icons.menu_book_rounded), label: 'Garden Log'),
            ],
          ),
        ),
      ),
    );
  }
}
