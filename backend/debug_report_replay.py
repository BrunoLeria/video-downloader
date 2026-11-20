import argparse
import json
import sys
from urllib import request


def replay(report_path):
    with open(report_path, 'r', encoding='utf-8') as report_file:
        report = json.load(report_file)

    url = report.get('normalizedUrl') or report.get('originalUrl')
    backend_url = report.get('backendUrl')
    platform = report.get('platform', 'generic')

    if not url or not backend_url:
        raise ValueError('The report is missing normalizedUrl/originalUrl or backendUrl.')

    results = {}
    for mode in ('info', 'options'):
        body = json.dumps({
                'url': url,
                'mode': mode,
                'platform': platform,
            }).encode('utf-8')
        req = request.Request(
            backend_url,
            data=body,
            headers={'Content-Type': 'application/json'},
            method='POST',
        )
        with request.urlopen(req, timeout=90) as response:
            response_body = response.read().decode('utf-8')
            status = response.status
        results[mode] = {
            'status': status,
            'body': json.loads(response_body)
            if response_body.startswith('{')
            else response_body,
        }

    print(json.dumps({
        'reportedAt': report.get('createdAt'),
        'url': url,
        'backendUrl': backend_url,
        'results': results,
    }, ensure_ascii=False, indent=2))


if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        description='Replay an exported Video Downloader debug report.'
    )
    parser.add_argument('report', help='Path to exported debug report JSON')
    args = parser.parse_args()

    try:
        replay(args.report)
    except Exception as error:
        print(f'Replay failed: {error}', file=sys.stderr)
        raise
