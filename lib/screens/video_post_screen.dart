import 'package:flutter/material.dart';
import '../widgets/bottom_nav_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';

class VideoPostScreen extends StatelessWidget {
  VideoPostScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'VidShare',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: 3,
        itemBuilder: (context, index) {
          return VideoPostItem(
            username: [
              'CreativeCanvas',
              'ComedyCentral',
              'FoodExplorer',
            ][index],
            category: ['Art', 'Comedy', 'Food'][index],
            caption: [
              'Creating creativity today! #DigitalArt #CreativeProcess',
              'Had a great gathering last night! Thanks for the laughs! #StandupComedy #NightToRemember',
              'Nothing beats a perfectly crafted latte to start the day! #CoffeeTime #LatteArt',
            ][index],
            likes: [155, 240, 98][index],
            comments: [12, 18, 5][index],
            videoPath: [
              '/Users/ravindrasirvi/Desktop/NYMRA_Sample/nymra_project/art.mp4',
              '/Users/ravindrasirvi/Desktop/NYMRA_Sample/nymra_project/comedy.mp4',
              '/Users/ravindrasirvi/Desktop/NYMRA_Sample/nymra_project/food.mp4',
            ][index],
            thumbnailUrl: [
              'https://images.unsplash.com/photo-1513364776144-60967b0f800f?ixlib=rb-1.2.1&auto=format&fit=crop&w=1351&q=80',
              'https://images.unsplash.com/photo-1527224538127-2104bb71c51b?ixlib=rb-1.2.1&auto=format&fit=crop&w=1351&q=80',
              'https://images.unsplash.com/photo-1497636577773-f1231844b336?ixlib=rb-1.2.1&auto=format&fit=crop&w=1351&q=80',
            ][index],
          );
        },
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
    );
  }
}

class VideoPostItem extends StatefulWidget {
  final String username;
  final String category;
  final String caption;
  final int likes;
  final int comments;
  final String videoPath;
  final String thumbnailUrl;

  const VideoPostItem({
    Key? key,
    required this.username,
    required this.category,
    required this.caption,
    required this.likes,
    required this.comments,
    required this.videoPath,
    required this.thumbnailUrl,
  }) : super(key: key);

  @override
  State<VideoPostItem> createState() => _VideoPostItemState();
}

class _VideoPostItemState extends State<VideoPostItem> {
  late int likesCount;
  bool isLiked = false;
  late VideoPlayerController _videoController;
  TextEditingController commentController = TextEditingController();

  bool _isVideoInitialized = false;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    likesCount = widget.likes;
    _initializeVideoPlayer();
  }

  void _initializeVideoPlayer() {
    _videoController = VideoPlayerController.file(File(widget.videoPath))
      ..initialize().then((_) {
        setState(() {
          _isVideoInitialized = true;
        });
      });
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  void _toggleLike() {
    setState(() {
      if (isLiked) {
        likesCount--;
      } else {
        likesCount++;
      }
      isLiked = !isLiked;
    });
  }

  void _togglePlayPause() {
    setState(() {
      if (_videoController.value.isPlaying) {
        _videoController.pause();
        _isPlaying = false;
      } else {
        _videoController.play();
        _isPlaying = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User info header
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.grey[300],
              child: Text(widget.username[0]),
            ),
            title: Text(
              widget.username,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('in ${widget.category}'),
            trailing: IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () {},
            ),
          ),

          // Video player with thumbnail
          Stack(
            alignment: Alignment.center,
            children: [
              if (_isVideoInitialized)
                AspectRatio(
                  aspectRatio: _videoController.value.aspectRatio,
                  child: VideoPlayer(_videoController),
                )
              else
                CachedNetworkImage(
                  imageUrl: widget.thumbnailUrl,
                  height: 250,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    height: 250,
                    width: double.infinity,
                    color: Colors.grey[300],
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 250,
                    width: double.infinity,
                    color: Colors.grey[300],
                    child: const Center(child: Icon(Icons.error)),
                  ),
                ),
              GestureDetector(
                onTap: _isVideoInitialized ? _togglePlayPause : null,
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white.withOpacity(0.7),
                  child: Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                    size: 40,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),

          // Action buttons
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        color: isLiked ? Colors.red : null,
                      ),
                      onPressed: _toggleLike,
                    ),
                    Text('$likesCount'),
                    const SizedBox(width: 16),
                    IconButton(
                      icon: const Icon(Icons.comment_outlined),
                      onPressed: () {},
                    ),
                    Text('${widget.comments}'),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.share_outlined),
                  onPressed: () {},
                ),
              ],
            ),
          ),

          // Caption
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Text(widget.caption),
          ),

          // Comments section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.grey[300],
                  child: const Text('Me'),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: commentController,
                    decoration: InputDecoration(
                      hintText: 'Add a comment...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    setState(() {
                      commentController.clear();
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Comment posted!'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
