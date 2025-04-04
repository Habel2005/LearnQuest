import 'package:flutter/material.dart';
import 'package:our_own_project/auth-service/api.dart';
import 'package:our_own_project/screens/homepages/coursepages/coursedetail.dart';
import 'package:our_own_project/screens/homepages/home.dart';

class CategoryDetailScreen extends StatefulWidget {
  final String categoryName;

  const CategoryDetailScreen({super.key, required this.categoryName});

  @override
  _CategoryDetailScreenState createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen>
    with SingleTickerProviderStateMixin {
  late Future<List<Map<String, dynamic>>> _coursesFuture;
  late AnimationController _controller;
  late Animation<double> _titleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _coursesFuture =
        CategoryService.fetchCoursesByCategory(widget.categoryName);

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _titleAnimation = Tween<double>(begin: 0.5, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    Future.delayed(const Duration(milliseconds: 500), () {
      _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFB3E5FC), Color(0xFFF8BBD0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _titleAnimation.value * 100),
                    child: Opacity(
                      opacity: 1 - _titleAnimation.value,
                      child: Padding(
                        padding: EdgeInsets.only(
                            left: 20, top: _titleAnimation.value * 150),
                        child: Text(
                          widget.categoryName,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: _coursesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError || snapshot.data!.isEmpty) {
                      return const Center(child: Text("No courses available."));
                    }

                    final courses = snapshot.data!;
                    return AnimatedBuilder(
                      animation: _fadeAnimation,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _fadeAnimation.value,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16.0),
                            itemCount: courses.length,
                            itemBuilder: (context, index) {
                              final course = courses[index];
                              return AnimatedOpacity(
                                opacity: _fadeAnimation.value,
                                duration:
                                    Duration(milliseconds: 300 + (index * 100)),
                                child: Card(
                                  color: Colors.white.withOpacity(
                                      0.20), // Semi-transparent background
                                  elevation: 2.5,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    title: Text(
                                      course['title'],
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Colors
                                            .white, // White text for better contrast
                                      ),
                                    ),
                                    subtitle: Text(
                                      course['description'],
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white.withOpacity(
                                            0.8), // Light gray text
                                      ),
                                    ),
                                    trailing: const Icon(
                                      Icons.arrow_forward_ios,
                                      color: Colors
                                          .white, // White icon to match theme
                                    ),
                                    onTap: () {
                                      navigateWithSlideTransition(
                                          context,
                                          CourseDetailsScreen(
                                              courseId: course['courseId']));
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
