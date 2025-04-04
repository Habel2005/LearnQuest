import 'package:flutter/material.dart';
import 'package:our_own_project/screens/authpages/info.dart';
import 'package:our_own_project/screens/authpages/open.dart';
import 'package:our_own_project/screens/homepage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RedirectPage extends StatelessWidget {
  const RedirectPage({super.key});

  Future<bool> _isPersonalInfoCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isPersonalInfoCompleted') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _isPersonalInfoCompleted(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        } else {
          bool isCompleted = snapshot.data ?? false;
          print("this is $isCompleted");
          if (FirebaseAuth.instance.currentUser != null) {
            return isCompleted ? const Homepage() : const PersonalInfoScreen();
          } else {
            return const OpenPage();
          }
        }
      },
    );
  }
}
