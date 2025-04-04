import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgetPass extends StatefulWidget {
  const ForgetPass({super.key});

  @override
  State<ForgetPass> createState() => _ForgetPassState();
}

class _ForgetPassState extends State<ForgetPass> {

  //text controller
  final TextEditingController emailController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  //function to reset password
  Future resetPassword() async{
    try {
      if(emailController.text.isEmpty){
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Error'),
              content: const Text('Please enter your email'),
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
        return;
      }
      await FirebaseAuth.instance.sendPasswordResetEmail(email: emailController.text.trim());
      //show dialog for success
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Reset Email Sent',style: TextStyle(color: Color.fromARGB(255, 202, 173, 232)),),
            content: const Text('Please Check your Email to reset password\n\nIf you dont receive email,enure you have entered correct email'),
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
    } on FirebaseAuthException catch (e) {
      //show dialog for error
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text(e.message.toString()),
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
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 170, 129, 203),
      body: Stack(
        children: [
          //back button
          Positioned(
            top: 100,
            left: 20,
            child: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.arrow_circle_left_outlined,
                color: Colors.black,
                size: 40,
              ),
            ),
          ),

          //forget password
          const Positioned(
            top: 180,
            left: 30,
            right: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Forget Password",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 25,
                      fontFamily: 'Intersb',
                      fontWeight: FontWeight.w800,
                      height: 1.2),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "Enter your email to reset password",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400,
                      height: 1.2),
                ),
              ],
            ),
          ),

          //your email
          Positioned(
            top: 300,
            left: 25,
            right: 30,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Your Email",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontFamily: 'Intersb',
                      fontWeight: FontWeight.w800,
                      height: 1.2),
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                    controller: emailController,
                    style: const TextStyle(
                      color: Color.fromARGB(255, 68, 59, 75),
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.only(left: 20),
                      hintText: 'Enter your email',
                      hintStyle:
                          TextStyle(color: Color.fromARGB(255, 68, 59, 75)),
                      fillColor: Colors.white70,
                      filled: true,
                    ),
                  ),
                ),

                const SizedBox(
                  height: 20,
                ),

                //reset password button
                Positioned(
                  top: 400,
                  left: 30,
                  right: 30,
                  child: ElevatedButton(
                    onPressed: resetPassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 34, 28, 39),
                      minimumSize: Size(screenWidth, 60),
                      textStyle: const TextStyle(
                        fontSize: 17,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      'Reset Password',
                      style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          color: Color.fromARGB(255, 217, 207, 225)),
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
