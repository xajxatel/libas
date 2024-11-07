import 'package:closetly/auth/providers/auth_provider.dart';
import 'package:closetly/auth/screens/landing.dart';
import 'package:closetly/home/widgets/loading_circle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math'; // Added for random delays

/// Helper class to hold category statistics.
class CategoryStats {
  final int itemCount;
  final double totalPrice;

  CategoryStats({required this.itemCount, required this.totalPrice});
}

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  Map<String, CategoryStats> categoryData = {};
  bool isLoading = true;

  final List<String> categories = [
    'Tops',
    'Outerwear',
    'Bottoms',
    'Shoes',
    'Shades',
    'Head',
    'Dresses',
    'Suits',
    'Knitwear',
    'Extras',
    'Festive',
  ];

  double allTotalPrice = 0.0; // To store the 'All' totalPrice

  // List to track opacity of each box (11 categories + 'All' = 12)
  List<double> _boxOpacities = List.filled(12, 0.0);

  @override
  void initState() {
    super.initState();
    _fetchAggregateData();
  }

  /// Displays an error dialog with the provided message.
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        title: const Text(
          'ERROR',
          style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
            fontSize: 16.0,
          ),
        ),
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 14.0,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
            ),
            child: const Text(
              'OK',
              style: TextStyle(
                color: Colors.black,
                fontSize: 14.0,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Fetches aggregate data from Firestore instead of individual items.
  Future<void> _fetchAggregateData() async {
    final userId = ref.read(userIdProvider);
    if (userId == null) {
      _showErrorDialog('User not authenticated');
      return;
    }

    final firestore = FirebaseFirestore.instance;

    Map<String, CategoryStats> tempCategoryData = {};
    int totalItems = 0;
    double totalPrice = 0.0;

    try {
      // Create a list of futures to fetch each category's aggregates in parallel
      List<Future<void>> fetchFutures = categories.map((category) async {
        DocumentSnapshot categorySnapshot = await firestore
            .collection('users')
            .doc(userId)
            .collection('aggregates')
            .doc('categories')
            .collection('categories')
            .doc(category.toLowerCase())
            .get();

        if (categorySnapshot.exists) {
          int itemCount = categorySnapshot.get('itemCount') ?? 0;
          double categoryTotalPrice =
              categorySnapshot.get('totalPrice')?.toDouble() ?? 0.0;

          tempCategoryData[category] = CategoryStats(
            itemCount: itemCount,
            totalPrice: categoryTotalPrice,
          );

          totalItems += itemCount;
          totalPrice += categoryTotalPrice;
        } else {
          // If no aggregate exists for the category, initialize with zero
          tempCategoryData[category] = CategoryStats(
            itemCount: 0,
            totalPrice: 0.0,
          );
        }
      }).toList();

      // Wait for all category aggregates to be fetched
      await Future.wait(fetchFutures);

      // Fetch 'All' aggregate data
      DocumentSnapshot allAggregateSnapshot = await firestore
          .collection('users')
          .doc(userId)
          .collection('aggregates')
          .doc('all')
          .get();

      if (allAggregateSnapshot.exists) {
        int allItemCount = allAggregateSnapshot.get('itemCount') ?? 0;
        double allTotalPriceFetched =
            allAggregateSnapshot.get('totalPrice')?.toDouble() ?? 0.0;

        tempCategoryData['All'] = CategoryStats(
          itemCount: allItemCount,
          totalPrice: allTotalPriceFetched,
        );

        allTotalPrice = allTotalPriceFetched;
      } else {
        // Initialize 'All' aggregate if it doesn't exist
        tempCategoryData['All'] = CategoryStats(
          itemCount: totalItems,
          totalPrice: totalPrice,
        );

        allTotalPrice = totalPrice;
      }

      setState(() {
        categoryData = tempCategoryData;
        isLoading = false;
      });

      // After data is fetched, start the fade-in animations
      _startFadeInAnimations();
    } catch (e) {
      _showErrorDialog('Failed to fetch profile data. Please try again.');
      setState(() {
        isLoading = false;
      });
    }
  }

  /// Starts the fade-in animations for the boxes with random delays.
  void _startFadeInAnimations() {
    final random = Random();

    for (int i = 0; i < 12; i++) {
      // Generate a random delay between 0 to 1000 milliseconds
      int delay = random.nextInt(1000);

      Future.delayed(Duration(milliseconds: delay), () {
        setState(() {
          _boxOpacities[i] = 1.0;
        });
      });
    }
  }

  /// Displays a confirmation dialog before signing out.
  void _showSignOutConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        contentPadding: const EdgeInsets.all(8.0),
        titlePadding: const EdgeInsets.all(8.0),
        actionsPadding: const EdgeInsets.only(bottom: 4.0),
        title: const Text(
          'LOGOUT ?',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 16.0,
          ),
        ),
        content: const Text(
          'ARE YOU SURE YOU WANT TO LOGOUT?',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 12.0,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
            ),
            child: const Text(
              'CANCEL',
              style: TextStyle(
                color: Colors.black,
                fontSize: 14.0,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(authProvider.notifier).signOut();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LandingScreen()),
                (route) => false,
              );
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
            ),
            child: const Text(
              'LOG OUT',
              style: TextStyle(
                color: Colors.black,
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Determines the background color based on the percentage of total price.
  Color _getBackgroundColor(double percentage) {
    if (percentage == 100) {
      return Colors.black;
    } else if (percentage >= 75 && percentage < 100) {
      return Colors.black.withOpacity(0.8); // Shade 4
    } else if (percentage >= 50 && percentage < 75) {
      return Colors.black.withOpacity(0.6); // Shade 3
    } else if (percentage >= 25 && percentage < 50) {
      return Colors.black.withOpacity(0.4); // Shade 2
    } else if (percentage >= 1 && percentage < 25) {
      return Colors.black.withOpacity(0.2); // Shade 1
    } else {
      return Colors.transparent; // 0%
    }
  }

  /// Determines the text color based on the percentage of total price.
  Color _getTextColor(double percentage) {
    if (percentage >= 25) {
      return Colors.white;
    } else {
      return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      // Removed AppBar to allow grid to span full width

      body: isLoading
          ? const Center(child: LoadingCircle())
          : Column(
              children: [
                // 'ME' Title with horizontal padding
                SizedBox(height: screenHeight * 0.025),
                const Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 8.0, vertical: 24.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'PORTFOLIO',
                      style: TextStyle(
                          fontSize: 36.0, fontWeight: FontWeight.normal),
                    ),
                  ),
                ),
                // Grid of 12 Boxes (11 categories + All) with no horizontal padding
                Expanded(
                  child: GridView.builder(
                    padding: EdgeInsets.zero, // No padding around the grid
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3, // 3 boxes per row
                      childAspectRatio: 1.0, // Square boxes
                      mainAxisSpacing: 0.0,
                      crossAxisSpacing: 0.0,
                    ),
                    itemCount: categories.length + 1, // +1 for 'All'
                    itemBuilder: (context, index) {
                      String category;
                      if (index < categories.length) {
                        category = categories[index];
                      } else {
                        category = 'All';
                      }

                      int itemCount = categoryData[category]?.itemCount ?? 0;
                      double totalPrice =
                          categoryData[category]?.totalPrice ?? 0.0;

                      // Calculate percentage for coloring
                      double percentage = 0.0;
                      if (category != 'All' && allTotalPrice > 0) {
                        percentage = (totalPrice / allTotalPrice) * 100;
                      } else if (category == 'All') {
                        percentage = 100.0;
                      }

                      Color backgroundColor = _getBackgroundColor(percentage);
                      Color textColor = _getTextColor(percentage);

                      // Determine box opacity
                      double boxOpacity =
                          (index < _boxOpacities.length) ? _boxOpacities[index] : 1.0;

                      return AnimatedOpacity(
                        opacity: boxOpacity,
                        duration:
                            const Duration(milliseconds: 500), // Fade-in duration
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            color: backgroundColor, // Dynamic background color
                          ),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Category Name
                                  Text(
                                    category.toUpperCase(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14.0,
                                      color: textColor, // Dynamic text color
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 8.0),
                                  // Item Count
                                  Text(
                                    '$itemCount ITEMS',
                                    style: TextStyle(
                                      fontSize: 12.0,
                                      color: textColor, // Dynamic text color
                                    ),
                                  ),
                                  const SizedBox(height: 4.0),
                                  // Total Price
                                  Text(
                                    '₹ ${totalPrice.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 12.0,
                                      color: textColor, // Dynamic text color
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Sign Out Button with horizontal padding
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 4.0),
                  child: OutlinedButton(
                    onPressed: _showSignOutConfirmationDialog,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black,
                      side: const BorderSide(color: Colors.black),
                      backgroundColor: Colors.transparent,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero, // Pointy edges
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 6.0, horizontal: 20.0),
                    ),
                    child: const Text(
                      'LOGOUT',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                ),
                // Footer Text with horizontal padding
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'MADE BY @xajxatel',
                    style: TextStyle(fontSize: 12.0),
                  ),
                ),
                const SizedBox(height: 16.0),
              ],
            ),
    );
  }
}