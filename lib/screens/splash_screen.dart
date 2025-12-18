import 'package:flutter/material.dart';
import 'package:musicapp/screens/update_check_screen.dart';
import 'dart:async';
import '../painters/particle_painter.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _glowController;
  late AnimationController _particleController;
  late Animation<double> _iconScale;
  late Animation<double> _iconRotation;
  late Animation<double> _textFade;
  late Animation<Offset> _textSlide;
  late Animation<double> _footerFade;
  late Animation<double> _glowPulse;
  late Animation<double> _glowIntensity;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startNavigationTimer();
  }

  void _initializeAnimations() {
    // Main animations controller
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // Glow controller - smooth pulsing
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    // Particle effect controller
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..repeat();

    // Icon animations
    _iconScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _iconRotation = Tween<double>(begin: 0, end: 6.2832).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
      ),
    );

    // Text animations
    _textFade = CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.4, 0.9, curve: Curves.easeIn),
    );

    _textSlide = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero)
        .animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.4, 0.9, curve: Curves.easeOut),
      ),
    );

    _footerFade = CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.6, 1.0, curve: Curves.easeIn),
    );

    // Optimized glow animations
    _glowPulse = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _glowIntensity = Tween<double>(begin: 0.4, end: 0.8).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _mainController.forward();
  }

  void _startNavigationTimer() {
    Timer(const Duration(milliseconds: 3500), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
            const UpdateCheckScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    _glowController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Particle effects background - cached builder
          RepaintBoundary(
            child: AnimatedBuilder(
              animation: _particleController,
              builder: (context, child) {
                return CustomPaint(
                  painter: ParticlePainter(_particleController.value),
                  size: Size.infinite,
                );
              },
            ),
          ),
          // Main content
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildAnimatedIcon(),
                const SizedBox(height: 45),
                _buildAnimatedText(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedIcon() {
    return AnimatedBuilder(
      animation: _mainController,
      builder: (context, child) {
        return Transform.rotate(
          angle: _iconRotation.value,
          child: Transform.scale(
            scale: _iconScale.value,
            child: AnimatedBuilder(
              animation: _glowController,
              builder: (context, iconChild) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    // Rotating glow ring
                    AnimatedBuilder(
                      animation: _particleController,
                      builder: (context, _) {
                        return Transform.rotate(
                          angle: _particleController.value * 6.28,
                          child: Container(
                            width: 170 * _glowPulse.value,
                            height: 170 * _glowPulse.value,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  Colors.transparent,
                                  Colors.deepPurpleAccent.withValues(
                                    alpha: _glowIntensity.value * 0.08,
                                  ),
                                  Colors.purpleAccent.withValues(
                                    alpha: _glowIntensity.value * 0.12,
                                  ),
                                  Colors.transparent,
                                ],
                                stops: const [0.0, 0.5, 0.7, 1.0],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    // Main glow container
                    Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.deepPurpleAccent.withValues(alpha: 0.2),
                            Colors.transparent,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.deepPurpleAccent.withValues(
                              alpha: _glowIntensity.value * 0.2,
                            ),
                            blurRadius: 50 * _glowPulse.value,
                            spreadRadius: 15 * _glowPulse.value,
                          ),
                          BoxShadow(
                            color: Colors.purpleAccent.withValues(
                              alpha: _glowIntensity.value * 0.3,
                            ),
                            blurRadius: 35 * _glowPulse.value,
                            spreadRadius: 10 * _glowPulse.value,
                          ),
                          BoxShadow(
                            color: Colors.deepPurpleAccent.withValues(
                              alpha: _glowIntensity.value * 0.4,
                            ),
                            blurRadius: 20 * _glowPulse.value,
                            spreadRadius: 5 * _glowPulse.value,
                          ),
                        ],
                      ),
                      child: iconChild,
                    ),
                  ],
                );
              },
              child: const Icon(
                Icons.music_note,
                size: 100,
                color: Colors.white,
                shadows: [
                  Shadow(
                    blurRadius: 25,
                    color: Colors.deepPurpleAccent,
                    offset: Offset.zero,
                  ),
                  Shadow(
                    blurRadius: 40,
                    color: Color(0x66673AB7),
                    offset: Offset.zero,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedText() {
    return FadeTransition(
      opacity: _textFade,
      child: SlideTransition(
        position: _textSlide,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTitle(),
            const SizedBox(height: 18),
            _buildSubtitle(),
            const SizedBox(height: 28),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return AnimatedBuilder(
      animation: _glowIntensity,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.deepPurpleAccent.withValues(
                  alpha: _glowIntensity.value * 0.25,
                ),
                blurRadius: 30 * _glowPulse.value,
                spreadRadius: 5 * _glowPulse.value,
              ),
            ],
          ),
          child: ShaderMask(
            shaderCallback: (bounds) {
              return const LinearGradient(
                colors: [Colors.white, Color(0xF2FFFFFF), Color(0xE6673AB7)],
              ).createShader(bounds);
            },
            child: child,
          ),
        );
      },
      child: const Text(
        "Music",
        style: TextStyle(
          color: Colors.white,
          fontSize: 42,
          fontWeight: FontWeight.bold,
          letterSpacing: 2.0,
          shadows: [
            Shadow(
              blurRadius: 15,
              color: Color(0x99673AB7),
              offset: Offset(0, 2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubtitle() {
    return AnimatedBuilder(
      animation: _glowIntensity,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.purpleAccent.withValues(
                  alpha: _glowIntensity.value * 0.15,
                ),
                blurRadius: 20 * _glowPulse.value,
                spreadRadius: 3 * _glowPulse.value,
              ),
            ],
          ),
          child: child,
        );
      },
      child: const Text(
        "🎵 Your music, your vibe",
        style: TextStyle(
          color: Color(0xFFEEEEEE),
          fontSize: 18,
          letterSpacing: 0.8,
          fontWeight: FontWeight.w400,
          shadows: [
            Shadow(
              blurRadius: 10,
              color: Color(0x66673AB7),
              offset: Offset(0, 1),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return FadeTransition(
      opacity: _footerFade,
      child: AnimatedBuilder(
        animation: _glowIntensity,
        builder: (context, child) {
          return Opacity(
            opacity: 0.6 + (_glowIntensity.value * 0.2),
            child: child,
          );
        },
        child: const Text(
          "Developed by Team 6",
          style: TextStyle(
            color: Color(0xFFBDBDBD),
            fontSize: 14,
            fontStyle: FontStyle.italic,
            letterSpacing: 0.5,
            shadows: [
              Shadow(
                blurRadius: 8,
                color: Color(0x44673AB7),
                offset: Offset(0, 1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}