enum SupportedPlatform { youtube, instagram, generic, unsupported }

class MediaInfo {
  const MediaInfo({
    required this.platform,
    required this.title,
    required this.author,
    required this.thumbnail,
    required this.duration,
    required this.originalUrl,
  });

  final SupportedPlatform platform;
  final String title;
  final String author;
  final String thumbnail;
  final Duration duration;
  final String originalUrl;

  Map<String, dynamic> toJson() => {
        'platform': platform.name,
        'title': title,
        'author': author,
        'thumbnail': thumbnail,
        'durationSeconds': duration.inSeconds,
        'originalUrl': originalUrl,
      };

  factory MediaInfo.fromJson(Map<String, dynamic> json) {
    return MediaInfo(
      platform: SupportedPlatform.values.firstWhere(
        (element) => element.name == (json['platform'] as String? ?? 'unsupported'),
        orElse: () => SupportedPlatform.unsupported,
      ),
      title: json['title'] as String? ?? 'Sem título',
      author: json['author'] as String? ?? 'Desconhecido',
      thumbnail: json['thumbnail'] as String? ?? '',
      duration: Duration(seconds: (json['durationSeconds'] as num?)?.toInt() ?? 0),
      originalUrl: json['originalUrl'] as String? ?? '',
    );
  }
}
