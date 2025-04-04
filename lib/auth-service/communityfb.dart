import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:our_own_project/auth-service/auth_message.dart';
import 'package:our_own_project/models/post.dart';
import 'package:our_own_project/screens/homepages/community.dart';

class FirebaseService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Stream<List<Post>> getPosts() {
    return _db
        .collection('posts')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Post.fromJson(doc.data(), doc.id))
            .toList());
  }

  DateTime _parseDate(dynamic dob) {
    if (dob is Timestamp) {
      return dob.toDate();
    } else if (dob is String) {
      try {
        return DateFormat('dd/MM/yyyy').parse(dob);
      } catch (_) {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }

  Future<UserProfile?> getUserProfile(String userId) async {
    final doc = await _db.collection('users').doc(userId).get();

    if (doc.exists) {
      final data = doc.data();
      if (data == null || !data.containsKey('profile')) return null;

      final profile = data['profile'];
      String country = profile['location'] is Map
          ? profile['location']['country'] ?? "Unknown Country"
          : "Unknown Country";
      String city = profile['location'] is Map
          ? profile['location']['city'] ?? "Unknown City"
          : "Unknown City";
      return UserProfile(
        fullName: profile['fullName'] ?? 'Unknown',
        profilePicture: profile['profilePicture'] ?? '',
        location: '$country,$city',
        gender: profile['gender'] ?? '',
        dob: _parseDate(profile['dob']),
      );
    }

    return null;
  }

  Future<void> createPost(String content, String topic) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final formattedTopic =
        topic.trim().isEmpty ? "General" : formatTopic(topic);

    // Ensure the topic exists in Firestore
    final topicRef = _db.collection('topics').doc(formattedTopic);
    final topicDoc = await topicRef.get();

    if (!topicDoc.exists) {
      await topicRef.set({'createdAt': FieldValue.serverTimestamp()});
    }

    // Add the post under posts collection
    await _db.collection('posts').add({
      'userId': user.uid,
      'content': content.trim(),
      'timestamp': FieldValue.serverTimestamp(),
      'likes': [],
      'topic': formattedTopic,
      'commentCount': 0,
    });
  }

  Future<void> toggleSavePost(String postId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final userRef = _db.collection('users').doc(user.uid);

    return _db.runTransaction((transaction) async {
      final userDoc = await transaction.get(userRef);

      if (!userDoc.exists) throw Exception("User document doesn't exist");

      Map<String, dynamic> profileData =
          userDoc.data()?['profile'] ?? {}; // Get the profile map
      List<String> savedPosts =
          List<String>.from(profileData['savedPosts'] ?? []);

      if (savedPosts.contains(postId)) {
        savedPosts.remove(postId);
      } else {
        savedPosts.add(postId);
      }

      profileData['savedPosts'] = savedPosts; // Update the profile map

      transaction.update(
          userRef, {'profile': profileData}); // Save back the modified profile
    });
  }

  Future<void> toggleLike(String postId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final postRef = _db.collection('posts').doc(postId);

    return _db.runTransaction((transaction) async {
      final postDoc = await transaction.get(postRef);
      if (!postDoc.exists) throw Exception('Post not found');

      List<String> likes = List<String>.from(postDoc.data()!['likes']);
      bool isLikeAdded = false; // To check if a new like is added

      if (likes.contains(user.uid)) {
        likes.remove(user.uid); // If the user already liked, remove it
      } else {
        likes.add(user.uid); // If the user has not liked, add their ID
        isLikeAdded = true; // Mark that a like was added
      }

      // Update the post's likes array
      transaction.update(postRef, {'likes': likes});

      // If the like was added, send the notification
      if (isLikeAdded) {
        // Fetch the post owner ID
        final postOwnerId = postDoc
            .data()!['userId']; // Assuming 'userId' is the owner of the post

        // Fetch the device token of the post owner from the 'auth' field
        final tokenSnapshot =
            await _db.collection('users').doc(postOwnerId).get();
        if (tokenSnapshot.exists) {
          final postOwnerAuth =
              tokenSnapshot.data()?['auth'] as Map<String, dynamic>?;
          final postOwnerDeviceToken = postOwnerAuth?['deviceToken'];

          if (postOwnerDeviceToken != null) {
            // Prepare the notification details

            final username =
                user.displayName ?? 'User'; // Get the current user's name

// Format the message
            final String notificationMessage = '$username Liked your Post!';

// Send the notification (assumes you have a method `sendNotificationForLikes`)
            await FirebaseMessage.sendNotificationForLikes(
              deviceToken: postOwnerDeviceToken,
              commentExcerpt: notificationMessage,
              postId: postId
            );
          }
        }
      }
    });
  }

  Stream<List<Comment>> getComments(String postId) {
    return _db
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Comment.fromJson(doc.data(), doc.id))
            .toList());
  }

  Future<void> addComment(String postId, String content) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final postRef = _db.collection('posts').doc(postId);
    final commentRef = postRef.collection('comments');

    await _db.runTransaction((transaction) async {
      final postDoc = await transaction.get(postRef);
      if (!postDoc.exists) throw Exception('Post not found');

      await commentRef.add({
        'userId': user.uid,
        'content': content,
        'timestamp': DateTime.now().toIso8601String(),
        'likes': [],
      });

      transaction.update(postRef, {
        'commentCount': FieldValue.increment(1),
      });
    });
  }
}
