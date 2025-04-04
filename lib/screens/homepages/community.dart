import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:our_own_project/auth-service/communityfb.dart';
import 'package:our_own_project/main.dart';
import 'package:our_own_project/models/post.dart';
import 'package:our_own_project/screens/homepages/communitypages/activitypage.dart';
import 'package:our_own_project/screens/homepages/communitypages/notification.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:string_similarity/string_similarity.dart';

class CommunityPage extends StatefulWidget {
  final PageController pageController;
  const CommunityPage({super.key, required this.pageController});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  final FirebaseService _firebaseService = FirebaseService();
  final TextEditingController _postController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  TextEditingController topicController = TextEditingController();
  String? newTopic;
  late Set<String> savedPosts = {};
  String _selectedTopic = 'General';
  String? suggestedTopic;
  String? errorMessage;
  final Map<String, UserProfile> _userProfiles = {};

  @override
  void dispose() {
    _postController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadSavedPosts();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        // Show the local notification (if needed)
        showFlutterNotification(message);
        _handleNotificationClick(message.data);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("📲 Notification clicked (Background/Terminated): ${message.data}");
      _handleNotificationClick(message.data); // Handle the click
    });

// App launched from a terminated state or background
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
      if (message != null) {
        print("🚀 App launched from notification: ${message.data}");
        _handleNotificationClick(message.data); // Handle the click
      }
    });
  }

  void _handleNotificationClick(Map<String, dynamic> data) {
    print('Handling notification click');
    final String? postId = data['post'];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.pageController.hasClients) {
        int currentIndex = widget.pageController.page?.round() ?? 0;
        print('hello');

        if (postId != null) {
          if (currentIndex == 2) {
            print('already on page 2');
            navigatorKey.currentState?.push(
              MaterialPageRoute(
                builder: (context) => const MyActivityPage(initialTabIndex: 1),
              ),
            );
          } else {
            print('switching to page 2');
            widget.pageController.jumpToPage(2);

            // 🚀 Use a global navigator that doesn't rely on the widget context
            WidgetsBinding.instance.addPostFrameCallback((_) {
              print('navigating to MyActivityPage');
              navigatorKey.currentState?.push(
                MaterialPageRoute(
                  builder: (context) => const MyActivityPage(initialTabIndex: 1),
                ),
              );
            });
          }
        }
      }
    });
  }

  void showFlutterNotification(RemoteMessage message) async {
    print("🛠 Showing Local Notification: ${message.notification?.title}");

    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      channelDescription: 'Channel for important notifications',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
      playSound: true,
    );

    var notificationDetails =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000), // Unique ID
      message.notification?.title ?? "New Notification",
      message.notification?.body ?? "You have a new message.",
      notificationDetails,
      payload: jsonEncode(message.data),
    );
  }

  void _loadSavedPosts() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userRef =
        FirebaseFirestore.instance.collection('users').doc(user.uid);
    final userDoc = await userRef.get();

    if (userDoc.exists) {
      Map<String, dynamic> profileData = userDoc.data()?['profile'] ?? {};
      setState(() {
        savedPosts = Set<String>.from(profileData['savedPosts'] ?? []);
      });
    }
  }

  void _navigateToProfile() {
    widget.pageController.animateToPage(
      3,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _postContent() async {
    FocusScope.of(context).unfocus();
    if (_postController.text.isEmpty) {
      setState(() {
        errorMessage = "Please Enter A Message";
      });
      return;
    }
    if (_selectedTopic.isEmpty) {
      setState(() {
        errorMessage = "Please select a topic";
      });
      return;
    }

    // Reset error message and post
    setState(() {
      errorMessage = null;
    });

    try {
      await _firebaseService.createPost(
        _postController.text.trim(),
        newTopic ?? "General",
      );

      _postController.clear();
      topicController.clear();

      setState(() {
        newTopic = null;
        suggestedTopic = null;
      });

      Navigator.pop(context);
    } catch (e) {
      setState(() => errorMessage = "Error posting: ${e.toString()}");
    }
  }

  Future<UserProfile?> _getUserProfile(String userId) async {
    if (!_userProfiles.containsKey(userId) || _userProfiles[userId] == null) {
      final profile = await _firebaseService.getUserProfile(userId);

      if (profile != null) {
        _userProfiles[userId] = profile;
      } else {
        _userProfiles[userId] = UserProfile(
          fullName: 'Unknown User',
          profilePicture: '',
          location: 'Unknown',
          gender: '',
          dob: DateTime.now(),
        );
      }
    }
    return _userProfiles[userId];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            floating: true,
            backgroundColor: Colors.white,
            elevation: 0,
            title: const Text(
              'Community',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              PopupMenuButton(
                color: const Color.fromARGB(255, 245, 251, 255),
                icon: const Icon(Icons.settings_rounded, color: Colors.black,size: 30,),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    child: const Text(
                      'My Profile',
                      style: TextStyle(color: Colors.black87),
                    ),
                    onTap: () => _navigateToProfile(),
                  ),
                  PopupMenuItem(
                    child: const Text(
                      'My Activity',
                      style: TextStyle(color: Colors.black87),
                    ),
                    onTap: () => _showSavedPosts(),
                  ),
                  PopupMenuItem(
                    child: const Text(
                      'Notification Settings',
                      style: TextStyle(color: Colors.black87),
                    ),
                    onTap: () => _shownotifcation(),
                  ),
                ],
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildCreatePost(),
                  const SizedBox(height: 16),
                  _buildTopics(),
                ],
              ),
            ),
          ),
          StreamBuilder<List<Post>>(
            stream: _firebaseService.getPosts(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverToBoxAdapter(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (snapshot.hasError) {
                return const SliverToBoxAdapter(
                  child: Center(child: Text('Error loading posts')),
                );
              }

              final posts = snapshot.data ?? [];
              final filteredPosts = _selectedTopic == 'General'
                  ? posts
                  : posts
                      .where((post) => post.topic == _selectedTopic)
                      .toList();

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildPost(filteredPosts[index]),
                  childCount: filteredPosts.length,
                ),
              );
            },
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 65),
          ),
        ],
      ),
    );
  }

  Widget _buildCreatePost() {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    return FutureBuilder<UserProfile?>(
      future: _getUserProfile(currentUserId!),
      builder: (context, snapshot) {
        final userProfile = snapshot.data;
        return GestureDetector(
          onTap: () => _showCreatePostDialog(context),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: (userProfile != null &&
                          userProfile.profilePicture.isNotEmpty)
                      ? NetworkImage(userProfile.profilePicture)
                      : null,
                  child: (userProfile == null ||
                          userProfile.profilePicture.isEmpty)
                      ? const Icon(Icons.person, color: Colors.grey)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Text(
                      'Share something with the community...',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopics() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('topics').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        List<String> topics = snapshot.data!.docs.map((doc) => doc.id).toList();
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: topics
                .map((topic) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(topic),
                        selected: _selectedTopic == topic,
                        onSelected: (selected) {
                          setState(() => _selectedTopic = topic);
                        },
                        backgroundColor: Colors.white,
                        selectedColor: Colors.blue[100],
                        labelStyle: TextStyle(
                          color: _selectedTopic == topic
                              ? Colors.blue
                              : Colors.black87,
                        ),
                      ),
                    ))
                .toList(),
          ),
        );
      },
    );
  }

  Widget _buildPost(Post post) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    return FutureBuilder<UserProfile?>(
      future: _getUserProfile(post.userId),
      builder: (context, snapshot) {
        final userProfile = snapshot.data;
        if (userProfile == null) return const SizedBox();

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: userProfile.profilePicture.isNotEmpty
                        ? NetworkImage(userProfile.profilePicture)
                        : null,
                    child: userProfile.profilePicture.isEmpty
                        ? const Icon(Icons.person)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userProfile.fullName,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black87),
                        ),
                        Text(
                          '${userProfile.location} • ${_getTimeAgo(post.timestamp)}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                post.content,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildInteractionButton(
                    icon: post.likes.contains(currentUserId)
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: post.likes.contains(currentUserId)
                        ? Colors.red
                        : Colors.grey[600],
                    label: post.likes.length.toString(),
                    onTap: () => {_firebaseService.toggleLike(post.id)},
                  ),
                  const SizedBox(width: 30),
                  _buildInteractionButton(
                      icon: Icons.comment_outlined,
                      color: Colors.grey[600],
                      onTap: () => _showComments(post.id),
                      label: post.commentcount.toString()),
                  const SizedBox(width: 30),
                  _buildInteractionButton(
                    icon: savedPosts.contains(post.id)
                        ? Icons.bookmark
                        : Icons.bookmark_border,
                    color: savedPosts.contains(post.id)
                        ? Colors.blue
                        : Colors.grey[600],
                    label: "Save",
                    onTap: () async {
                      await _firebaseService.toggleSavePost(post.id);
                      _loadSavedPosts(); // Reload saved posts so UI updates
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInteractionButton({
    required IconData icon,
    Color? color,
    String? label,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          if (label != null) ...[
            const SizedBox(width: 4),
            Text(label, style: TextStyle(color: color)),
          ],
        ],
      ),
    );
  }

  void _handleTopicChange(String value) async {
    String formattedTopic = formatTopic(value);
    String? existingTopic = await checkTopicExists(formattedTopic);

    setState(() {
      suggestedTopic =
          (existingTopic != null && existingTopic != formattedTopic)
              ? existingTopic
              : null;
      newTopic = suggestedTopic ?? formattedTopic; // Set new topic
    });
  }

  void _showSavedPosts() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => const MyActivityPage(
                initialTabIndex: 0,
              )),
    );
  }

  void _shownotifcation() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) =>  const NotificationSettingsPage()),
    );
  }

  void toggleSavePost(String userId, String postId) async {
    final userRef = FirebaseFirestore.instance.collection('users').doc(userId);

    final userDoc = await userRef.get();
    if (userDoc.exists) {
      List savedPosts = userDoc['savedPosts'] ?? [];

      if (savedPosts.contains(postId)) {
        // Unsave the post (remove from array)
        await userRef.update({
          'savedPosts': FieldValue.arrayRemove([postId])
        });
      } else {
        // Save the post (add to array)
        await userRef.update({
          'savedPosts': FieldValue.arrayUnion([postId])
        });
      }
    }
  }

  void _showCreatePostDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Create Post',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _postController,
              style: const TextStyle(color: Colors.black87),
              decoration: InputDecoration(
                hintText: "What's on your mind?",
                hintStyle: const TextStyle(color: Colors.black87),
                border: InputBorder.none,
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.all(16),
              ),
              maxLines: 5,
            ),
            if (errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(errorMessage!,
                    style: const TextStyle(color: Colors.red)),
              ),
            const SizedBox(height: 10),
            SizedBox(
              child: TextField(
                style: const TextStyle(color: Colors.black87),
                controller: topicController,
                decoration: const InputDecoration(
                    labelText: "Enter Topic",
                    labelStyle: TextStyle(color: Colors.black87)),
                onChanged: _handleTopicChange,
              ),
            ),
            if (suggestedTopic != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      newTopic =
                          suggestedTopic; // Accept suggestion when tapped
                      topicController.text = newTopic!;
                      suggestedTopic = null; // Hide suggestion after selection
                    });
                  },
                  child: Text(
                    "Did you mean \"$suggestedTopic\"?",
                    style: const TextStyle(color: Colors.blue, fontSize: 14),
                  ),
                ),
              ),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.black87),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  onPressed: _postContent,
                  child: const Text('Post'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showComments(String postId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Comments',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: StreamBuilder<List<Comment>>(
                  stream: _firebaseService.getComments(postId),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final comments = snapshot.data!;
                    return ListView.builder(
                      controller: controller,
                      itemCount: comments.length,
                      itemBuilder: (context, index) =>
                          _buildComment(comments[index]),
                    );
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                child: _buildCommentInput(postId),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildComment(Comment comment) {
    return FutureBuilder<UserProfile?>(
      future: _getUserProfile(comment.userId),
      builder: (context, snapshot) {
        final userProfile = snapshot.data;
        if (userProfile == null) return const SizedBox();

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundImage: userProfile.profilePicture.isNotEmpty
                    ? NetworkImage(userProfile.profilePicture)
                    : null,
                radius: 16,
                child: userProfile.profilePicture.isEmpty
                    ? const Icon(Icons.person, size: 16)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          userProfile.fullName,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _getTimeAgo(comment.timestamp),
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      comment.content,
                      style: TextStyle(color: Colors.grey[850]),
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

  Widget _buildCommentInput(String postId) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: 'Add a comment...',
                hintStyle:
                    TextStyle(color: Colors.grey[700]), // Darker hint text
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: Colors.black),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: Colors.black),
                ),
              ),
              style: const TextStyle(
                  color: Colors.black), // Ensure input text is visible
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon:
                const Icon(Icons.send, color: Colors.black), // Black send icon
            onPressed: () async {
              if (_commentController.text.isNotEmpty) {
                await _firebaseService.addComment(
                  postId,
                  _commentController.text,
                );
                _commentController.clear();
              }
            },
          ),
        ],
      ),
    );
  }

  String _getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'just now';
    }
  }
}

Future<String?> checkTopicExists(String topic) async {
  String formattedTopic = formatTopic(topic);
  QuerySnapshot topicsSnapshot =
      await FirebaseFirestore.instance.collection('topics').get();

  List<String> existingTopics =
      topicsSnapshot.docs.map((doc) => doc.id).toList();

  if (existingTopics.contains(formattedTopic)) {
    return formattedTopic; // Exact topic match found
  }

  // Find the most similar topic (handling typos)
  String? closestMatch;
  double highestSimilarity = 0.0;

  for (String existing in existingTopics) {
    double similarity = existing.similarityTo(formattedTopic);
    if (similarity > highestSimilarity && similarity > 0.7) {
      highestSimilarity = similarity;
      closestMatch = existing;
    }
  }

  return closestMatch; // Return closest suggestion or null
}

String formatTopic(String topic) {
  if (topic.isEmpty) return topic;
  return topic[0].toUpperCase() + topic.substring(1).toLowerCase();
}
