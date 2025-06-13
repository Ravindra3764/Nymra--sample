class MediaPost {
  final String id;
  final String filePath;
  final bool isVideo;
  final String title;
  final String description;
  final DateTime createdAt;
  final int views;
  final String duration;

  MediaPost({
    required this.id,
    required this.filePath,
    required this.isVideo,
    required this.title,
    required this.description,
    required this.createdAt,
    this.views = 0,
    required this.duration,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'filePath': filePath,
      'isVideo': isVideo,
      'title': title,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'views': views,
      'duration': duration,
    };
  }

  factory MediaPost.fromJson(Map<String, dynamic> json) {
    return MediaPost(
      id: json['id'],
      filePath: json['filePath'],
      isVideo: json['isVideo'],
      title: json['title'],
      description: json['description'],
      createdAt: DateTime.parse(json['createdAt']),
      views: json['views'],
      duration: json['duration'],
    );
  }
}
