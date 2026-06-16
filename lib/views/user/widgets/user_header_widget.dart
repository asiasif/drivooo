import 'package:driving_school/controller/user_controller.dart';
import 'package:driving_school/views/user/user_settings.dart';
import 'package:driving_school/const.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';

class UserHeaderWidget extends StatelessWidget {
  final UserController userController;

  const UserHeaderWidget({
    super.key,
    required this.userController,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return SizedBox(
      width: width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              'Welcome back,\n${userController.userModel.userName},',
              style: GoogleFonts.epilogue(
                fontSize: 25,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const UserSettings(),
                ),
              );
            },
            child: Column(
              children: [
                const Icon(
                  MingCute.settings_1_line,
                  color: defaultBlue,
                ),
                Text(
                  'Settings',
                  style: GoogleFonts.epilogue(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
