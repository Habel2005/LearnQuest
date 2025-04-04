import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:our_own_project/models/category.dart';
import 'package:our_own_project/models/course.dart';

class CourseService {
  static const String baseUrl =
      'https://learnquestapi-production.up.railway.app';

  /// Search for courses or generate a new one
  static Future<List<Map<String, dynamic>>> searchCourses(
      String query, String userId,
      {bool generateNew = false}) async {
    final url = Uri.parse("$baseUrl/courses/search");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "search_query": query,
          "user_id": userId,
          "generate_new": generateNew,
        }),
      );

      if (response.statusCode == 200) {
        if (response.body.isNotEmpty) {
          final data = jsonDecode(response.body);

          if (data is List) {
            return List<Map<String, dynamic>>.from(
                data); // Handle list of courses
          } else if (data is Map<String, dynamic>) {
            return [data]; // Convert single course to a list
          }
        }
        return []; // Return empty list if no data
      } else {
        throw Exception("Failed to search courses: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error searching courses: $e");
    }
  }

  /// Get details of a specific course
  static Future<Map<String, dynamic>> getCourseDetails(String courseId) async {
    final url = Uri.parse("$baseUrl/courses/$courseId");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Failed to fetch course details: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error fetching course details: $e");
    }
  }

  /// Update user progress in a course
  static Future<Map<String, dynamic>> updateProgress(
      String courseId, String lessonId, bool completed) async {
    final url = Uri.parse("$baseUrl/courses/$courseId/progress");

    try {
      final response = await http.post(
        // Use PATCH for updating progress
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id": FirebaseAuth.instance.currentUser!.uid,
          "lesson_id": lessonId,
          "completed": completed,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print("Error: ${response.body}");
        return {
          "error": true,
          "message": "Failed to update progress",
          "details": response.body
        };
      }
    } catch (e) {
      print("Exception: $e");
      return {"error": true, "message": "Error updating progress"};
    }
  }

  static final FirebaseFirestore _firestore =
      FirebaseFirestore.instance; // ✅ Make it static

  /// Fetch all courses from Firestore
  static Future<List<Course>> fetchCourses() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection("courses")
          .orderBy("createdAt", descending: true)
          .get();

      return Future.value(snapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        return Course.fromJson({...data, "courseId": doc.id});
      }).toList());
    } catch (e) {
      throw Exception("Error fetching courses: $e");
    }
  }

  /// Fetch only new courses (created within the last 24 hours)
static Future<List<Course>> fetchNewCourses() async {
  try {
    List<Course> allCourses = await fetchCourses();
    DateTime now = DateTime.now();
    DateTime oneWeekAgo = now.subtract(const Duration(days: 7));

    return allCourses.where((course) {
      return course.createdAt.isAfter(oneWeekAgo);
    }).toList();
  } catch (e) {
    throw Exception("Error fetching new courses: $e");
  }
}


static Future<List<Course>> fetchMatchingCourses() async {
  try {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    // ✅ Fetch user preferences
    DocumentSnapshot userDoc = await _firestore.collection("users").doc(userId).get();
    if (!userDoc.exists) throw Exception("User not found");

    Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
    List<String> interests = List<String>.from(userData["preferences"]["interests"] ?? []);
    String skillLevel = userData["preferences"]["skillLevel"] ?? "";

    if (interests.isEmpty) return []; // No preferences found

    // ✅ Query courses that match the user's interests and skill level
    QuerySnapshot snapshot = await _firestore
        .collection("courses")
        .where("category", whereIn: interests)
        .where("skillLevel", isEqualTo: skillLevel)
        .get();

    return snapshot.docs.map((doc) {
      var data = doc.data() as Map<String, dynamic>;
      return Course.fromJson({...data, "courseId": doc.id});
    }).toList();
  } catch (e) {
    throw Exception("Error fetching matching courses: $e");
  }
}

  
/// Marks a challenge as completed in Firestore
static Future<bool> toggleChallengeCompletion(String challengeId) async {
  String userId = FirebaseAuth.instance.currentUser!.uid;
  String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

  DocumentReference dailyChallengeRef = _firestore
      .collection('users')
      .doc(userId)
      .collection("daily_challenges")
      .doc(today);

  try {
    DocumentSnapshot snapshot = await dailyChallengeRef.get();

    if (!snapshot.exists) {
      return false; // No daily challenge exists for today
    }

    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    List<dynamic> completedToday = data["completedToday"] ?? [];
    int streakCount = data["streakCount"] ?? 0;

    if (completedToday.contains(challengeId)) {
      // If challenge is already completed, remove it (Undo completion)
      completedToday.remove(challengeId);
      streakCount = (streakCount > 0) ? streakCount - 1 : 0;
    } else {
      // Otherwise, mark it as completed
      completedToday.add(challengeId);
      streakCount++;
    }

    await dailyChallengeRef.update({
      "completedToday": completedToday,
      "streakCount": streakCount,
    });

    return completedToday.contains(challengeId); // Return new state
  } catch (e) {
    print("Error updating challenge completion: $e");
    return false;
  }
}


static Future<bool> fetchChallengeStatus(String challengeId) async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    DocumentReference dailyChallengeRef = _firestore
        .collection('users')
        .doc(userId)
        .collection("daily_challenges")
        .doc(today);

    DocumentSnapshot snapshot = await dailyChallengeRef.get();

    if (!snapshot.exists) {
      return false;
    }

    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    List<dynamic> completedToday = data["completedToday"] ?? [];

    return completedToday.contains(challengeId);
  }

}

class CategoryService {
  static const String apiUrl =
      "https://learnquestapi-production.up.railway.app/categories/all"; // Replace with your backend IP

  static Future<List<Category>> fetchCategories() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => Category.fromJson(json)).toList();
      } else {
        throw Exception("Failed to load categories");
      }
    } catch (e) {
      print("Error fetching categories1: $e");
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> fetchHomeCategories(
      int limit) async {
    final response = await http.get(Uri.parse(
        'https://learnquestapi-production.up.railway.app/categories?limit=$limit'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data
          .map((category) => {
                'name': category['name'],
                'gradient_colors': (category['color'] as List)
                    .map((color) =>
                        Color(int.parse(color.replaceFirst('#', '0xFF'))))
                    .toList(),
                'image': category['image'],
              })
          .toList();
    } else {
      throw Exception('Failed to load categories');
    }
  }

  static Future<List<Map<String, dynamic>>> fetchCoursesByCategory(String category) async {
  try {
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('courses')
        .where('category', isEqualTo: category)
        .get();

    return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  } catch (e) {
    print("Error fetching courses: $e");
    return [];
  }
  }

 static Future<List<Category>> fetchMoreCategories(List<String> excludedCategories) async {
   const String apiUrl =
      "https://learnquestapi-production.up.railway.app/categories/more";
  final uri = Uri.parse(apiUrl).replace(queryParameters: {
    "excluded": excludedCategories,
  });

  try {
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Category.fromJson(json)).toList();
    } else {
      throw Exception("Failed to load more categories");
    }
  } catch (e) {
    print("Error fetching more categories: $e");
    return [];
  }
}


}

