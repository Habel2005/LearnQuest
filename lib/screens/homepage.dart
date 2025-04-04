import 'dart:async';
import 'package:flutter/material.dart';
import 'package:circle_nav_bar/circle_nav_bar.dart';
import 'package:our_own_project/components/gif.dart';
import 'package:our_own_project/screens/homepages/community.dart';
import 'package:our_own_project/screens/homepages/coursepage.dart';
import 'package:our_own_project/screens/homepages/home.dart';
import 'package:our_own_project/screens/homepages/profile.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage>
    with SingleTickerProviderStateMixin {
  int _tabIndex = 0;
  int get tabIndex => _tabIndex;
  set tabIndex(int v) {
    _tabIndex = v;
    setState(() {});
  }

  late PageController _pageController;
  final List<bool> _gifStates = [
    false,
    false,
    false,
    false
  ]; // Track GIF state for each tab

  Timer? _gifTimer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _tabIndex);
  }

  @override
  void dispose() {
    _gifTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  final ValueNotifier<bool> shouldAutoFocusNotifier = ValueNotifier(false);


  void _navigateToSearchFromHome() {
    FocusScope.of(context).unfocus();

    _pageController
        .animateToPage(
      1, // CoursePage index
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    )
        .then((_) {
      // Set focus flag after navigation completes
      shouldAutoFocusNotifier.value = true;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBody: true,
      body: PageView(
        controller: _pageController,
        onPageChanged: (v) {
          tabIndex = v; // Update tab index when page changes
        },
        children: [
          Home(
              pageController: _pageController,
              onSearchTap: _navigateToSearchFromHome),
          CourseBrowser(
              pageController: _pageController,
              shouldAutoFocusNotifier: shouldAutoFocusNotifier),
          CommunityPage(
            pageController: _pageController,
          ),
          const ProfilePage(),
        ],
      ),
      bottomNavigationBar: CircleNavBar(
        activeIcons: [
          AnimatedCustomIcon(
            gifPath: 'assets/home.gif',
            imagePath: 'assets/home.png',
            shouldPlayGif: _gifStates[0], // Play GIF only when true
          ),
          AnimatedCustomIcon(
            gifPath: 'assets/open-book.gif',
            imagePath: 'assets/open-book.png',
            shouldPlayGif: _gifStates[1], // Play GIF only when true
          ),
          AnimatedCustomIcon(
            gifPath: 'assets/community.gif',
            imagePath: 'assets/community.png',
            shouldPlayGif: _gifStates[2], // Play GIF only when true
          ),
          AnimatedCustomIcon(
            gifPath: 'assets/user.gif',
            imagePath: 'assets/user.png',
            shouldPlayGif: _gifStates[3], // Play GIF only when true
          ),
        ],
        inactiveIcons: [
          _buildInactiveIcon((Icons.home_rounded), 'Home'),
          _buildInactiveIcon(Icons.library_books_rounded, 'Courses'),
          _buildInactiveIcon(Icons.groups, 'Community'),
          _buildInactiveIcon(Icons.manage_accounts_rounded, 'Profile'),
        ],
        color: Theme.of(context).colorScheme.secondary,
        circleColor: Colors.transparent,
        height: 50,
        circleWidth: 45,
        activeIndex: tabIndex,
        onTap: (index) {
          setState(() {
            _gifStates[index] =
                true; // Enable GIF to play for the selected icon
            tabIndex = index;
            _pageController.jumpToPage(tabIndex); // Sync with PageView

          });

          _gifTimer?.cancel();

          // Start a new Timer
          _gifTimer = Timer(const Duration(seconds: 2), () {
            if (mounted) {
              setState(() {
                _gifStates[index] = false;
              });
            }
          });
        },
        padding: const EdgeInsets.only(left: 5, right: 5, bottom: 5),
        cornerRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
          bottomRight: Radius.circular(30),
          bottomLeft: Radius.circular(30),
        ),
        shadowColor: const Color.fromARGB(165, 58, 51, 74),
        elevation: 8,
      ),
    );
  }

  // Helper method to build inactive icons with text below
  Widget _buildInactiveIcon(IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
      ],
    );
  }
}
