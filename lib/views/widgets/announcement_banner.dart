import 'package:driving_school/models/announcement_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AnnouncementBanner extends StatefulWidget {
  final AnnouncementModel announcement;

  const AnnouncementBanner({super.key, required this.announcement});

  @override
  State<AnnouncementBanner> createState() => _AnnouncementBannerState();
}

class _AnnouncementBannerState extends State<AnnouncementBanner> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _isVisible = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    
    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _dismiss() {
    _controller.reverse().then((_) {
      if (mounted) {
        setState(() => _isVisible = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) return const SizedBox.shrink();

    final isUrgent = widget.announcement.type == 'Urgent';
    
    final Color bgColor = isUrgent ? Colors.red.shade50 : const Color(0xFFF0F6FF);
    final Color borderColor = isUrgent ? Colors.red.shade200 : Colors.blue.shade200;
    final Color iconColor = isUrgent ? Colors.red.shade600 : Colors.blue.shade700;
    final Color titleColor = isUrgent ? Colors.red.shade900 : Colors.blue.shade900;
    final Color descColor = isUrgent ? Colors.red.shade700 : Colors.blue.shade800;
    final IconData icon = isUrgent ? Icons.warning_amber_rounded : Icons.campaign_rounded;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: isUrgent ? Colors.red.withOpacity(0.1) : Colors.blue.withOpacity(0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                )
              ]
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon styling
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isUrgent ? Colors.red.shade100 : Colors.blue.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                
                const SizedBox(width: 14),
                
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              widget.announcement.title,
                              style: GoogleFonts.epilogue(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: titleColor,
                                height: 1.2,
                              ),
                            ),
                          ),
                          if (widget.announcement.date.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                widget.announcement.date,
                                style: GoogleFonts.epilogue(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: iconColor,
                                ),
                              ),
                            )
                          ]
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.announcement.description,
                        style: GoogleFonts.epilogue(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: descColor,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Dismiss button
                GestureDetector(
                  onTap: _dismiss,
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Icon(Icons.close_rounded, size: 18, color: iconColor.withOpacity(0.5)),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
