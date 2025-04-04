import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:our_own_project/auth-service/infoorhome.dart';
import 'package:our_own_project/screens/authpages/open.dart';

class StartAuth extends StatelessWidget {
  const StartAuth({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(  
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: ( context,  snapshot) {

          // Handle loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Handle error state
         else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          // Handle authenticated state
         else if (snapshot.hasData && snapshot.data != null) {
            return const RedirectPage();
          }

          // Handle unauthenticated state
          else{
          return const OpenPage();}
        },
      ),
    );
  }
}