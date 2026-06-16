import 'package:driving_school/const.dart';
import 'package:driving_school/controller/user_controller.dart';
import 'package:driving_school/views/choose_user.dart';
import 'package:driving_school/widgets/table_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:provider/provider.dart';
import 'package:driving_school/views/user/edit_profile_screen.dart';
import 'package:driving_school/widgets/language_switcher.dart';
import 'package:easy_localization/easy_localization.dart'; // Added

class UserSettings extends StatelessWidget {
  const UserSettings({super.key});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final userSettingController = Provider.of<UserController>(context);
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                width: width,
                height: height / 2,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.elliptical(100, 50),
                    bottomRight: Radius.elliptical(100, 50),
                  ),
                  color: defaultBlue,
                ),
              ),
              SizedBox(
                width: width,
                height: height / 2,
              ),
            ],
          ),
          /////////////////////////////////////////////////////////////////
          Align(
              alignment: Alignment.topRight,
              child: Image.asset('assets/Ellipse 16.png')),
          Align(
              alignment: Alignment.topRight,
              child: Image.asset('assets/Ellipse 17.png')),
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'profile'.tr(),
                            style: GoogleFonts.epilogue(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Container(
                            decoration: const BoxDecoration(
                                shape: BoxShape.circle, color: defaultBlue),
                            child: IconButton.filled(
                              style: const ButtonStyle(
                                backgroundColor:
                                    MaterialStatePropertyAll(Colors.white),
                              ),
                              visualDensity: VisualDensity.compact,
                              iconSize: 20,
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const EditProfileScreen(),
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.edit_outlined,
                                color: Colors.amber,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      TableWidget(
                          title: 'Name:',  // In real prod, add to JSON
                          value: userSettingController.userModel.userName),
                      const SizedBox(
                        height: 15,
                      ),
                      TableWidget(
                          title: 'Email:', 
                          value: userSettingController.userModel.userEmail),
                      const SizedBox(
                        height: 15,
                      ),
                      TableWidget(
                        title: 'Phone:',
                        value: userSettingController.userModel.userNumber
                            .toString(),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      TableWidget(
                          title: 'courses'.tr() + ':',
                          value: userSettingController
                                      .userModel.selectedCourse ==
                                  null
                              ? 'No course selected'
                              : userSettingController
                                  .userModel.selectedCourse!),
                      const SizedBox(
                        height: 15,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'language'.tr() + ':',
                              style: GoogleFonts.epilogue(fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const LanguageSwitcher(),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            top: height * 0.13,
            right: 0,
            left: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage:
                          userSettingController.userModel.userProPic != null
                              ? NetworkImage(
                                  userSettingController.userModel.userProPic!)
                              : const AssetImage('assets/profile.jpg')
                                  as ImageProvider,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: IconButton.filled(
                        style: const ButtonStyle(
                            backgroundColor:
                                MaterialStatePropertyAll(Colors.white)),
                        visualDensity: VisualDensity.compact,
                        iconSize: 20,
                        onPressed: () {
                          userSettingController
                              .selectproPic(context)
                              .whenComplete(
                                () => userSettingController.uploadProPic(
                                    userSettingController.proPic!,
                                    'Users Profile Pic',
                                    userSettingController.uid),
                              );
                        },
                        icon: const Icon(
                          Icons.edit_outlined,
                          color: Colors.amber,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  userSettingController.userModel.userName,
                  style: GoogleFonts.epilogue(
                    color: Colors.white,
                    fontSize: 15,
                  ),
                ),
                Text(
                  'UserID : ${userSettingController.userModel.userID}',
                  style: GoogleFonts.epilogue(
                    color: Colors.white,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: width,
            height: height / 6,
            child: Row(
              // crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(
                    EvaIcons.arrow_ios_back_outline,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(
                  width: 20,
                ),
                Text(
                  'settings'.tr(),
                  style: GoogleFonts.epilogue(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () async {
                    await userSettingController.signOut(context);
                  },
                  icon: const Icon(
                    EvaIcons.log_out,
                    color: Colors.white,
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
