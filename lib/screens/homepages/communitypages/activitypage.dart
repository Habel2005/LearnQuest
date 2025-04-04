import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyActivityPage extends StatefulWidget {
  final int initialTabIndex;
  const MyActivityPage({super.key, required this.initialTabIndex});

  @override
  State<MyActivityPage> createState() => _MyActivityPageState();
}

class _MyActivityPageState extends State<MyActivityPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> savedPosts = [];
  List<Map<String, dynamic>> myPosts = [];
  List<Map<String, dynamic>> likedPosts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this,initialIndex: widget.initialTabIndex);
    _fetchAllData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchAllData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await Future.wait([
      _fetchSavedPosts(),
      _fetchMyPosts(user.uid),
      _fetchLikedPosts(user.uid),
    ]);

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _fetchSavedPosts() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final userDoc = await userRef.get();

    if (!userDoc.exists) return;

    List<String> savedPostIds = List<String>.from(userDoc.data()?['profile']['savedPosts'] ?? []);

    List<Map<String, dynamic>> fetchedPosts = [];
    for (String postId in savedPostIds) {
      final postDoc = await FirebaseFirestore.instance.collection('posts').doc(postId).get();
      if (postDoc.exists) {
        fetchedPosts.add(postDoc.data()!..['id'] = postId);
      }
    }

    setState(() {
      savedPosts = fetchedPosts;
    });
  }

Future<void> _fetchMyPosts(String userId) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('posts')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .get();

    setState(() {
      myPosts = querySnapshot.docs
          .map((doc) => doc.data()..['id'] = doc.id)
          .toList();
    });
  }

  Future<void> _fetchLikedPosts(String userId) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('posts')
        .where('likes', arrayContains: userId)
        .orderBy('timestamp', descending: true)
        .get();

    setState(() {
      likedPosts = querySnapshot.docs
          .map((doc) => doc.data()..['id'] = doc.id)
          .toList();
    });
  }

  Widget _buildPostList(List<Map<String, dynamic>> posts, bool showRemoveOption) {
    if (posts.isEmpty) {
      return const Center(
        child: Text(
          "No posts yet.",
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        return Card(
          color: Colors.grey[100],
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: ListTile(
            title: Text(
              post['content'] ?? "No content",
              style: const TextStyle(color: Colors.black),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Topic: ${post['topic']}",
                  style: TextStyle(color: Colors.grey[600]),
                ),
                Text(
                  "Likes: ${(post['likes'] as List?)?.length ?? 0}",
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
            trailing: showRemoveOption
                ? IconButton(
                    icon: const Icon(Icons.bookmark_remove, color: Colors.red),
                    onPressed: () => _removeSavedPost(post['id']),
                  )
                : Text(
                    _formatTimestamp(post['timestamp']),
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
          ),
        );
      },
    );
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return '';
    final date = timestamp.toDate();
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _removeSavedPost(String postId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    await userRef.update({
      'profile.savedPosts': FieldValue.arrayRemove([postId])
    });

    setState(() {
      savedPosts.removeWhere((post) => post['id'] == postId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("My Activity", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.grey[200],
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0.5,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.black,
          tabs: const [
            Tab(text: "Saved", icon: Icon(Icons.bookmark)),
            Tab(text: "My Posts", icon: Icon(Icons.post_add)),
            Tab(text: "Liked", icon: Icon(Icons.favorite)),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.black))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildPostList(savedPosts, true),
                _buildPostList(myPosts, false),
                _buildPostList(likedPosts, false),
              ],
            ),
    );
  }
}