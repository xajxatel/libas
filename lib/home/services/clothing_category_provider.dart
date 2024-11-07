import 'package:cloud_firestore/cloud_firestore.dart';

class ClothingCategoryProvider {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetches the list of clothing items for a specific category and user
  Future<List<DocumentSnapshot>> fetchClothingItems(
      String userId, String category) async {
    List<DocumentSnapshot> clothingItems = [];
    try {
      // Fetch clothing items for each sub-category in the specified category
      final subCategoryList = getSubCategories(category);
      for (String subCategory in subCategoryList) {
        Query query = _firestore
            .collection('users')
            .doc(userId)
            .collection('clothing')
            .doc(category.toLowerCase())
            .collection(subCategory);
        final snapshot = await query.get();
        clothingItems.addAll(snapshot.docs);
      }
      return clothingItems;
    } catch (e) {
      return [];
    }
  }

  // Fetches the list of brands for a specific category and user
  Future<List<String>> getBrands(String userId, String category) async {
    List<String> brands = [];
    try {
      final brandsCollection = await _firestore
          .collection('users')
          .doc(userId)
          .collection('clothing')
          .doc(category.toLowerCase())
          .collection('brands')
          .get();
      for (var doc in brandsCollection.docs) {
        brands.add((doc['brandName'] as String).toLowerCase());
      }
      return brands;
    } catch (e) {
      return [];
    }
  }

  // Fetches the list of colors for a specific category and user
  Future<List<Map<String, String>>> getColors(
      String userId, String category) async {
    List<Map<String, String>> colors = [];
    try {
      final colorsCollection = await _firestore
          .collection('users')
          .doc(userId)
          .collection('clothing')
          .doc(category.toLowerCase())
          .collection('colors')
          .get();
      for (var doc in colorsCollection.docs) {
        colors.add({
          'name': (doc['colorName'] as String).toLowerCase(),
          'hex': doc['hex'],
        });
      }
      return colors;
    } catch (e) {
      return [];
    }
  }

  // Provides known sub-categories for each category
  List<String> getSubCategories(String category) {
    final Map<String, List<String>> subCategories = {
      'tops': [
        't-shirts',
        'shirts',
        'polos',
        
        'hoodies',
        'vests',
        'blouses',
        'crop tops',
        'dress',
        'short sleeve shirts',
        
        'overshirts'
      ],
      'outerwear': [
        'jackets',
        'coats',
        'puffers',
        'gilets',
        'blazers',
        'waistcoats'
      ],
      'bottoms': [
        'jeans',
        'trousers',
        'shorts',
        'skirts',
        'cargos',
        'leggings',
        'sweatpants',
        'joggers'
      ],
      'shoes': [
        'sneakers',
        'sandals',
        'boots',
        'loafers',
        'dress shoes',
        'flats',
        'slides' ,
        'heels',
        'trainers'
      ],
      'shades': ['sunglasses', 'eyeglasses', 'goggles'],
      'head': ['caps', 'hats', 'beanies', 'headbands'],
      'dresses': ['dresses', 'tops bodysuits'],
      'suits': ['suits', 'tracksuits'],
      'knitwear': ['sweaters', 'cardigans'],
      'extras': [
        'bags',
        'belts',
        'scarves',
        'watches',
        'jewelry',
        'wallets',
        'gloves',
        'backpacks',
        'accessories'
      ],
      'festive': [
        'sarees',
        'lehenga choli',
        'kurta pajama',
        'sherwani',
        'anarkali suits',
        'salwar kameez',
        'dhoti kurta',
        'palazzo sets',
        'gowns',
        'ethnic jackets',
        'bandhgala'
      ]
    };
    return subCategories[category.toLowerCase()] ?? [];
  }

  // Fetches the count for a specific color in the user's clothing data
  Future<int> getColorCount(
      String userId, String category, String colorName) async {
    try {
      final colorDoc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('clothing')
          .doc(category.toLowerCase())
          .collection('colors')
          .doc(colorName.toLowerCase())
          .get();

      if (colorDoc.exists) {
        return colorDoc['count'] ?? 0;
      } else {
        return 0;
      }
    } catch (e) {
      return 0;
    }
  }

  // Fetches the count for a specific brand in the user's clothing data
  Future<int> getBrandCount(
      String userId, String category, String brandName) async {
    try {
      final brandDoc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('clothing')
          .doc(category.toLowerCase())
          .collection('brands')
          .doc(brandName.toLowerCase())
          .get();

      if (brandDoc.exists) {
        return brandDoc['count'] ?? 0;
      } else {
        return 0;
      }
    } catch (e) {
      return 0;
    }
  }
}
