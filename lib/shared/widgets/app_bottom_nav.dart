import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';

import 'app_scaffold.dart';

class AppBottomNav extends ConsumerStatefulWidget {
  final String location;

  const AppBottomNav({super.key, required this.location});

  @override
  ConsumerState<AppBottomNav> createState() => _AppBottomNavState();
}

class _AppBottomNavState extends ConsumerState<AppBottomNav>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  int _prevIndex = 0;
  int _currentIndex = 0;

  int _indexFromLocation() {
    if (widget.location.startsWith('/wallet')) return 1;
    if (widget.location.startsWith('/transactions')) return 2;
    if (widget.location.startsWith('/profile')) return 3;
    return 0;
  }

  @override
  void initState() {
    super.initState();
    _currentIndex = _indexFromLocation();
    _prevIndex = _currentIndex;
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    // Initially set controller value to 1.0 since it starts at the active index
    _animationController.value = 1.0;
  }

  @override
  void didUpdateWidget(covariant AppBottomNav oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newIndex = _indexFromLocation();
    if (newIndex != _currentIndex) {
      setState(() {
        _prevIndex = _currentIndex;
        _currentIndex = newIndex;
      });
      _animationController.forward(from: 0.0);
      
      // Make sure bottom nav becomes visible on tab change
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref.read(bottomNavVisibleProvider.notifier).setVisible(true);
        }
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/wallet');
        break;
      case 2:
        context.go('/transactions');
        break;
      case 3:
        context.go('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.home_outlined, Icons.home, 'Beranda'),
      (Icons.account_balance_wallet_outlined, Icons.account_balance_wallet, 'Dompet'),
      (Icons.receipt_long_outlined, Icons.receipt_long, 'Riwayat'),
      (Icons.person_outline, Icons.person, 'Profil'),
    ];

    // Compute coordinate alignments for transition endpoints
    final double prevAlignmentX = -1.0 + (_prevIndex * (2.0 / (items.length - 1)));
    final double targetAlignmentX = -1.0 + (_currentIndex * (2.0 / (items.length - 1)));

    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: SafeArea(
          top: false,
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              // Interpolate line alignment based on the unified animation progress
              final double currentAlignmentX =
                  prevAlignmentX + (targetAlignmentX - prevAlignmentX) * _animation.value;

              return Stack(
                children: [
                  // Sliding Active Indicator Line at the top
                  Align(
                    alignment: Alignment(currentAlignmentX, -1.0),
                    child: FractionallySizedBox(
                      widthFactor: 1.0 / items.length,
                      child: Container(
                        height: 3,
                        margin: const EdgeInsets.symmetric(horizontal: 24),
                        decoration: const BoxDecoration(
                          color: AppColors.primaryRed,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(3),
                            bottomRight: Radius.circular(3),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Navigation Items Row
                  Positioned.fill(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: List.generate(items.length, (index) {
                        final item = items[index];

                        double clipFactor = 0.0;
                        Alignment clipAlignment = Alignment.center;
                        Color textColor = AppColors.textSecondary;
                        FontWeight fontWeight = FontWeight.normal;

                        final bool isL2R = _currentIndex > _prevIndex;

                        if (index == _currentIndex) {
                          // Tab B (revealing active red)
                          clipFactor = _animation.value;
                          clipAlignment = isL2R ? Alignment.centerLeft : Alignment.centerRight;
                          textColor = Color.lerp(
                            AppColors.textSecondary,
                            AppColors.primaryRed,
                            _animation.value,
                          )!;
                          if (_animation.value >= 0.5) {
                            fontWeight = FontWeight.w600;
                          }
                        } else if (index == _prevIndex) {
                          // Tab A (hiding active red, revealing inactive grey)
                          clipFactor = 1.0 - _animation.value;
                          clipAlignment = isL2R ? Alignment.centerRight : Alignment.centerLeft;
                          textColor = Color.lerp(
                            AppColors.primaryRed,
                            AppColors.textSecondary,
                            _animation.value,
                          )!;
                          if (_animation.value < 0.5) {
                            fontWeight = FontWeight.w600;
                          }
                        } else {
                          // Other inactive tabs remain static grey
                          clipFactor = 0.0;
                          textColor = AppColors.textSecondary;
                          fontWeight = FontWeight.normal;
                        }

                        return Expanded(
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => _onTap(context, index),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        // Grey Outlined Inactive Icon with fade-out cross-fade
                                        Opacity(
                                          opacity: (1.0 - clipFactor).clamp(0.0, 1.0),
                                          child: Icon(
                                            item.$1,
                                            color: AppColors.textSecondary,
                                            size: 22,
                                          ),
                                        ),
                                        // Red Solid Active Icon with animated static clipping mask
                                        ClipRect(
                                          clipper: HorizontalClipClipper(
                                            clipFactor: clipFactor,
                                            alignment: clipAlignment,
                                          ),
                                          child: Icon(
                                            item.$2,
                                            color: AppColors.primaryRed,
                                            size: 22,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item.$3,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: fontWeight,
                                        color: textColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class HorizontalClipClipper extends CustomClipper<Rect> {
  final double clipFactor;
  final Alignment alignment;

  HorizontalClipClipper({required this.clipFactor, required this.alignment});

  @override
  Rect getClip(Size size) {
    if (alignment == Alignment.centerLeft) {
      // Reveal crop from left-to-right (keeps icon stationary)
      return Rect.fromLTWH(0, 0, size.width * clipFactor, size.height);
    } else {
      // Reveal crop from right-to-left (keeps icon stationary)
      return Rect.fromLTWH(
        size.width * (1.0 - clipFactor),
        0,
        size.width * clipFactor,
        size.height,
      );
    }
  }

  @override
  bool shouldReclip(covariant HorizontalClipClipper oldClipper) {
    return oldClipper.clipFactor != clipFactor || oldClipper.alignment != alignment;
  }
}
