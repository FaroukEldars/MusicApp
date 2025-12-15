import 'package:flutter/material.dart';
import 'dart:math';

class DevelopersScreen extends StatefulWidget {
  const DevelopersScreen({super.key});

  @override
  State<DevelopersScreen> createState() => _DevelopersScreenState();
}

class _DevelopersScreenState extends State<DevelopersScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<Map<String, dynamic>> developers = [
    {
      'name': 'Farouk Ebrahim',
      'role': 'Software Engineer',
      'avatar': Icons.person,
      'color': const Color(0xFF673AB7),
    },
    {
      'name': 'Fares Sakr',
      'role': 'Software Engineer',
      'avatar': Icons.person,
      'color': const Color(0xFF9C27B0),
    },
    {
      'name': 'Mohamed Fathy',
      'role': 'Software Engineer',
      'avatar': Icons.person,
      'color': const Color(0xFFE91E63),
    },
    {
      'name': 'Ahmed Alaa',
      'role': 'Software Engineer',
      'avatar': Icons.person,
      'color': const Color(0xFF00BCD4),
    },
    {
      'name': 'Karl Manassa',
      'role': 'Software Engineer',
      'avatar': Icons.person,
      'color': const Color(0xFF4CAF50),
    },
    {
      'name': 'Youssef ElGohary',
      'role': 'Software Engineer',
      'avatar': Icons.person,
      'color': const Color(0xFFFF9800),
    },
    {
      'name': 'Youssef Yasser',
      'role': 'Software Engineer',
      'avatar': Icons.person,
      'color': const Color(0xFFF44336),
    },
    {
      'name': 'Bishoy Osama',
      'role': 'Software Engineer',
      'avatar': Icons.person,
      'color': const Color(0xFF3F51B5),
    },
  ];

  @override
  void initState() {
    super.initState();

    developers.shuffle(Random());

    _initAnimations();
  }

  void _initAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: ShaderMask(
          shaderCallback: (bounds) {
            return const LinearGradient(
              colors: [Colors.white, Color(0xFFB39DDB)],
            ).createShader(bounds);
          },
          child: const Text(
            'Our Team',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 40),
              _buildDevelopersList(),
              const SizedBox(height: 40),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFF673AB7), Color(0xFF9C27B0)],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.deepPurpleAccent.withValues(alpha: 0.5),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: const Icon(
            Icons.group,
            size: 50,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),
        ShaderMask(
          shaderCallback: (bounds) {
            return const LinearGradient(
              colors: [Colors.white, Color(0xFFB39DDB)],
            ).createShader(bounds);
          },
          child: const Text(
            'Team 6',
            style: TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Passionate developers building amazing music experiences',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 16,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildDevelopersList() {
    return Column(
      children: developers.asMap().entries.map((entry) {
        final index = entry.key;
        final dev = entry.value;

        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 400 + (index * 100)),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 50 * (1 - value)),
              child: Opacity(opacity: value, child: child),
            );
          },
          child: _buildDeveloperCard(dev),
        );
      }).toList(),
    );
  }

  Widget _buildDeveloperCard(Map<String, dynamic> dev) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E1E1E), Color(0xFF2A2A2A)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: (dev['color'] as Color).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    dev['color'] as Color,
                    (dev['color'] as Color).withValues(alpha: 0.7),
                  ],
                ),
              ),
              child: Icon(
                dev['avatar'],
                size: 35,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dev['name'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dev['role'],
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Text(
          'Made with ❤️ by Team 6',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
