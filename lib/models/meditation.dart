class Meditation {
  final int id;
  final String title;
  final String description;
  final String category;
  final int duration;
  final String audioUrl;
  final String imageUrl;

  Meditation({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.duration,
    required this.audioUrl,
    required this.imageUrl,
  });

  factory Meditation.fromJson(Map<String, dynamic> json) {
    // API Laravel : audio_url/image_url en appends, ou media.file_path en fallback
    String audioUrl = json['audio_url']?.toString() ?? '';
    if (audioUrl.isEmpty && json['media'] != null) {
      if (json['media'] is Map) {
        final media = json['media'] as Map<String, dynamic>;
        audioUrl = media['file_path']?.toString() ?? media['url']?.toString() ?? '';
      } else if (json['media'] is List && (json['media'] as List).isNotEmpty) {
        final first = (json['media'] as List).first;
        if (first is Map) {
          final m = first as Map<String, dynamic>;
          audioUrl = m['file_path']?.toString() ?? m['url']?.toString() ?? '';
        }
      }
    }
    if (audioUrl.isNotEmpty) {
      audioUrl = audioUrl.trim();
    }
    return Meditation(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      duration: json['duration'] ?? 0,
      audioUrl: audioUrl,
      imageUrl: json['image_url']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'duration': duration,
      'audio_url': audioUrl,
      'image_url': imageUrl,
    };
  }
}
