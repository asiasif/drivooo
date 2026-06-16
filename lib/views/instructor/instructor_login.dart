import 'dart:math' as math;
import 'package:driving_school/const.dart';
import 'package:driving_school/controller/instructor_controller.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:icons_plus/icons_plus.dart';

class InstructorLogin extends StatefulWidget {
  const InstructorLogin({super.key});

  @override
  State<InstructorLogin> createState() => _InstructorLoginState();
}

class _InstructorLoginState extends State<InstructorLogin>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late AnimationController _driftController;

  late Animation<double> _fadeAnim;
  late Animation<Offset> _titleSlide;
  late Animation<Offset> _subtitleSlide;
  late Animation<Offset> _buttonSlide;
  late Animation<double> _buttonFade;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();

    // Fade controller for the overall page
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);

    // Slide controller for staggered elements
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOutCubic),
    ));

    _subtitleSlide = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: const Interval(0.2, 0.65, curve: Curves.easeOutCubic),
    ));

    _buttonSlide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: const Interval(0.4, 0.85, curve: Curves.easeOutCubic),
    ));

    _buttonFade = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _slideController,
      curve: const Interval(0.4, 0.85, curve: Curves.easeIn),
    ));

    // Pulse for the icon
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Slow drifting background circles
    _driftController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();

    // Start animations
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _slideController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    _driftController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Stack(
          children: [
            // Modern Animated Drifting Background Circles (Replacing static yellow images)
            AnimatedBuilder(
              animation: _driftController,
              builder: (context, child) {
                return Stack(
                  children: [
                    Positioned(
                      top: -100 + (math.sin(_driftController.value * 2 * math.pi) * 30),
                      right: -50 + (math.cos(_driftController.value * 2 * math.pi) * 30),
                      child: Container(
                        width: 300,
                        height: 300,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: defaultBlue.withOpacity(0.04),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 150 + (math.cos(_driftController.value * 2 * math.pi) * 40),
                      left: -150 + (math.sin(_driftController.value * 2 * math.pi) * 40),
                      child: Container(
                        width: 400,
                        height: 400,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: defaultBlue.withOpacity(0.03),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -80 + (math.sin(_driftController.value * 2 * math.pi) * 20),
                      right: -100 + (math.cos(_driftController.value * 2 * math.pi) * 20),
                      child: Container(
                        width: 250,
                        height: 250,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: defaultBlue.withOpacity(0.05),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),

            // Main content
            SafeArea(
              child: Column(
                children: [
                  // Back button
                  Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8, top: 8),
                      child: IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 22),
                      ),
                    ),
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(height: height * 0.06),

                            // Animated icon with pulse
                            ScaleTransition(
                              scale: _pulseAnim,
                              child: Hero(
                                tag: 'tag_1',
                                child: Container(
                                  width: 140,
                                  height: 140,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: defaultBlue.withOpacity(0.08),
                                    border: Border.all(
                                      color: defaultBlue.withOpacity(0.15),
                                      width: 2,
                                    ),
                                  ),
                                  child: Center(
                                    child: Container(
                                      width: 100,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: defaultBlue.withOpacity(0.12),
                                      ),
                                      child: const Icon(
                                        Icons.school_rounded,
                                        size: 50,
                                        color: defaultBlue,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            
                            SizedBox(height: height * 0.05),

                            // Title with slide animation
                            SlideTransition(
                              position: _titleSlide,
                              child: Column(
                                children: [
                                  Text(
                                    'Instructor Portal',
                                    style: GoogleFonts.epilogue(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    width: 40,
                                    height: 3,
                                    decoration: BoxDecoration(
                                      color: defaultBlue,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Subtitle with slide animation
                            SlideTransition(
                              position: _subtitleSlide,
                              child: Text(
                                'Sign in with your registered Google account\nto access your dashboard',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.epilogue(
                                  fontSize: 14,
                                  color: Colors.grey.shade500,
                                  height: 1.5,
                                ),
                              ),
                            ),

                            SizedBox(height: height * 0.06),

                            // Info card
                            SlideTransition(
                              position: _subtitleSlide,
                              child: Container(
                                width: width,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: defaultBlue.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: defaultBlue.withOpacity(0.1),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline_rounded,
                                      color: defaultBlue.withOpacity(0.7),
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        'Only admins can register instructor accounts. Contact your admin if you don\'t have access.',
                                        style: GoogleFonts.epilogue(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                          height: 1.4,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 40),

                            // Google Sign-In button with spring scale & slide + fade animation
                            FadeTransition(
                              opacity: _buttonFade,
                              child: SlideTransition(
                                position: _buttonSlide,
                                child: const _AnimatedGoogleButton(),
                              ),
                            ),

                            const SizedBox(height: 40),

                            // Bottom decorative text
                            FadeTransition(
                              opacity: _buttonFade,
                              child: Text(
                                'Driving School Management',
                                style: GoogleFonts.epilogue(
                                  fontSize: 12,
                                  color: Colors.grey.shade400,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),

                            const SizedBox(height: 30),
                          ],
                        ),
                      ),
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
}

class _AnimatedGoogleButton extends StatefulWidget {
  const _AnimatedGoogleButton();

  @override
  State<_AnimatedGoogleButton> createState() => _AnimatedGoogleButtonState();
}

class _AnimatedGoogleButtonState extends State<_AnimatedGoogleButton> with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final instructorController = Provider.of<InstructorController>(context, listen: false);

    return GestureDetector(
      onTapDown: (_) {
        _scaleController.forward();
        setState(() => _isHovered = true);
      },
      onTapUp: (_) {
        _scaleController.reverse();
        setState(() => _isHovered = false);
        instructorController.signInWithGoogle(context);
      },
      onTapCancel: () {
        _scaleController.reverse();
        setState(() => _isHovered = false);
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 60,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isHovered ? defaultBlue : Colors.grey.shade200,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: _isHovered 
                    ? defaultBlue.withOpacity(0.2) 
                    : Colors.grey.withOpacity(0.1),
                blurRadius: _isHovered ? 20 : 10,
                offset: const Offset(0, 8),
              )
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Brand(Brands.google, size: 26), // Replaced broken asset with icons_plus Brand!
              const SizedBox(width: 14),
              Text(
                'Continue with Google',
                style: GoogleFonts.epilogue(
                  color: Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
