import 'package:closetly/auth/providers/auth_provider.dart';
import 'package:closetly/home/screens/helper_home/clothing_category_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart'; // Added for location
import 'package:http/http.dart' as http; // Added for HTTP requests
import 'dart:convert'; // Added for JSON decoding

import '../helper_home/add_clothing_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  String? _cityName;
  String? _weatherDescription;
  double? _temperature;
  String? _country;

  // AnimationController for "New Drop" box
  late AnimationController _newDropAnimationController;
  late Animation<double> _newDropFadeAnimation;

  // List of categories
  final List<String> _categories = [
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

  // List to track visibility of each chip
  late List<bool> _chipVisibility;

  // AnimationController for blinking "FETCHING WEATHER..."
  late AnimationController _weatherBlinkController;
  late Animation<double> _weatherBlinkAnimation;

  // State variable to track if weather is being fetched
  bool isFetchingWeather = true;

  @override
  void initState() {
    super.initState();
    _fetchLocationAndWeather();

    // Initialize AnimationController for "New Drop" fade-in
    _newDropAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800), // Duration of the fade-in
    );

    _newDropFadeAnimation = CurvedAnimation(
      parent: _newDropAnimationController,
      curve: Curves.easeIn,
    );

    // Start the fade-in animation
    _newDropAnimationController.forward();

    // Initialize chip visibility list
    _chipVisibility = List<bool>.filled(_categories.length, false);

    // Trigger chip animations with staggered delays
    _animateChips();

    // Initialize AnimationController for weather blinking
    _weatherBlinkController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1), // Duration of one blink cycle
    );

    _weatherBlinkAnimation = Tween<double>(
      begin: 1.0, // Fully visible
      end: 0.0, // Fully transparent
    ).animate(
      CurvedAnimation(
        parent: _weatherBlinkController,
        curve: Curves.easeInOut,
      ),
    );

    // Set the animation to repeat indefinitely
    _weatherBlinkController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _newDropAnimationController.dispose();
    _weatherBlinkController.dispose();
    super.dispose();
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

  Future<void> _fetchLocationAndWeather() async {
    try {
      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
        if (permission != LocationPermission.always &&
            permission != LocationPermission.whileInUse) {
          // Permissions are denied, handle appropriately
          setState(() {
            isFetchingWeather = false;
          });
          return;
        }
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.low);

      // Fetch weather data
      await _fetchWeatherData(position.latitude, position.longitude);
    } catch (e) {
      // Handle errors, e.g., show a default city or an error message
      print('Error fetching location and weather: $e');
      setState(() {
        isFetchingWeather = false;
      });
    }
  }

  Future<void> _fetchWeatherData(double lat, double lon) async {
    const apiKey =
        '99811f84eb406787c2488c93210b3b65'; // Replace with your API key
    final url =
        'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&units=metric&appid=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _cityName = data['name'];
          _weatherDescription = data['weather'][0]['description'];
          _temperature = data['main']['temp'];
          _country = data['sys']['country'];
          isFetchingWeather = false; // Data fetched successfully
        });
      } else {
        print('Failed to fetch weather data: ${response.statusCode}');
        setState(() {
          isFetchingWeather = false;
        });
      }
    } catch (e) {
      print('Error fetching weather data: $e');
      setState(() {
        isFetchingWeather = false;
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
            curve: Curves.easeOut, // Easing curve for a natural movement
          ),
        );

        // Define the fade transition
        final fadeTween = Tween<double>(
          begin: 0.0, // Fully transparent
          end: 1.0, // Fully opaque
        ).animate(
          CurvedAnimation(
            parent: animation,
            curve: Curves.easeIn, // Easing curve for a smooth fade
          ),
        );

        // Combine both transitions: slide and fade
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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final userId = ref.watch(userIdProvider);

    return Scaffold(
      body: userId == null
          ? const Center(child: Text("User not authenticated"))
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: screenHeight * 0.06),
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Image.asset(
                      'assets/logo14.png',
                      width: screenWidth * 0.85,
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.05),
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(top: 10.0),
                    child: const Divider(
                      color: Colors.grey,
                      thickness: 1.0,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _temperature != null
                              ? '${_temperature!.toStringAsFixed(1)}°C'
                              : '',
                          style: const TextStyle(
                            fontSize: 26.0,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          _weatherDescription != null
                              ? _weatherDescription!.toUpperCase()
                              : '',
                          style: const TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        isFetchingWeather
                            ? FadeTransition(
                                opacity: _weatherBlinkAnimation,
                                child: const Text(
                                  'FETCHING WEATHER...',
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              )
                            : (_cityName != null && _country != null
                                ? Text(
                                    '${_cityName!.toUpperCase()}, ${_country!.toUpperCase()}',
                                    style: const TextStyle(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  )
                                : const Text(
                                    'WEATHER DATA UNAVAILABLE',
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  )),
                      ],
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          _createRoute(const AddClothingScreen()),
                        );
                      },
                      child: FadeTransition(
                        opacity: _newDropFadeAnimation,
                        child: Container(
                          width: double.infinity,
                          height: screenHeight * 0.35,
                          decoration: BoxDecoration(
                            image: const DecorationImage(
                              image: AssetImage('assets/back7.png'),
                              fit: BoxFit.cover,
                            ),
                            borderRadius: BorderRadius.zero,
                            border: Border.all(color: Colors.black, width: 1.0),
                          ),
                          child: const Align(
                            alignment: Alignment.topLeft,
                            child: Padding(
                              padding: EdgeInsets.only(top: 5.0, left: 8),
                              child: Text(
                                'NEW DROP',
                                style: TextStyle(
                                  fontSize: 22.0,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      'MY COLLECTION',
                      style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Wrap(
                      spacing: 4.0,
                      runSpacing: 4.0,
                      children:
                          List<Widget>.generate(_categories.length, (index) {
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
                          offset: Offset(50 * (1 - value),
                              0), // Moves from right to original position
                          child: child,
                        ),
                      );
                    },
                    child: _buildCategoryChip(context, _categories[index]),)
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // Helper method to create a category chip with custom navigation
  Widget _buildCategoryChip(BuildContext context, String category) {
    final userId = ref.watch(userIdProvider);

    return FilterChip(
      label: Text(
        category.toUpperCase(),
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.normal,
        ),
      ),
      onSelected: (_) {
        Navigator.push(
          context,
          _createRoute(
            ClothingCategoryScreen(userId: userId!, category: category),
          ),
        );
      },
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
        side: BorderSide(
          color: Colors.black,
          width: 1.0,
        ),
      ),
      selected: false,
      selectedColor: Colors.transparent,
      backgroundColor: Colors.transparent,
      showCheckmark: false,
      pressElevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
      labelPadding: const EdgeInsets.symmetric(horizontal: 2.0),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
