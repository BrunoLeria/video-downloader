class UrlNormalizer {
  static String normalize(String raw) {
    final value = raw.trim();
    if (value.isEmpty) {
      throw const FormatException('Informe um link válido.');
    }

    final candidate = value.replaceAll(RegExp(r'\s+'), '');
    final parsed = Uri.tryParse(candidate);
    if (parsed == null) {
      throw const FormatException('URL inválida.');
    }

    if (!parsed.hasScheme) {
      return normalize('https://$candidate');
    }

    var uri = parsed.normalizePath();
    final host = uri.host.toLowerCase();

    if (host == 'youtu.be' && uri.pathSegments.isNotEmpty) {
      final firstSegment = uri.pathSegments.first;
      final videoId = firstSegment == 'shorts' && uri.pathSegments.length > 1
          ? uri.pathSegments[1]
          : firstSegment;
      return Uri(
        scheme: 'https',
        host: 'www.youtube.com',
        path: '/watch',
        queryParameters: {'v': videoId},
      ).toString();
    }

    if (host.endsWith('youtube.com')) {
      final pathSegments = uri.pathSegments;
      if (pathSegments.length >= 2 && pathSegments[0] == 'shorts') {
        final videoId = pathSegments[1];
        return Uri(
          scheme: 'https',
          host: 'www.youtube.com',
          path: '/watch',
          queryParameters: {'v': videoId},
        ).toString();
      }
    }

    if (host == 'm.youtube.com' || host == 'music.youtube.com') {
      uri = Uri(
        scheme: 'https',
        host: 'www.youtube.com',
        path: uri.path,
        queryParameters: uri.queryParameters,
      );
      return uri.toString();
    }

    return uri.toString();
  }
}
