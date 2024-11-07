import 'dart:math';

import 'package:closetly/home/screens/helper_home/item_info_scree.dart';
import 'package:closetly/home/services/clothing_category_provider.dart';
import 'package:closetly/home/widgets/loading_circle.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Helper class to hold category statistics.
class CategoryStats {
  final int itemCount;
  final double totalPrice;

  CategoryStats({required this.itemCount, required this.totalPrice});
}

class ClothingCategoryScreen extends StatefulWidget {
  final String userId;
  final String category;

  const ClothingCategoryScreen({required this.userId, required this.category});

  @override
  _ClothingCategoryScreenState createState() => _ClothingCategoryScreenState();
}

class _ClothingCategoryScreenState extends State<ClothingCategoryScreen> {
  final ClothingCategoryProvider _provider = ClothingCategoryProvider();

  List<DocumentSnapshot>? _allClothingItems;
  List<DocumentSnapshot>? _filteredClothingItems;

  List<String>? _allBrands;
  List<String> _selectedBrands = [];

  List<Map<String, String>>? _allColors;
  List<String> _selectedColors = [];

  List<String> _selectedSubTypes = [];
  bool isLoading = true; // Loading indicator

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  /// Fetches aggregate data from Firestore instead of individual items.
  Future<void> _fetchInitialData() async {
    setState(() {
      isLoading = true; // Set loading to true when starting fetch
    });

    _allBrands = await _provider.getBrands(widget.userId, widget.category);
    _allColors = await _provider.getColors(widget.userId, widget.category);
    _allClothingItems =
        await _provider.fetchClothingItems(widget.userId, widget.category);

    _applyFilters();

    setState(() {
      isLoading = false; // Set loading to false when done
    });
  }

  void _applyFilters() {
    setState(() {
      _filteredClothingItems = _allClothingItems?.where((item) {
        final itemBrand = (item['brand'] ?? '').toLowerCase();
        final brandMatches = _selectedBrands.isEmpty ||
            _selectedBrands.map((b) => b.toLowerCase()).contains(itemBrand);

        final itemColor = (item['colorName'] ?? '').toLowerCase();
        final colorMatches = _selectedColors.isEmpty ||
            _selectedColors.map((c) => c.toLowerCase()).contains(itemColor);

        final itemSubType = (item['subType'] ?? '').toLowerCase();
        final typeMatches = _selectedSubTypes.isEmpty ||
            _selectedSubTypes.map((t) => t.toLowerCase()).contains(itemSubType);

        return brandMatches && colorMatches && typeMatches;
      }).toList();
    });
  }

  void _showBrandPicker(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              // Pop-up box edges pointy (no smooth edges)
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
              // Reduce margin and padding of the pop-up box
              contentPadding: const EdgeInsets.all(8.0),
              titlePadding: const EdgeInsets.all(8.0),
              title: const Text('SELECT BRANDS'),
              content: SingleChildScrollView(
                child: _allBrands == null || _allBrands!.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: const EdgeInsets.all(1.0),
                          child: Text(
                            'YOU DO NOT HAVE ANY ITEMS IN THIS CATEGORY',
                            style: TextStyle(color: Colors.black),
                            textAlign: TextAlign.left,
                          ),
                        ),
                      )
                    : Wrap(
                        // Reduce gap between choice chips in different rows
                        spacing: 4.0,
                        runSpacing: 2.0,
                        children: _allBrands!.map((brandName) {
                          final isSelected =
                              _selectedBrands.contains(brandName);
                          return FilterChip(
                            label: Text(
                              brandName.toUpperCase(),
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedBrands.add(brandName);
                                } else {
                                  _selectedBrands.remove(brandName);
                                }
                              });
                            },
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero,
                              side: BorderSide(
                                color: Colors.black,
                                width: 1.0,
                              ),
                            ),
                            selectedColor:
                                Colors.black12, // Selected background

