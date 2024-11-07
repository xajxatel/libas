import 'package:closetly/auth/providers/auth_provider.dart';
import 'package:closetly/home/widgets/loading_circle.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';

class AddClothingScreen extends ConsumerStatefulWidget {
  final bool isEditing;
  final Map<String, dynamic>? itemData;
  final String? itemId;
  final String? category;
  final String? subCategory;

  const AddClothingScreen({
    super.key,
    this.isEditing = false,
    this.itemData,
    this.itemId,
    this.category,
    this.subCategory,
  });

  @override
  _AddClothingScreenState createState() => _AddClothingScreenState();
}

class _AddClothingScreenState extends ConsumerState<AddClothingScreen> {
  final String apiKey = 'qghTy2TBMsUeJ2TzWrifosF3';
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  bool _isProcessing = false;
  String? _selectedType;
  String? _selectedSubType;
  String _brand = '';
  String _colorName = 'COLOR';
  Color _selectedColor = Colors.white;
  String _colorHex = '#FFFFFF'; // Default color hex value
  String _price = '';
  String _purchaseYear = '';
  List<String> predefinedBrands = [];

  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _purchaseYearController = TextEditingController();

  final List<Map<String, String>> predefinedColors = [
    {'heading': 'Reds and Pinks'},
    {'name': 'Red', 'hex': '#FF0000'},
    {'name': 'Crimson', 'hex': '#DC143C'},
    {'name': 'Rose Pink', 'hex': '#FF007F'},
    {'name': 'Blush Pink', 'hex': '#FFB6C1'},
    {'name': 'Coral', 'hex': '#FF7F50'},
    {'name': 'Peach', 'hex': '#FFDAB9'},
    {'name': 'Wine', 'hex': '#722F37'},
    {'name': 'Maroon', 'hex': '#800000'},
    {'name': 'Burgundy', 'hex': '#800020'},
    {'heading': 'Oranges and Yellows'},
    {'name': 'Orange', 'hex': '#FFA500'},
    {'name': 'Burnt Orange', 'hex': '#CC5500'},
    {'name': 'Amber', 'hex': '#FFBF00'},
    {'name': 'Rust', 'hex': '#B7410E'},
    {'name': 'Gold', 'hex': '#FFD700'},
    {'name': 'Mustard Yellow', 'hex': '#FFDB58'},
    {'name': 'Lemon', 'hex': '#FFF44F'},
    {'heading': 'Greens'},
    {'name': 'Light Green', 'hex': '#90EE90'},
    {'name': 'Lime Green', 'hex': '#32CD32'},
    {'name': 'Sage Green', 'hex': '#9DC183'},
    {'name': 'Olive Green', 'hex': '#808000'},
    {'name': 'Forest Green', 'hex': '#228B22'},
    {'name': 'Emerald Green', 'hex': '#50C878'},
    {'name': 'Mint Green', 'hex': '#98FF98'},
    {'name': 'Teal', 'hex': '#008080'},
    {'name': 'Jade', 'hex': '#00A36C'},
    {'name': 'Olive Drab', 'hex': '#6B8E23'},
    {'heading': 'Blues'},
    {'name': 'Light Blue', 'hex': '#ADD8E6'},
    {'name': 'Sky Blue', 'hex': '#87CEEB'},
    {'name': 'Cyan', 'hex': '#00FFFF'},
    {'name': 'Turquoise', 'hex': '#40E0D0'},
    {'name': 'Cobalt Blue', 'hex': '#0047AB'},
    {'name': 'Royal Blue', 'hex': '#4169E1'},
    {'name': 'Navy Blue', 'hex': '#000080'},
    {'name': 'Midnight Blue', 'hex': '#191970'},
    {'heading': 'Purples and Lavenders'},
    {'name': 'Lavender', 'hex': '#E6E6FA'},
    {'name': 'Lilac', 'hex': '#C8A2C8'},
    {'name': 'Violet', 'hex': '#8A2BE2'},
    {'name': 'Orchid', 'hex': '#DA70D6'},
    {'name': 'Magenta', 'hex': '#FF00FF'},
    {'name': 'Periwinkle', 'hex': '#CCCCFF'},
    {'name': 'Amethyst', 'hex': '#9966CC'},
    {'name': 'Plum', 'hex': '#DDA0DD'},
    {'heading': 'Neutrals and Browns'},
    {'name': 'Beige', 'hex': '#F5F5DC'},
    {'name': 'Cream', 'hex': '#FFFDD0'},
    {'name': 'Taupe', 'hex': '#483C32'},
    {'name': 'Chocolate Brown', 'hex': '#D2691E'},
    {'name': 'Sienna', 'hex': '#A0522D'},
    {'name': 'Clay', 'hex': '#B66A50'},
    {'name': 'Chestnut', 'hex': '#954535'},
    {'name': 'Charcoal Grey', 'hex': '#36454F'},
    {'name': 'Slate Grey', 'hex': '#708090'},
    {'heading': 'Whites and Blacks'},
    {'name': 'Ivory', 'hex': '#FFFFF0'},
    {'name': 'Off White', 'hex': '#F8F8FF'},
    {'name': 'Pearl', 'hex': '#EAE0C8'},
    {'name': 'Light Grey', 'hex': '#D3D3D3'},
    {'name': 'Grey', 'hex': '#808080'},
    {'name': 'Charcoal', 'hex': '#36454F'},
    {'name': 'Black', 'hex': '#000000'},
    {'name': 'White', 'hex': '#FFFFFF'},
  ];

