import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/video_post_screen.dart';
import 'screens/story_upload_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/payment_screen.dart';
import 'package:provider/provider.dart';
import 'services/media_storage_service.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => MediaStorageService(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VidShare',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
        fontFamily: 'Roboto',
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/video_post': (context) => VideoPostScreen(),
        '/story_upload': (context) => const StoryUploadScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/payment': (context) => const PaymentScreen(),
      },
    );
  }
}
