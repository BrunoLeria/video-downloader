class DownloadHistoryItem {
  const DownloadHistoryItem({
    required this.id,
    required this.title,
    required this.platform,
    required this.savedAt,
    required this.fileSizeBytes,
    required this.status,
    required this.filePath,
    required this.url,
  });

  final int? id;
  final String title;
  final String platform;
  final DateTime savedAt;
  final int fileSizeBytes;
  final String status;
  final String filePath;
  final String url;

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'platform': platform,
        'savedAt': savedAt.toIso8601String(),
        'fileSizeBytes': fileSizeBytes,
        'status': status,
        'filePath': filePath,
        'url': url,
      };

  factory DownloadHistoryItem.fromMap(Map<String, dynamic> map) {
    return DownloadHistoryItem(
      id: map['id'] as int?,
      title: map['title'] as String? ?? 'Sem título',
      platform: map['platform'] as String? ?? 'unknown',
      savedAt: DateTime.tryParse(map['savedAt'] as String? ?? '') ?? DateTime.now(),
      fileSizeBytes: (map['fileSizeBytes'] as num?)?.toInt() ?? 0,
      status: map['status'] as String? ?? 'completed',
      filePath: map['filePath'] as String? ?? '',
      url: map['url'] as String? ?? '',
    );
  }
}
