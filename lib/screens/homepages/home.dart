import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:our_own_project/auth-service/api.dart';
import 'package:our_own_project/screens/homepages/coursepages/coursedetail.dart';
import 'package:our_own_project/screens/homepages/mainpages/ailearn.dart';
import 'package:our_own_project/screens/homepages/mainpages/allcategory.dart';
import 'package:our_own_project/screens/homepages/mainpages/categorycourse.dart';
import 'package:our_own_project/screens/homepages/mainpages/courselist.dart';
import 'package:our_own_project/screens/homepages/mainpages/daily.dart';
import 'package:our_own_project/screens/homepages/mainpages/quicklearn.dart';
import 'package:our_own_project/screens/homepages/mainpages/techtrend.dart';
import 'package:rive/rive.dart' as rive;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

class Home extends StatefulWidget {
  final PageController pageController;
  final Function onSearchTap;
  const Home(
      {super.key, required this.pageController, required this.onSearchTap});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late String username = 'User';
  bool isLoading = false;
  final _offsetToarmed = 220.0;

  @override
  initState() {
    _loadUsername();
    _loadProfilePicture();
    _fetchCategories();
    super.initState();
  }

  final List<Map<String, dynamic>> _dailyLearningPaths = [
    {
      'title': 'AI-Generated Python Fundamentals',
      'duration': '2-3h',
      'resourceCount': '15+ resources',
      'difficulty': 'Beginner',
      'tags': ['Programming', 'Python', 'AI-Curated'],
      'id': '6296cda2-b248-4610-a432-5f854b7342ea'
    },
    {
      'title': 'Machine Learning Basics',
      'duration': 'Self-paced',
      'resourceCount': '12+ resources',
      'difficulty': 'Intermediate',
      'tags': ['ML', 'Data Science', 'Hands-on'],
      'id': '86daefb7-2681-4561-b566-daa9bf76546a'
    },
    {
      'title': 'Web Development Roadmap',
      'duration': '4-5h',
      'resourceCount': '20+ resources',
      'difficulty': 'Mixed',
      'tags': ['Web Dev', 'Full-Stack', 'Modern'],
      'id': ''
    },
  ];

  final List<Map<String, dynamic>> _categoryTiles = [
    {
      'title': 'Daily Challenges',
      'subtitle': 'Hands-on coding tasks',
      'icon': Icons.flash_on,
      'gradient': [Colors.blue.shade400, Colors.blue.shade100],
      'activeCount': '3 new today',
      'route': DailyChallengesPage(
        userId: FirebaseAuth.instance.currentUser!.uid,
      ),
    },
    {
      'title': 'Quick Learn',
      'subtitle': 'Bite-sized tech concepts',
      'icon': Icons.lightbulb_outline,
      'gradient': [Colors.purple.shade400, Colors.purple.shade100],
      'activeCount': '12 concepts',
      'route': const QuickLearnPage(),
    },
    {
      'title': 'Tech Trends',
      'subtitle': 'Current popular technologies',
      'icon': Icons.trending_up,
      'gradient': [Colors.orange.shade400, Colors.orange.shade100],
      'activeCount': 'Updated daily',
      'route': const TechTrendsPage(),
    },
    {
      'title': 'AI Learning',
      'subtitle': 'AI-powered tutorials',
      'icon': Icons.psychology,
      'gradient': [Colors.teal.shade400, Colors.teal.shade100],
      'activeCount': 'Personalized for you',
      'route': const AILearningPage(),
    },
  ];

  List<Map<String, dynamic>> _categories = [];
  static List<Map<String, dynamic>> _cachedCategories = [];
  bool _isLoading = true;

  Future<void> _fetchCategories() async {
    if (_cachedCategories.isNotEmpty) {
      // Use cached data instead of calling API
      setState(() {
        _categories = _cachedCategories;
        _isLoading = false;
      });
      return;
    }

    try {
      List<Map<String, dynamic>> categories =
          await CategoryService.fetchHomeCategories(6);
      setState(() {
        _categories = categories;
        _cachedCategories = categories; // Cache the data
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching categories2: $e');
    }
  }

  Future<String> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    String? cachedUsername = prefs.getString('cachedUsername');

    // Always attempt fetching from Firestore first
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String userId = user.uid;
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        var data = userDoc.data() as Map<String, dynamic>?;
        var profile = data?['profile'] as Map<String, dynamic>?;

        if (profile != null && profile.containsKey('fullName')) {
          String fullName = profile['fullName'];

          // Update cache with new username
          await prefs.setString('cachedUsername', fullName);

          return fullName; // Return latest name from Firestore
        }
      }
    }

