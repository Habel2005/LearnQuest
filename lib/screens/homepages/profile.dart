import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:our_own_project/screens/homepages/profilepages/contact.dart';
import 'package:our_own_project/screens/homepages/profilepages/editprofile.dart';
import 'package:our_own_project/screens/homepages/profilepages/terms_cond.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _username = '';
  String profileImageUrl = '';

  Future<void> _loadProfilePicture() async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        var data = userDoc.data() as Map<String, dynamic>?;
        var profile = data?['profile'] as Map<String, dynamic>?;

        if (profile != null && profile.containsKey('profilePicture')) {
          setState(() {
            profileImageUrl = profile['profilePicture'];
          });
        }
      }
    } on FirebaseException catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('An Error Ocuured $e')));
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUsername();
    _loadProfilePicture();
  }

  Future<void> _loadUsername() async {
    String username = await getUsername();
    setState(() {
      _username = username;
    });
  }

  Future<String> getUsername() async {
    final user = FirebaseAuth.instance.currentUser;

    try {
      if (user != null) {
        String userId = user.uid;
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();

        if (userDoc.exists) {
          var data = userDoc.data() as Map<String, dynamic>?;
          var profile = data?['profile'] as Map<String, dynamic>?;

          if (profile != null && profile.containsKey('fullName')) {
            return profile['fullName'];
          }
        }
      }
    } on Exception catch (e) {
      print('Error Occured $e');
    }

    return 'User Name';
  }

  //log out
  void _confirmLogout(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (BuildContext context) {
        Color borderColor = const Color.fromARGB(
            255, 127, 65, 186); // Change this color if needed

        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Thick top line
              Container(
                width: 35,
                height: 6, // Thickness of the line
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 78, 68, 98), // Line color
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 15),

              // Title
              const Text(
                "Logout",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              // Message
              const Text(
                "Are you sure you want to log out?",
                style: TextStyle(fontSize: 16, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),

              Row(
                children: [
                  // Cancel Button (Outlined)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                            color: borderColor, width: 2), // Border color
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        "Cancel",
                        style: TextStyle(color: borderColor, fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Log Out Button (Filled)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          FirebaseAuth.instance.signOut();
                        });
                        Navigator.pop(context); 
                        setState(() {
                          print("hello");
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            borderColor, // Fill color same as outline
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        "Log Out",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color.fromARGB(255, 89, 51, 172),
        body: Column(
          children: [
            // Top Profile Section
            SizedBox(
              height: 350,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Background Image
                  Image.asset(
                    'assets/prof3.jpg',
                    fit: BoxFit.cover,
                  ),
                  // Profile Content
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white,
                        child: ClipOval(
                          child: profileImageUrl.isNotEmpty
                              ? CircleAvatar(
                                  radius: 50,
                                  backgroundImage:
                                      NetworkImage(profileImageUrl),
                                )
                              : CircleAvatar(
                                  radius: 50,
                                  backgroundColor: Colors.grey[200],
                                  child: const Icon(Icons.person,
                                      size: 50, color: Colors.black87),
                                ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _username,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Menu Items
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color.fromARGB(237, 255, 255, 255),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: ListView(
                  children: [
                    // Profile Screen Menu
                    _buildMenuItem(
                      icon: Icons.person_outline,
                      title: 'Edit Profile',
                      onTap: () => navigateProfSlideTransition(
                        context,
                        const EditProfileScreen(),
                      ),
                    ),
                    _buildMenuItem(
                      icon: Icons.description_outlined,
                      title: 'Terms & Privacy',
                      onTap: () => navigateProfSlideTransition(
                        context,
                        const TermsAndConditionsPage(),
                      ),
                    ),
                    _buildMenuItem(
                      icon: Icons.contact_support_outlined,
                      title: 'Contact',
                      onTap: () => navigateProfSlideTransition(
                        context,
                        const ContactPage(),
                      ),
                    ),
                    _buildMenuItem(
                      icon: Icons.logout,
                      title: 'Logout',
                      onTap: () => _confirmLogout(context),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ));
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 10.0, vertical: 5), // Adds spacing
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15), // Smooth rounded corners
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12), // Glass effect
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                  color: Colors.white), // Subtle border
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.blue.shade100.withOpacity(0.2), // Light Blue Tint
                  Colors.pink.shade100.withOpacity(0.2), // Light Pink Tint
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color:
                      Colors.black.withOpacity(0.05), // Soft shadow for depth
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListTile(
              leading: Icon(icon, color: const Color(0xFF6B45BC)),
              title: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                  fontFamily: 'Poppins',
                ),
              ),
              trailing: const Icon(Icons.chevron_right, color: Colors.black54),
              onTap: onTap,
            ),
          ),
        ),
      ),
    );
  }
}

void navigateProfSlideTransition(BuildContext context, Widget targetPage) {
  Navigator.push(
    context,
    PageRouteBuilder(
      transitionDuration:
          const Duration(milliseconds: 400), // Slightly slower for smoothness
      pageBuilder: (context, animation, secondaryAnimation) => targetPage,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0); // Start off-screen (right)
        const end = Offset.zero; // End at center
        const curve = Curves.easeInOutQuad; // Smoother curve

        var slideTween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        var fadeTween = Tween<double>(begin: 0.0, end: 1.0).chain(
          CurveTween(curve: Curves.easeInOut), // Smooth fade-in
        );

        return SlideTransition(
          position: animation.drive(slideTween),
          child: FadeTransition(
            opacity: animation.drive(fadeTween), // Apply fade effect
            child: child,
          ),
        );
      },
    ),
  );
}
