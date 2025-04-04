import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:our_own_project/auth-service/api.dart';
import 'package:our_own_project/screens/homepages/coursepages/coursedetail.dart';
import 'package:our_own_project/screens/homepages/coursepages/searchscreen.dart';
import 'package:our_own_project/screens/homepages/home.dart';
import 'package:our_own_project/models/course.dart' as c;

class CourseBrowser extends StatefulWidget {
  final PageController pageController;
  final ValueNotifier<bool> shouldAutoFocusNotifier;

  const CourseBrowser(
      {super.key,
      required this.pageController,
      required this.shouldAutoFocusNotifier});

  @override
  State<CourseBrowser> createState() => _CourseBrowserState();
}

class _CourseBrowserState extends State<CourseBrowser> {
  final TextEditingController _searchController = TextEditingController();
  void _appendTagToSearch(String tag) {
    setState(() {
      if (_searchController.text.isNotEmpty) {
        _searchController.text += " $tag"; // Append tag to existing text
      } else {
        _searchController.text = tag; // Set tag as first input
      }
    });
  }

  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    widget.shouldAutoFocusNotifier.addListener(() {
      if (widget.shouldAutoFocusNotifier.value) {
        // Simple delay to ensure UI is ready
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) {
            _searchFocusNode.requestFocus();
          }
          widget.shouldAutoFocusNotifier.value = false;
        });
      }
    });
  }

  bool _isLoading = false;

  Future<void> _handleSearch(String query) async {
    if (query.isEmpty) return;

    _isLoading = true;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchResultsScreen(searchQuery: query),
      ),
    );

    _isLoading = false;
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0.3, -0.1), // Slightly off-center
              radius: 1.2,
              colors: [
                Color(0xFFFFF0F5), // Very light pink glow
                Color(0xFFECEFFF), // Very light bluish-white
                Color(0xFFFFFFFF), // White at the edges
              ],
              stops: [0.2, 0.5, 1.0],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 50),
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: SearchBarComponent(
                          onSearch:
                              _handleSearch, // Pass function to search bar
                          isLoading: _isLoading,
                          controller: _searchController, // Update UI state
                        ),
                      ),
                      const FilterButton(),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                UserSectionBox(
                  userId: FirebaseAuth.instance.currentUser!.uid,
                ),
                const CategorySection(title: 'New Courses'),
                const SizedBox(height: 10),
                CourseGrid(courses: newCourses),
                const SizedBox(height: 24),
                const CategorySection(title: 'Specially For You'),
                const SizedBox(height: 10),
                const SpecialCourseCategories(),
                const SizedBox(height: 24),
                Text(
                  'Often Searched',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Colors.black.withOpacity(0.7)),
                ),
                const SizedBox(height: 16),
                SearchTags(onTagSelected: _appendTagToSearch),
                const SizedBox(height: 55),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class UserSectionBox extends StatefulWidget {
  final String userId;

  const UserSectionBox({super.key, required this.userId});

  @override
  State<UserSectionBox> createState() => _UserSectionBoxState();
}

class _UserSectionBoxState extends State<UserSectionBox> {
  List<String> bookmarkedCourses = [];
  List<String> activeCourses = [];
  double latestProgress = 0.0;
  String latestCourseName = "";

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .get();

