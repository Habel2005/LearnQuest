import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:our_own_project/auth-service/api.dart';
import 'package:our_own_project/screens/homepages/coursepages/lessonscreen.dart';

class CourseDetailsScreen extends StatefulWidget {
  final String courseId;

  const CourseDetailsScreen({super.key, required this.courseId});

  @override
  State<CourseDetailsScreen> createState() => _CourseDetailsScreenState();
}

class _CourseDetailsScreenState extends State<CourseDetailsScreen> {
  late Future<Map<String, dynamic>> _courseFuture;
  Map<String, dynamic>? _userProgress;
  bool isBookmarked = false; // Track bookmark state

  @override
  void initState() {
    super.initState();
    _courseFuture = _fetchCourseDetails();
    _loadUserProgress();
    _checkBookmarkStatus();
  }

  Future<Map<String, dynamic>> _fetchCourseDetails() async {
    final response = await CourseService.getCourseDetails(widget.courseId);
    if (response.isNotEmpty) {
      return response;
    } else {
      throw Exception('Failed to load course details');
    }
  }

  Future<void> _loadUserProgress() async {
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();

    setState(() {
      _userProgress = userDoc.data()?['progress']?[widget.courseId] ?? {};
    });
  }

  Future<void> _checkBookmarkStatus() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    DocumentReference userRef =
        FirebaseFirestore.instance.collection('users').doc(userId);

    try {
      DocumentSnapshot userDoc = await userRef.get();

      if (userDoc.exists) {
        // Safely cast `data()` to a Map<String, dynamic>
        Map<String, dynamic>? userData =
            userDoc.data() as Map<String, dynamic>?;

        List<String> bookmarks = [];

        if (userData != null && userData.containsKey('bookmarkedCourses')) {
          bookmarks = List<String>.from(userData['bookmarkedCourses']);
        }

        setState(() {
          isBookmarked = bookmarks.contains(widget.courseId);
        });
      }
    } catch (e) {
      print("Error fetching bookmarks: $e");
    }
  }

  Future<void> _toggleBookmark() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    DocumentReference userRef =
        FirebaseFirestore.instance.collection('users').doc(userId);

    try {
      DocumentSnapshot userDoc = await userRef.get();
      List<String> bookmarks = [];

      if (userDoc.exists) {
        // Cast data() to Map<String, dynamic> safely
        Map<String, dynamic>? userData =
            userDoc.data() as Map<String, dynamic>?;

        if (userData != null && userData.containsKey('bookmarkedCourses')) {
          bookmarks = List<String>.from(userData['bookmarkedCourses']);
        }
      }

      setState(() {
        if (bookmarks.contains(widget.courseId)) {
          bookmarks.remove(widget.courseId);
          isBookmarked = false;
        } else {
          bookmarks.add(widget.courseId);
          isBookmarked = true;
        }
      });

      // Update Firestore with the modified bookmarks list
      await userRef
          .set({'bookmarkedCourses': bookmarks}, SetOptions(merge: true));
    } catch (e) {
      print("Error updating bookmarks: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Base color stays white
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.white,
        title: const Text(
          'Course Details',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black54),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: isBookmarked ? Colors.blue : Colors.grey,
            ),
            onPressed: _toggleBookmark,
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black54),
            onPressed: () => setState(() {
              _courseFuture = _fetchCourseDetails();
              _loadUserProgress();
            }),
          ),
        ],
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _courseFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final courseData = snapshot.data!;
          final lessons =
              List<Map<String, dynamic>>.from(courseData['lessons']);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CourseHeader(
                    courseData: courseData), // The card matches the theme
                const SizedBox(height: 24),
                _ProgressIndicator(
                  totalLessons: lessons.length,
                  completedLessons: _userProgress?.values
                          .where((v) => v['completed'] == true)
                          .length ??
                      0,
                ),
                const SizedBox(height: 16),
                Text(
                  "Lessons",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold, color: Colors.blue.shade300),
                ),
                const SizedBox(height: 12),
                ...lessons.map((lesson) => _LessonTile(
                      lesson: lesson,
                      isCompleted: _userProgress?[lesson['lessonId']]
                              ?['completed'] ??
                          false,
                      onTap: () => _navigateToLesson(context, lesson),
                    )),
              ],
            ),
          );
        },
      ),
    );
  }

  void _navigateToLesson(
      BuildContext context, Map<String, dynamic> lesson) async {
    final courseData = await _courseFuture;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LessonScreen(
          courseId: widget.courseId,
          lesson: lesson,
          totalLessons: (courseData['lessons'] as List).length,
        ),
      ),
    );
  }
}

class _CourseHeader extends StatelessWidget {
  final Map<String, dynamic> courseData;

  const _CourseHeader({required this.courseData});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              courseData['title'],
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold, color: Colors.grey.shade800),
            ),
            const SizedBox(height: 8),
            Text(
              courseData['description'],
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _InfoChip(
                    icon: Icons.schedule,
                    label: courseData['estimatedCompletion']),
                _InfoChip(icon: Icons.school, label: courseData['skillLevel']),
                _InfoChip(icon: Icons.category, label: courseData['category']),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressIndicator extends StatelessWidget {
  final int totalLessons;
  final int completedLessons;

  const _ProgressIndicator({
    required this.totalLessons,
    required this.completedLessons,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = totalLessons > 0 ? (completedLessons / totalLessons) : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Course Progress',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: percentage as double,
            backgroundColor: Colors.grey.shade200,
            minHeight: 10,
            valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF6A89CC)), // Subtle blue
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '$completedLessons/$totalLessons lessons completed',
          style: TextStyle(color: Colors.grey.shade600),
        ),
      ],
    );
  }
}

class _LessonTile extends StatelessWidget {
  final Map<String, dynamic> lesson;
  final bool isCompleted;
  final VoidCallback onTap;

  const _LessonTile({
    required this.lesson,
    required this.isCompleted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              isCompleted ? Colors.green.shade100 : Colors.grey.shade200,
          child: Icon(
            isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isCompleted ? Colors.green : Colors.grey,
          ),
        ),
        title: Text(lesson['title'],
            style: TextStyle(
                fontWeight: FontWeight.w500, color: Colors.blue.shade800)),
        subtitle: Text(
          lesson['description'],
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: Colors.grey.shade600),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 18, color: Colors.blueAccent),
      label: Text(
        label,
        style: TextStyle(color: Colors.blue.shade600),
      ),
      backgroundColor: Colors.blue.shade50,
    );
  }
}
