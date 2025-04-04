import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:our_own_project/auth-service/login_sign.dart';

class OpenPage extends StatefulWidget {
  const OpenPage({super.key});

  @override
  State<OpenPage> createState() => _OpenPageState();
}

class _OpenPageState extends State<OpenPage> {
  @override
  Widget build(BuildContext context) {
    // Get the height and width of the screen
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    // Get the padding values (to account for areas like the notch or navigation bar)
    double bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFF8C5CB3),
      body: Stack(
        children: [
          // Background SVG - Move this to the beginning of the stack
          SvgPicture.asset(
            'assets/login_back.svg',
            width: screenWidth,
            height: screenHeight,
            fit: BoxFit.contain,
          ),

          //girl image bottom
          Positioned(
            bottom: bottomPadding,
            child: Image.asset(
              'assets/girl.png',
              height: screenHeight,
              width: screenWidth,
              fit: BoxFit.cover,
            ),
          ),

          //Welcome text
          const Positioned(
            top: 60,
            left: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Welcome To",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 45,
                      fontFamily: 'Intersb',
                      fontWeight: FontWeight.w800,
                      height: 1.2),
                ),
                Text(
                  "LearnQuest!",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontFamily: 'Inters',
                      fontWeight: FontWeight.w800,
                      height: 0),
                ),
                Text(
                  "A Portal Where Learning",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                      fontFamily: 'Inters',
                      fontWeight: FontWeight.w800,
                      height: 2),
                ),
                Text(
                  "Sparks Ignite",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                      fontFamily: 'Inters',
                      fontWeight: FontWeight.w800,
                      height: -0.001),
                ),
              ],
            ),
          ),

          //sign up button
          Positioned(
            bottom: 250,
            left: 60,
            right: 10,
            child: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const AuthTogglePage(initialPage: true),
                  ),
                );
              },
              child: Card(
                color: const Color.fromARGB(255, 0, 0, 0),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Sign up",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 21,
                            fontFamily: 'Inters',
                            fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          //already have an account
          Positioned(
            bottom: 220,
            left: 80,
            right: 20,
            child: Row(
              children: [
                const Text(
                  "Already have an account?",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontFamily: 'Inters',
                      fontWeight: FontWeight.w700),
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const AuthTogglePage(initialPage: false),
                        ),
                      );
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Text(
                        "Login",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 17,
                            fontFamily: 'Inters',
                            fontWeight: FontWeight.w900),
                      ),
                    ),
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