    if (userDoc.exists) {
      Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;

      setState(() {
        bookmarkedCourses = List<String>.from(data['bookmarkedCourses'] ?? []);
        Map<String, dynamic> progressData = data['progress'] ?? {};

        activeCourses = progressData.keys.toList();

        if (activeCourses.isNotEmpty) {
          String latestCourseId = activeCourses.last;

          // Fetch actual course title
          FirebaseFirestore.instance
              .collection('courses')
              .doc(latestCourseId)
              .get()
              .then((courseDoc) {
            if (courseDoc.exists) {
              setState(() {
                latestCourseName = courseDoc['title'] ?? 'Unknown Course';
              });
            }
          });

          Map<String, dynamic> latestCourseProgress =
              progressData[latestCourseId] ?? {};
          int totalLessons = latestCourseProgress.length;
          int completedLessons = latestCourseProgress.values
              .where((lesson) => lesson["completed"] == true)
              .length;

          latestProgress =
              totalLessons > 0 ? (completedLessons / totalLessons) * 100 : 0;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        navigateWithSlideTransition(
            context, UserDashboardPage(userId: widget.userId));
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 16.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFE0F7FA), Color(0xFFB2EBF2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              Icons.account_circle,
              size: 50,
              color: Colors.blue.shade700,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'My Dashboard',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    activeCourses.isEmpty
                        ? 'No active courses. Start learning now!'
                        : 'You are learning ${activeCourses.length} courses.',
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                  if (latestCourseName.isNotEmpty)
                    Text(
                      'Latest: $latestCourseName ($latestProgress%)',
                      style:
                          const TextStyle(fontSize: 14, color: Colors.blueGrey),
                    ),
                  const SizedBox(height: 8),
                  Text(
                    bookmarkedCourses.isEmpty
                        ? 'No bookmarks yet.'
                        : 'Bookmarked: ${bookmarkedCourses.length} courses.',
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.blue.shade700),
          ],
        ),
      ),
    );
  }
}

class UserDashboardPage extends StatefulWidget {
  final String userId;

  const UserDashboardPage({super.key, required this.userId});

  @override
  State<UserDashboardPage> createState() => _UserDashboardPageState();
}

class _UserDashboardPageState extends State<UserDashboardPage> {
  List<Map<String, dynamic>> myCourses = [];
  List<Map<String, dynamic>> favoriteCourses = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();

      if (userDoc.exists) {
        var data = userDoc.data() as Map<String, dynamic>;
        List<String> bookmarkedCourseIds =
            List<String>.from(data['bookmarkedCourses'] ?? []);
        Map<String, dynamic> progressData = data['progress'] ?? {};

        Set<String> allCourseIds = {
          ...bookmarkedCourseIds,
          ...progressData.keys
        };
        List<Map<String, dynamic>> fetchedCourses = [];

        for (String courseId in allCourseIds) {
          var courseDoc = await FirebaseFirestore.instance
              .collection('courses')
              .doc(courseId)
              .get();

          if (courseDoc.exists) {
            var courseData = courseDoc.data() as Map<String, dynamic>;

            List<dynamic> allLessons = courseData["lessons"] ?? [];
            int totalLessons = allLessons.length;
            Map<String, dynamic> courseProgress = progressData[courseId] ?? {};
            int completedLessons = courseProgress.values
                .where((lesson) => lesson["completed"] == true)
                .length;

            fetchedCourses.add({
              "id": courseId,
              "title": courseData["title"],
              "description": courseData["description"],
              "totalLessons": totalLessons,
              "completedLessons": completedLessons,
            });
          }
        }

        setState(() {
          myCourses = fetchedCourses;
          favoriteCourses = fetchedCourses
              .where((course) => bookmarkedCourseIds.contains(course["id"]))
              .toList();
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching user data: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFDEBEB), Color(0xFFD6E5FA)], // Light pink to blue
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Text(
              'My Dashboard',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            elevation: 4,
            shadowColor: Colors.black.withOpacity(0.2),
            backgroundColor: Colors.white.withOpacity(0.8),
            foregroundColor: Colors.black,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(20),
              ),
            ),
            bottom: const TabBar(
              labelColor: Color(0xFF5A67D8), // Soft blue
              unselectedLabelColor: Colors.grey,
              indicatorColor: Color(0xFF5A67D8),
              tabs: [
                Tab(text: "My Courses"),
                Tab(text: "Favorites"),
              ],
            ),
          ),
          body: isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFF5A67D8)))
              : TabBarView(
                  children: [
                    _buildCourseList(
                        myCourses, "You have not enrolled in any courses yet."),
                    _buildCourseList(favoriteCourses, "No favorites yet."),
                  ],
                ),
        ),
      ),
    );
  }
}

