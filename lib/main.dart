import 'dart:async';
import 'package:video_player/video_player.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:our_own_project/auth-service/start_auth.dart';
import 'package:our_own_project/firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await dotenv.load(fileName: ".env");
  _requestPermissions();

  //splash screen
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool seenOnboarding = prefs.getBool('seenOnboarding') ?? false;

  //notification
  var initializationSettingsAndroid =
      const AndroidInitializationSettings('@mipmap/ic_launcher');
  var initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      print("📩 Local Notification Clicked: ${response.payload}");
    },
  );

  setupNotifications();

  runApp(MyApp(
    seenOnboarding: seenOnboarding,
  ));
}

Future<void> _requestPermissions() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  print("🟢 Notification permission: ${settings.authorizationStatus}");
}

void setupNotifications() async {
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is for important notifications',
    importance: Importance.max,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
}

class MyApp extends StatelessWidget {
  final bool seenOnboarding;
  const MyApp({super.key, required this.seenOnboarding});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor:
          Colors.transparent, // Set to transparent or your app's color
      statusBarIconBrightness: Brightness.dark, // Icons color: light or dark
    ));

    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Skill Swap',
      theme: ThemeData(
        snackBarTheme: const SnackBarThemeData(
            showCloseIcon: true,
            backgroundColor: Color.fromARGB(255, 116, 71, 149),
            contentTextStyle:
                TextStyle(color: Colors.white, fontFamily: 'Poppins')),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
              side: const BorderSide(
                color: Colors.white,
              ),
              foregroundColor: Colors.white),
        ),

        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Colors.white, // This will change the text color
          ),
        ),

        useMaterial3: true,

        colorScheme: const ColorScheme(
          brightness: Brightness.dark,
          primary: Color.fromARGB(255, 224, 198, 231),
          onPrimary: Colors.white,
          secondary: Color.fromARGB(255, 114, 75, 122),
          onSecondary: Colors.white,
          surface: Color.fromARGB(255, 219, 191, 227),
          onSurface: Colors.white,
          error: Colors.redAccent,
          onError: Colors.white,
        ),

        fontFamily: 'Poppins',

        // dropdownMenuTheme: DropdownMenuThemeData(
        //   menuStyle: MenuStyle(
        //     backgroundColor: WidgetStateProperty.all(Colors.grey[900]),  // Set dropdown menu background color globally
        //     shape: WidgetStateProperty.all(
        //       RoundedRectangleBorder(
        //         borderRadius: BorderRadius.circular(8.0),  // Add border radius
        //         side: BorderSide(
        //           color: Colors.white,  // Add a light white border around the dropdown menu
        //           width: 1.0,
        //         ),
        //       ),
        //     ),
        //   ),
        //   textStyle: (TextStyle(color: Colors.white)), // Text color globally for dropdown items
        // ),

        // tabBarTheme: const TabBarTheme(
        //   labelColor: Color.fromARGB(
        //       255, 74, 47, 95), // Color for the selected tab text
        //   unselectedLabelColor:
        //       Colors.white, // Color for the unselected tab text
        // ),

        inputDecorationTheme: InputDecorationTheme(
          labelStyle: const TextStyle(color: Colors.white), // Label text color
          hintStyle: TextStyle(color: Colors.grey[400]), // Hint text color
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(
                color: Colors.white), // Border color when enabled
            borderRadius: BorderRadius.circular(8.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(
                color: Color.fromARGB(255, 70, 51, 87),
                width: 2.0), // Border color when focused
            borderRadius: BorderRadius.circular(8.0),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: const BorderSide(
                color: Colors.redAccent), // Border color when error occurs
            borderRadius: BorderRadius.circular(8.0),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: const BorderSide(
                color: Colors.redAccent,
                width: 2.0), // Border color when focused and error occurs
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      ),
      home: const IntroScreen(),
    );
  }
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int currentPage = 0;

  final List<Map<String, String>> onboardingData = [
    {
      "image": "assets/01_onboarding_1.png",
      "title": "Discover Useful Resources",
      "description":
          "E-Learning is for everyone. Now is the chance to sign up and receive all the lessons we’ve prepared for education so far.",
    },
    {
      "image": "assets/02_onboarding_2.png",
      "title": "New Profession",
      "description":
          "With us you can get a new profession, learn skills for career development or reconfigure your business.",
    },
    {
      "image": "assets/03_onboarding_3.png",
      "title": "Move Forward",
      "description":
          "We have created a comfortable learning environment so that you always have the motivation to move forward.",
    },
  ];

  void finishOnboarding() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seenOnboarding', true);
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => const StartAuth()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: onboardingData.length,
            onPageChanged: (index) {
              setState(() {
                currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(onboardingData[index]['image']!),
                  const SizedBox(height: 20),
                  Text(
                    onboardingData[index]['title']!,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text(
                      onboardingData[index]['description']!,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              );
            },
          ),
          Positioned(
            top: 40,
            right: 20,
            child: TextButton(
              onPressed: finishOnboarding,
              child: const Text("Skip",
                  style: TextStyle(color: Colors.black, fontSize: 16)),
            ),
          ),
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () {
                if (currentPage == onboardingData.length - 1) {
                  finishOnboarding();
                } else {
                  _controller.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.ease);
                }
              },
              child: Text(currentPage == onboardingData.length - 1
                  ? "Get Started"
                  : "Next"),
            ),
          ),
        ],
      ),
    );
  }
}

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen>
    with TickerProviderStateMixin {
  late VideoPlayerController _controller;
  late AnimationController _animController;
  late AnimationController _layerAnimController;

  late Animation<double> _videoAnim;
  late Animation<double> _layer1Anim;
  late Animation<double> _layer2Anim;
  late Animation<double> _layer3Anim;

  bool _transitioning = false;

  @override
  void initState() {
    super.initState();

    // Initialize the video player
    _controller = VideoPlayerController.asset('assets/intro.mp4')
      ..initialize().then((_) {
        setState(() {}); // Rebuild after video is initialized
        _controller.play();

        // When video finishes, start transition
        _controller.addListener(() {
          if (_controller.value.position >= _controller.value.duration) {
            _startTransition();
          }
        });
      });

    // Animation Controller for layers
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000), // Smooth transition
    );

    // Animation Controller for staggered layers
    _layerAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // Define different movement speeds for layers
    _videoAnim = Tween<double>(begin: 0, end: 1.2).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );

    _layer1Anim = Tween<double>(begin: 0, end: 1.1).animate(
      CurvedAnimation(parent: _layerAnimController, curve: Curves.easeInOut),
    );

    _layer2Anim = Tween<double>(begin: 0, end: 1.05).animate(
      CurvedAnimation(parent: _layerAnimController, curve: Curves.easeInOut),
    );

    _layer3Anim = Tween<double>(begin: 0, end: 1.02).animate(
      CurvedAnimation(parent: _layerAnimController, curve: Curves.easeInOut),
    );
  }

  void _startTransition() {
    if (!_transitioning) {
      setState(() {
        _transitioning = true;
      });

      // Start the animations
      _animController.forward();
      Future.delayed(const Duration(milliseconds: 100),
          () => _layerAnimController.forward());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _animController.dispose();
    _layerAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Stack(
      children: [
        // Your main app screen (final screen after transition)
        const StartAuth(),

        // Layer 3 (Deepest - Appears earlier & moves slower)
        AnimatedBuilder(
          animation: _layer3Anim,
          builder: (context, child) {
            return Positioned(
              top: (_layer3Anim.value - 0.2) *
                  screenHeight *
                  1.3, // Start slightly earlier
              left: 0,
              right: 0,
              height: screenHeight,
              child: Container(color: Colors.pink.shade50),
            );
          },
        ),

// Layer 2 (Middle - Starts earlier than before)
        AnimatedBuilder(
          animation: _layer2Anim,
          builder: (context, child) {
            return Positioned(
              top: (_layer2Anim.value - 0.1) *
                  screenHeight *
                  1.2, // Slightly ahead
              left: 0,
              right: 0,
              height: screenHeight,
              child: Container(color: Colors.blue.shade50),
            );
          },
        ),

// Layer 1 (Closest - Moves faster but still staggered)
        AnimatedBuilder(
          animation: _layer1Anim,
          builder: (context, child) {
            return Positioned(
              top: _layer1Anim.value * screenHeight * 1.1, // Moves normally
              left: 0,
              right: 0,
              height: screenHeight,
              child: Container(color: Colors.grey.shade200),
            );
          },
        ),

        // Video Layer (Main splash screen)
        AnimatedBuilder(
          animation: _videoAnim,
          builder: (context, child) {
            return Positioned(
              top: _videoAnim.value * screenHeight,
              left: 0,
              right: 0,
              height: screenHeight,
              child: Container(
                color: Colors.white,
                child: Center(
                  child: _controller.value.isInitialized
                      ? AspectRatio(
                          aspectRatio: _controller.value.aspectRatio,
                          child: VideoPlayer(_controller),
                        )
                      : const CircularProgressIndicator(), // Shows loading circle at start
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
