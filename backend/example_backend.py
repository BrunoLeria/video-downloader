import json
import sys
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

import yt_dlp


class Handler(BaseHTTPRequestHandler):
    media_cache = {}

    def do_POST(self):
        try:
            length = int(self.headers.get('Content-Length', 0))
            payload = self.rfile.read(length)
            data = json.loads(payload.decode('utf-8'))
            url = data.get('url', '').strip()
            mode = data.get('mode', 'info')

            if not url:
                self._send_json({'error': 'URL não informada.'}, 400)
                return

            media = self.media_cache.get(url)
            if media is None:
                ydl_opts = {
                    'quiet': True,
                    'no_warnings': True,
                    'noplaylist': True,
                    'socket_timeout': 60,
                    'retries': 2,
                    'fragment_retries': 2,
                }
                with yt_dlp.YoutubeDL(ydl_opts) as ydl:
                    media = ydl.extract_info(url, download=False)
                self.media_cache[url] = media

            if mode == 'options':
                options = self._build_options(media)
                self._send_json({'options': options})
                return

            thumbnails = media.get('thumbnails') or []
            thumbnail = media.get('thumbnail') or (
                thumbnails[-1].get('url', '') if thumbnails else ''
            )
            self._send_json({
                'title': media.get('title') or 'Mídia sem título',
                'author': media.get('uploader') or media.get('channel') or 'Desconhecido',
                'thumbnail': thumbnail,
                'durationSeconds': int(media.get('duration') or 0),
            })
        except Exception as error:
            print(f'Extraction error: {error}', file=sys.stderr)
            self._send_json({'error': str(error)}, 502)

    def _build_options(self, media):
        options = []
        formats = media.get('formats') or []

        for item in formats:
            direct_url = item.get('url', '')
            if not direct_url:
                continue
            if item.get('vcodec') == 'none':
                media_type = 'audio'
                quality = 'Audio'
            else:
                media_type = 'video'
                quality = item.get('format_note') or item.get('resolution') or 'Vídeo'

            estimated = int(item.get('filesize') or item.get('filesize_approx') or 0)
            ext = item.get('ext') or 'mp4'
            options.append({
                'type': media_type,
                'format': ext,
                'quality': quality,
                'estimatedBytes': estimated,
                'sizeLabel': f'{estimated / 1048576:.1f} MB' if estimated else '',
                'url': direct_url,
            })

        if not options and media.get('url'):
            estimated = int(media.get('filesize') or media.get('filesize_approx') or 0)
            options.append({
                'type': 'video',
                'format': media.get('ext') or 'mp4',
                'quality': media.get('format_note') or 'Vídeo',
                'estimatedBytes': estimated,
                'sizeLabel': f'{estimated / 1048576:.1f} MB' if estimated else '',
                'url': media['url'],
            })

        unique = []
        seen = set()
        for option in options:
            if option['url'] not in seen:
                seen.add(option['url'])
                unique.append(option)
        return unique

    def _send_json(self, payload, status=200):
        body = json.dumps(payload).encode('utf-8')
        self.send_response(status)
        self.send_header('Content-Type', 'application/json')
        self.send_header('Content-Length', str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def log_message(self, format, *args):
        return


if __name__ == '__main__':
    server = ThreadingHTTPServer(('0.0.0.0', 8000), Handler)
    print('Servidor backend em http://0.0.0.0:8000')
    server.serve_forever()