                            labelStyle: const TextStyle(color: Colors.black),
                            showCheckmark: false,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4.0, vertical: 2.0),
                            labelPadding:
                                const EdgeInsets.symmetric(horizontal: 2.0),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          );
                        }).toList(),
                      ),
              ),
              actionsPadding: const EdgeInsets.symmetric(horizontal: 8.0),
              actions: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedBrands.clear();
                    });
                  },
                  child: const Text('CLEAR',
                      style: TextStyle(color: Colors.black)),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    // Removed _applyFilters() from here
                  },
                  child: const Text('APPLY',
                      style: TextStyle(color: Colors.black)),
                ),
              ],
            );
          },
        );
      },
    );
    // After the dialog is closed, apply filters
    _applyFilters();
  }

  void _showColorPicker(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
              contentPadding: const EdgeInsets.all(8.0),
              titlePadding: const EdgeInsets.all(8.0),
              title: const Text('PALETTE'),
              content: SingleChildScrollView(
                child: _allColors == null || _allColors!.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(1.0),
                          child: Text(
                            'YOU DO NOT HAVE ANY ITEMS IN THIS CATEGORY',
                            style: TextStyle(color: Colors.black),
                            textAlign: TextAlign.left,
                          ),
                        ),
                      )
                    : Wrap(
                        spacing: 4.0,
                        runSpacing: 2.0,
                        children: _allColors!.map((color) {
                          final colorName = color['name'];
                          final colorHex = color['hex'];
                          final isSelected =
                              _selectedColors.contains(colorName);
                          return FilterChip(
                            label: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 16,
                                  height: 16,
                                  color: Color(int.parse(
                                      '0xFF${colorHex!.substring(1)}')),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  colorName!.toUpperCase(),
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedColors.add(colorName);
                                } else {
                                  _selectedColors.remove(colorName);
                                }
                              });
                            },
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero,
                              side: BorderSide(
                                color: Colors.black,
                                width: 1.0,
                              ),
                            ),
                            selectedColor:
                                Colors.black12, // Selected background
                            labelStyle: const TextStyle(color: Colors.black),
                            showCheckmark: false,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4.0, vertical: 2.0),
                            labelPadding:
                                const EdgeInsets.symmetric(horizontal: 2.0),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          );
                        }).toList(),
                      ),
              ),
              actionsPadding: const EdgeInsets.symmetric(horizontal: 8.0),
              actions: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedColors.clear();
                    });
                  },
                  child: const Text('CLEAR',
                      style: TextStyle(color: Colors.black)),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    // Removed _applyFilters() from here
                  },
                  child: const Text('APPLY',
                      style: TextStyle(color: Colors.black)),
                ),
              ],
            );
          },
        );
      },
    );
    // After the dialog is closed, apply filters
    _applyFilters();
  }

  void _showTypePicker(BuildContext context) async {
    final subCategories = _provider.getSubCategories(widget.category);
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
              contentPadding: const EdgeInsets.all(8.0),
              titlePadding: const EdgeInsets.all(8.0),
              title: const Text('SELECT TYPES'),
              content: SingleChildScrollView(
                child: _allColors == null || _allColors!.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(1.0),
                          child: Text(
                            'YOU DO NOT HAVE ANY ITEMS IN THIS CATEGORY',
                            style: TextStyle(color: Colors.black),
                            textAlign: TextAlign.left,
                          ),
                        ),
                      )
                    : Wrap(
                        spacing: 4.0,
                        runSpacing: 2.0,
                        children: subCategories.map((type) {
                          final isSelected = _selectedSubTypes.contains(type);
                          return FilterChip(
                            label: Text(
                              type.toUpperCase(),
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedSubTypes.add(type);
                                } else {
                                  _selectedSubTypes.remove(type);
                                }
                              });
                            },
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero,
                              side: BorderSide(
                                color: Colors.black,
                                width: 1.0,
                              ),
                            ),
                            selectedColor:
                                Colors.black12, // Selected background
                            labelStyle: const TextStyle(color: Colors.black),
                            showCheckmark: false,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4.0, vertical: 2.0),
                            labelPadding:
                                const EdgeInsets.symmetric(horizontal: 2.0),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          );
                        }).toList(),
                      ),
              ),
              actionsPadding: const EdgeInsets.symmetric(horizontal: 8.0),
              actions: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedSubTypes.clear();
                    });
                  },
                  child: const Text('CLEAR',
                      style: TextStyle(color: Colors.black)),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    // Removed _applyFilters() from here
                  },
                  child: const Text('APPLY',
                      style: TextStyle(color: Colors.black)),
                ),
              ],
            );
          },
        );
      },
    );
    // After the dialog is closed, apply filters
    _applyFilters();
  }

  final List<String> loadingMessages = [
    "ONE MOMENT, POR FAVOR...",
    "UN MOMENTO, POR FAVOR...",
    "UN INSTANT, S'IL VOUS PLAÎT...",
    "EINEN MOMENT, BITTE...",
    "UN MOMENTO, PER FAVORE...",
    "UM MOMENTO, POR FAVOR...",
    "EEN MOMENT, ALSTUBLIEFT...",
    "ОДНУ МИНУТУ, ПОЖАЛУЙСТА...",
    "请稍等...",
    "少々お待ちください...",
    "잠시만 기다려 주세요...",
    "एक मिनट..."
  ];

  // Initialize a random number generator
  final Random random = Random();

  // Method to get a random loading message
  String getRandomLoadingMessage() {
    return loadingMessages[random.nextInt(loadingMessages.length)];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Spacer to push content down (10% of screen height)
          SizedBox(height: MediaQuery.of(context).size.height * 0.051),

          // 'CATEGORY' Title with individual padding
          Padding(
            padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                widget.category.toUpperCase(),
                style: const TextStyle(
                    fontSize: 32.0, fontWeight: FontWeight.normal),
              ),
            ),
          ),

          // Filter Buttons and Loading/Text with individual padding
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: Column(
              children: [
                Row(
                  children: [
                    // Brand Filter Button
                    Expanded(
                      child: Container(
                        height: 40,
                        // Removed margin to eliminate spacing around buttons
                        decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.black,
                              width: _selectedBrands.isNotEmpty ? 2.0 : 1.0,
                            ),
                            color: _selectedBrands.isNotEmpty
                                ? Colors.black12
                                : Colors.transparent),
                        child: TextButton(
                          onPressed: isLoading
                              ? null
                              : () => _showBrandPicker(context),
                          child: Text(
                            "BRAND",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16.0,
                              fontWeight: _selectedBrands.isNotEmpty
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 4.0), // Small spacing between buttons

                    // Color Filter Button
                    Expanded(
                      child: Container(
                        height: 40,
                        // Removed margin to eliminate spacing around buttons
                        decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.black,
                              width: _selectedColors.isNotEmpty ? 2.0 : 1.0,
                            ),
                            color: _selectedColors.isNotEmpty
                                ? Colors.black12
                                : Colors.transparent),
                        child: TextButton(
                          onPressed: isLoading
                              ? null
                              : () => _showColorPicker(context),
                          child: Text(
                            "COLOR",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16.0,
                              fontWeight: _selectedColors.isNotEmpty
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 4.0), // Small spacing between buttons

                    // Type Filter Button
                    Expanded(
                      child: Container(
                        height: 40,
                        // Removed margin to eliminate spacing around buttons
                        decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.black,
                              width: _selectedSubTypes.isNotEmpty ? 2.0 : 1.0,
                            ),
                            color: _selectedSubTypes.isNotEmpty
                                ? Colors.black12
                                : Colors.transparent),
                        child: TextButton(
                          onPressed:
                              isLoading ? null : () => _showTypePicker(context),
                          child: Text(
                            "TYPE",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16.0,
                              fontWeight: _selectedSubTypes.isNotEmpty
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8.0),

                // Display loading message or items found
                Text(
                  _filteredClothingItems == null
                      ? getRandomLoadingMessage()
                      : '${_filteredClothingItems!.length} ITEMS FOUND',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),

          // Expanded GridView without universal padding
          Expanded(
            child: _filteredClothingItems == null
                ? const Center(child: LoadingCircle())
                : _filteredClothingItems!.isEmpty
                    ? const Center(
                        child: Text(
                          'NO ITEMS FOUND',
                          style: TextStyle(
                            fontSize: 16.0,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    : GridView.builder(
  padding: EdgeInsets.zero, // Removed universal padding
  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    childAspectRatio: 0.75,
    crossAxisSpacing: 0, // Removed horizontal spacing
    mainAxisSpacing: 4, // Optional: minimal vertical spacing
  ),
  itemCount: _filteredClothingItems!.length,
  itemBuilder: (context, index) {
    final item = _filteredClothingItems![index];
    final imageUrl = item['imageUrl'] ?? '';
    final brand = item['brand'] ?? "Unknown";
    final subType = item['subType'] ?? "Unknown";

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 500 + (index * 100)), // Staggered duration
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value, // Fade effect
          child: Transform.translate(
            offset: Offset(50 * (1 - value), 0), // Slide from right to original position
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: () {
          // Pass the item details to the FullScreenImagePage
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => FullScreenImagePage(
                itemData: item.data() as Map<String, dynamic>,
                itemId: item.id,
                category: widget.category,
                subCategory: item['subType'] ?? '',
              ),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.transparent),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.contain,
                        width: double.infinity,
                      )
                    : Container(
                        color: Colors.grey[300],
                      ),
              ),
              // Grey partition line
              Container(
                height: 1,
                color: Colors.transparent,
              ),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text(
                  '${brand.toUpperCase()} ${subType.toUpperCase()}',
                  style: const TextStyle(
                    fontSize: 12.0,
                    fontWeight: FontWeight.normal,
                    color: Colors.black,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.left,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  },
)
          ),
        ],
      ),
    );
  }
}
