import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:intl/intl.dart';
import 'add_clothing_screen.dart'; // Import the AddClothingScreen

class FullScreenImagePage extends StatelessWidget {
  final Map<String, dynamic> itemData;
  final String itemId; // Add itemId to identify the document
  final String category; // Add category and subCategory to locate the document
  final String subCategory;

  const FullScreenImagePage({
    super.key,
    required this.itemData,
    required this.itemId,
    required this.category,
    required this.subCategory,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = itemData['imageUrl'] ?? '';
    final brand = itemData['brand'] ?? 'Unknown';
    final subType = itemData['subType'] ?? 'Unknown';
    final purchaseYear = itemData['purchaseYear'] ?? 'Unknown';
    final price = itemData['price'] ?? 'Unknown';
    final color = itemData['colorName'] ?? 'Unknown';

    // Format the price with commas if it's a valid number
    final formattedPrice = int.tryParse(price) != null
        ? NumberFormat('#,##0').format(int.parse(price))
        : price;

    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Align text to the left
        children: [
          // Row with ITEM INFO and EDIT button
          SizedBox(height: screenHeight * 0.08),
          Padding(
            padding:
                const EdgeInsets.only(left: 15.0, right: 15.0, bottom: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'ITEM INFO',
                  style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.w500),
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to AddClothingScreen in edit mode
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddClothingScreen(
                          isEditing: true,
                          itemData: itemData,
                          itemId: itemId,
                          category: category,
                          subCategory: subCategory,
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    'EDIT',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 22.0,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Image with zoom functionality
          Expanded(
            flex: 5,
            child: imageUrl.isNotEmpty
                ? PhotoView(
                    imageProvider: NetworkImage(imageUrl),
                    backgroundDecoration:
                        const BoxDecoration(color: Colors.white),
                  )
                : Container(color: Colors.grey[300]),
          ),
          // Grey partition line
          Container(
            height: 1,
            color: Colors.grey,
          ),
          // Details section
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${brand.toUpperCase()} ${subType.toUpperCase()}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'PRICE: ₹ $formattedPrice',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'COLOR: $color',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'PURCHASED ON: $purchaseYear',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
