import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:video_player/video_player.dart';
import 'firebase_options.dart';
import 'user_model.dart';
import 'login_screen.dart';
import 'package:taskapp/free_map_screen.dart';
import 'package:taskapp/weather_page.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'common_widgets.dart';

// --- NOTIFICATION BACKGROUND HANDLER ---
// Isay top level par hona chahiye
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}

// --- SINGLETON DATABASE SERVICE ---
class FirestoreService {
  FirestoreService._private();
  static final FirestoreService instance = FirestoreService._private();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> addTask(String title) async {
    if (title.isNotEmpty) {
      await _db.collection('tasks').add({
        'title_task': title,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> deleteTask(String docId) async {
    await _db.collection('tasks').doc(docId).delete();
  }

  Stream<QuerySnapshot> getTasks() {
    return _db.collection('tasks')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
}

// --- MAIN FUNCTION ---
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Notification Setup
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await setupNotifications();

  runConstructorTest();
  runApp(const MyApp());
}

// --- SETUP NOTIFICATIONS FUNCTION ---
Future<void> setupNotifications() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    String? token = await messaging.getToken();
    print("##############################################");
    print("FCM_TOKEN: $token"); // Android Studio ke Logcat mein ye search karein
    print("##############################################");
  }
}

void runConstructorTest() {
  print("---------- CONSTRUCTOR TEST START ----------");
  var user1 = UserProfile("Sidra", "Senior Dev", "Working", 3);
  print("Normal User: ${user1.name} is a ${user1.role}");
  print("---------- CONSTRUCTOR TEST END ----------");
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: LoginScreen(),
    );
  }
}

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> with WidgetsBindingObserver {
  final TextEditingController _taskController = TextEditingController();
  late VideoPlayerController _videoController;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Foreground listener: Jab app khuli ho tab message catch karne ke liye
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      if (message.notification != null) {
        print('Message Title: ${message.notification!.title}');
      }
    });

    _videoController = VideoPlayerController.networkUrl(
      Uri.parse('https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4'),
    )..initialize().then((_) {
      setState(() {
        _isInitialized = true;
        _videoController.play();
        _videoController.setLooping(true);
      });
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _videoController.dispose();
    _taskController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    debugPrint("-------------------------------------------");
    debugPrint("📱 APP STATUS CHECK: $state");

    if (state == AppLifecycleState.resumed) {
      if (_isInitialized) {
        _videoController.play();
        debugPrint("✅ STAGE: Active / Foreground (Video Playing)");
      }
    } else if (state == AppLifecycleState.paused) {
      if (_isInitialized) {
        _videoController.pause();
        debugPrint("💤 STAGE: Paused / Background (Video Stopped)");
      }
    } else if (state == AppLifecycleState.inactive) {
      debugPrint("⚠️ STAGE: Inactive (User is leaving or interrupted)");
    } else if (state == AppLifecycleState.hidden) {
      debugPrint("🌑 STAGE: Hidden (App is nSot visible at all)");
    } else if (state == AppLifecycleState.detached) {
      debugPrint("🛑 STAGE: Detached / Closed (App Terminated)");
    }
    debugPrint("-------------------------------------------");
  }

  void _handleAddTask() {
    if (_taskController.text.isNotEmpty) {
      FirestoreService.instance.addTask(_taskController.text);
      _taskController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nexus AI Task & Video"),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blueAccent, Colors.indigoAccent],
                ),
              ),
              child: Center(
                child: Text(
                  'Menu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.map, color: Colors.orangeAccent),
              title: const Text('Free Map'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FreeMapScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.cloud, color: Colors.lightBlueAccent),
              title: const Text('Weather Dekhein'),
              onTap: () async {
                Navigator.pop(context); // Close the drawer
                LocationPermission permission = await Geolocator.requestPermission();
                if (permission != LocationPermission.denied) {
                  Position position = await Geolocator.getCurrentPosition();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WeatherPage(
                        lat: position.latitude,
                        lon: position.longitude,
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            height: 200,
            width: double.infinity,
            color: Colors.black,
            child: _isInitialized
                ? AspectRatio(
              aspectRatio: _videoController.value.aspectRatio,
              child: VideoPlayer(_videoController),
            )
                : const Center(child: CircularProgressIndicator()),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _taskController,
                      decoration: const InputDecoration(
                        hintText: "What do you need to do?",
                        hintStyle: TextStyle(color: Colors.grey),
                        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.blueAccent, Colors.indigoAccent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blueAccent.withOpacity(0.4),
                        spreadRadius: 2,
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.add, color: Colors.white, size: 28),
                    onPressed: _handleAddTask,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, indent: 16, endIndent: 16),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirestoreService.instance.getTasks(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                var docs = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    var doc = docs[index];
                    return TaskCardWidget(
                      taskTitle: doc['title_task'],
                      onDelete: () => FirestoreService.instance.deleteTask(doc.id),
                    );
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