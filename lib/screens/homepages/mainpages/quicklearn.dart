import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class QuickLearnPage extends StatefulWidget {
  const QuickLearnPage({super.key});

  @override
  State<QuickLearnPage> createState() => _QuickLearnPageState();
}

class _QuickLearnPageState extends State<QuickLearnPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, dynamic>> _concepts = [
    {
      'title': 'State Management',
      'timeToRead': '5 min',
      'complexity': 'Intermediate',
      'tags': ['Flutter', 'Architecture'],
      'image': 'assets/card1.jpg',
    },
    {
      'title': 'Asynchronous Programming',
      'timeToRead': '8 min',
      'complexity': 'Advanced',
      'tags': ['Dart', 'Flutter'],
      'image': 'assets/card1.jpg',
    },
    {
      'title': 'UI Animations',
      'timeToRead': '6 min',
      'complexity': 'Intermediate',
      'tags': ['Flutter', 'UI/UX'],
      'image': 'assets/card1.jpg',
    },
    {
      'title': 'Firebase Integration',
      'timeToRead': '10 min',
      'complexity': 'Intermediate',
      'tags': ['Backend', 'Database'],
      'image': 'assets/card1.jpg',
    },
    {
      'title': 'REST API Calls',
      'timeToRead': '7 min',
      'complexity': 'Beginner',
      'tags': ['Network', 'Data'],
      'image': 'assets/card1.jpg',
    },
    {
      'title': 'Custom Widgets',
      'timeToRead': '4 min',
      'complexity': 'Beginner',
      'tags': ['Flutter', 'UI/UX'],
      'image': 'assets/card1.jpg',
    },
    {
      'title': 'App Architecture',
      'timeToRead': '12 min',
      'complexity': 'Advanced',
      'tags': ['Flutter', 'Architecture'],
      'image': 'assets/card1.jpg',
    },
    {
      'title': 'Performance Optimization',
      'timeToRead': '9 min',
      'complexity': 'Advanced',
      'tags': ['Flutter', 'Performance'],
      'image': 'assets/card1.jpg',
    },
    {
      'title': 'Local Storage',
      'timeToRead': '6 min',
      'complexity': 'Beginner',
      'tags': ['Flutter', 'Storage'],
      'image': 'assets/card1.jpg',
    },
    {
      'title': 'Package Management',
      'timeToRead': '3 min',
      'complexity': 'Beginner',
      'tags': ['Dart', 'Flutter'],
      'image': 'assets/card1.jpg',
    },
    {
      'title': 'Form Validation',
      'timeToRead': '5 min',
      'complexity': 'Intermediate',
      'tags': ['Flutter', 'UI/UX'],
      'image': 'assets/card1.jpg',
    },
    {
      'title': 'Responsive Design',
      'timeToRead': '7 min',
      'complexity': 'Intermediate',
      'tags': ['Flutter', 'UI/UX'],
      'image': 'assets/card1.jpg',
    },
  ];

  final List<String> _categories = [
    'All',
    'Beginner',
    'Intermediate',
    'Advanced',
    'Flutter',
    'Dart',
    'UI/UX',
    'Backend',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              _buildSearchBar(),
              _buildCategoryTabs(),
              Expanded(
                child: _buildConceptGrid(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Quick Learn',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey.shade800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Bite-sized tech concepts',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.blueGrey.shade600,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: Colors.amber.shade600,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  '12 concepts',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.blueGrey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            Icon(
              Icons.search,
              color: Colors.blueGrey.shade400,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search concepts...',
                  hintStyle: TextStyle(
                    color: Colors.blueGrey.shade300,
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
            Container(
              height: 36,
              width: 36,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                Icons.filter_list,
                color: Colors.blue.shade700,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return Container(
      height: 50,
      margin: const EdgeInsets.only(top: 8),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.blueGrey.shade600,
        indicatorSize: TabBarIndicatorSize.label,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              Colors.blue.shade400,
              Colors.purple.shade300,
            ],
          ),
        ),
        tabs: _categories.map((category) {
          return Tab(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.blueGrey.shade200,
                  width: 1,
                ),
              ),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  category,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildConceptGrid() {
    return TabBarView(
      controller: _tabController,
      children: _categories.map((category) {
        List<Map<String, dynamic>> filteredConcepts = _concepts;
        if (category != 'All') {
          filteredConcepts = _concepts.where((concept) {
            if (['Beginner', 'Intermediate', 'Advanced'].contains(category)) {
              return concept['complexity'] == category;
            } else {
              return concept['tags'].contains(category);
            }
          }).toList();
        }

        return filteredConcepts.isEmpty
            ? Center(
                child: Text(
                  'No concepts found for $category',
                  style: TextStyle(
                    color: Colors.blueGrey.shade400,
                    fontSize: 16,
                  ),
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(16),
                child: MasonryGridView.count(
                  controller: _scrollController,
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  itemCount: filteredConcepts.length,
                  itemBuilder: (context, index) {
                    final concept = filteredConcepts[index];
                    return _buildConceptCard(concept);
                  },
                ),
              );
      }).toList(),
    );
  }

  Widget _buildConceptCard(Map<String, dynamic> concept) {
    return GestureDetector(
      onTap: () {
        // Navigate to concept detail page
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              child: Image.asset(
                concept['image'],
                fit: BoxFit.cover,
                height: 120,
                width: double.infinity,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    concept['title'],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey.shade800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: Colors.blueGrey.shade400,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        concept['timeToRead'],
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blueGrey.shade400,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getComplexityColor(concept['complexity']),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          concept['complexity'],
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: (concept['tags'] as List).map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.blue.shade100,
                          ),
                        ),
                        child: Text(
                          tag,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getComplexityColor(String complexity) {
    switch (complexity) {
      case 'Beginner':
        return Colors.green.shade400;
      case 'Intermediate':
        return Colors.orange.shade400;
      case 'Advanced':
        return Colors.red.shade400;
      default:
        return Colors.blue.shade400;
    }
  }
}
