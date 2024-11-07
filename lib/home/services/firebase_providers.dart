import 'package:closetly/auth/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final categoryClothingProvider =
    FutureProvider.family<List<Map<String, dynamic>>, Map<String, String>>(
        (ref, params) async {
  final firestore = ref.read(firebaseFirestoreProvider);
  final userId = ref.read(userIdProvider);

  final category = params['category']!;
  final subcategory = params['subcategory']!;

  if (userId == null) {
    return []; // Return an empty list if the user is not authenticated
  }

  final querySnapshot = await firestore
      .collection('users')
      .doc(userId)
      .collection('clothing')
      .doc(category.toLowerCase())
      .collection(subcategory.toLowerCase()) // Access specific subcategory
      .get();

  return querySnapshot.docs.map((doc) => doc.data()).toList();
});

final allCategoryItemsProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>(
        (ref, category) async {
  final firestore = ref
      .read(firebaseFirestoreProvider); // Use the provided Firestore instance
  final userId = ref.read(userIdProvider);

  if (userId == null) {
    return []; // Return an empty list if the user is not authenticated
  }

  final clothingRef = firestore
      .collection('users')
      .doc(userId)
      .collection('clothing')
      .doc(category.toLowerCase());

  // Define your subcategories as per your Firestore structure
  final List<String> subcategories = _getSubCategories(category);

  List<Map<String, dynamic>> allItems = [];

  for (String subcategory in subcategories) {
    final itemsSnapshot =
        await clothingRef.collection(subcategory.toLowerCase()).get();

    allItems.addAll(itemsSnapshot.docs.map((doc) => doc.data()).toList());
  }

  return allItems;
});

// Helper function to get subcategories based on category
List<String> _getSubCategories(String category) {
  final Map<String, List<String>> clothingCategories = {
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

  return clothingCategories[category.toLowerCase()] ?? [];
}
final allItemsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final firestore = ref.read(firebaseFirestoreProvider);
  final userId = ref.read(userIdProvider);

  if (userId == null) {
    return []; // Return an empty list if the user is not authenticated
  }

  final clothingCollectionRef = firestore.collection('users').doc(userId).collection('clothing');

  // Define all subcategories across all categories
  final Map<String, List<String>> clothingCategories = {
    'tops': [
      't-shirts',
      'shirts',
      'polos',
      'sweaters',
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

  List<Map<String, dynamic>> allItems = [];

  // Iterate over all categories and subcategories to fetch items
  for (String category in clothingCategories.keys) {
    List<String> subcategories = clothingCategories[category]!;

    for (String subcategory in subcategories) {
      final querySnapshot = await clothingCollectionRef
          .doc(category.toLowerCase())
          .collection(subcategory.toLowerCase())
          .get();

      allItems.addAll(querySnapshot.docs.map((doc) => doc.data()).toList());
    }
  }

  return allItems;
});