Widget _buildCourseList(
    List<Map<String, dynamic>> courses, String emptyMessage) {
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: courses.isEmpty
        ? Center(
            child: Text(
              emptyMessage,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          )
        : ListView.builder(
            itemCount: courses.length,
            itemBuilder: (context, index) {
              var course = courses[index];
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Card(
                  color: Colors.white.withOpacity(0.9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(
                      course["title"],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          course["description"],
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.black87),
                        ),
                        const SizedBox(height: 8),
                        _ProgressIndicator(
                          totalLessons: course["totalLessons"] ?? 0,
                          completedLessons: course["completedLessons"] ?? 0,
                        ),
                      ],
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios,
                        color: Color(0xFF5A67D8), size: 18),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              CourseDetailsScreen(courseId: course["id"]),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
  );
}

class _ProgressIndicator extends StatelessWidget {
  final int totalLessons;
  final int completedLessons;

  const _ProgressIndicator({
    required this.totalLessons,
    required this.completedLessons,
  });

  @override
  Widget build(BuildContext context) {
    final double percentage =
        totalLessons > 0 ? (completedLessons / totalLessons).toDouble() : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Course Progress',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: percentage,
            backgroundColor: Colors.grey.shade300,
            minHeight: 12,
            valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF6A89CC)), // Subtle blue
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '$completedLessons/$totalLessons lessons completed',
          style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
        ),
      ],
    );
  }
}

class CategorySection extends StatelessWidget {
  final String title;

  const CategorySection({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.black.withOpacity(0.7)),
        ),
        TextButton(
          onPressed: () {
            // Navigate to view all courses in this category
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => CourseCatalogPage(title: title)),
            );
          },
          child: const Row(
            children: [
              Text(
                'View all',
                style: TextStyle(color: Colors.black),
              ),
              Icon(Icons.chevron_right, color: Colors.black, size: 18),
            ],
          ),
        ),
      ],
    );
  }
}

class CourseGrid extends StatelessWidget {
  final List<Course> courses;

  const CourseGrid({super.key, required this.courses});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: courses.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              navigateWithSlideTransition(
                context,
                CourseDetailsScreen(
                  courseId: courses[index].id,
                ),
              );
            },
            child: CourseCard(course: courses[index]),
          );
        },
      ),
    );
  }
}

class CourseCard extends StatefulWidget {
  final Course course;

  const CourseCard({super.key, required this.course});

  @override
  State<CourseCard> createState() => _CourseCardState();
}

class _CourseCardState extends State<CourseCard> {
  late bool isFavorite;