  @override
  void initState() {
    super.initState();
    _loadBrands();

    if (widget.isEditing && widget.itemData != null) {
      _initializeEditing();
    }
  }

  Future<void> _initializeEditing() async {
    final itemData = widget.itemData!;

    setState(() {
      _selectedImage = null; // Initially, no new image selected
      _selectedType = itemData['type'];
      _selectedSubType = itemData['subType'];
      _brand = itemData['brand'] ?? '';
      _brandController.text = _brand;
      _colorName = itemData['colorName'] ?? 'COLOR';
      _colorHex = itemData['colorHex'] ?? '#FFFFFF';
      _selectedColor = Color(int.parse('0xFF${_colorHex.substring(1)}'));
      _price = itemData['price'] ?? '';
      _priceController.text = _price;
      _purchaseYear = itemData['purchaseYear'] ?? '';
      _purchaseYearController.text = _purchaseYear;
      _categoryController.text = _selectedSubType?.toUpperCase() ?? '';
    });
  }

  void _showDeleteConfirmationDialog() {
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
          'ARE YOU SURE YOU WANT TO DELETE THIS ITEM?',
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
              _deleteClothing(); // Call the delete function
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

  Future<void> _loadBrands() async {
    final userId = ref.read(userIdProvider);
    final firestore = ref.read(firebaseFirestoreProvider);

    // Initialize with predefined brands in uppercase
    List<String> defaultBrands = [
      "FABINDIA",
      "BIBA",
      "MANYAVAR & MOHEY",
      "W FOR WOMEN",
      "GLOBAL DESI",
      "PETER ENGLAND",
      "VAN HEUSEN",
      "ALLEN SOLLY",
      "LOUIS PHILIPPE",
      "RAYMOND",
      "PANTALOONS",
      "MAX FASHION",
      "H&M",
      "ZARA",
      "LEVI'S",
      "U.S. POLO ASSN.",
      "NIKE",
      "ADIDAS",
      "FOREVER 21",
      "JACK & JONES"
    ];

    if (userId == null) return;

    final brandsSnapshot = await firestore
        .collection('users')
        .doc(userId)
        .collection('brands')
        .get();

    // Get brands from Firestore and convert to uppercase
    final firestoreBrands =
        brandsSnapshot.docs.map((doc) => doc.id.toUpperCase()).toList();

    // Merge the predefined brands and firestore brands, avoiding duplicates
    setState(() {
      predefinedBrands = [
        ...defaultBrands,
        ...firestoreBrands.where((brand) => !defaultBrands.contains(brand)),
      ];
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _isProcessing = true;
      });

      // Ask the user if they want to remove the background
      bool removeBackground = await _confirmRemoveBackground();
      if (removeBackground) {
        await _removeBackground(pickedFile.path);
      } else {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }

      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<bool> _confirmRemoveBackground() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
              titlePadding: const EdgeInsets.all(8.0),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero, // Pointy edges
              ),
              title: const Padding(
                padding: const EdgeInsets.all(4.0), // Very low padding
                child: Text(
                  'REMOVE BACKGROUND?',
                  style: TextStyle(
                    fontSize: 16.0,
                  ), // Optional: Adjust font size if needed
                ),
              ),
              content: Padding(
                padding: const EdgeInsets.all(4.0), // Very low padding
                child: Text(
                  'DO YOU WANT TO REMOVE THE BACKGROUND OF THE SELECTED IMAGE?',
                  style: TextStyle(
                      fontSize: 12.0,
                      color: Colors.grey
                          .shade800), // Optional: Adjust font size if needed
                ),
              ),
              actionsPadding: const EdgeInsets.symmetric(
                  horizontal: 8.0, vertical: 4.0), // Very low padding
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.black, // Black text
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 4.0), // Very low padding
                  ),
                  child: Text('NO'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.black, // Black text
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 4.0), // Very low padding
                  ),
                  child: Text('YES'),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  Future<void> _removeBackground(String imagePath) async {
    try {
      final url = Uri.parse('https://api.remove.bg/v1.0/removebg');
      final request = http.MultipartRequest('POST', url)
        ..headers['X-Api-Key'] = apiKey
        ..files.add(await http.MultipartFile.fromPath('image_file', imagePath));

      final response = await request.send();

      if (response.statusCode == 200) {
        final resultBytes = await response.stream.toBytes();
        final tempDir = await getTemporaryDirectory();
        final filePath = '${tempDir.path}/no_bg_image.png';
        File(filePath).writeAsBytesSync(resultBytes);

        setState(() {
          _selectedImage = File(filePath);
        });
      } else {
        _showErrorDialog('Failed to remove background. Please try again.');
      }
    } catch (e) {
      _showErrorDialog('An error occurred. Please try again.');
    }
  }

  Future<void> _deleteClothing() async {
    final userId = ref.read(userIdProvider);
    final firestore = ref.read(firebaseFirestoreProvider);

    if (userId == null ||
        widget.itemId == null ||
        widget.category == null ||
        widget.subCategory == null) {
      _showErrorDialog('Error deleting item. Please try again.');
      return;
    }

    // Start the loading indicator
    setState(() {
      _isProcessing = true;
    });

    try {
      // Reference to the clothing item document
      final clothingDocRef = firestore
          .collection('users')
          .doc(userId)
          .collection('clothing')
          .doc(widget.category!.toLowerCase())
          .collection(widget.subCategory!.toLowerCase())
          .doc(widget.itemId);

      // Fetch the clothing item data
      final clothingDoc = await clothingDocRef.get();
      if (!clothingDoc.exists) {
        _showErrorDialog('Item does not exist.');
        return;
      }

      final clothingData = clothingDoc.data() as Map<String, dynamic>?;
      if (clothingData == null) {
        _showErrorDialog('Item data is corrupted.');
        return;
      }

      // Extract necessary fields
      final String priceStr = clothingData['price'] ?? '0';
      final double price = double.tryParse(priceStr) ?? 0.0;
      final String colorName = clothingData['colorName'] ?? 'unknown';
      final String colorHex = clothingData['colorHex'] ?? '#FFFFFF';
      final String brand = clothingData['brand'] ?? 'unknown';

      // Start Firestore batch
      WriteBatch batch = firestore.batch();

      // 1. Delete the clothing item
      batch.delete(clothingDocRef);

      // 2. References for aggregates
      DocumentReference categoryAggregateRef = firestore
          .collection('users')
          .doc(userId)
          .collection('aggregates')
          .doc('categories')
          .collection('categories')
          .doc(widget.category!.toLowerCase());

      DocumentReference allAggregateRef = firestore
          .collection('users')
          .doc(userId)
          .collection('aggregates')
          .doc('all');

      // 3. Decrement itemCount and totalPrice for the category
      batch.update(categoryAggregateRef, {
        'itemCount': FieldValue.increment(-1),
        'totalPrice': FieldValue.increment(-price),
      });

      // 4. Decrement itemCount and totalPrice for all aggregates
      batch.update(allAggregateRef, {
        'itemCount': FieldValue.increment(-1),
        'totalPrice': FieldValue.increment(-price),
      });

      // 5. Update color count and delete if count reaches zero
      DocumentReference colorDocRef = firestore
          .collection('users')
          .doc(userId)
          .collection('clothing')
          .doc(widget.category!.toLowerCase())
          .collection('colors')
          .doc(colorName.toLowerCase());

      final colorDoc = await colorDocRef.get();
      if (colorDoc.exists) {
        final colorData = colorDoc.data() as Map<String, dynamic>?;
        final int currentColorCount = (colorData?['count'] ?? 1) - 1;

        if (currentColorCount > 0) {
          batch.update(colorDocRef, {'count': currentColorCount});
        } else {
          batch.delete(colorDocRef);
        }
      }

      // 6. Update brand count and delete if count reaches zero
      DocumentReference brandDocRef = firestore
          .collection('users')
          .doc(userId)
          .collection('clothing')
          .doc(widget.category!.toLowerCase())
          .collection('brands')
          .doc(brand.toLowerCase());

      final brandDoc = await brandDocRef.get();
      if (brandDoc.exists) {
        final brandData = brandDoc.data() as Map<String, dynamic>?;
        final int currentBrandCount = (brandData?['count'] ?? 1) - 1;

        if (currentBrandCount > 0) {
          batch.update(brandDocRef, {'count': currentBrandCount});
        } else {
          batch.delete(brandDocRef);
        }
      }

      // Commit the batch
      await batch.commit();

      // Show success message
      Navigator.of(context).popUntil((route) => route.isFirst);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'ITEM DELETED',
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
    } catch (e) {
      _showErrorDialog('Failed to delete item. Please try again.');
    } finally {
      // Stop the loading indicator
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _uploadClothing() async {
    // 1. Validation Checks
    if (_selectedImage == null && !widget.isEditing) {
      _showErrorDialog('PLEASE SELECT AN IMAGE');
      return;
    }
    if (_selectedType == null || _selectedSubType == null || _brand.isEmpty) {
      _showErrorDialog('PLEASE COMPLETE ALL THE FIELDS');
      return;
    }
    if (_price.isEmpty) {
      _showErrorDialog('INVALID AMOUNT');
      return;
    }
    if (_colorName == 'COLOR') {
      _showErrorDialog('PLEASE CHOOSE A COLOR');
      return;
    }
    if (_purchaseYear.isEmpty) {
      _showErrorDialog('INVALID YEAR');
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final userId = ref.read(userIdProvider);
      final firebaseStorage = ref.read(firebaseStorageProvider);
      final firestore = ref.read(firebaseFirestoreProvider);

      if (userId == null) {
        _showErrorDialog('User not authenticated');
        return;
      }

      String imageUrl = '';

      // 2. Upload Image if a new one is selected
      if (_selectedImage != null) {
        final storageRef = firebaseStorage.ref().child(
            'users/$userId/clothing/${_selectedType!.toLowerCase()}/${_selectedSubType!.toLowerCase()}/${DateTime.now().toIso8601String()}');
        await storageRef.putFile(_selectedImage!);
        imageUrl = await storageRef.getDownloadURL();
      } else if (widget.isEditing) {
        // Retain the old image URL if editing and no new image is selected
        imageUrl = widget.itemData?['imageUrl'] ?? '';
      }

      // 3. Parse the new price to double for aggregate calculations
      double newPrice = double.tryParse(_price) ?? 0.0;

      // 4. Prepare the clothing item data with 'price' as a String
      final clothingData = {
        'imageUrl': imageUrl,
        'type': _selectedType,
        'subType': _selectedSubType,
        'brand': _brand,
        'colorHex': _colorHex,
        'colorName': _colorName,
        'price': _price, // Store as String
        'purchaseYear': _purchaseYear,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // 5. Reference paths for the new clothing item
      final clothingCollectionRef = firestore
          .collection('users')
          .doc(userId)
          .collection('clothing')
          .doc(_selectedType!.toLowerCase())
          .collection(_selectedSubType!.toLowerCase());

      // 6. Add new clothing item
      final newDocRef = await clothingCollectionRef.add(clothingData);

      // 7. Variables to hold old data if editing
      String? oldCategory = widget.category?.toLowerCase();
      String? oldSubCategory = widget.subCategory?.toLowerCase();
      double oldPrice = 0.0;
      String? oldBrand;
      String? oldColorName;
      String? oldColorHex;

      if (widget.isEditing && widget.itemId != null) {
        // Ensure category and subCategory are not null in editing mode
        if (oldCategory == null || oldSubCategory == null) {
          _showErrorDialog('Invalid category or subcategory for editing.');
          return;
        }

        // Retrieve old price from widget.itemData
        var oldPriceValue = widget.itemData?['price'];
        if (oldPriceValue is num) {
          oldPrice = oldPriceValue.toDouble();
        } else if (oldPriceValue is String) {
          oldPrice = double.tryParse(oldPriceValue) ?? 0.0;
        } else {
          oldPrice = 0.0;
        }

        // Retrieve old brand and color
        oldBrand = widget.itemData?['brand'];
        oldColorName = widget.itemData?['colorName'];
        oldColorHex = widget.itemData?['colorHex'];

        // Delete the old clothing item
        final oldDocRef = firestore
            .collection('users')
            .doc(userId)
            .collection('clothing')
            .doc(oldCategory)
            .collection(oldSubCategory)
            .doc(widget.itemId);
        await oldDocRef.delete();
      }

      // 8. Start Firestore batch for aggregate updates
      WriteBatch batch = firestore.batch();

      // References for aggregates
      DocumentReference newCategoryAggregateRef = firestore
          .collection('users')
          .doc(userId)
          .collection('aggregates')
          .doc('categories')
          .collection('categories')
          .doc(_selectedType!.toLowerCase());

      DocumentReference allAggregateRef = firestore
          .collection('users')
          .doc(userId)
          .collection('aggregates')
          .doc('all');

      if (widget.isEditing && widget.itemId != null) {
        // If editing, subtract old price and item count from old category aggregate
        DocumentReference oldCategoryAggregateRef = firestore
            .collection('users')
            .doc(userId)
            .collection('aggregates')
            .doc('categories')
            .collection('categories')
            .doc(oldCategory!);

        batch.update(oldCategoryAggregateRef, {
          'itemCount': FieldValue.increment(-1),
          'totalPrice': FieldValue.increment(-oldPrice),
        });

        // Also subtract from 'All' aggregate
        batch.update(allAggregateRef, {
          'itemCount': FieldValue.increment(-1),
          'totalPrice': FieldValue.increment(-oldPrice),
        });

        // Decrease count of old color and delete if count reaches zero
        if (oldColorName != null) {
          DocumentReference oldColorDocRef = firestore
              .collection('users')
              .doc(userId)
              .collection('clothing')
              .doc(oldCategory)
              .collection('colors')
              .doc(oldColorName.toLowerCase());

          final oldColorDoc = await oldColorDocRef.get();
          if (oldColorDoc.exists) {
            final oldColorData = oldColorDoc.data() as Map<String, dynamic>?;
            final int currentColorCount = (oldColorData?['count'] ?? 1) - 1;

            if (currentColorCount > 0) {
              batch.update(oldColorDocRef, {'count': currentColorCount});
            } else {
              batch.delete(oldColorDocRef);
            }
          }
        }

        // Decrease count of old brand and delete if count reaches zero
        if (oldBrand != null) {
          DocumentReference oldBrandDocRef = firestore
              .collection('users')
              .doc(userId)
              .collection('clothing')
              .doc(oldCategory)
              .collection('brands')
              .doc(oldBrand.toLowerCase());

          final oldBrandDoc = await oldBrandDocRef.get();
          if (oldBrandDoc.exists) {
            final oldBrandData = oldBrandDoc.data() as Map<String, dynamic>?;
            final int currentBrandCount = (oldBrandData?['count'] ?? 1) - 1;

            if (currentBrandCount > 0) {
              batch.update(oldBrandDocRef, {'count': currentBrandCount});
            } else {
              batch.delete(oldBrandDocRef);
            }
          }
        }
      }

      // Add new price and item count to new category aggregate
      batch.set(
          newCategoryAggregateRef,
          {
            'itemCount': FieldValue.increment(1),
            'totalPrice': FieldValue.increment(newPrice),
          },
          SetOptions(merge: true));

      // Also add to 'All' aggregate
      batch.set(
          allAggregateRef,
          {
            'itemCount': FieldValue.increment(1),
            'totalPrice': FieldValue.increment(newPrice),
          },
          SetOptions(merge: true));

      // Commit the batch
      await batch.commit();

      // 10. Update color count
      final colorDocRef = firestore
          .collection('users')
          .doc(userId)
          .collection('clothing')
          .doc(_selectedType!.toLowerCase())
          .collection('colors')
          .doc(_colorName.toLowerCase());

      await firestore.runTransaction((transaction) async {
        final colorDoc = await transaction.get(colorDocRef);
        if (colorDoc.exists) {
          final colorData = colorDoc.data() as Map<String, dynamic>?;
          final int currentCount = (colorData?['count'] ?? 0) + 1;
          transaction.update(colorDocRef, {'count': currentCount});
        } else {
          transaction.set(colorDocRef, {
            'count': 1,
            'colorName': _colorName,
            'hex': _colorHex,
          });
        }
      });

      // 11. Update brand count
      final brandDocRef = firestore
          .collection('users')
          .doc(userId)
          .collection('clothing')
          .doc(_selectedType!.toLowerCase())
          .collection('brands')
          .doc(_brand.toLowerCase());

      await firestore.runTransaction((transaction) async {
        final brandDoc = await transaction.get(brandDocRef);
        if (brandDoc.exists) {
          final brandData = brandDoc.data() as Map<String, dynamic>?;
          final int currentCount = (brandData?['count'] ?? 0) + 1;
          transaction.update(brandDocRef, {'count': currentCount});
        } else {
          transaction.set(brandDocRef, {'count': 1, 'brandName': _brand});
        }
      });

      // 12. Provide feedback to the user
      Navigator.of(context).popUntil((route) => route.isFirst);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'ADDED TO COLLECTION',
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
    } catch (e) {
      _showErrorDialog('Failed to upload clothing. Please try again.');
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        contentPadding:
            const EdgeInsets.symmetric(vertical: 2.0, horizontal: 8.0),
        titlePadding: const EdgeInsets.all(8.0),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero, // Pointy edges
        ),
        title: const Padding(
          padding: EdgeInsets.all(4.0), // Very low padding
          child: Text(
            'ERROR',
            style: TextStyle(
                fontSize: 16.0), // Optional: Adjust font size if needed
          ),
        ),
        content: Padding(
          padding: const EdgeInsets.all(4.0), // Very low padding
          child: Text(
            message,
            style: TextStyle(
                fontSize: 13.0,
                color: Colors
                    .grey.shade800), // Optional: Adjust font size if needed
          ),
        ),
        actionsPadding: const EdgeInsets.symmetric(
            horizontal: 8.0, vertical: 4.0), // Very low padding
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: Colors.black, // Black text
              padding: const EdgeInsets.symmetric(
                  horizontal: 8.0, vertical: 4.0), // Very low padding
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showColorPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          contentPadding:
              const EdgeInsets.only(bottom: 10, left: 15, right: 10, top: 20),
          titlePadding:
              const EdgeInsets.only(bottom: 10, left: 15, right: 10, top: 20),
          title: const Text('PALETTE'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < predefinedColors.length; i++)
                  if (predefinedColors[i].containsKey('heading')) ...[
                    // Add section heading
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        predefinedColors[i]['heading']!,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    // Display color swatches for the current section
                    Wrap(
                      spacing: 8.0, // Space between color blocks
                      runSpacing: 8.0, // Space between rows of colors
                      children: predefinedColors
                          .skip(i + 1) // Skip heading
                          .takeWhile((color) => color.containsKey('name'))
                          .map((color) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _colorName = color['name']!;
                              _colorHex = color['hex']!;
                              _selectedColor = Color(int.parse(
                                  '0xFF${color['hex']!.substring(1)}'));
                            });
                            Navigator.of(context).pop();
                          },
                          child: Container(
                            width: 45,
                            height: 45,
                            decoration: BoxDecoration(
                              color: Color(int.parse(
                                  '0xFF${color['hex']!.substring(1)}')),
                              borderRadius: BorderRadius.circular(0),
                              border: Border.all(color: Colors.black, width: 1),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
              ],
            ),
          ),
        );
      },
    );
  }

  final Map<String, List<String>> _clothingCategories = {
    'Tops': [
      'T-Shirts',
      'Shirts',
      'Polos',
      
      'Hoodies',
      'Vests',
      'Blouses',
      'Crop Tops',
      'Dress',
      'Short Sleeve Shirts',
      
      'Overshirts'
    ],
    'Outerwear': [
      'Jackets',
      'Coats',
      'Puffers',
      'Gilets',
      'Blazers',
      'Waistcoats'
    ],
    'Bottoms': [
      'Jeans',
      'Trousers',
      'Shorts',
      'Skirts',
      'Cargos',
      'Leggings',
      'Sweatpants',
      'Joggers'
    ],
    'Shoes': [
      'Sneakers',
      'Sandals',
      'Boots',
      'Loafers',
      'Dress Shoes',
      'Flats',
      'Slides' ,
      'Heels',
      'Trainers'
    ],
    'Shades': ['Sunglasses', 'Eyeglasses', 'Goggles'],
    'Head': ['Caps', 'Hats', 'Beanies', 'Headbands'],
    'Dresses': ['Dresses', 'Tops Bodysuits'],
    'Suits': ['Suits', 'Tracksuits'],
    'Knitwear': ['Sweaters', 'Cardigans'],
    'Extras': [
      'Bags',
      'Belts',
      'Scarves',
      'Watches',
      'Jewelry',
      'Wallets',
      'Gloves',
      'Backpacks',
      'Accessories'
    ],
    'Festive': [
      'Sarees',
      'Lehenga Choli',
      'Kurta Pajama',
      'Sherwani',
      'Anarkali Suits',
      'Salwar Kameez',
      'Dhoti Kurta',
      'Palazzo Sets',
      'Gowns',
      'Ethnic Jackets',
      'Bandhgala'
    ]
  };

  void _showCategoryPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero, // Pointy edges
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            String selectedCategory = _selectedType ?? '';
            String selectedSubCategory = _selectedSubType ?? '';

            return Padding(
              padding: MediaQuery.of(context).viewInsets,
              child: Container(
                padding: const EdgeInsets.all(10.0),
                height: 400,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'CATEGORY',
                      style: TextStyle(
                        fontSize: 16.0,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: _clothingCategories.entries.map((entry) {
                            final category = entry.key;
                            final subCategories = entry.value;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  category.toUpperCase(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Wrap(
                                  spacing: 4.0,
                                  runSpacing: 2.0,
                                  children: subCategories.map((subCat) {
                                    final isSelected =
                                        selectedSubCategory == subCat;

                                    return FilterChip(
                                      label: Text(
                                        subCat.toUpperCase(),
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: isSelected
                                              ? FontWeight.bold
                                              : FontWeight.w100,
                                        ),
                                      ),
                                      selected: isSelected,
                                      onSelected: (selected) {
                                        setState(() {
                                          _selectedType = category;
                                          _selectedSubType = subCat;
                                          _categoryController.text =
                                              subCat.toUpperCase();
                                        });
                                        Navigator.pop(context);
                                      },
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.zero,
                                        side: BorderSide(
                                          color: Colors.black,
                                          width: 1.0,
                                        ),
                                      ),
                                      labelStyle:
                                          const TextStyle(color: Colors.black),
                                      showCheckmark: false,
                                      selectedColor: Colors.black12,
                                      backgroundColor: Colors.transparent,
                                      pressElevation: 0,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 4.0, vertical: 2.0),
                                      labelPadding: const EdgeInsets.symmetric(
                                          horizontal: 2.0),
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    );
                                  }).toList(),
                                ),
                                const SizedBox(height: 8.0),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showImageSourceSelection() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero, // Pointy edges
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Photos button
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.zero,
                    color: Colors.transparent,
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: const Text(
                    'PHOTOS',
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              // Camera button
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.zero,
                    color: Colors.transparent,
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: const Text(
                    'CAMERA',
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showBrandPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero, // Pointy edges
      ),
      builder: (context) {
        String searchQuery = '';
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            List<String> filteredBrands = predefinedBrands
                .where((brand) =>
                    brand.toUpperCase().contains(searchQuery.toUpperCase()))
                .toList();

            return Padding(
              padding: MediaQuery.of(context).viewInsets,
              child: Container(
                padding: const EdgeInsets.all(10.0),
                height: 400,
                child: Column(
                  children: [
                    TextField(
                      cursorColor: Colors.grey, // Grey cursor color
                      decoration: InputDecoration(
                        labelText: 'SEARCH BRAND',
                        labelStyle: const TextStyle(color: Colors.grey),
                        isDense: true, // Reduces vertical height
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 10.0,
                            horizontal: 12.0), // Adjust padding as needed
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.zero, // Pointy edges
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.zero,
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setModalState(() {
                              searchQuery = '';
                            });
                          },
                        ),
                      ),
                      onChanged: (value) {
                        setModalState(() {
                          searchQuery = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Wrap(
                          spacing: 4.0,
                          runSpacing: 2.0,
                          children: filteredBrands.map((brandName) {
                            final isSelected =
                                _brand.toUpperCase() == brandName.toUpperCase();
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
                                  _brand = brandName.toUpperCase();
                                  _brandController.text = _brand;
                                });
                                Navigator.pop(context);
                              },
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.zero,
                                side: BorderSide(
                                  color: Colors.black,
                                  width: 1.0,
                                ),
                              ),
                              labelStyle: const TextStyle(color: Colors.black),
                              showCheckmark: false,
                              selectedColor: Colors.black12,
                              backgroundColor: Colors.transparent,
                              pressElevation: 0,
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
                    ),
                    if (filteredBrands.isEmpty && searchQuery.isNotEmpty)
                      ElevatedButton(
                        onPressed: () async {
                          String newBrand = searchQuery.toUpperCase();

                          // Check if the brand already exists
                          if (!predefinedBrands.contains(newBrand)) {
                            setState(() {
                              _brand = newBrand;
                              _brandController.text = _brand;
                              predefinedBrands.add(newBrand);
                            });

                            // Save the new brand to Firestore
                            final userId = ref.read(userIdProvider);
                            final firestore =
                                ref.read(firebaseFirestoreProvider);

                            if (userId != null) {
                              await firestore
                                  .collection('users')
                                  .doc(userId)
                                  .collection('brands')
                                  .doc(newBrand)
                                  .set({'brandName': newBrand});
                            }
                          } else {
                            setState(() {
                              _brand = newBrand;
                              _brandController.text = _brand;
                            });
                          }

                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.black,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                            side: BorderSide(color: Colors.black),
                          ),
                        ),
                        child: Text(
                            "ADD AND SELECT '${searchQuery.toUpperCase()}'"),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Color _getContrastingTextColor(Color bgColor) {
    // Calculate luminance to determine if the text should be black or white
    double luminance =
        (0.299 * bgColor.red + 0.587 * bgColor.green + 0.114 * bgColor.blue) /
            255;
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  // Define the InputDecoration inside the class
  InputDecoration _buildInputDecoration(String labelText, {String? hintText}) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      isDense: true, // Reduces height
      labelStyle: const TextStyle(
        color: Colors.grey,
        fontSize: 12,
        height: 1.0, // Adjust to bring label closer
      ),
      contentPadding:
          const EdgeInsets.only(bottom: 0.0), // Further reduce padding
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.grey, width: 1.0),
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.black, width: 2.0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: screenHeight * 0.035),
                  Padding(
                    padding: const EdgeInsets.only(left: 0.0, bottom: 8.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        widget.isEditing ? 'EDIT ITEM' : 'DROP ITEM',
                        style: const TextStyle(
                            fontSize: 32.0, fontWeight: FontWeight.normal),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () => _showImageSourceSelection(),
                    child: DottedBorder(
                      color: Colors.black,
                      strokeWidth: 1,
                      dashPattern: [4, 4],
                      borderType: BorderType.Rect,
                      child: Container(
                        width: screenWidth * 0.9,
                        height: screenHeight * 0.4,
                        color: Colors.transparent,
                        child: Center(
                          child: _selectedImage != null
                              ? Image.file(_selectedImage!)
                              : (widget.isEditing &&
                                      widget.itemData?['imageUrl'] != null
                                  ? Image.network(widget.itemData!['imageUrl'])
                                  : const Icon(Icons.add,
                                      size: 50, color: Colors.grey)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: GestureDetector(
                          onTap: () => _showBrandPicker(context),
                          child: AbsorbPointer(
                            child: TextField(
                              controller: _brandController,
                              decoration: _buildInputDecoration('BRAND'),
                              cursorColor: Colors.black,
                              textAlignVertical: TextAlignVertical.bottom,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _showColorPicker(context),
                          child: Container(
                            height: 45,
                            decoration: BoxDecoration(
                              color: _selectedColor,
                              borderRadius: BorderRadius.zero,
                              border: Border.all(width: 1, color: Colors.black),
                            ),
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 10.0),
                                child: Text(
                                  _colorName.toUpperCase(),
                                  style: TextStyle(
                                    color: _getContrastingTextColor(
                                        _selectedColor),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _priceController,
                    cursorColor: Colors.black,
                    keyboardType: TextInputType.number,
                    decoration: _buildInputDecoration('PRICE ₹'),
                    textAlignVertical: TextAlignVertical.bottom,
                    onChanged: (value) {
                      final parsedValue = double.tryParse(value);
                      if (parsedValue != null && parsedValue >= 0) {
                        _price = value;
                      } else {
                        _price = '';
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _purchaseYearController,
                    cursorColor: Colors.black,
                    keyboardType: TextInputType.number,
                    decoration: _buildInputDecoration('YEAR OF PURCHASE'),
                    textAlignVertical: TextAlignVertical.bottom,
                    onChanged: (value) {
                      final year = int.tryParse(value) ?? 0;
                      if (year >= 1 && year <= DateTime.now().year) {
                        _purchaseYear = value;
                      } else {
                        _purchaseYear = '';
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () => _showCategoryPicker(context),
                    child: AbsorbPointer(
                      child: TextField(
                        controller: _categoryController,
                        cursorColor: Colors.black,
                        decoration: _buildInputDecoration('CATEGORY',
                            hintText: 'SELECT CATEGORY'),
                        textAlignVertical: TextAlignVertical.bottom,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: _uploadClothing,
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.black,
                            side: const BorderSide(
                                color: Colors.black, width: 1.0),
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero,
                            ),
                            padding: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 16.0),
                          ),
                          child: Text(
                              widget.isEditing ? 'SAVE CHANGES' : 'SAVE ITEM'),
                        ),
                        const SizedBox(width: 10), // Space between buttons
                        if (widget
                            .isEditing) // Show delete button only in editing mode
                          ElevatedButton(
                            onPressed:
                                _showDeleteConfirmationDialog, // Show confirmation dialog
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.black,
                              side: const BorderSide(
                                  color: Colors.black, width: 1.0),
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.zero,
                              ),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 16.0),
                            ),
                            child: const Text('DELETE'),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (_isProcessing)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(
                  child: LoadingCircle(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
