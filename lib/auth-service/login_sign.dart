import 'package:flutter/material.dart';
import 'package:our_own_project/screens/authpages/authlogin.dart';
import 'package:our_own_project/screens/authpages/authsignup.dart';

class AuthTogglePage extends StatefulWidget {
  final bool initialPage;

  const AuthTogglePage({super.key, required this.initialPage});

  @override
  State<AuthTogglePage> createState() => _AuthTogglePageState();
}

class _AuthTogglePageState extends State<AuthTogglePage> {
  late bool currentPage;

  @override
  void initState() {
    super.initState();
    currentPage = widget.initialPage;
  }

  void togglePage() {
    setState(() {
      currentPage = !currentPage; 
    });
  }

  @override
  Widget build(BuildContext context) {
    return currentPage == false ? LoginPage(togglePage: togglePage) : RegisterPage(togglePage: togglePage);
  }
}