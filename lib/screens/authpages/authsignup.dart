import 'package:flutter/material.dart';
import 'package:our_own_project/auth-service/auth.dart';
import 'package:our_own_project/auth-service/start_auth.dart';

class RegisterPage extends StatefulWidget {
  //toggle page
  final VoidCallback togglePage;
  const RegisterPage({super.key, required this.togglePage});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // sign out
  void register(BuildContext context) async {
    if (emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Email can't be empty"),
      ));
      return;
    } else if (passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Password can't be empty"),
      ));
      return;
    } else if (passwordController.text != confrmpasscontrol.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Passwords do not match'),
      ));
      return;
    } else if (!isChecked) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Agree to the terms and conditions to continue'),
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

      await auth.registerFirebase(
          emailController.text, passwordController.text,_nameController.text);

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
                  content: Text(e.toString()),
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

  bool isChecked = false;

  // email and password controller
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confrmpasscontrol = TextEditingController();

  bool _obscureText1 = true;
  bool _obscureText2 = true;

  @override
  Widget build(BuildContext context) {
    // Get the height and width of the screen
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    double height = screenHeight * 0.06;
    double width = screenWidth * 0.85;

    // Get the padding values (to account for areas like the notch or navigation bar)
    double bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: const Color.fromARGB(223, 156, 106, 197),
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: [
              //girl image
              Positioned(
                bottom: bottomPadding,
                child: Image.asset(
                  'assets/wh.png',
                  height: screenHeight,
                  width: screenWidth,
                  fit: BoxFit.cover,
                ),
              ),

              //a title of sign up to skill swap!
              const Positioned(
                top: 75,
                left: 0,
                right: 0,
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    "Sign up to LearnQuest!",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontFamily: 'Intersb',
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),

              // sign up with google card
              Positioned(
                top: 145,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: ElevatedButton.icon(
                        onPressed: google,
                        icon: const Image(
                          image: AssetImage('assets/search.png'),
                          height: 20,
                        ),
                        label: const Text(
                          " Sign up with Google",
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
                              horizontal: 40, vertical: 15),
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

                    //name field
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Stack(
                        children: [
                          // Image background
                          Image.asset(
                            'assets/text.png',
                            height: height,
                            width: width,
                            fit: BoxFit.contain,
                          ),
                          // Positioned TextField on top
                          Positioned(
                            left: 20,
                            right: 20,
                            bottom: height * 0.1,
                            child: TextField(
                              controller: _nameController,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 14.0,
                              ),
                              decoration: const InputDecoration(
                                hintText: 'Enter Name',
                                hintStyle: TextStyle(
                                  color: Color.fromARGB(120, 0, 0, 0),
                                  fontFamily: 'Inters',
                                  fontWeight: FontWeight.w800,
                                ),
                                filled: false,
                                border: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.transparent),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.transparent),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.transparent),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 10),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    //email field
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Stack(
                        children: [
                          // Image background
                          Image.asset(
                            'assets/text.png',
                            height: height,
                            width: width,
                            fit: BoxFit.contain,
                          ),
                          // Positioned TextField on top
                          Positioned(
                            left: 20,
                            right: 20,
                            bottom: height * 0.1,
                            child: TextField(
                              controller: emailController,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 14.0,
                              ),
                              decoration: const InputDecoration(
                                hintText: 'Enter Email',
                                hintStyle: TextStyle(
                                  color: Color.fromARGB(120, 0, 0, 0),
                                  fontFamily: 'Inters',
                                  fontWeight: FontWeight.w800,
                                ),
                                filled: false,
                                border: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.transparent),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.transparent),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.transparent),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 10),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    //password field
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Stack(
                        children: [
                          // Image background
                          Image.asset(
                            'assets/text.png',
                            height: height,
                            width: width,
                            fit: BoxFit.contain,
                          ),
                          // Positioned TextField on top
                          Positioned(
                            left: 20,
                            right: 20,
                            bottom: height * 0.1,
                            child: TextField(
                              obscureText: _obscureText1,
                              controller: passwordController,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 14.0,
                              ),
                              obscuringCharacter: '#',
                              decoration: InputDecoration(
                                hintText: 'Enter Password',
                                hintStyle: const TextStyle(
                                  color: Color.fromARGB(120, 0, 0, 0),
                                  fontFamily: 'Inters',
                                  fontWeight: FontWeight.w800,
                                ),
                                filled: false,
                                border: const OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.transparent),
                                ),
                                enabledBorder: const OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.transparent),
                                ),
                                focusedBorder: const OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.transparent),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 10),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureText1
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                  ),
                                  color: Colors.black,
                                  onPressed: () {
                                    setState(() {
                                      _obscureText1 = !_obscureText1;
                                    });
                                  },
                                  iconSize: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    //confirm password field
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Stack(
                        children: [
                          // Image background
                          Image.asset(
                            'assets/text.png',
                            height: height,
                            width: width,
                            fit: BoxFit.contain,
                          ),
                          // Positioned TextField on top
                          Positioned(
                            left: 20,
                            right: 20,
                            bottom: height * 0.1,
                            child: TextField(
                              controller: confrmpasscontrol,
                              obscureText: _obscureText2,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 14.0,
                              ),
                              obscuringCharacter: '#',
                              decoration: InputDecoration(
                                hintText: 'Confirm Password',
                                hintStyle: const TextStyle(
                                  color: Color.fromARGB(120, 0, 0, 0),
                                  fontFamily: 'Inters',
                                  fontWeight: FontWeight.w800,
                                ),
                                filled: false,
                                border: const OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.transparent),
                                ),
                                enabledBorder: const OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.transparent),
                                ),
                                focusedBorder: const OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.transparent),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 10),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureText2
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                  ),
                                  color: Colors.black,
                                  onPressed: () {
                                    setState(() {
                                      _obscureText2 = !_obscureText2;
                                    });
                                  },
                                  iconSize: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    //agree to terms and conditions
                    Padding(
                      padding: const EdgeInsets.only(left: 35),
                      child: Row(
                        children: [
                          Checkbox(
                            checkColor: Colors.black,
                            activeColor: Colors.white,
                            fillColor:
                                const WidgetStatePropertyAll(Colors.white),
                            side: const BorderSide(color: Colors.black),
                            value: isChecked,
                            onChanged: (bool? value) {
                              setState(() {
                                isChecked = value ?? false;
                              });
                            },
                          ),
                          const Text(
                            "I agree to the Terms and Conditions",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontFamily: 'Inters',
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              //create account button
              Positioned(
                right: 15,
                top: 585,
                child: TextButton(
                  onPressed: () => register(context),
                  child: Card(
                    color: const Color.fromARGB(255, 0, 0, 0),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Create Account",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
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
                top: 660,
                right: 25,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      "Already have an account?",
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
                          padding: EdgeInsets.symmetric(horizontal: 5),
                          child: Text(
                            "Login",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
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
