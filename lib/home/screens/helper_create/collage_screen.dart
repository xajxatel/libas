import 'package:closetly/auth/providers/auth_provider.dart';
import 'package:closetly/home/widgets/loading_circle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CollageScreen extends ConsumerStatefulWidget {
  final Map<String, List<Map<String, dynamic>>> selectedItems;

  const CollageScreen({super.key, required this.selectedItems});

  @override
  _CollageScreenState createState() => _CollageScreenState();
}

class _CollageScreenState extends ConsumerState<CollageScreen> {
  String? selectedCategory;
  bool isSaving = false;
  final TextEditingController _outfitNameController =
      TextEditingController(); // Controller for outfit name

  final List<String> outfitCategories = [
    'Everyday',
    'Outing',
    'Date',
    'Formal',
    'Ethnic',
  ];

  final List<String> itemOrder = [
    'Head',
    'Shades',
    'Outerwear',
    'Knitwear',
    'Tops',
    'Festive',
    'Bottoms',
    'Shoes',
    'Extras'
  ];

  InputDecoration _buildInputDecoration(String labelText, {String? hintText}) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      isDense: true,
      labelStyle: const TextStyle(
        color: Colors.grey,
        fontSize: 14,
        height: 1.0,
      ),
      hintStyle: const TextStyle(
        color: Colors.grey,
        fontSize: 14,
        height: 1.0,
      ),
      contentPadding: const EdgeInsets.only(bottom: 0.0),
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.grey, width: 1.0),
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.black, width: 2.0),
      ),
    );
  }

  void _saveCollage() async {
    if (selectedCategory == null) {
      _showDialog(
        "NO CATEGORY SELECTED",
        "PLEASE MAKE A SELECTION TO SAVE YOUR OUTFIT",
      );
      return;
    }

    final userId = ref.read(userIdProvider);
    if (userId == null) {
      _showDialog(
        "USER NOT AUTHENTICATED",
        "PLEASE LOG IN TO SAVE YOUR OUTFIT",
      );
      return;
    }

    List<String> imageUrls = [];
    itemOrder.forEach((category) {
      if (widget.selectedItems[category] != null) {
        for (var item in widget.selectedItems[category]!) {
          if (item['imageUrl'] != null) {
            imageUrls.add(item['imageUrl']);
          }
        }
      }
    });

    if (imageUrls.isEmpty) {
      _showDialog(
        "NO IMAGES TO SAVE",
        "PLEASE SELECT AT LEAST ONE ITEM TO SAVE YOUR OUTFIT",
      );
      return;
    }

    if (_outfitNameController.text.isEmpty) {
      _showDialog(
        "NO OUTFIT NAME",
        "PLEASE PROVIDE A NAME FOR YOUR OUTFIT",
      );
      return;
    }

    setState(() => isSaving = true);

    final firestore = ref.read(firebaseFirestoreProvider);
    await firestore.collection('users').doc(userId).collection('outfits').add({
      'category': selectedCategory,
      'images': imageUrls,
      'outfitName': _outfitNameController.text.trim(), // Save outfit name
      'timestamp': FieldValue.serverTimestamp(),
    });

    setState(() => isSaving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'OUTFIT SAVED SUCCESSFULLY',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(0),
      ),
    );

    Navigator.of(context).pop();
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

  @override
  Widget build(BuildContext context) {
    int totalItems = itemOrder.fold(
        0,
        (count, category) =>
            count + (widget.selectedItems[category]?.length ?? 0));
    int crossAxisCount = 2;
    int rowCount = (totalItems / crossAxisCount).ceil();
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: isSaving
          ? const Center(
              child: LoadingCircle()) // Show LoadingCircle while saving
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: screenHeight * 0.05),
                const Padding(
                  padding: EdgeInsets.only(left: 8.0, bottom: 8.0),
                  child: Text(
                    'PREVIEW',
                    style: TextStyle(
                        fontSize: 36.0, fontWeight: FontWeight.normal),
                  ),
                ),
                SizedBox(height: screenHeight * 0.022),

                // Outfit Name TextField
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: TextField(
                    controller: _outfitNameController,
                    decoration: _buildInputDecoration('Outfit Name',
                        hintText: 'Enter a name for this outfit'),
                    cursorColor: Colors.black, // Set cursor color to grey
                  ),
                ),
                const SizedBox(height: 12.0),

                // Category Chips
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Wrap(
                    spacing: 4.0,
                    runSpacing: 2.0,
                    children: outfitCategories.map((category) {
                      final isSelected = selectedCategory == category;
                      return FilterChip(
                        label: Text(
                          category.toUpperCase(),
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
                            selectedCategory = selected ? category : null;
                          });
                        },
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                          side: BorderSide(color: Colors.black, width: 1.0),
                        ),
                        backgroundColor: Colors.transparent,
                        selectedColor: Colors.black12,
                        showCheckmark: false,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4.0, vertical: 2.0),
                        labelPadding:
                            const EdgeInsets.symmetric(horizontal: 2.0),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 30.0),

                Expanded(
                  child: GridView.builder(
                    padding: EdgeInsets.zero,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: totalItems,
                    itemBuilder: (context, index) {
                      List<Map<String, dynamic>> orderedItems = [];
                      itemOrder.forEach((category) {
                        if (widget.selectedItems[category] != null) {
                          orderedItems.addAll(widget.selectedItems[category]!);
                        }
                      });
                      final item = orderedItems[index];
                      final imageUrl = item['imageUrl'] ?? '';

                      int row = index ~/ crossAxisCount;
                      int column = index % crossAxisCount;
                      bool isFirstInRow = column == 0;
                      bool isLastInRow = column == crossAxisCount - 1;

                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          border: Border(
                            top: const BorderSide(
                                color: Colors.grey, width: 1.0),
                            bottom: const BorderSide(
                                color: Colors.grey, width: 1.0),
                            left: isFirstInRow
                                ? BorderSide.none
                                : const BorderSide(
                                    color: Colors.grey, width: 1.0),
                            right: isLastInRow
                                ? BorderSide.none
                                : const BorderSide(
                                    color: Colors.grey, width: 1.0),
                          ),
                        ),
                        child: imageUrl.isNotEmpty
                            ? Image.network(
                                imageUrl,
                                fit: BoxFit.contain,
                              )
                            : Container(
                                color: Colors.grey[300],
                                child: const Icon(Icons.image,
                                    size: 50, color: Colors.white),
                              ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 6.0),
                  child: Center(
                    child: OutlinedButton(
                      onPressed: _saveCollage,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 40),
                        side: const BorderSide(color: Colors.black),
                        backgroundColor: Colors.transparent,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                      child: const Text(
                        'SAVE',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.normal,
                          fontSize: 16.0,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
