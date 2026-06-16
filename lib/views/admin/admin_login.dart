import 'package:driving_school/const.dart';
import 'package:driving_school/controller/admin_controller.dart';
import 'package:driving_school/controller/user_controller.dart';
import 'package:driving_school/views/admin/admin_home.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class AdminLogin extends StatelessWidget {
  const AdminLogin({super.key});

  @override
  Widget build(BuildContext context) {
    // final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final adminLoginController =
        Provider.of<AdminController>(context, listen: false);
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(
            height: 50,
          ),
          SizedBox(
            width: width,
            child: Center(
              child: Text(
                'ADMIN Login',
                style: GoogleFonts.epilogue(
                    fontSize: 20, fontWeight: FontWeight.w500),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 100),
                    child: Hero(
                      tag: 'tag_1',
                      child: Image.asset('assets/user_selection.png'),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                    ),
                    child: Form(
                      key: adminLoginController.adminLoginKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '*this field is required';
                              }
                              return null;
                            },
                            style: const TextStyle(color: Color(0xFF786868)),
                            controller: adminLoginController.adminIDController,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor:
                                  const Color.fromARGB(59, 255, 255, 255),
                              hintStyle: GoogleFonts.epilogue(),
                              hintText: 'Enter ID',
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    const BorderSide(color: Colors.black26),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    const BorderSide(color: Colors.black26),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          TextFormField(
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '*this field is required';
                              }
                              return null;
                            },
                            style: const TextStyle(color: Color(0xFF786868)),
                            controller:
                                adminLoginController.adminPasswordController,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor:
                                  const Color.fromARGB(59, 255, 255, 255),
                              hintStyle: GoogleFonts.epilogue(),
                              hintText: 'Enter password',
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    const BorderSide(color: Colors.black26),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    const BorderSide(color: Colors.black26),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Container(
                            width: width,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5)),
                            child: ElevatedButton(
                              style: ButtonStyle(
                                shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        10), // Set your desired border radius here
                                  ),
                                ),
                                backgroundColor:
                                    const MaterialStatePropertyAll(defaultBlue),
                              ),
                              onPressed: () {
                                if (adminLoginController
                                    .adminLoginKey.currentState!
                                    .validate()) {

                                  adminLoginController.adminLogin(
                                      adminLoginController
                                          .adminIDController.text,
                                      adminLoginController
                                          .adminPasswordController.text,
                                      context);
                                }
                              },
                              child: Text(
                                'Verify',
                                style: GoogleFonts.epilogue(
                                    fontSize: 15, color: Colors.white),
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
          ),
        ],
      ),
    );
  }
}
