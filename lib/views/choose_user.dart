import 'package:driving_school/const.dart';
import 'package:driving_school/views/admin/admin_login.dart';
import 'package:driving_school/views/instructor/instructor_login.dart';
import 'package:driving_school/views/otp_verification.dart';
import 'package:driving_school/views/super_admin/super_admin_login.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

class ChooseUser extends StatefulWidget {
  const ChooseUser({super.key});

  @override
  State<ChooseUser> createState() => _ChooseUserState();
}

class _ChooseUserState extends State<ChooseUser> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Column(
        children: [
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Select Your Option',
                    style: GoogleFonts.epilogue(
                      color: defaultBlue,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Login to access your dashboard',
                    style: GoogleFonts.epilogue(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Wrap(
                    spacing: 15,
                    runSpacing: 15,
                    alignment: WrapAlignment.center,
                    children: [
                      _AnimatedRoleCard(
                        delay: 0,
                        title: 'USER',
                        icon: Iconsax.user,
                        onTap: () {
                          _navigateTo(context, const OTPVerification());
                        },
                        width: width * 1.35,
                        height: height,
                      ),
                      _AnimatedRoleCard(
                        delay: 150,
                        title: 'INSTRUCTOR',
                        icon: Iconsax.teacher,
                        onTap: () {
                          _navigateTo(context, const InstructorLogin());
                        },
                        width: width * 1.35,
                        height: height,
                      ),
                      _AnimatedRoleCard(
                        delay: 300,
                        title: 'ADMIN',
                        icon: Iconsax.security_user,
                        onTap: () {
                          _navigateTo(context, const AdminLogin());
                        },
                        width: width * 1.35,
                        height: height,
                      ),
                      _AnimatedRoleCard(
                        delay: 450,
                        title: 'SUPER ADMIN',
                        icon: Icons.security,
                        onTap: () {
                          _navigateTo(context, const SuperAdminLogin());
                        },
                        width: width * 1.35,
                        height: height,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Hero(
            transitionOnUserGestures: true,
            tag: 'tag_1',
            child: Image.asset('assets/user_selection.png'),
          ),
        ],
      ),
    );
  }

  void _navigateTo(BuildContext context, Widget page) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => FadeTransition(
          opacity: animation,
          child: page,
        ),
        transitionDuration: const Duration(milliseconds: 1000),
        reverseTransitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }
}

class _AnimatedRoleCard extends StatefulWidget {
  final int delay;
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final double width;
  final double height;

  const _AnimatedRoleCard({
    required this.delay,
    required this.title,
    required this.icon,
    required this.onTap,
    required this.width,
    required this.height,
  });

  @override
  State<_AnimatedRoleCard> createState() => _AnimatedRoleCardState();
}

class _AnimatedRoleCardState extends State<_AnimatedRoleCard> with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  bool _isVisible = false;
  
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) {
        setState(() => _isVisible = true);
      }
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 600),
      opacity: _isVisible ? 1.0 : 0.0,
      curve: Curves.easeOut,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 600),
        offset: _isVisible ? Offset.zero : const Offset(0, 0.2),
        curve: Curves.easeOutCubic,
        child: GestureDetector(
          onTapDown: (_) {
            _scaleController.forward();
            setState(() => _isHovered = true);
          },
          onTapUp: (_) {
            _scaleController.reverse();
            setState(() => _isHovered = false);
            widget.onTap();
          },
          onTapCancel: () {
            _scaleController.reverse();
            setState(() => _isHovered = false);
          },
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: widget.width / 3.2,
              height: widget.height * 0.17,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _isHovered ? defaultBlue : Colors.transparent,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _isHovered 
                        ? defaultBlue.withOpacity(0.2) 
                        : Colors.grey.withOpacity(0.1),
                    blurRadius: _isHovered ? 20 : 10,
                    offset: const Offset(0, 10),
                    spreadRadius: _isHovered ? 5 : 0,
                  )
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: _isHovered ? defaultBlue : defaultBlue.withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      widget.icon,
                      color: _isHovered ? Colors.white : defaultBlue,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    widget.title,
                    style: GoogleFonts.epilogue(
                      color: _isHovered ? defaultBlue : Colors.black87,
                      fontSize: 13,
                      fontWeight: _isHovered ? FontWeight.bold : FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
