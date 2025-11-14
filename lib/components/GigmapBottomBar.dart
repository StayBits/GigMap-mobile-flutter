import 'package:flutter/material.dart';

class GigmapBottomBar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onItemSelected;

  const GigmapBottomBar({
    super.key,
    required this.currentIndex,
    required this.onItemSelected,
  });

  @override
  State<GigmapBottomBar> createState() => _GigmapbottombarState();
}

class _GigmapbottombarState extends State<GigmapBottomBar> {
  static const Color mainColor = Color(0xFF5C0F1A);
  static const Color circleColor = Color(0xFF5C0F1A);
  static const Color selectedIconColor = Colors.white;
  static const Color unselectedIconColor = Colors.white;

  final List<IconData> _icons = const [
    Icons.home,
    Icons.location_on,
    Icons.person_add_alt_1,
    Icons.settings,
  ];


  double _currentOffset = 0;

  @override
  Widget build(BuildContext context) {
    const double circleRadius = 32;
    const double circleGap = 6;
    const double barHeight = 64;

    return SizedBox(
      height: barHeight + circleRadius,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final step = width / (_icons.length * 2);

          final targetOffset =
              step + widget.currentIndex * 2 * step; // en px

          if (_currentOffset == 0) {
            _currentOffset = targetOffset;
          }

          return TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: _currentOffset, end: targetOffset),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            onEnd: () {
              _currentOffset = targetOffset;
            },
            builder: (context, value, child) {
              final cutoutCenterX = value;
              const double circleR = circleRadius;
              const double gap = circleGap;

              return Stack(
                clipBehavior: Clip.none,
                children: [

                  Positioned(
                    top: circleR,
                    left: 0,
                    right: 0,
                    child: ClipPath(
                      clipper: _BottomBarClipper(
                        offset: cutoutCenterX,
                        circleRadius: circleR,
                        circleGap: gap,
                      ),
                      child: Container(
                        height: barHeight,
                        color: mainColor,
                      ),
                    ),
                  ),

                  Positioned(
                    left: cutoutCenterX - circleR,
                    top: 0,
                    child: Container(
                      width: circleR * 2,
                      height: circleR * 2,
                      decoration: const BoxDecoration(
                        color: circleColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _icons[widget.currentIndex],
                        color: selectedIconColor,
                        size: 28,
                      ),
                      ),
                    ),

                  Positioned(
                    top: circleR,
                    left: 0,
                    right: 0,
                    child: SizedBox(
                      height: barHeight,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: List.generate(_icons.length, (index) {
                          final isSelected = index == widget.currentIndex;
                          return Expanded(
                            child: InkWell(
                              onTap: () => widget.onItemSelected(index),
                              child: SizedBox(
                                height: barHeight,
                                child: Center(
                                  child: !isSelected
                                      ? Icon(
                                    _icons[index],
                                    color: unselectedIconColor,
                                    size: 26,
                                  )
                                      : const SizedBox.shrink(),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

/// Clipper que replica tu `BottomBarShape` de Kotlin
class _BottomBarClipper extends CustomClipper<Path> {
  final double offset;
  final double circleRadius;
  final double circleGap;

  _BottomBarClipper({
    required this.offset,
    required this.circleRadius,
    this.circleGap = 6,
  });

  @override
  Path getClip(Size size) {
    final double cutoutCenterX = offset;
    final double cutoutRadius = circleRadius + circleGap;
    final double cutoutEdgeOffset = cutoutRadius * 1.5;
    final double cutoutLeftX = cutoutCenterX - cutoutEdgeOffset;
    final double cutoutRightX = cutoutCenterX + cutoutEdgeOffset;

    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, 0)
      ..lineTo(cutoutLeftX, 0)
    // primera curva
      ..cubicTo(
        cutoutCenterX - cutoutRadius,
        0,
        cutoutCenterX - cutoutRadius,
        cutoutRadius,
        cutoutCenterX,
        cutoutRadius,
      )
    // segunda curva
      ..cubicTo(
        cutoutCenterX + cutoutRadius,
        cutoutRadius,
        cutoutCenterX + cutoutRadius,
        0,
        cutoutRightX,
        0,
      )
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    return path;
  }

  @override
  bool shouldReclip(_BottomBarClipper oldClipper) {
    return oldClipper.offset != offset ||
        oldClipper.circleRadius != circleRadius ||
        oldClipper.circleGap != circleGap;
  }
}
