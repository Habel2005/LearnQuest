import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Post {
  final String id;
  final String userId;
  final String content;
  final DateTime timestamp;
  final List<String> likes;
  final String topic;
  final List<String> tags;
  final int commentcount;

  Post({
    required this.id,
    required this.userId,
    required this.content,
    required this.timestamp,
    required this.likes,
    required this.topic,
    required this.tags,
    required this.commentcount,
  });

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'content': content,
    'timestamp': timestamp.toIso8601String(),
    'likes': likes,
    'topic': topic,
    'tags': tags,
    'commentCount': commentcount,
  };

  factory Post.fromJson(Map<String, dynamic> json, String id) => Post(
    id: id,
    userId: json['userId'],
    content: json['content'],
    timestamp: json['timestamp'] is Timestamp 
      ? (json['timestamp'] as Timestamp).toDate() 
      : DateTime.parse(json['timestamp']),
    likes: List<String>.from(json['likes']),
    topic: json['topic'],
    tags: List<String>.from(json['tags'] ?? []),
    commentcount: json['commentCount']
  );
}

class Message {
  final String id;
  final String userId;
  final String content;
  final DateTime timestamp;

  Message({
    required this.id,
    required this.userId,
    required this.content,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'content': content,
    'timestamp': timestamp.toIso8601String(),
  };

  factory Message.fromJson(Map<String, dynamic> json, String id) => Message(
    id: id,
    userId: json['userId'],
    content: json['content'],
    timestamp: DateTime.parse(json['timestamp']),
  );
}

class UserProfile {
  final String fullName;
  final String profilePicture;
  final String location;
  final String gender;
  final DateTime dob;

  UserProfile({
    required this.fullName,
    required this.profilePicture,
    required this.location,
    required this.gender,
    required this.dob,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        fullName: json['fullName'] ?? '',
        profilePicture: json['profilePicture'] ?? '',
        location: json['location'] ?? '',
        gender: json['gender'] ?? '',
        dob: _parseDate(json['dob']),
      );

  static DateTime _parseDate(dynamic dob) {
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
}

// models/comment.dart
class Comment {
  final String id;
  final String userId;
  final String content;
  final DateTime timestamp;
  final List<String> likes;

  Comment({
    required this.id,
    required this.userId,
    required this.content,
    required this.timestamp,
    required this.likes,
  });

  factory Comment.fromJson(Map<String, dynamic> json, String id) => Comment(
    id: id,
    userId: json['userId'],
    content: json['content'],
    timestamp: DateTime.parse(json['timestamp']),
    likes: List<String>.from(json['likes']),
  );
}