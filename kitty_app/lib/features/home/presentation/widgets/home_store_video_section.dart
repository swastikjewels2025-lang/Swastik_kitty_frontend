import 'dart:async';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_spacing.dart';
import 'home_section_heading.dart';

/// Store Video Section for Home Screen where showroom and craftsmanship videos
/// can be previewed and played.
class HomeStoreVideoSection extends StatefulWidget {
  const HomeStoreVideoSection({super.key});

  @override
  State<HomeStoreVideoSection> createState() => _HomeStoreVideoSectionState();
}

class _HomeStoreVideoSectionState extends State<HomeStoreVideoSection>
    with SingleTickerProviderStateMixin {
  bool _isPlaying = false;
  bool _isMuted = false;
  double _playbackProgress = 0.32; // 32% played initially
  Timer? _playbackTimer;

  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    if (WidgetsBinding.instance is WidgetsFlutterBinding) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _playbackTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying) {
        _playbackTimer = Timer.periodic(const Duration(milliseconds: 250), (timer) {
          if (!mounted) return;
          setState(() {
            _playbackProgress += 0.005;
            if (_playbackProgress >= 1.0) {
              _playbackProgress = 0.0;
              _isPlaying = false;
              timer.cancel();
            }
          });
        });
      } else {
        _playbackTimer?.cancel();
      }
    });
  }


  void _openFullScreenVideo() {
    showDialog<void>(
      context: context,
      builder: (BuildContext ctx) {
        return Dialog(
          backgroundColor: Colors.black,
          insetPadding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const Padding(
                    padding: EdgeInsets.all(12),
                    child: Text(
                      'Swastik Flagship Store Tour (4K)',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    Image.asset(
                      'assets/images/hero_carousel_1.jpg',
                      fit: BoxFit.cover,
                    ),
                    Center(
                      child: IconButton(
                        iconSize: 56,
                        icon: Icon(
                          _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                          color: AppColors.honeyGoldAccent,
                        ),
                        onPressed: () {
                          _togglePlayPause();
                          Navigator.of(ctx).pop();
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  'Heritage vault walkthrough, master karigars crafting 22K jewellery, and showroom consultation lounge.',
                  style: TextStyle(color: Color(0xFFC0BCB5), fontSize: 12),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final int currentSeconds = (_playbackProgress * 155).toInt(); // 2m 35s video
    final String currentMinutesStr = '${currentSeconds ~/ 60}:${(currentSeconds % 60).toString().padLeft(2, '0')}';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.fromLTRB(10, 14, 10, 12),
      decoration: BoxDecoration(
        color: AppColors.creamIvoryCard,
        borderRadius: AppRadius.border20,
        border: Border.all(color: AppColors.warmLinenInset, width: 1),
        boxShadow: AppShadows.cardSubtle,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // Section Title
          const HomeSectionHeading(
            title: 'Experience Swastik',
            padding: EdgeInsets.only(bottom: 12),
          ),

          // Main Video Player Container
          ClipRRect(
            borderRadius: AppRadius.border16,
            child: Stack(
              children: <Widget>[
                // Video Poster / Backdrop
                AspectRatio(
                  aspectRatio: 16 / 9.5,
                  child: Image.asset(
                    'assets/images/hero_carousel_1.jpg',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: AppColors.espressoCharcoal,
                      child: const Center(
                        child: Icon(Icons.storefront_rounded, size: 50, color: AppColors.honeyGoldAccent),
                      ),
                    ),
                  ),
                ),

                // Dark Cinematic Gradient Overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: <Color>[
                          Colors.black.withValues(alpha: 0.25),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.75),
                        ],
                      ),
                    ),
                  ),
                ),

                // Top Badge: 4K & Store Location
                Positioned(
                  top: 10,
                  left: 10,
                  right: 10,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.65),
                          borderRadius: AppRadius.border8,
                          border: Border.all(color: AppColors.honeyGoldAccent.withValues(alpha: 0.6)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: AppColors.statusSuccessText,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 5),
                            const Text(
                              '4K ULTRA HD • STORE TOUR',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: _openFullScreenVideo,
                        icon: const Icon(Icons.fullscreen_rounded, color: Colors.white, size: 22),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        tooltip: 'Full Screen',
                      ),
                    ],
                  ),
                ),

                // Center: Play / Pause Button with Pulsing Gold Glow
                Positioned.fill(
                  child: Center(
                    child: GestureDetector(
                      onTap: _togglePlayPause,
                      child: ScaleTransition(
                        scale: _isPlaying ? const AlwaysStoppedAnimation<double>(1.0) : _pulseAnimation,
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.honeyGoldAccent,
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                color: AppColors.honeyGoldAccent.withValues(alpha: 0.5),
                                blurRadius: 16,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Icon(
                            _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                            color: AppColors.deepUmberBronze,
                            size: 34,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Bottom Video Controls & Scrub Bar
                Positioned(
                  bottom: 8,
                  left: 12,
                  right: 12,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      // Progress Bar
                      ClipRRect(
                        borderRadius: AppRadius.border8,
                        child: LinearProgressIndicator(
                          value: _playbackProgress,
                          backgroundColor: Colors.white.withValues(alpha: 0.3),
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.honeyGoldAccent),
                          minHeight: 4,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            '$currentMinutesStr / 02:35',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _isMuted = !_isMuted;
                              });
                            },
                            child: Icon(
                              _isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

        ],
      ),
    );
  }
}
