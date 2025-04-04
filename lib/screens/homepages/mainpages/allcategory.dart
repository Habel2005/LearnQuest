import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:our_own_project/auth-service/api.dart';
import 'package:our_own_project/screens/homepages/home.dart';
import 'package:our_own_project/screens/homepages/mainpages/categorycourse.dart';

import '../../../models/category.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  late Future<List<Category>> futureCategories;
  List<Category> categories = [];
  bool isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    futureCategories = CategoryService.fetchCategories();
  }

  Future<void> loadMoreCategories() async {
    if (isLoadingMore) return;

    setState(() {
      isLoadingMore = true;
    });

    List<String> excluded = categories.map((cat) => cat.name).toList();
    List<Category> additionalCategories =
        await CategoryService.fetchMoreCategories(excluded);

    setState(() {
      categories.addAll(additionalCategories);
      isLoadingMore = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 223, 205, 228),
              Color.fromARGB(255, 234, 246, 255),
              Colors.white,
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // AppBar
            Padding(
              padding: const EdgeInsets.only(top: 50, left: 16, right: 16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios,
                        size: 20, color: Colors.black87),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  const Text(
                    'Categories',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 40),
                ],
              ),
            ),

            // Fetch and Display Categories
            Expanded(
              child: FutureBuilder<List<Category>>(
                future: futureCategories,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return const Center(
                        child: Text("Failed to load categories"));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text("No categories found"));
                  }

                  if (categories.isEmpty) {
                    categories = snapshot.data!;
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    child: MasonryGridView.builder(
                      gridDelegate:
                          const SliverSimpleGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                      ),
                      itemCount: categories.length,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      itemBuilder: (context, index) {
                        final category = categories[index];

                        return GestureDetector(
                          onTap: () {
                            navigateWithSlideTransition(
                                context,
                                CategoryDetailScreen(
                                    categoryName: category.name));
                          },
                          child: Container(
                            width: category.width *
                                (MediaQuery.of(context).size.width / 2 - 20),
                            height: category.height *
                                100, // Adjusted height for randomness
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: category.gradientColors,
                              ),
                            ),
                            child: Stack(
                              children: [
                                // Category Image
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Image.asset(
                                      category.illustrationAsset,
                                      width: category.width > 0.7 ? 210 : 160,
                                      height: category.width > 0.7 ? 200 : 150,
                                      fit: BoxFit.cover,
                                      opacity:
                                          const AlwaysStoppedAnimation(0.7),
                                    ),
                                  ),
                                ),

                                // Category Text
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        category.name,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      const Text(
                                        'View Courses',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white70,
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
                  );
                },
              ),
            ),
          ],
        ),
      ),

      // Floating Action Button for "Show More"
      floatingActionButton: FloatingActionButton.extended(
        onPressed: loadMoreCategories,
        backgroundColor: Colors.deepPurple,
        icon: isLoadingMore
            ? const CircularProgressIndicator(color: Colors.white)
            : const Icon(Icons.add),
        label:
            isLoadingMore ? const Text("Loading...") : const Text("Show More"),
      ),
    );
  }
}
