import 'package:driving_school/const.dart';
import 'package:driving_school/views/super_admin/super_admin_home.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SuperAdminLogin extends StatefulWidget {
  const SuperAdminLogin({super.key});

  @override
  State<SuperAdminLogin> createState() => _SuperAdminLoginState();
}

class _SuperAdminLoginState extends State<SuperAdminLogin> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    if (_formKey.currentState!.validate()) {
      if (_idController.text == 'superadmin@gmail.com' &&
          _passwordController.text == '123456') {
        _idController.clear();
        _passwordController.clear();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const SuperAdminHome(),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid Super Admin credentials'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text('Super Admin', style: GoogleFonts.epilogue(fontSize: 18)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 10),
          SizedBox(
            width: width,
            child: Center(
              child: Text(
                'SUPER ADMIN Login',
                style: GoogleFonts.epilogue(
                    fontSize: 20, fontWeight: FontWeight.bold, color: defaultBlue),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Hero(
                      tag: 'super_admin_login_icon',
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: defaultBlue.withAlpha(20),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.security, size: 80, color: defaultBlue),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            controller: _idController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '*this field is required';
                              }
                              return null;
                            },
                            style: const TextStyle(color: Color(0xFF786868)),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: const Color.fromARGB(59, 255, 255, 255),
                              hintStyle: GoogleFonts.epilogue(),
                              hintText: 'Enter Super Admin ID',
                              prefixIcon: const Icon(Icons.person_outline),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: Colors.black26),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: defaultBlue, width: 2),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '*this field is required';
                              }
                              return null;
                            },
                            style: const TextStyle(color: Color(0xFF786868)),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: const Color.fromARGB(59, 255, 255, 255),
                              hintStyle: GoogleFonts.epilogue(),
                              hintText: 'Enter password',
                              prefixIcon: const Icon(Icons.lock_outline),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: Colors.black26),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: defaultBlue, width: 2),
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                          Container(
                            width: width,
                            height: 50,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10)),
                            child: ElevatedButton(
                              style: ButtonStyle(
                                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                backgroundColor: const MaterialStatePropertyAll(defaultBlue),
                              ),
                              onPressed: _login,
                              child: Text(
                                'Login as Super Admin',
                                style: GoogleFonts.epilogue(
                                    fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
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
