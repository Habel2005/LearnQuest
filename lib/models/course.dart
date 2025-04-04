class Course {
  final String courseId;
  final String title;
  final double rating;
  final String duration;
  final double price;
  final String category;
  final String description;
  final List<String> tags;
  final List<Module> modules;
  final List<Review> reviews;
  final String thumbnailUrl;
  final int studentsEnrolled;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String searchQuery;
  bool isBookmarked; // Mutable for toggling bookmarks

  Course({
    required this.courseId,
    required this.title,
    required this.rating,
    required this.duration,
    required this.price,
    required this.category,
    required this.description,
    required this.tags,
    required this.modules,
    required this.reviews,
    required this.thumbnailUrl,
    required this.studentsEnrolled,
    required this.createdAt,
    required this.updatedAt,
    required this.searchQuery,
    this.isBookmarked = false,
  });

  factory Course.empty() => Course(
        courseId: '',
        title: '',
        rating: 0.0,
        duration: '',
        price: 0.0,
        category: '',
        description: '',
        tags: [],
        modules: [],
        reviews: [],
        thumbnailUrl: '',
        studentsEnrolled: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        searchQuery: '',
      );

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      courseId: json['courseId'],
      title: json['title'] ?? '',
      rating: json['rating']?.toDouble() ?? 0.0,
      duration: json['estimatedCompletion'] ?? '',
      price: json['price']?.toDouble() ?? 0.0,
      category: json['category'] ?? '',
      description: json['description'] ?? '',
      tags: List<String>.from(json['tags'] ?? []),
      modules: List<Module>.from((json['lessons'] ?? []).map((m) => Module.fromJson(m))),
      reviews: List<Review>.from((json['reviews'] ?? []).map((r) => Review.fromJson(r))),
      thumbnailUrl: json['thumbnailUrl'] ?? "assets/card1.jpg",
      studentsEnrolled: json['studentsEnrolled'] ?? 0,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      searchQuery: json['searchQuery'] ?? '',
    );
  }
}

class Module {
  final String lessonId;
  final String title;
  final String description;
  final LessonContent content;
  final String estimatedDuration;

  Module({
    required this.lessonId,
    required this.title,
    required this.description,
    required this.content,
    required this.estimatedDuration,
  });

  factory Module.fromJson(Map<String, dynamic> json) {
    return Module(
      lessonId: json['lessonId'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      content: LessonContent.fromJson(json['content'] ?? {}),
      estimatedDuration: json['estimatedDuration'] ?? '',
    );
  }
}

class LessonContent {
  final String theory;
  final String practice;
  final List<String> resources;

  LessonContent({
    required this.theory,
    required this.practice,
    required this.resources,
  });

  factory LessonContent.fromJson(Map<String, dynamic> json) {
    return LessonContent(
      theory: json['theory'] ?? '',
      practice: json['practice'] ?? '',
      resources: List<String>.from(json['resources'] ?? []),
    );
  }
}

class Review {
  final String id;
  final String userName;
  final DateTime date;
  final double rating;
  final String comment;

  Review({
    required this.id,
    required this.userName,
    required this.date,
    required this.rating,
    required this.comment,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      userName: json['userName'],
      date: DateTime.parse(json['date']),
      rating: json['rating']?.toDouble() ?? 0.0,
      comment: json['comment'],
    );
  }
}