  @override
  void initState() {
    super.initState();
    isFavorite = widget.course.isFavorite;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: widget.course.backgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Rating & Favorite Row
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(1, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            widget.course.rating.toString(),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: Color.fromARGB(255, 74, 74, 74)),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isFavorite = !isFavorite;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isFavorite
                              ? Colors.red.shade100
                              : Colors.white.withOpacity(0.3),
                        ),
                        child: Icon(
                          isFavorite ? Icons.auto_awesome_sharp : Icons.auto_awesome_outlined,
                          color:
                              isFavorite ? Colors.red.shade400 : Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                // Course Title
                Text(
                  widget.course.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 6),

                // Duration
                Row(
                  children: [
                    const Icon(Icons.access_time,
                        color: Colors.white70, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      widget.course.duration,
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Price
                Text(
                  'Free',
                  style: TextStyle(
                    color: getRandomColor(),
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Color getRandomColor() {
  List<Color> colors = [
    Colors.blueAccent.shade100,
    Colors.orangeAccent.shade100,
    Colors.purpleAccent.shade100,
    Colors.tealAccent.shade100,
    Colors.pinkAccent.shade100,
    Colors.amberAccent.shade100
  ];
  return colors[Random().nextInt(colors.length)];
}

class CourseList extends StatelessWidget {
  final List<c.Course> courses;

  const CourseList({super.key, required this.courses});

  @override
  Widget build(BuildContext context) {
    return Column(
      children:
          courses.map((course) => CourseListItem(course: course)).toList(),
    );
  }
}

class CourseListItem extends StatelessWidget {
  final c.Course course;

  const CourseListItem({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    CourseDetailsScreen(courseId: course.courseId),
              ),
            );
          },
          child: Container(
              height: 90,
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  // Course Thumbnail with Fixed Size
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: const SizedBox(
                      width: 80, // Set a fixed width to prevent overflow
                      height: 80, // Set a fixed height
                      child: Image(
                        image: AssetImage("assets/card1.jpg") as ImageProvider,
                        fit: BoxFit
                            .cover, // Ensures the image fits within the box
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Course Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          course.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.black.withOpacity(0.8),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          course.duration.isNotEmpty
                              ? course.duration
                              : "Duration not available",
                          style:
                              const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              )),
        ),
        // Divider
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          height: 0.5,
          color: Colors.grey.withOpacity(0.3),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}

class SpecialCourseCategories extends StatelessWidget {
  const SpecialCourseCategories({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SpecialCategoryCard(
          title: 'Graphic Design Training From Scratch',
          courses: 3,
          color: Colors.orange.shade100,
          icon: Icons.brush,
          id: ''
        ),
        const SizedBox(width: 12),
        SpecialCategoryCard(
          title: 'Mobile Application Development',
          courses: 17,
          color: Colors.blue.shade100,
          icon: Icons.phone_android,
          id: 'e24457a2-8ab2-4e9a-a9a4-7df027ac25ad'
        ),
      ],
    );
  }
}

class SpecialCategoryCard extends StatelessWidget {
  final String title;
  final int courses;
  final Color color;
  final IconData icon;
  final String id;

  const SpecialCategoryCard({
    super.key,
    required this.title,
    required this.courses,
    required this.color,
    required this.icon,
    required this.id
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CourseDetailsScreen(
                  courseId: id,
                ),
              ),
            );
          },
        child: Container(
          height: 100,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.3), // Background color from earlier
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            children: [
              // Circular decorative shape (right side)
              Positioned(
                right: -5,
                bottom: -5,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.5), // Slightly stronger opacity
                    shape: BoxShape.circle,
                  ),
                ),
              ),
        
              // Text content (ensuring full visibility)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment:
                    MainAxisAlignment.center, // Center the text properly
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.black.withOpacity(0.7),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4), // Small gap instead of Spacer
                  Text(
                    '$courses Courses',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SearchTags extends StatelessWidget {
  final Function(String) onTagSelected;

  SearchTags({super.key, required this.onTagSelected});

  final List<String> tags = [
    'Java',
    'Python',
    'Marketing',
    'App',
    'Database',
    'Analytics',
    'UI/UX',
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: tags
          .map((tag) => GestureDetector(
                onTap: () => onTagSelected(tag), // Append to search bar
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade50, // Light blue theme
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    tag,
                    style: TextStyle(
                      color: Colors.purple.shade400,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ))
          .toList(),
    );
  }
}

class CourseCatalogPage extends StatelessWidget {
  final String title;

  const CourseCatalogPage({super.key, required this.title});

Future<List<c.Course>> fetchCourses() async {
  if (title == 'New Courses') {
    return await CourseService.fetchNewCourses();
  } else {
    return await CourseService.fetchMatchingCourses();
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FF), // Light bluish background
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 2,
        shadowColor: Colors.grey.withOpacity(0.2),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Title
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                "Explore $title",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Course List
            Expanded(
              child: FutureBuilder<List<c.Course>>(
                future: fetchCourses(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF2F80ED), // Light blue loading
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        "Something went wrong 😔",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.redAccent.withOpacity(0.8),
                        ),
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            "assets/empty.png", // Placeholder empty state image
                            width: 120,
                            height: 120,
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            "No courses available yet!",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return CourseList(courses: snapshot.data!);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FilterButton extends StatelessWidget {
  const FilterButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FilterPage.show(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.filter_list,
              size: 18,
              color: Colors.black,
            ),
          ],
        ),
      ),
    );
  }
}

class FilterPage {
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // Allows gradient to show
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => const _FilterContent(),
    );
  }
}

