import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lottie/lottie.dart';
import 'package:our_own_project/auth-service/api.dart';
import 'package:our_own_project/screens/homepages/coursepages/coursedetail.dart';

class SearchBarComponent extends StatefulWidget {
  final Function(String) onSearch;
  final bool isLoading;
  final TextEditingController controller;

  const SearchBarComponent({
    super.key,
    required this.onSearch,
    this.isLoading = false,
    required this.controller,
  });

  @override
  State<SearchBarComponent> createState() => _SearchBarComponentState();
}

class _SearchBarComponentState extends State<SearchBarComponent> {
  bool _isSearching = false;

  void _performSearch() {
    String value = widget.controller.text.trim();
    if (value.isNotEmpty) {
      setState(() => _isSearching = true);
      widget.onSearch(value);
      FocusScope.of(context).unfocus(); // Hide keyboard
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: widget.controller,
              style: TextStyle(color: Colors.grey.shade900),
              decoration: InputDecoration(
                hintText: 'Search for courses',
                hintStyle: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
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
                  vertical: 12,
                  horizontal: 12,
                ),
                filled: true,
                fillColor: Colors.grey.shade200,
                prefixIcon: const Icon(Icons.search, color: Colors.blue),
              ),
              onSubmitted: (_) => _performSearch(),
              onChanged: (text) {
                if (text.isEmpty) {
                  setState(() => _isSearching = false); // Reset when cleared
                }
              },
            ),
          ),
          if (widget.isLoading || _isSearching)
            const Padding(
              padding: EdgeInsets.only(right: 10),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.blue),
                onPressed: _performSearch,
              ),
            ),
        ],
      ),
    );
  }
}

class SearchResultsScreen extends StatefulWidget {
  final String searchQuery;

