import 'package:closetly/auth/providers/auth_provider.dart';
import 'package:closetly/home/widgets/loading_circle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OutfitScreen extends ConsumerStatefulWidget {
  const OutfitScreen({super.key});

  @override
  _OutfitsScreenState createState() => _OutfitsScreenState();
}

class _OutfitsScreenState extends ConsumerState<OutfitScreen> {
  String? selectedFilterCategory =
      'Everyday'; // Default selection for "Everyday"

  final List<String> filterCategories = [
    'Everyday',
    'Outing',
    'Date',
    'Formal',
    'Ethnic'
  ];

  // List to track visibility of each filter chip
  late List<bool> _chipVisibility;

  @override
  void initState() {
    super.initState();

    // Initialize chip visibility list
    _chipVisibility = List<bool>.filled(filterCategories.length, false);

    // Trigger chip animations with staggered delays
    _animateChips();
  }

  // Method to animate chips sequentially
  void _animateChips() async {
    for (int i = 0; i < filterCategories.length; i++) {
      await Future.delayed(const Duration(milliseconds: 100)); // Delay between each chip
      if (mounted) {
        setState(() {
          _chipVisibility[i] = true;
        });
      }
    }
  }

  void _showDeleteConfirmationDialog(String outfitId) {
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
          'CONFIRM DELETE',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 16.0,
          ),
        ),
        content: const Text(
          'ARE YOU SURE YOU WANT TO DELETE THIS OUTFIT?',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 12.0,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
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
            onPressed: () {
              Navigator.pop(context);
              _deleteOutfit(outfitId);
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
            ),
            child: const Text(
              'DELETE',
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

  void _deleteOutfit(String outfitId) {
    final userId = ref.read(userIdProvider);
    if (userId != null) {
      ref
          .read(firebaseFirestoreProvider)
          .collection('users')
          .doc(userId)
          .collection('outfits')
          .doc(outfitId)
          .delete()
          .then((_) {
        setState(() {}); // Refresh screen after deletion
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'OUTFIT DELETED',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.black,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
          ),
        );
      });
    }
  }

  // Helper method to build animated filter chips
  Widget _buildAnimatedFilterChip(String category, bool isSelected, int index) {
    return AnimatedOpacity(
      opacity: _chipVisibility[index] ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 500), // Duration of fade-in
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(50 * (1 - value), 0), // Moves from right to original position
              child: child,
            ),
          );
        },
        child: FilterChip(
          label: Text(
            category.toUpperCase(),
            style: TextStyle(
              color: Colors.black,
              fontWeight:
                  isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                selectedFilterCategory = category;
              } else {
                selectedFilterCategory = null;
              }
            });
          },
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
            side: BorderSide(color: Colors.black, width: 1.0),
          ),
          backgroundColor:
              Colors.transparent, // Unselected background
          selectedColor: Colors.black12, // Selected background
          showCheckmark: false,
          padding: const EdgeInsets.symmetric(
              horizontal: 4.0, vertical: 2.0),
          labelPadding: const EdgeInsets.symmetric(horizontal: 2.0),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    );
  }

  // Helper method to build animated outfit cards
  Widget _buildAnimatedOutfitCard(Map<String, dynamic> outfit, int index) {
    return AnimatedOpacity(
      opacity: 1.0,
      duration: const Duration(milliseconds: 500),
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeIn,
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: child,
          );
        },
        child: GestureDetector(
          onLongPress: () =>
              _showDeleteConfirmationDialog(outfit['id']),
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(vertical: 4.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              color: Colors.transparent,
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Outfit Name
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      outfit['outfitName'].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // Outfit Images in 2-column Grid
                  GridView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: (outfit['images'] as List<String>).length,
                    itemBuilder: (context, imgIndex) {
                      final imageUrl = outfit['images'][imgIndex];

                      return Container(
                        margin: const EdgeInsets.all(2.0), // Add margin between images
                        color: Colors.white,
                        child: imageUrl.isNotEmpty
                            ? Image.network(
                                imageUrl,
                                fit: BoxFit.contain, // Adjust BoxFit for better coverage
                              )
                            : Container(
                                color: Colors.grey[300],
                                child: const Icon(
                                  Icons.image,
                                  size: 50,
                                  color: Colors.white,
                                ),
                              ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userId = ref.watch(userIdProvider);
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title: "GALLERY" with no animation
          SizedBox(height: screenHeight * 0.05),
          const Padding(
            padding: EdgeInsets.only(left: 8.0, bottom: 8.0),
            child: Text(
              'GALLERY',
              style: TextStyle(fontSize: 36.0, fontWeight: FontWeight.normal),
            ),
          ),
          SizedBox(height: screenHeight * 0.022),
          // Filter Chips with specified animation
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Wrap(
              spacing: 4.0,
              runSpacing: 2.0,
              children: List<Widget>.generate(filterCategories.length, (index) {
                final category = filterCategories[index];
                final isSelected = selectedFilterCategory == category;
                return _buildAnimatedFilterChip(category, isSelected, index);
              }),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: userId != null
                  ? ref
                      .watch(firebaseFirestoreProvider)
                      .collection('users')
                      .doc(userId)
                      .collection('outfits')
                      .orderBy('timestamp', descending: true)
                      .snapshots()
                  : null,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const LoadingCircle();
                }

                final outfits = snapshot.data!.docs.map((doc) {
                  return {
                    'id': doc.id,
                    'category': doc['category'],
                    'outfitName': doc['outfitName'],
                    'images': List<String>.from(doc['images']),
                  };
                }).toList();

                final filteredOutfits = selectedFilterCategory == null
                    ? outfits
                    : outfits
                        .where((outfit) =>
                            outfit['category'] == selectedFilterCategory)
                        .toList();

                if (selectedFilterCategory == null) {
                  return const Center(child: Text('PLEASE SELECT A CATEGORY'));
                }

                if (filteredOutfits.isEmpty) {
                  return const Center(child: Text('NO OUTFITS FOUND'));
                }

                return ListView.builder(
                  itemCount: filteredOutfits.length,
                  itemBuilder: (context, index) {
                    final outfit = filteredOutfits[index];
                    return _buildAnimatedOutfitCard(outfit, index);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}