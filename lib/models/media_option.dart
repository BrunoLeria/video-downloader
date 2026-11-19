enum MediaType { video, audio, videoAudio }

class MediaOption {
  const MediaOption({
    required this.type,
    required this.format,
    required this.quality,
    required this.url,
    this.estimatedBytes,
    this.sizeLabel,
  });

  final MediaType type;
  final String format;
  final String quality;
  final String url;
  final int? estimatedBytes;
  final String? sizeLabel;

  String get label => '${quality.isNotEmpty ? quality : 'Padrão'} • $format';

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'format': format,
        'quality': quality,
        'url': url,
        'estimatedBytes': estimatedBytes,
        'sizeLabel': sizeLabel,
      };

  factory MediaOption.fromJson(Map<String, dynamic> json) {
    return MediaOption(
      type: MediaType.values.firstWhere(
        (element) => element.name == (json['type'] as String? ?? 'video'),
        orElse: () => MediaType.video,
      ),
      format: json['format'] as String? ?? 'mp4',
      quality: json['quality'] as String? ?? '720p',
      url: json['url'] as String? ?? '',
      estimatedBytes: (json['estimatedBytes'] as num?)?.toInt(),
      sizeLabel: json['sizeLabel'] as String?,
    );
  }
}
