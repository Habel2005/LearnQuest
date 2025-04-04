import 'package:flutter/material.dart';

class AILearningPage extends StatelessWidget {
  const AILearningPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade50,
              Colors.pink.shade50,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(child: _buildCourseList()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('AI Learning',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey.shade800,
                  )),
              Text('Personalized AI tutorials',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.blueGrey.shade600,
                  )),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              shape: BoxShape.circle,
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                )
              ],
            ),
            child:
                Icon(Icons.psychology, color: Colors.teal.shade600, size: 28),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseList() {
    final List<Map<String, dynamic>> courses = [
      {
        'title': 'Neural Networks 101',
        'progress': 0.4,
        'difficulty': 'Beginner',
        'duration': '20 mins',
        'image': 'assets/card1.jpg'
      },
      {
        'title': 'Computer Vision Basics',
        'progress': 0.2,
        'difficulty': 'Intermediate',
        'duration': '30 mins',
        'image': 'assets/card1.jpg'
      },
      {
        'title': 'Natural Language Processing',
        'progress': 0.7,
        'difficulty': 'Advanced',
        'duration': '45 mins',
        'image': 'assets/card1.jpg'
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: courses.length,
      itemBuilder: (context, index) {
        final course = courses[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, 4),
              )
            ],
          ),
          child: Column(
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                child: Image.asset(course['image'] as String,
                    height: 150, fit: BoxFit.cover),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(course['title'] as String,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey.shade800,
                        )),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: (course['progress'] as double),
                      backgroundColor: Colors.blueGrey.shade50,
                      color: Colors.pink.shade300,
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Chip(
                          backgroundColor: Colors.teal.shade50,
                          label: Text(course['difficulty'] as String,
                              style: TextStyle(color: Colors.teal.shade700)),
                        ),
                        Text(course['duration'] as String,
                            style: TextStyle(
                              color: Colors.blueGrey.shade600,
                            )),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
