import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';


class Auth {
  //auth instance
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//log in user
  Future<UserCredential> signInFirebase(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);

      String uid = userCredential.user!.uid;

      // Only update the last login time, without overwriting other fields
      await _firestore.collection('users').doc(uid).set({
        'auth': {
          'lastLogin': FieldValue.serverTimestamp(),
        }
      }, SetOptions(merge: true)); // Merge to avoid data loss

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

// Register with email and password
  Future<UserCredential> registerFirebase(
      String email, String password, String fullName) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      String uid = userCredential.user!.uid;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isPersonalInfoCompleted', false);

      // Store new user data in Firestore with structured format
      await _firestore.collection('users').doc(uid).set({
        'profile': {
          'fullName': fullName,
          'dob': "",
          'gender': "",
          'location': {},
          'savedPosts': []
        },
        'preferences': {
          'skillLevel': "",
          'interests': [],
          'learningStyle': "",
          'dailyCommitment': 0,
        },
        'progress': {}, // Empty for now, to be updated later
        'auth': {
          'uid': uid,
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
        }
      });

      storeDeviceToken();

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

// Google Sign-In
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        return null; // User canceled sign-in
      }

      final GoogleSignInAuthentication gAuth = await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: gAuth.accessToken,
        idToken: gAuth.idToken,
      );

      UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      User? user = userCredential.user;

      if (user != null) {
        String uid = user.uid;

        // Check if user already exists
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(uid).get();

        final prefs = await SharedPreferences.getInstance();

        if (!userDoc.exists) {
          // If user is new, create full structured data
          await _firestore.collection('users').doc(uid).set({
            'profile': {
              'fullName': user.displayName ?? "",
              'dob': "",
              'gender': "",
              'location': {},
              'savedPosts': []
            },
            'preferences': {
              'skillLevel': "beginner",
              'interests': [],
              'learningStyle': "videos",
              'dailyCommitment': 0,
            },
            'progress': {},
            'auth': {
              'uid': uid,
              'email': user.email,
              'createdAt': FieldValue.serverTimestamp(),
            }
          });
          await prefs.setBool('isPersonalInfoCompleted', false);
        } else {
          // If user exists, only update the last login time
          await _firestore.collection('users').doc(uid).set({
            'auth': {
              'lastLogin': FieldValue.serverTimestamp(),
            }
          }, SetOptions(merge: true));
        }
      }

      storeDeviceToken();

      return userCredential;
    } catch (e) {
      throw Exception("Google Sign-In failed: $e");
    }
  }

  //error handling
  String getError(String e) {
    switch (e) {
      case 'Exception: wrong-password':
        return 'The password is incorrect,please try again';
      case 'Exception: user-not-found':
        return 'The user does not exist,please register';
      case 'Exception: email-already-in-use':
        return 'The email is already in use,please login';
      case 'Exception: invalid-email':
        return 'The email is invalid,please enter a valid email';
      case 'Exception: weak-password':
        return 'The password is too weak,please enter a stronger password';
      default:
        return 'An unexpected error occured,please try again';
    }
  }

  //profile filling
  Future<void> saveUserInfo(String uid, Map<String, dynamic> profile) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'profile': profile,
    }, SetOptions(merge: true));
  }

//prefrence filling
  Future<void> saveUserPref(String uid, Map<String, dynamic> prefs) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .set({'preferences': prefs}, SetOptions(merge: true));
  }

Future<void> storeDeviceToken() async {
  final user = _auth.currentUser;
  if (user == null) throw Exception('User not authenticated');

  String? deviceToken = await FirebaseMessaging.instance.getToken();
  if (deviceToken != null) {
    await _firestore.collection('users').doc(user.uid).update({
      'auth': {
        'deviceToken': deviceToken,
      },
    });
  }
}
}


