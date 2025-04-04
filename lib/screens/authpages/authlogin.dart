import 'package:flutter/material.dart';
import 'package:our_own_project/auth-service/auth.dart';
import 'package:our_own_project/auth-service/start_auth.dart';
import 'package:our_own_project/screens/authpages/forget.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback togglePage;
  const LoginPage({super.key, required this.togglePage});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Password visibility
  bool _obscureText = true;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  //login using auth
  void signIn(BuildContext context) async {
    if (emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          "Email can't be empty",
        ),
      ));
      return;
    } else if (passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          "Password can't be empty",
        ),
      ));
      return;
    }
    final auth = Auth();

    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Attempt sign in
      await auth.signInFirebase(emailController.text, passwordController.text);

      if (context.mounted) {
        // Remove loading indicator
        Navigator.pop(context);

        // Clear navigation stack and return to StartAuth
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const StartAuth()),
          (route) => false,
        );
      }
    } catch (e) {
      // Remove loading indicator if it's showing
      if (context.mounted) {
        Navigator.of(context).pop();
        // Show error dialog
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: const Text(
                    "Error",
                    style: TextStyle(color: Color.fromARGB(255, 191, 177, 206)),
                  ),
                  content: Text(auth.getError(e.toString())),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("OK"))
                  ],
                ));
      }
    }
  }

  void google() async {
    try {
      await Auth().signInWithGoogle();

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const StartAuth()),
        (route) => false,
      );
    } catch (e) {
      //show error dialog
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text(e.toString()),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the height and width of the screen
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    double height = screenHeight * 0.07;

    // Get the padding values (to account for areas like the notch or navigation bar)
    double bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      //resizeToAvoidBottomInset: true,
      backgroundColor: const Color.fromARGB(236, 144, 99, 181),
      body: SingleChildScrollView(
        child: SizedBox(
          height: screenHeight +
              bottomPadding, // Ensure the scrollable area is tall enough
          child: Stack(
            children: [
              //girl image
              Positioned(
                bottom: bottomPadding,
                child: Image.asset(
                  'assets/rf.png',
                  height: screenHeight,
                  width: screenWidth,
                  fit: BoxFit.cover,
                ),
              ),

              const Padding(
                padding: EdgeInsets.only(top: 100),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Text(
                    'Log in to LearnQuest!',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontFamily: 'Inters',
                        fontWeight: FontWeight.w800),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(top: 175),
                child: Column(children: [
                  //or loginwith email
                  Align(
                    alignment: Alignment.center,
                    child: ElevatedButton.icon(
                      onPressed: google,
                      icon: const Image(
                        image: AssetImage('assets/search.png'),
                        height: 20,
                      ),
                      label: const Text(
                        " Log in with Google",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontFamily: 'Inters',
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 45, vertical: 15),
                      ),
                    ),
                  ),

                  //or continue with line
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Row(children: [
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.only(left: 30, right: 20),
                          child: const Divider(
                            color: Colors.black,
                            height: 50,
                          ),
                        ),
                      ),
                      const Text(
                        "Or continue with Email",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontFamily: 'Inters',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.only(
                            left: 20,
                            right: 30,
                          ),
                          child: const Divider(
                            color: Colors.black,
                            height: 50,
                          ),
                        ),
                      ),
                    ]),
                  ),

                  //Username or email text
                  const Padding(
                    padding: EdgeInsets.only(top: 5),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.only(left: 50),
                        child: Text(
                          "Username or Email",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 17,
                            fontFamily: 'Inters',
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 5),

                  //text field
                  Stack(
                    children: [
                      // Image background
                      Image.asset(
                        'assets/text2.png',
                        height: height,
                        width: screenWidth * 0.85,
                        fit: BoxFit.contain,
                      ),
                      // Positioned TextField on top
                      Positioned(
                        left: 25,
                        right: 25,
                        child: TextField(
                          controller: emailController,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16.0,
                          ),
                          decoration: const InputDecoration(
                            filled: false,
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.transparent),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.transparent),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.transparent),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 10),
                          ),
                        ),
                      ),
                    ],
                  ),

                  //Password text
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Row(
                      children: [
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: EdgeInsets.only(left: 50),
                            child: Text(
                              "Password",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 17,
                                fontFamily: 'Inters',
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 65, right: 10),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const ForgetPass(),
                                    ),
                                  );
                                },
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  child: Text(
                                    "Forgot Password?",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontFamily: 'Inters',
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 5),

                  //password field
                  Stack(
                    children: [
                      // Image background
                      Padding(
                        padding: const EdgeInsets.only(),
                        child: Image.asset(
                          'assets/text2.png',
                          height: height,
                          width: screenWidth * 0.85,
                          fit: BoxFit.contain,
                        ),
                      ),
                      // Positioned TextField on top
                      Positioned(
                        left: 25,
                        right: 25,
                        child: TextField(
                          obscuringCharacter: '#',
                          obscureText: _obscureText,
                          controller: passwordController,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16.0,
                          ),
                          decoration: InputDecoration(
                            filled: false,
                            border: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.transparent),
                            ),
                            enabledBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.transparent),
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.transparent),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 10),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureText
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              color: Colors.black,
                              onPressed: () {
                                setState(() {
                                  _obscureText = !_obscureText;
                                });
                              },
                              iconSize: 23,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ]),
              ),

              Positioned(
                left: 20,
                top: 510,
                child: TextButton(
                  onPressed: () => signIn(context),
                  child: Card(
                    color: const Color.fromARGB(255, 0, 0, 0),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.only(
                          left: 40, right: 40, top: 15, bottom: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Login",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 19,
                                fontFamily: 'Inters',
                                fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              //already have an account and login
              Positioned(
                top: 600,
                left: 45,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Don't have an account?",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontFamily: 'Inters',
                          fontWeight: FontWeight.w700),
                    ),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: widget.togglePage,
                        child: const Padding(
                          padding: EdgeInsets.only(),
                          child: Text(
                            "Sign up",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 17,
                              fontFamily: 'Inters',
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
