import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../utils/responsive.dart';
import '../widgets/navbar/navbar.dart';
import 'home_screen.dart';
import 'history_screen.dart';
import 'comparison_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  void _goTo(int i) {
    if (_index == i) return;
    _scaffoldKey.currentState?.closeDrawer();
    setState(() => _index = i);
  }

  @override
  Widget build(BuildContext context) {
    final isWide = Responsive.isWide(context);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.bgOf(context),
      drawer: isWide
          ? null
          : Drawer(
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: NavBar(currentIndex: _index, onChangePage: _goTo),
            ),
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (isWide)
              NavBar(currentIndex: _index, onChangePage: _goTo),
            Expanded(
              child: IndexedStack(
                index: _index,
                children: const [
                  HomeScreen(),
                  HistoryScreen(),
                  ComparisonScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
