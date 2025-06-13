import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/media_post.dart';

class MediaStorageService extends ChangeNotifier {
  List<MediaPost> _mediaPosts = [];
  final String _storageKey = 'media_posts';
  bool _isLoaded = false;

  List<MediaPost> get mediaPosts => _mediaPosts;

  Future<void> loadMediaPosts() async {
    if (_isLoaded) return;

    final prefs = await SharedPreferences.getInstance();
    final postsJson = prefs.getStringList(_storageKey) ?? [];

    _mediaPosts = postsJson
        .map((json) => MediaPost.fromJson(jsonDecode(json)))
        .toList();

    // Sort by creation date (newest first)
    _mediaPosts.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    _isLoaded = true;
    notifyListeners();
  }

  Future<void> saveMediaPost({
    required File mediaFile,
    required bool isVideo,
    required String title,
    required String description,
    required String duration,
  }) async {
    // Create a unique ID for the post
    final uuid = Uuid();
    final id = uuid.v4();

    // Get the app's document directory for storing files
    final appDir = await getApplicationDocumentsDirectory();
    final fileName =
        '${id}_${DateTime.now().millisecondsSinceEpoch}${isVideo ? '.mp4' : '.jpg'}';
    final savedFilePath = '${appDir.path}/$fileName';

    // Copy the file to the app's document directory
    await mediaFile.copy(savedFilePath);

    // Create a new MediaPost
    final newPost = MediaPost(
      id: id,
      filePath: savedFilePath,
      isVideo: isVideo,
      title: title,
      description: description,
      createdAt: DateTime.now(),
      views: 0,
      duration: duration,
    );

    // Add to the list
    _mediaPosts.insert(0, newPost);

    // Save to SharedPreferences
    await _saveToPrefs();

    notifyListeners();
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final postsJson = _mediaPosts
        .map((post) => jsonEncode(post.toJson()))
        .toList();

    await prefs.setStringList(_storageKey, postsJson);
  }

  String getFormattedViewCount(int views) {
    if (views >= 1000000) {
      return '${(views / 1000000).toStringAsFixed(1)}M';
    } else if (views >= 1000) {
      return '${(views / 1000).toStringAsFixed(1)}K';
    } else {
      return views.toString();
    }
  }
}