  const SearchResultsScreen({super.key, required this.searchQuery});

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _courses = [];
  String? _error;
  bool _dialogShown = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_dialogShown) {
      _dialogShown = true; // Ensure it runs only once

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showCourseGenerationDialog();
      });
    }
  }

  Future<void> _showCourseGenerationDialog() async {
    bool generateNew = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Colors.white,
                      Color(0xFFB3E5FC),
                      Color(0xFFFFCDD2)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.auto_awesome,
                        size: 48, color: Colors.blueAccent),
                    const SizedBox(height: 12),
                    const Text(
                      "Generate a New Course?",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Would you like to generate a new course based on your search query?",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.redAccent,
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                          ),
                          onPressed: () => Navigator.of(context).pop(false),
                          child:
                              const Text("No", style: TextStyle(fontSize: 16)),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.blueAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                          ),
                          onPressed: () => Navigator.of(context).pop(true),
                          child:
                              const Text("Yes", style: TextStyle(fontSize: 16)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ) ??
        false;

    _performSearch(generateNew);
  }

  Future<void> _performSearch(bool generateNew) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _error = 'You must be logged in to search for courses';
          _isLoading = false;
        });
        return;
      }

      final results = await CourseService.searchCourses(
        widget.searchQuery,
        user.uid,
        generateNew: generateNew,
      );

      setState(() {
        _courses = results;
        if (_courses.isEmpty) {
          _error = 'No courses found for "${widget.searchQuery}"';
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Color(0xFFDFF3FF)], // White to light blue
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom AppBar
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.blue),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        'Results for "${widget.searchQuery}"',
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              // Content Section
              Expanded(
                child: _isLoading
                    ? _buildLoadingScreen()
                    : _error != null
                        ? _buildErrorMessage()
                        : _buildResultsList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Modern Loading UI with Progress Bar
  Widget _buildLoadingScreen() {
    return Center(
      // Ensures animation is centered properly
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Fix: Increased animation size & ensured it's fully visible
          SizedBox(
            width: 300, // Bigger size
            height: 300,
            child: Lottie.asset(
              'assets/loading.json',
              fit: BoxFit.contain, // Ensures it doesn’t overflow
              repeat: true, // Ensures it loops continuously
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "Fetching results...",
            style: TextStyle(
                color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          // Progress Bar (Fix: Ensuring it starts from the left & stays aligned)
          SizedBox(
            width: 250, // Slightly wider for better visibility
            child: LinearProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              backgroundColor: Colors.grey[300],
              minHeight: 5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(_error!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
            onPressed: () => _performSearch(false),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList() {
    return ListView.builder(
      itemCount: _courses.length,
      padding: const EdgeInsets.only(top: 8, bottom: 24),
      itemBuilder: (context, index) {
        final course = _courses[index];
        print(course);

        return CourseCard(
          courseId: course['courseId'] ?? 'no-id',
          title: course['title'] ?? 'Untitled Course',
          description: course['description'] ?? 'No description available',
          category: course['category'] ?? 'General',
          skillLevel: course['skillLevel'] ?? 'Beginner',
          estimatedCompletion:
              course['estimatedCompletion'] ?? 'Variable duration',
          lessonsCount: (course['lessons'] as List<dynamic>?)?.length ?? 0,
          lessonTitles: (course['lessons'] as List<dynamic>?)
                  ?.map((lesson) => lesson['title'] as String)
                  .toList() ??
              [],

          isNew: course['createdAt'] != null
              ? DateTime.parse(course['createdAt'])
                  .isAfter(DateTime.now().subtract(const Duration(days: 7)))
              : false,
          userRating: course['averageRating'] != null
              ? course['averageRating'].toDouble()
              : double.parse((Random().nextDouble() * 5).toStringAsFixed(1)),
          progressPercentage: 0.0, // Placeholder for now
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    CourseDetailsScreen(courseId: course['courseId']),
              ),
            );
          },
        );
      },
    );
  }
}

class CourseCard extends StatelessWidget {
  final bool isNew;
  final double progressPercentage;
  final double userRating;
  final String courseId;
  final String title;
  final String description;
  final String category;
  final String skillLevel;
  final String estimatedCompletion;
  final int lessonsCount;
  final List<String> lessonTitles;
  final VoidCallback onTap;

  const CourseCard({
    super.key,
    required this.courseId,
    required this.title,
    required this.description,
    required this.category,
    required this.skillLevel,
    required this.estimatedCompletion,
    required this.lessonsCount,
    required this.lessonTitles,
    required this.onTap,
    this.isNew = false,
    this.progressPercentage = 0.0,
    this.userRating = 0.0,
  });

  Color _getCategoryColor() {
    switch (category) {
      case 'Web Development':
        return Colors.blue;
      case 'Mobile Apps':
        return Colors.purple;
      case 'Data Science':
        return Colors.green;
      case 'Machine Learning':
        return Colors.orange;
      case 'Cybersecurity':
        return Colors.red;
      case 'UI/UX Design':
        return Colors.pink;
      default:
        return Colors.blueGrey;
    }
  }

  IconData _getCategoryIcon() {
    switch (category) {
      case 'Web Development':
        return Icons.web;
      case 'Mobile Apps':
        return Icons.phone_android;
      case 'Data Science':
        return Icons.analytics;
      case 'Machine Learning':
        return Icons.psychology;
      case 'Cybersecurity':
        return Icons.security;
      case 'UI/UX Design':
        return Icons.design_services;
      default:
        return Icons.school;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [Colors.white, Colors.blue.shade50],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Header (Category & Skill Level)
              Row(
                children: [
                  Icon(_getCategoryIcon(),
                      color: _getCategoryColor(), size: 24),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getCategoryColor(),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        category,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      skillLevel,
                      style:
                          TextStyle(color: Colors.grey.shade800, fontSize: 12),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              /// Title
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 6),

              /// Description (Ensuring Visibility)
              Text(
                description,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                maxLines: 3, // Show more description before truncation
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 12),

              /// Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progressPercentage,
                  backgroundColor: Colors.grey.shade200,
                  minHeight: 5,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(_getCategoryColor()),
                ),
              ),

              const SizedBox(height: 10),

              /// Rating & Course Info (Now in Column to Prevent Overflow)
              Wrap(
                spacing: 10,
                runSpacing: 6, // Ensures no overflow
                alignment: WrapAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        userRating.toStringAsFixed(1),
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.timer, size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          estimatedCompletion,
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade600),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(width: 4),
                      Text(
                        '$lessonsCount lessons',
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),

              /// Lesson Titles Preview
              Text(
                'Lessons:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 8),
              ...lessonTitles.take(3).map(
                    (lesson) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          Icon(Icons.circle,
                              size: 8, color: _getCategoryColor()),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              lesson,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              if (lessonTitles.length > 3)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '+ ${lessonTitles.length - 3} more lessons',
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontStyle: FontStyle.italic),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
