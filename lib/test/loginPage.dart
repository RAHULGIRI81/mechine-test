import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mechinetest/test/Home.dart';
import 'package:mechinetest/test/SignUp.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool obscurePassword = true;
  final formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Email validation function
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    const pattern = r'^[^@]+@[^@]+\.[^@]+$';
    final regExp = RegExp(pattern);
    if (!regExp.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  // Password validation function
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    return null;
  }

  // Login function
  Future<void> login(BuildContext context) async {
    if (formKey.currentState!.validate()) {
      try {
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login Successful')),
        );

        // Navigate to the User Home Page and pass the user ID
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Home(userId: userCredential.user!.uid),
          ),
        );
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Login Failed')),
        );
      }
    }
  }

  // Google Sign-In function
  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        // The user canceled the sign-in
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google Sign-In Successful')),
      );

      // Navigate to the User Home Page and pass the user ID
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => Home(userId: userCredential.user!.uid),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google Sign-In Failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Form(
        key: formKey,
        child: Scaffold(
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 60.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Log in",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 50.sp,
                  ),
                ),
                SizedBox(height: 20.h),
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                    hintText: 'Email',
                    hintStyle: TextStyle(color: Colors.black),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(
                        color: Colors.white,
                        width: 2.0.w,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(
                        color: Colors.black,
                        width: 2.0.w,
                      ),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: validateEmail,
                ),
                SizedBox(height: 10.h),
                TextFormField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    hintStyle: TextStyle(color: Colors.black),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(width: 2.0, color: Colors.black),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(
                        color: Colors.white,
                        width: 2.0,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(
                        color: Colors.black,
                        width: 2.0.w,
                      ),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        color: Colors.black,
                        obscurePassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          obscurePassword = !obscurePassword;
                        });
                      },
                    ),
                  ),
                  obscureText: obscurePassword,
                  validator: validatePassword,
                ),
                SizedBox(height: 20.h),
                InkWell(
                  onTap: () {
                    login(context);
                  },
                  child: Container(
                    height: 50.h,
                    width: 300.w,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.green.shade800,
                    ),
                    child: Center(
                      child: Text(
                        "Log In",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20.sp,
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 50),
                  child: Row(
                    children: [
                      Text(
                        "Don't have an account?",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SignUp(),
                              ));
                        },
                        child: Text(
                          "Sign up",
                          style: GoogleFonts.poppins(
                              color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 25.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