    // If Firestore fetch fails or userDoc doesn't exist, use cached name
    return cachedUsername ?? 'User';
  }

  Future<void> _loadUsername() async {
    username = await getUsername();
  }

  late String profileImageUrl = '';
  //load picture
  Future<void> _loadProfilePicture() async {
    final prefs = await SharedPreferences.getInstance();
    String? cachedProfileUrl = prefs.getString('cachedProfilePicture');

    if (cachedProfileUrl != null) {
      setState(() {
        profileImageUrl = cachedProfileUrl; // Load from cache
      });
      return; // Avoid Firestore call
    }

    // If no cache, fetch from Firestore
    String userId = FirebaseAuth.instance.currentUser!.uid;
    print(userId);
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (userDoc.exists) {
      var data = userDoc.data() as Map<String, dynamic>?;
      var profile = data?['profile'] as Map<String, dynamic>?;

      if (profile != null && profile.containsKey('profilePicture')) {
        String profileUrl = profile['profilePicture'];

        setState(() {
          profileImageUrl = profileUrl;
        });

        // Save to cache for next time
        await prefs.setString('cachedProfilePicture', profileUrl);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor:
            Colors.transparent, // Ensure Scaffold has no background
        body: Stack(
            fit: StackFit.expand, // Prevent clipping
            children: [
              // Background gradient
              Container(
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(0.3, -0.1),
                    radius: 1.2,
                    colors: [
                      Color(0xFFFFF0F5), // Light pink glow
                      Color(0xFFECEFFF), // Light bluish-white
                      Color(0xFFFFFFFF), // White at edges
                    ],
                    stops: [0.2, 0.5, 1.0],
                  ),
                ),
              ),

              // Refresh animation overlay
              CustomRefreshIndicator(
                onRefresh: () async {
                  setState(() {});
                  await Future.delayed(const Duration(seconds: 3));
                  // Rebuilds the widget
                },
                offsetToArmed: _offsetToarmed,
                builder: (context, child, controller) {
                  return Stack(
                    clipBehavior: Clip.none, // Prevent clipping
                    children: [
                      Positioned(
                        top: 50 - _offsetToarmed * (1 - controller.value),
                        left: 0,
                        right: 0,
                        child: SizedBox(
                          width: double.infinity,
                          height: _offsetToarmed * (controller.value * 1.5),
                          child: const rive.RiveAnimation.asset(
                            'assets/reload.riv',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Transform.translate(
                        offset: Offset(0.0, _offsetToarmed * controller.value),
                        child: child,
                      ),
                    ],
                  );
                },
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    _buildHeroSection(),
                    _buildPopularSection(),
                    _buildCategoriesSection(),
                    _buildDailyQuestSection(),
                    SliverToBoxAdapter(
                        child: Padding(
                      padding: const EdgeInsets.only(top: 16, left: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Available Courses',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                                color: Colors.black.withOpacity(0.7)),
                          ),
                          TextButton(
                            onPressed: () {
                              navigateWithSlideTransition(
                                  context, const CourseCatalogPage());
                            },
                            child: const Row(
                              children: [
                                Text(
                                  'View all',
                                  style: TextStyle(color: Colors.black),
                                ),
                                Icon(Icons.chevron_right,
                                    color: Colors.black, size: 18),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )),
                    SliverToBoxAdapter(
                        child: Padding(
                            padding: const EdgeInsets.only(
                                top: 16, left: 16, bottom: 24),
                            child: CourseList(courses: topRatedCourses))),
                  ],
                ),
              ),
            ]));
  }

  Widget _buildHeroSection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding:
            const EdgeInsets.only(left: 16, right: 16, top: 50, bottom: 16),
        child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20), // Rounded corners
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [Colors.blue.shade200, Colors.purple.shade100],
              ),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: _navigateToProfile,
                  child: Row(
                    children: [
                      profileImageUrl.isNotEmpty
                          ? CircleAvatar(
                              radius: 20,
                              backgroundImage: NetworkImage(profileImageUrl),
                            )
                          : CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.grey[200],
                              child: const Icon(Icons.person,
                                  size: 20, color: Colors.black87),
                            ),
                      const SizedBox(width: 8),
                      Text(
                        'Hello, $username',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Find a course you want to learn.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                ),
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: GestureDetector(
                    onTap: () {
                      widget.onSearchTap(); // Call the search function on tap
                    },
                    child: Container(
                      height: 50, // Approximate height of a TextField
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: Colors.black.withOpacity(0.3), width: 1.2),
                        borderRadius: BorderRadius.circular(
                            5), // Mimics TextField border radius
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.search,
                              color: Colors.white.withOpacity(0.7)),
                          const SizedBox(width: 10),
                          Text(
                            'Search',
                            style:
                                TextStyle(color: Colors.black.withOpacity(0.5)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDailyQuestSection() {
    //third
    return SliverToBoxAdapter(
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 16, left: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Explore',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.normal,
                      color: Colors.black),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 230,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(top: 16, left: 16),
              itemCount: _dailyLearningPaths.length,
              itemBuilder: (context, index) {
                final quest = _dailyLearningPaths[index];
                return Container(
                  width: 300,
                  margin: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.purple.shade200, Colors.blue.shade200],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: GestureDetector(
                    onTap: () {
                      navigateWithSlideTransition(
                          context, CourseDetailsScreen(courseId: quest['id']));
                    },
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  quest['difficulty'],
                                  style: const TextStyle(
                                    color: Colors.purple,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                quest['title'],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              Wrap(
                                children: (quest['tags'] as List<String>)
                                    .map((tag) => Chip(
                                          label: Text(
                                            tag,
                                            style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.purple),
                                          ),
                                          padding: const EdgeInsets.all(0),
                                        ))
                                    .toList(),
                              ),
                              const Spacer(),
                              Row(
                                children: [
                                  Icon(Icons.access_time,
                                      color: Colors.white.withOpacity(0.7),
                                      size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    quest['duration'],
                                    style: TextStyle(
                                        color: Colors.white.withOpacity(0.7)),
                                  ),
                                  const Spacer(),
                                  Text(
                                    quest['resourceCount'],
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.7),
                                    ),
                                  ),
                                  const SizedBox(width: 50),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          right: 20,
                          bottom: 20,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.arrow_forward,
                                color: Colors.purple),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesSection() {
    return SliverToBoxAdapter(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Categories',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.normal,
                      color: Colors.black),
                ),
                TextButton(
                  onPressed: () {
                    navigateWithSlideTransition(
                        context, const CategoriesPage());
                    setState(() {});
                  },
                  child: const Row(
                    children: [
                      Text('View all', style: TextStyle(color: Colors.black)),
                      Icon(Icons.arrow_forward_ios, size: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _isLoading
              ? _buildShimmerEffect() // Show shimmer when loading
              : SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      final List<Color> gradientColors =
                          category['gradient_colors'];

                      return GestureDetector(
                        onTap: () {
                          navigateWithSlideTransition(
                              context,
                              CategoryDetailScreen(
                                  categoryName: category['name']));
                        },
                        child: Container(
                          width: 120,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: gradientColors,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Positioned.fill(
                                  child: Image.asset(
                                    category['image'],
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                Text(
                                  category['name'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildShimmerEffect() {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 5, // Number of placeholder cards
        itemBuilder: (context, index) {
          return Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: 120,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPopularSection() {
    //first
    return SliverToBoxAdapter(
      child: Column(
        children: [
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categoryTiles.length,
              itemBuilder: (context, index) {
                final category = _categoryTiles[index];
                return GestureDetector(
                  onTap: () {
                    navigateWithSlideTransition(context, category['route']);
                  },
                  child: Container(
                    width: 280,
                    margin: const EdgeInsets.only(right: 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: category['gradient'],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: category['gradient'][0].withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // Subtle pattern overlay
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Opacity(
                              opacity: 0.2,
                              child: CustomPaint(
                                painter: GridPainter(),
                              ),
                            ),
                          ),
                        ),
                        // Content
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                category['icon'],
                                color: Colors.white,
                                size: 32,
                              ),
                              const Spacer(),
                              Text(
                                category['title'],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                category['subtitle'],
                                style: TextStyle(
                                  color: Colors.black.withOpacity(0.5),
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  category['activeCount'],
                                  style: TextStyle(
                                    color: Colors.deepPurple.shade300,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToProfile() {
    if (!mounted) return; // Prevent navigation if the widget is unmounted

    widget.pageController.jumpToPage(3);
  }
}

void navigateWithSlideTransition(BuildContext context, Widget targetPage) {
  Navigator.push(
    context,
    PageRouteBuilder(
      transitionDuration:
          const Duration(milliseconds: 400), // Slightly slower for smoothness
      pageBuilder: (context, animation, secondaryAnimation) => targetPage,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0); // Start off-screen (right)
        const end = Offset.zero; // End at center
        const curve = Curves.easeInOutQuad; // Smoother curve

        var slideTween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        var fadeTween = Tween<double>(begin: 0.0, end: 1.0).chain(
          CurveTween(curve: Curves.easeInOut), // Smooth fade-in
        );

        return SlideTransition(
          position: animation.drive(slideTween),
          child: FadeTransition(
            opacity: animation.drive(fadeTween), // Apply fade effect
            child: child,
          ),
        );
      },
    ),
  );
}

// Custom painter for subtle grid pattern
class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 0.5;

    final spacing = size.width / 10;

    for (var i = 0; i < size.width; i += spacing.toInt()) {
      canvas.drawLine(
        Offset(i.toDouble(), 0),
        Offset(i.toDouble(), size.height),
        paint,
      );
    }

    for (var i = 0; i < size.height; i += spacing.toInt()) {
      canvas.drawLine(
        Offset(0, i.toDouble()),
        Offset(size.width, i.toDouble()),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class Course {
  final String title;
  final double rating;
  final String duration;
  final double price;
  final Color backgroundColor;
   bool isFavorite;
  final Widget icon;
  final ImageProvider<Object> image;
  final int studentsCount;
  final String instructorName;
  final List<Module> modules;
  final List<Review> reviews;
  final String id;

  Course({
    required this.title,
    required this.rating,
    required this.duration,
    required this.price,
    required this.backgroundColor,
    this.isFavorite = false,
    required this.image,
    required this.icon,
    this.studentsCount = 0,
    this.instructorName = '',
    this.modules = const [],
    this.reviews = const [],
    this.id = '',
  });

  static fromJson(Map<String, dynamic> cours) {}
}

class Module {
  final String title;
  final String duration;
  final List<Lesson> lessons;
  final int progress; // 0-100

  Module({
    required this.title,
    required this.duration,
    required this.lessons,
    this.progress = 0,
  });
}

class Lesson {
  final String title;
  final String duration;
  final bool isLocked;

  Lesson({
    required this.title,
    required this.duration,
    this.isLocked = true,
  });
}

class Review {
  final String userName;
  final String date;
  final double rating;
  final String comment;

  Review({
    required this.userName,
    required this.date,
    required this.rating,
    required this.comment,
  });
}

// Sample data
final List<Course> newCourses = [
  Course(
    title: 'Development Of Virtual Reality & Augmented Reality',
    image: const AssetImage('assets/card1.jpg'),
    rating: 5.0,
    duration: '12h 10m',
    price: 65.00,
    backgroundColor: Colors.purple.shade300,
    isFavorite: false,
    icon: const Icon(Icons.headphones, color: Colors.white, size: 30),
    studentsCount: 2719,
    instructorName: 'Chris Johnson',
    id: '3e46cb11-7139-41f9-9117-d922bb4da2b0',
    modules: [
      Module(
        title: '01. Introduction',
        duration: '7 min',
        progress: 70,
        lessons: [
          Lesson(
            title: 'Setting up individual Camera Rigs',
            duration: '00:44',
            isLocked: false,
          ),
          Lesson(
            title: 'Setting Up VRTKs Tracked Alias',
            duration: '03:49',
            isLocked: true,
          ),
          Lesson(
            title: 'Setting Up VRTKs Tracked Alias',
            duration: '02:22',
            isLocked: true,
          ),
        ],
      ),
      Module(
        title: '02. Movement In VR',
        duration: '1h 33 min',
        progress: 0,
        lessons: [],
      ),
      Module(
        title: '03. Distance Grabber',
        duration: '27 min',
        progress: 0,
        lessons: [],
      ),
    ],
    reviews: [
      Review(
        userName: 'Lillian Davis',
        date: 'March 3, 2022',
        rating: 4.0,
        comment: 'Lots of good info.',
      ),
      Review(
        userName: 'Adam Thompson',
        date: 'March 28, 2022',
        rating: 5.0,
        comment:
            'Great course, Chris helps you get started with a framework where you can then build off of and focus on getting your games.',
      ),
      Review(
        userName: 'Ryan Howard',
        date: 'February 12, 2022',
        rating: 5.0,
        comment: 'It has explained it very well & made it very simple.',
      ),
    ],
  ),
  Course(
      title: 'Creation Of Mobile App For iOS & Android',
      image: const AssetImage('assets/card1.jpg'),
      rating: 4.7,
      duration: '10h 20m',
      price: 55.00,
      backgroundColor: Colors.pink.shade300,
      isFavorite: true,
      icon: const Icon(Icons.phone_android, color: Colors.white, size: 30),
      id: 'e24457a2-8ab2-4e9a-a9a4-7df027ac25ad'),
];

final List<Course> topRatedCourses = [
  Course(
      title: 'Learning Python For Data Analysis And Visualization',
      image: const AssetImage('assets/card1.jpg'),
      rating: 5.0,
      duration: '5h 30m',
      price: 35.00,
      backgroundColor: Colors.purple.shade100,
      isFavorite: false,
      icon: const Image(
        image: AssetImage('assets/card1.jpg'),
      ),
      id: '7535a9ab-b0e5-44b7-ad4e-3e9773d24449'),
  Course(
    title: 'Learn Photoshop, Web Design & Profitable Freelance 2022',
    image: const AssetImage('assets/card1.jpg'),
    rating: 5.0,
    duration: '5h 30m',
    price: 35.00,
    backgroundColor: Colors.pink.shade100,
    isFavorite: false,
    icon: Image.asset('assets/card1.jpg'),
  ),
  Course(
    title: 'Complete Wordpress Training For Beginners',
    image: const AssetImage('assets/card1.jpg'),
    rating: 5.0,
    duration: '5h 30m',
    price: 35.00,
    backgroundColor: Colors.purple.shade100,
    isFavorite: false,
    icon: Image.asset(
      'assets/card1.jpg',
      fit: BoxFit.cover,
    ),
  ),
];

class CourseList extends StatelessWidget {
  final List<Course> courses;

  const CourseList({super.key, required this.courses});

  @override
  Widget build(BuildContext context) {
    return Column(
      children:
          courses.map((course) => CourseListItem(course: course)).toList(),
    );
  }
}

class CourseListItem extends StatefulWidget {
  final Course course;

  const CourseListItem({super.key, required this.course});

  @override
  State<CourseListItem> createState() => _CourseListItemState();
}

class _CourseListItemState extends State<CourseListItem> {

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CourseDetailsScreen(
                  courseId: widget.course.id,
                ),
              ),
            );
          },
          child: Container(
            height: 80,
            margin: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Stack(
                  children: [
                    // Background Image inside a rounded container
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        image: DecorationImage(
                          image: widget.course.image,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                    // Rating positioned at the bottom-left
                    Positioned(
                      bottom: 4,
                      left: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star,
                                color: Colors.amber, size: 12),
                            const SizedBox(width: 3),
                            Text(
                              widget.course.rating.toString(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.course.title,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.black.withOpacity(0.7)),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.access_time,
                                color: Colors.grey, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              widget.course.duration,
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                        setState(() {
                            widget.course.isFavorite = !widget.course.isFavorite;
                        });
                      },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Icon(
                      widget.course.isFavorite ? Icons.cancel : Icons.cancel_outlined,
                      color:
                          widget.course.isFavorite ? Colors.black87 : Colors.grey,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // 🔽 Thin Divider Below the Course Card 🔽
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          height: 0.6, // Thin line
          color: Colors.grey.withOpacity(0.3), // Light grey separator
        ),

        const SizedBox(
          height: 25,
        )
      ],
    );
  }
}
