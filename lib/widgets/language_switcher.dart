import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_fonts/google_fonts.dart';

class LanguageSwitcher extends StatelessWidget {
  const LanguageSwitcher({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButton<Locale>(
      value: context.locale,
      icon: const Icon(Icons.language, color: Colors.deepPurple),
      underline: Container(
        height: 1,
        color: Colors.deepPurple,
      ),
      style: GoogleFonts.epilogue(
        color: Colors.black87,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      items: const [
        DropdownMenuItem(
          value: Locale('en', 'US'),
          child: Text('English'),
        ),
      ],
      onChanged: (Locale? newLocale) {
        if (newLocale != null) {
          context.setLocale(newLocale);
        }
      },
    );
  }
}
