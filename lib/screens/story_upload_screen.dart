import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../widgets/bottom_nav_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import '../services/media_storage_service.dart';

class StoryUploadScreen extends StatefulWidget {
  const StoryUploadScreen({Key? key}) : super(key: key);

  @override
  State<StoryUploadScreen> createState() => _StoryUploadScreenState();
}

class _StoryUploadScreenState extends State<StoryUploadScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _allowComments = true;
  String _privacy = 'Public';
  bool _postToFacebook = true;
  bool _postToTwitter = false;
  bool _postToInstagram = true;
  File? _mediaFile;
  bool _isVideo = false;
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _pickMedia(ImageSource source, bool isVideo) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = isVideo
          ? await picker.pickVideo(source: source)
          : await picker.pickImage(source: source);

      if (pickedFile != null) {
        setState(() {
          _mediaFile = File(pickedFile.path);
          _isVideo = isVideo;
        });

        if (isVideo) {
          _initializeVideoPlayer();
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking media: $e')));
    }
  }

  void _initializeVideoPlayer() {
    if (_mediaFile != null && _isVideo) {
      _videoController?.dispose();
      _videoController = VideoPlayerController.file(_mediaFile!)
        ..initialize().then((_) {
          setState(() {
            _isVideoInitialized = true;
          });
        });
    }
  }

  void _togglePlayPause() {
    if (_videoController != null) {
      setState(() {
        if (_videoController!.value.isPlaying) {
          _videoController!.pause();
        } else {
          _videoController!.play();
        }
      });
    }
  }

  void _showMediaOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Photo from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickMedia(ImageSource.gallery, false);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Take a Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickMedia(ImageSource.camera, false);
                },
              ),
              ListTile(
                leading: const Icon(Icons.video_library),
                title: const Text('Video from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickMedia(ImageSource.gallery, true);
                },
              ),
              ListTile(
                leading: const Icon(Icons.videocam),
                title: const Text('Record a Video'),
                onTap: () {
                  Navigator.pop(context);
                  _pickMedia(ImageSource.camera, true);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Story'),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              // Save draft logic
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Draft saved!')));
            },
            child: const Text(
              'Save Draft',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Upload Story',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Media preview
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (_mediaFile != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: _isVideo && _isVideoInitialized
                            ? AspectRatio(
                                aspectRatio:
                                    _videoController!.value.aspectRatio,
                                child: VideoPlayer(_videoController!),
                              )
                            : Image.file(
                                _mediaFile!,
                                width: double.infinity,
                                height: 200,
                                fit: BoxFit.cover,
                              ),
                      )
                    else
                      const Icon(
                        Icons.camera_alt,
                        size: 50,
                        color: Colors.grey,
                      ),

                    if (_isVideo && _mediaFile != null)
                      GestureDetector(
                        onTap: _togglePlayPause,
                        child: CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.white.withOpacity(0.7),
                          child: Icon(
                            _videoController?.value.isPlaying ?? false
                                ? Icons.pause
                                : Icons.play_arrow,
                            size: 40,
                            color: Colors.black,
                          ),
                        ),
                      ),

                    Positioned(
                      bottom: 10,
                      right: 10,
                      child: ElevatedButton(
                        onPressed: _showMediaOptions,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Change Media'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Title
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Description
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                  hintText:
                      'Exploring the vibrant streets and breathtaking landscapes of the city. Every corner holds a new story. #travel #adventure #cityscapes',
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 20),

              // Interaction Settings
              const Text(
                'Interaction Settings',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              // Allow Comments
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Allow Comments', style: TextStyle(fontSize: 16)),
                      Text(
                        'Users can leave comments on your story',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                  Switch(
                    value: _allowComments,
                    onChanged: (value) {
                      setState(() {
                        _allowComments = value;
                      });
                    },
                  ),
                ],
              ),
              const Divider(),

              // Privacy
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Who can watch', style: TextStyle(fontSize: 16)),
                      Text(
                        'Control your audience privacy',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                  DropdownButton<String>(
                    value: _privacy,
                    items: ['Public', 'Friends', 'Only Me']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _privacy = value;
                        });
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Also post on
              const Text(
                'Also post on',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              // Facebook
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.facebook, color: Colors.blue),
                      SizedBox(width: 10),
                      Text('Facebook', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                  Switch(
                    value: _postToFacebook,
                    onChanged: (value) {
                      setState(() {
                        _postToFacebook = value;
                      });
                    },
                  ),
                ],
              ),

              // Twitter
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.flutter_dash, color: Colors.lightBlue),
                      SizedBox(width: 10),
                      Text('Twitter', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                  Switch(
                    value: _postToTwitter,
                    onChanged: (value) {
                      setState(() {
                        _postToTwitter = value;
                      });
                    },
                  ),
                ],
              ),

              // Instagram
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.camera_alt, color: Colors.purple),
                      SizedBox(width: 10),
                      Text('Instagram', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                  Switch(
                    value: _postToInstagram,
                    onChanged: (value) {
                      setState(() {
                        _postToInstagram = value;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // Post Story Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    // Validate inputs
                    if (_mediaFile == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please select a media file'),
                        ),
                      );
                      return;
                    }

                    if (_titleController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter a title')),
                      );
                      return;
                    }

                    // Calculate duration for videos or use a placeholder for images
                    String duration = '00:00';
                    if (_isVideo && _videoController != null) {
                      final videoDuration = _videoController!.value.duration;
                      final minutes = videoDuration.inMinutes
                          .toString()
                          .padLeft(2, '0');
                      final seconds = (videoDuration.inSeconds % 60)
                          .toString()
                          .padLeft(2, '0');
                      duration = '$minutes:$seconds';
                    }

                    // Save the media post
                    await Provider.of<MediaStorageService>(
                      context,
                      listen: false,
                    ).saveMediaPost(
                      mediaFile: _mediaFile!,
                      isVideo: _isVideo,
                      title: _titleController.text,
                      description: _descriptionController.text,
                      duration: duration,
                    );

                    // Show success message
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Story posted successfully!'),
                      ),
                    );
                    Navigator.pushNamed(context, '/');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Post Story',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 1),
    );
  }
}