class _FilterContent extends StatefulWidget {
  const _FilterContent();

  @override
  _FilterContentState createState() => _FilterContentState();
}

class _FilterContentState extends State<_FilterContent> {
  bool isPaidSelected = false;
  bool isFreeSelected = true;
  bool isExpertSelected = true;
  bool isRating4Selected = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75, // 75% screen height
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0.3, -0.1), // Slightly off-center
          radius: 1.2,
          colors: [
            Color(0xFFFFF0F5), // Light pink glow
            Color(0xFFECEFFF), // Light bluish-white
            Color(0xFFFFFFFF), // White at the edges
          ],
          stops: [0.2, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title & Clear Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filters',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              TextButton(
                onPressed: () {
                  // Clear all filters
                  setState(() {
                    isPaidSelected = false;
                    isFreeSelected = false;
                    isExpertSelected = false;
                    isRating4Selected = false;
                  });
                },
                child:
                    const Text('Clear', style: TextStyle(color: Colors.black)),
              ),
            ],
          ),
          const Divider(),

          // Filters
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Price',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black)),
                  FilterCheckItem(
                    title: 'Paid',
                    subtitle: '(142)',
                    isSelected: isPaidSelected,
                    onChanged: (value) =>
                        setState(() => isPaidSelected = value!),
                  ),
                  FilterCheckItem(
                    title: 'Free',
                    subtitle: '(18)',
                    isSelected: isFreeSelected,
                    onChanged: (value) =>
                        setState(() => isFreeSelected = value!),
                  ),
                  const SizedBox(height: 16),
                  const Text('Level',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black)),
                  FilterCheckItem(
                    title: 'All Levels',
                    subtitle: '(1,167)',
                    isSelected: false,
                    onChanged: (value) {},
                  ),
                  FilterCheckItem(
                    title: 'Beginner',
                    subtitle: '(956)',
                    isSelected: false,
                    onChanged: (value) {},
                  ),
                  FilterCheckItem(
                    title: 'Intermediate',
                    subtitle: '(187)',
                    isSelected: false,
                    onChanged: (value) {},
                  ),
                  FilterCheckItem(
                    title: 'Expert',
                    subtitle: '(20)',
                    isSelected: isExpertSelected,
                    onChanged: (value) =>
                        setState(() => isExpertSelected = value!),
                  ),
                  const SizedBox(height: 16),
                  const Text('Ratings',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black)),
                  FilterCheckItem(
                    title: '4.0 & up',
                    subtitle: '(1,537)',
                    isSelected: isRating4Selected,
                    onChanged: (value) =>
                        setState(() => isRating4Selected = value!),
                  ),
                  FilterCheckItem(
                    title: '4.5 & up',
                    subtitle: '(698)',
                    isSelected: false,
                    onChanged: (value) {},
                  ),
                ],
              ),
            ),
          ),

          // Apply Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Apply', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

// Checkbox List Item
class FilterCheckItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isSelected;
  final ValueChanged<bool?> onChanged;

  const FilterCheckItem({
    super.key,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      title: Text(title, style: const TextStyle(color: Colors.black)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.black54)),
      value: isSelected,
      onChanged: onChanged,
      activeColor: Colors.black,
    );
  }
}
