import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mechinetest/test/loginPage.dart';


class drawer extends StatefulWidget {
  const drawer({super.key});

  @override
  State<drawer> createState() => drawerState();
}

class drawerState extends State<drawer> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> logout() async {
    try {
      await _auth.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Login()), // Redirect to main page after logout
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout Failed: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 10, right: 20, left: 20),
        child: Column(
          children: [
            SizedBox(height: 20.h),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('LogOut'),
              onTap: logout, // Call the logout function
            ),
          ],
        ),
      ),
    );
  }
}
