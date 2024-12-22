import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mechinetest/test/loginPage.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Validation functions
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    const pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    final regExp = RegExp(pattern);
    if (!regExp.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    return null;
  }


  String? validatePhoneNumber(String? value) {
    final phoneRegExp = RegExp(r'^\+?[0-9]{10,13}$');
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    } else if (!phoneRegExp.hasMatch(value)) {
      return 'Enter a valid phone number';
    }
    return null;
  }



  Future<void> signUp(BuildContext context) async {
    if (formKey.currentState!.validate()) {
      try {
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'email': emailController.text.trim(),
          'name': nameController.text.trim(),
          'Phone': phoneController.text.trim(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign-Up Successful')),
        );

        // Navigate to the Login Page
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Login()),
        );
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Sign-Up Failed')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Scaffold(
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Sign up",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 40.sp,
                    ),
                  ),
                  SizedBox(height: 5.h),
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      hintText: 'Name',hintStyle: TextStyle(color: Colors.black),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(
                          color: Colors.black,
                          width: 2.0, // Change this value to set the thickness when not focused
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 5.h),
                  TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(
                      hintText: 'Email',hintStyle: TextStyle(color: Colors.black),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(
                          color: Colors.black,
                          width: 2.0, // Change this value to set the thickness when not focused
                        ),
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: validateEmail,
                  ),
                  SizedBox(height: 5.h),
                  TextFormField(
                    controller: phoneController,
                    decoration: InputDecoration(
                      hintText: 'Phone Number',
                      hintStyle: TextStyle(color: Colors.black),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(
                          color: Colors.black,
                          width: 2.0, // Change this value to set the thickness when not focused
                        ),
                      ),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: validatePhoneNumber,
                  ),
                  SizedBox(height: 5.h),
                  TextFormField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      hintText: 'Password',hintStyle: TextStyle(color: Colors.black),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(
                          color: Colors.black,
                          width: 2.0, // Change this value to set the thickness when not focused
                        ),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(color: Colors.black,
                          _obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword; // Toggle password visibility
                          });
                        },
                      ),
                    ),
                    obscureText: _obscurePassword, // Use the state variable
                    validator: validatePassword,
                  ),
                  SizedBox(height: 5.h),
                  InkWell(
                    onTap: () {
                      signUp(context);
                    },
                    child: Container(
                      height: 50,
                      width: 300,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.green.shade800,
                      ),
                      child: Center(
                        child: Text(
                          "Sign up",
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
                    padding: const EdgeInsets.only(left: 40),
                    child: Row(
                      children: [
                        Text(
                          "Do you have an account?",
                          style: GoogleFonts.poppins(fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        InkWell(onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => SignUp(),));
                        },
                          child: Text(
                            "Login",
                            style: GoogleFonts.poppins(
                                color: Colors.black, fontSize: 24.sp, fontWeight: FontWeight.bold
                            ),
                          ),
                        ),

                      ],
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
