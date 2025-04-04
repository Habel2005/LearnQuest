import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:our_own_project/auth-service/api.dart';
import 'package:url_launcher/url_launcher.dart';

class LessonScreen extends StatefulWidget {
  final String courseId;
  final Map<String, dynamic> lesson;
  final int totalLessons;

  const LessonScreen({
    super.key,
    required this.courseId,
    required this.lesson,
    required this.totalLessons,
  });

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  bool _isCompleted = false;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _loadCompletionStatus();
  }

  Future<void> _loadCompletionStatus() async {
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();

    setState(() {
      _isCompleted = userDoc.data()?['progress']?[widget.courseId]
              ?[widget.lesson['lessonId']]?['completed'] ??
          false;
    });
  }

  Future<void> _toggleCompletion() async {
    setState(() => _isUpdating = true);

    try {
      final response = await CourseService.updateProgress(
          widget.courseId, widget.lesson['lessonId'], !_isCompleted);

      print("API Response: $response"); // Debugging log

      if (response["progress"] != null) {
        setState(() {
          _isCompleted = !_isCompleted;
        });
      } else {
        throw Exception("Invalid response: ${jsonEncode(response)}");
      }
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update progress: $e')),
      );
    } finally {
      setState(() => _isUpdating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Keeping the white theme
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.white,
        title: Text(
          'Lesson ${widget.lesson['lessonId']}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.black87, // Darker color for visibility
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark, color: Colors.black54),
            onPressed: () {/* Implement bookmarking */},
          ),
        ],
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.lesson['title'],
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87, // Ensuring visibility
                  ),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Theory',
              content: widget.lesson['content']['theory'],
            ),
            const SizedBox(height: 16),
            if (widget.lesson['content']['practice'] != null)
              _SectionCard(
                title: 'Practice',
                content: widget.lesson['content']['practice'],
                resources: widget.lesson['content']
                    ['resources'], // Pass content resources
              ),
            const SizedBox(height: 16),
            if (widget.lesson['content']['resources'] != null &&
                widget.lesson['content']['resources'].isNotEmpty)
              _ResourceSection(resources: widget.lesson['resources']),
          ],
        ),
      ),
      floatingActionButton: _CompletionButton(
        isCompleted: _isCompleted,
        isUpdating: _isUpdating,
        onPressed: _toggleCompletion,
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String content;
  final List<dynamic>? resources; // Added resources field

  const _SectionCard({
    required this.title,
    required this.content,
    this.resources, // Optional resources
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              content,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            if (resources != null && resources!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: resources!.map((url) {
                  return GestureDetector(
                    onTap: () => _launchUrl(url),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.attach_file,
                              size: 14, color: Colors.blue),
                          SizedBox(width: 4),
                          Text(
                            "Resource Link",
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 14,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ResourceSection extends StatelessWidget {
  final List<dynamic> resources;

  const _ResourceSection({required this.resources});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Resources',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        if (resources.isEmpty)
          const Text(
            'No resources available',
            style: TextStyle(color: Colors.grey),
          )
        else
          ...resources.map((resource) {
            if (resource is Map<String, dynamic>) {
              if (resource['type'] == 'video') {
                // New YouTube video card
                return _buildVideoCard(resource);
              } else {
                // Other resource types remain unchanged
                return _buildResourceCard(
                  icon: _getResourceIcon(resource['type']),
                  title: resource['title'] ?? 'No Title',
                  subtitle: resource['url'] ?? 'No URL',
                  url: resource['url'],
                );
              }
            } else {
              return const SizedBox();
            }
          }),
      ],
    );
  }

  // Extracted method to create resource cards
  Widget _buildResourceCard({
    required IconData icon,
    required String title,
    required String subtitle,
    String? url,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        leading: Icon(icon, color: Colors.blueAccent),
        title: Text(title, style: const TextStyle(color: Colors.black87)),
        subtitle: Text(subtitle, style: TextStyle(color: Colors.grey.shade600)),
        onTap: url != null ? () => _launchUrl(url) : null, // Disable if no URL
      ),
    );
  }

  // New YouTube video card layout
  Widget _buildVideoCard(Map<String, dynamic> resource) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
            child: Image.network(
              resource['thumbnail'] ?? '',
              width: double.infinity,
              height: 160,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  resource['title'] ?? 'No Title',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  resource['channel'] ?? 'Unknown Channel',
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  "Published: ${resource['published_at']?.split('T')[0] ?? 'N/A'}",
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: OutlinedButton.icon(
                    onPressed: () => _launchUrl(resource['url']),
                    icon: const Icon(Icons.play_arrow, size: 18),
                    label: const Text("Watch Video"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black87,
                      side: BorderSide(color: Colors.grey.shade400),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      textStyle: const TextStyle(fontSize: 14),
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

  IconData _getResourceIcon(String? type) {
    switch (type) {
      case 'video':
        return Icons.video_library;
      case 'article':
        return Icons.article;
      case 'repository':
        return Icons.code;
      default:
        return Icons.link;
    }
  }
}

class _CompletionButton extends StatelessWidget {
  final bool isCompleted;
  final bool isUpdating;
  final VoidCallback onPressed;

  const _CompletionButton({
    required this.isCompleted,
    required this.isUpdating,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      icon: isUpdating
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                  color: Colors.white, strokeWidth: 2),
            )
          : Icon(isCompleted ? Icons.replay : Icons.check),
      label: Text(
        isCompleted ? 'Mark Incomplete' : 'Complete Lesson',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      backgroundColor: isCompleted ? Colors.green : Colors.blueAccent,
      onPressed: isUpdating ? null : onPressed,
    );
  }
}

void _launchUrl(String url) async {
  if (url.isEmpty || !url.startsWith('http')) {
    print("Invalid URL: $url");
    return;
  }

  final Uri uri = Uri.tryParse(url) ?? Uri();

  if (await canLaunchUrl(uri)) {
    await launchUrl(uri,
        mode: LaunchMode.externalApplication); // Open in browser
  } else {
    print("Could not launch $url");
  }
}
