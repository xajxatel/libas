import 'package:closetly/home/screens/helper_create/collage_screen.dart';
import 'package:closetly/home/services/firebase_providers.dart';
import 'package:closetly/home/widgets/loading_circle.dart';
import 'package:closetly/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart'; // Import the package

class CreateScreen extends ConsumerStatefulWidget {
  const CreateScreen({super.key});

  @override
  _CreateScreenState createState() => _CreateScreenState();
}

class _CreateScreenState extends ConsumerState<CreateScreen>
    with RouteAware, TickerProviderStateMixin {
  final Map<String, List<Map<String, dynamic>>> selectedItems = {};
  final Set<String> selectedCategories = {}; // Tracks selected categories

  final List<String> _categories = [
    'Head',
    'Shades',
    'Outerwear',
    'Knitwear',
    'Tops',
    'Suits',
    'Dresses',
    'Festive',
    'Bottoms',
    'Shoes',
    'Extras'
  ];

  // List to track visibility of each chip
  late List<bool> _chipVisibility;

  @override
  void initState() {
    super.initState();
    // _fetchLocationAndWeather(); // Remove if not needed

    // Initialize chip visibility list
    _chipVisibility = List<bool>.filled(_categories.length, false);

    // Trigger chip animations with staggered delays
    _animateChips();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)! as PageRoute);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    // Called when the current route has been popped back to
    _refreshItems();
  }

  @override
  void didPush() {
    // Called when the current route has been pushed
    _refreshItems();
  }

  void _refreshItems() {
    // Refresh all category items
    for (var category in _categories) {
      ref.refresh(allCategoryItemsProvider(category.toLowerCase()));
    }
    // Optionally, reset selections
    setState(() {
      selectedItems.clear();
      selectedCategories.clear();
      _chipVisibility = List<bool>.filled(_categories.length, false);
      _animateChips();
    });
  }

  // Method to animate chips sequentially
  void _animateChips() async {
    for (int i = 0; i < _categories.length; i++) {
      await Future.delayed(
          const Duration(milliseconds: 100)); // Delay between each chip
      setState(() {
        _chipVisibility[i] = true;
      });
    }
  }

  // Helper method to create a custom route with fade and slide animations
  Route _createRoute(Widget destination) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => destination,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Define the slide transition (from bottom to top)
        final slideTween = Tween<Offset>(
          begin: const Offset(0, 1), // Start just below the screen
          end: Offset.zero, // End at the original position
        ).animate(
          CurvedAnimation(
            parent: animation,
            curve: Curves.easeOut, // Easing curve for natural movement
          ),
        );

        // Define the fade transition
        final fadeTween = Tween<double>(
          begin: 0.0, // Fully transparent
          end: 1.0, // Fully opaque
        ).animate(
          CurvedAnimation(
            parent: animation,
            curve: Curves.easeIn, // Easing curve for smooth fade
          ),
        );

        // Combine both transitions
        return SlideTransition(
          position: slideTween,
          child: FadeTransition(
            opacity: fadeTween,
            child: child,
          ),
        );
      },
      transitionDuration:
          const Duration(milliseconds: 500), // Duration of the transition
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: screenHeight * 0.05),
          // Removed FadeTransition for "STUDIO" heading
          const Padding(
            padding: EdgeInsets.only(left: 8.0, bottom: 8.0),
            child: Text(
              'STUDIO',
              style: TextStyle(fontSize: 36.0, fontWeight: FontWeight.normal),
            ),
          ),
          SizedBox(height: screenHeight * 0.022),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Wrap(
              spacing: 4.0,
              runSpacing: 2.0,
              children: List<Widget>.generate(_categories.length, (index) {
                final category = _categories[index];
                final isSelected = selectedCategories.contains(category);
                return AnimatedOpacity(
                  opacity: _chipVisibility[index] ? 1.0 : 0.0,
                  duration:
                      const Duration(milliseconds: 500), // Duration of fade-in
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOut,
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset:
                              Offset(50 * (1 - value), 0), // Moves from right to original position
                          child: child,
                        ),
                      );
                    },
                    child: FilterChip(
                      label: Text(
                        category.toUpperCase(),
                        style: TextStyle(
                          color: !isSelected ? Colors.black : Colors.pink, // Change label color based on selection
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            selectedCategories.add(category);
                          } else {
                            selectedCategories.remove(category);
                            selectedItems.remove(
                                category); // Optional: Remove items when category is deselected
                          }
                        });
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                        side: BorderSide(
                            color: !isSelected ? Colors.black : Colors.pink, // Change border color based on selection
                            width: 1.0),
                      ),
                      backgroundColor:
                          Colors.transparent, // Unselected background
                      selectedColor: Colors.transparent, // Selected background remains transparent
                      showCheckmark: false,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4.0, vertical: 2.0),
                      labelPadding:
                          const EdgeInsets.symmetric(horizontal: 2.0),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                );
              }),
            ),
          ),
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 10.0),
            child: const Divider(
              color: Colors.grey,
              thickness: 1.0,
            ),
          ),
          SizedBox(height: screenHeight * 0.01),
          Expanded(
            child: selectedCategories.isEmpty
                // If no categories are selected, display the centered message
                ? const Center(
                    child: Text(
                      "PICK A CHIP TO START STYLING",
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Colors.black,
                        fontWeight: FontWeight.normal,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                // Else, display the ListView with selected categories and their items
                : ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      for (String category in _categories)
                        if (selectedCategories.contains(category))
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 0.0, vertical: 4.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: 4.0, left: 8),
                                  child: Text(
                                    category.toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Consumer(
                                  builder: (context, ref, _) {
                                    final clothingAsyncValue = ref.watch(
                                        allCategoryItemsProvider(
                                            category.toLowerCase()));

                                    return clothingAsyncValue.when(
                                      data: (items) {
                                        if (items.isEmpty) {
                                          return const Padding(
                                            padding: EdgeInsets.only(left: 8.0),
                                            child: Text('NO ITEMS AVAILABLE'),
                                          );
                                        }
                                        return AnimationLimiter(
                                          // Wrap ListView.builder with AnimationLimiter
                                          child: SizedBox(
                                            height: 160,
                                            child: ListView.builder(
                                              scrollDirection: Axis.horizontal,
                                              itemCount: items.length,
                                              itemBuilder:
                                                  (context, itemIndex) {
                                                final item = items[itemIndex];
                                                final isSelected =
                                                    selectedItems[category]
                                                            ?.contains(item) ??
                                                        false;
                                                final imageUrl =
                                                    item['imageUrl'] ?? '';

                                                return AnimationConfiguration
                                                    .staggeredList(
                                                  position: itemIndex,
                                                  duration: const Duration(
                                                      milliseconds: 800),
                                                  child: FadeInAnimation(
                                                    // Apply FadeInAnimation only
                                                    child: GestureDetector(
                                                      onTap: () =>
                                                          toggleSelection(
                                                              category, item),
                                                      child: Container(
                                                        width: 120,
                                                        margin: const EdgeInsets
                                                            .only(left : 4 , right : 4), // Add space between item boxes
                                                        decoration:
                                                            BoxDecoration(
                                                          color: isSelected
                                                              ? Colors.black12
                                                              : Colors
                                                                  .transparent,
                                                          border: isSelected
                                                              ? Border.all(
                                                                  color:
                                                                      Colors.pink,
                                                                  width: 1.0)
                                                              : null, // Remove borders when not selected
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      0.0), // Optional: Rounded corners
                                                        ),
                                                        child: Stack(
                                                          children: [
                                                            // Display the image
                                                            imageUrl.isNotEmpty
                                                                ? Image.network(
                                                                    imageUrl,
                                                                    fit: BoxFit
                                                                        .contain,
                                                                    width: double
                                                                        .infinity,
                                                                    height: double
                                                                        .infinity,
                                                                  )
                                                                : Container(
                                                                    color:
                                                                        Colors
                                                                            .grey[
                                                                                300],
                                                                    width:
                                                                        double
                                                                            .infinity,
                                                                    height:
                                                                        double
                                                                            .infinity,
                                                                    child:
                                                                        const Icon(
                                                                      Icons
                                                                          .image,
                                                                      size: 50,
                                                                      color: Colors
                                                                          .white,
                                                                    ),
                                                                  ),
                                                            // Optional: Add overlay or other widgets if needed
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        );
                                      },
                                      loading: () =>
                                          const LoadingCircle(),
                                      error: (error, stack) => Text(
                                          'ERROR FETCHING ITEMS: ${error.toString()}'),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                    ],
                  ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 8.0, vertical: 6.0),
            child: Center(
              child: OutlinedButton(
                onPressed: _createCollage,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(40),
                  side: const BorderSide(color: Colors.black),
                  backgroundColor: Colors.transparent,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                ),
                child: const Text(
                  'STYLE',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Toggle item selection
  void toggleSelection(String category, Map<String, dynamic> item) {
    setState(() {
      selectedItems[category] ??= [];
      if (selectedItems[category]!.contains(item)) {
        selectedItems[category]!.remove(item);
      } else {
        selectedItems[category]!.add(item);
      }
    });
  }

  void _createCollage() {
    if (selectedItems.isEmpty) {
      _showDialog(
        'NO ITEMS SELECTED',
        'PLEASE MAKE A SELECTION TO CREATE AN OUTFIT',
      );
      return;
    }

    Navigator.of(context).push(
      _createRoute(
        CollageScreen(selectedItems: selectedItems),
      ),
    );
  }

  void _showDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        contentPadding: const EdgeInsets.all(8.0),
        titlePadding: const EdgeInsets.all(8.0),
        actionsPadding: const EdgeInsets.only(bottom: 4.0),
        title: Text(
          title.toUpperCase(),
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 16.0,
          ),
          textAlign: TextAlign.left,
        ),
        content: Text(
          content.toUpperCase(),
          style: TextStyle(
            color: Colors.grey[800],
            fontSize: 12.0,
          ),
          textAlign: TextAlign.left,
        ),
        actions: [
          Container(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12.0, vertical: 0.0),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
              ),
              child: const Text(
                'OK',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}