import 'package:flutter/material.dart';
import 'package:gigmap_mobile_flutter/components/GigmapBottomBar.dart';
import 'package:gigmap_mobile_flutter/views/CommunitiesListView.dart';
import 'package:gigmap_mobile_flutter/views/ConcertList.dart';
import 'package:gigmap_mobile_flutter/views/HomeView.dart';
import 'package:gigmap_mobile_flutter/views/MapView.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  late int _currentIndex;

  static const List<Widget> _pages = [
    HomeView(),
    MapView(),
    CommunitiesListView(),

  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, _pages.length - 1);
  }

  void _handleNavigationTap(int index) {
    if (_currentIndex != index) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xFFF3F3F3),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: GigmapBottomBar(
        currentIndex: _currentIndex,
        onItemSelected: _handleNavigationTap,
      ),
    );
  }
}


