import 'package:driving_school/const.dart';
import 'package:driving_school/controller/user_controller.dart';
import 'package:driving_school/views/user/add_user_details.dart';
import 'package:driving_school/views/user/user_home.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';

class OTPVerification extends StatefulWidget {
  const OTPVerification({super.key});

  @override
  State<OTPVerification> createState() => _OTPVerificationState();
}

class _OTPVerificationState extends State<OTPVerification> with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _slideController;

  late Animation<double> _fadeAnim;
  late Animation<Offset> _imageSlide;
  late Animation<Offset> _formSlide;
  late Animation<Offset> _buttonSlide;
  late Animation<double> _formFade;

  @override
  void initState() {
    super.initState();

    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _mainController, curve: Curves.easeIn);

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _imageSlide = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOutCubic),
    ));

    _formSlide = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: const Interval(0.2, 0.6, curve: Curves.easeOutCubic),
    ));

    _buttonSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: const Interval(0.4, 0.8, curve: Curves.easeOutCubic),
    ));

    _formFade = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _slideController,
      curve: const Interval(0.2, 0.8, curve: Curves.easeIn),
    ));

    _mainController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _slideController.forward();
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final otpController = Provider.of<UserController>(context, listen: false);

    // Modern pinput theme
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 60,
      textStyle: GoogleFonts.epilogue(
        fontSize: 22,
        color: Colors.black87,
        fontWeight: FontWeight.w600,
      ),
      decoration: BoxDecoration(
        color: defaultBlue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.transparent),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: defaultBlue, width: 2),
      borderRadius: BorderRadius.circular(12),
      color: Colors.white,
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        color: defaultBlue.withOpacity(0.1),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Column(
          children: [
            const SizedBox(height: 60),

            // Header Top Title
            Text(
              'USER Login',
              style: GoogleFonts.epilogue(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
                letterSpacing: 0.5,
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Hero Image with slight slide
                    SlideTransition(
                      position: _imageSlide,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 40, bottom: 40),
                        child: Hero(
                          tag: 'tag_1',
                          child: Image.asset(
                            'assets/user_selection.png',
                            height: 200,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: FadeTransition(
                        opacity: _formFade,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Phone Input Section
                            SlideTransition(
                              position: _formSlide,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Phone Number',
                                    style: GoogleFonts.epilogue(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    onChanged: (value) {
                                      otpController.setPhonenumber(value, context);
                                    },
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return '*this field is required';
                                      }
                                      return null;
                                    },
                                    style: GoogleFonts.epilogue(
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                    ),
                                    keyboardType: TextInputType.phone,
                                    controller: otpController.numberController,
                                    decoration: InputDecoration(
                                      suffixIcon: Consumer<UserController>(
                                        builder: (context, controller, child) => 
                                          controller.numberController.text.length == 10
                                              ? const Icon(
                                                  Icons.check_circle_rounded,
                                                  color: Colors.green,
                                                )
                                              : const SizedBox.shrink(),
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey.shade50,
                                      hintStyle: GoogleFonts.epilogue(color: Colors.grey.shade400),
                                      hintText: 'Enter your phone number',
                                      contentPadding: const EdgeInsets.symmetric(vertical: 20),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(14),
                                        borderSide: BorderSide(color: Colors.grey.shade200),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(14),
                                        borderSide: const BorderSide(color: defaultBlue, width: 2),
                                      ),
                                      prefixIcon: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 16),
                                        child: InkWell(
                                          splashColor: Colors.transparent,
                                          highlightColor: Colors.transparent,
                                          onTap: () {
                                            otpController.showCountries(context);
                                          },
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Consumer<UserController>(
                                                builder: (context, controller, child) => Text(
                                                  "${controller.selectedCountry.flagEmoji} +${controller.selectedCountry.phoneCode}",
                                                  style: GoogleFonts.epilogue(
                                                    fontSize: 16,
                                                    color: Colors.black87,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            const SizedBox(height: 24),

                            // OTP Input Section
                            SlideTransition(
                              position: _formSlide,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Verify OTP',
                                    style: GoogleFonts.epilogue(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  SizedBox(
                                    width: width,
                                    child: Pinput(
                                      length: 6,
                                      defaultPinTheme: defaultPinTheme,
                                      focusedPinTheme: focusedPinTheme,
                                      submittedPinTheme: submittedPinTheme,
                                      showCursor: true,
                                      onChanged: (value) {
                                        otpController.otpCode = value;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            const SizedBox(height: 40),

                            // Buttons & Divider
                            SlideTransition(
                              position: _buttonSlide,
                              child: Column(
                                children: [
                                  _AnimatedScaleButton(
                                    text: 'Verify',
                                    backgroundColor: defaultBlue,
                                    textColor: Colors.white,
                                    onTap: () {
                                      // Preserve EXACT complex authentication routing logic
                                      otpController.verifyOTP(
                                        context: context,
                                        verificationId: otpController.verificationCode,
                                        userOTP: otpController.otpCode ?? '',
                                        onSuccess: () {
                                          otpController.checkExistingUser().then(
                                            (value) async {
                                              if (value == true) {
                                                Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                    builder: (context) => UserHome(
                                                        uid: otpController
                                                            .firebaseAuth
                                                            .currentUser!
                                                            .uid),
                                                  ),
                                                );
                                              } else {
                                                Navigator.of(context).pushReplacement(
                                                  MaterialPageRoute(
                                                    builder: (context) => const AddUserDetails(),
                                                  ),
                                                );
                                              }
                                            },
                                          );
                                        },
                                      );
                                    },
                                  ),
                                  
                                  const SizedBox(height: 24),
                                  
                                  // The OR Divider requested by the user
                                  Row(
                                    children: [
                                      Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16),
                                        child: Text(
                                          'OR',
                                          style: GoogleFonts.epilogue(
                                            color: Colors.grey.shade500,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
                                    ],
                                  ),
                                  
                                  const SizedBox(height: 24),
                                  
                                  _AnimatedScaleButton(
                                    text: 'Sign in with Google',
                                    backgroundColor: Colors.white,
                                    textColor: Colors.black87,
                                    showGoogleIcon: true,
                                    onTap: () {
                                      otpController.signInWithGoogle(context);
                                    },
                                  ),
                                  
                                  const SizedBox(height: 40),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedScaleButton extends StatefulWidget {
  final String text;
  final VoidCallback onTap;
  final Color backgroundColor;
  final Color textColor;
  final bool showGoogleIcon;

  const _AnimatedScaleButton({
    required this.text,
    required this.onTap,
    required this.backgroundColor,
    required this.textColor,
    this.showGoogleIcon = false,
  });

  @override
  State<_AnimatedScaleButton> createState() => _AnimatedScaleButtonState();
}

class _AnimatedScaleButtonState extends State<_AnimatedScaleButton> with SingleTickerProviderStateMixin {
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
    return GestureDetector(
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
          height: 56,
          width: double.infinity,
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: widget.showGoogleIcon ? Colors.grey.shade200 : Colors.transparent,
              width: widget.showGoogleIcon ? 2 : 0,
            ),
            boxShadow: [
              BoxShadow(
                color: _isHovered 
                    ? widget.backgroundColor.withOpacity(0.3) 
                    : (widget.showGoogleIcon ? Colors.grey.withOpacity(0.1) : widget.backgroundColor.withOpacity(0.2)),
                blurRadius: _isHovered ? 16 : 8,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.showGoogleIcon) ...[
                Brand(Brands.google, size: 24),
                const SizedBox(width: 12),
              ],
              Text(
                widget.text,
                style: GoogleFonts.epilogue(
                  color: widget.textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
