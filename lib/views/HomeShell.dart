import 'package:flutter/material.dart';

import 'HomeView.dart';
import 'MapView.dart';
import 'ProfileView.dart';
import 'CommunitiesListView.dart';

import '../components/GigmapBottomBar.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({
    super.key,
    this.initialIndex = 0,
    this.selectedConcertId,
    this.profileUserId,
  });

  final int initialIndex;
  final int? selectedConcertId;
  final int? profileUserId;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, 3);
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      const HomeView(),
      MapView(selectedConcertId: widget.selectedConcertId),
      const CommunitiesListView(),
      ProfileView(userId: widget.profileUserId),
    ];

    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xFFF3F3F3),
      body: IndexedStack(index: _currentIndex, children: pages),
      bottomNavigationBar: (_currentIndex == 3 && widget.profileUserId != null)
          ? null
          : GigmapBottomBar(
              currentIndex: _currentIndex,
              onItemSelected: (i) {
                setState(() => _currentIndex = i);
              },
            ),
    );
  }
}
