"""Serves the site locally with save endpoints for the scan editor.

    python tools/scan_editor.py [port]        then open http://localhost:8772/?edit

The editor's Save button posts every place's view to /save-views, written to
assets/splats/scan_views.json, and on the room the bulbs clicked on its wall to /save-bulbs
(assets/splats/room_bulbs.json); the page reads those files on load, on the site too once they are pushed.
"""
import http.server
import json
import pathlib
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
OUT = {'/save-views': ROOT / 'assets' / 'splats' / 'scan_views.json',
       '/save-bulbs': ROOT / 'assets' / 'splats' / 'room_bulbs.json'}


class Handler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=str(ROOT), **kwargs)

    def end_headers(self):
        self.send_header('Cache-Control', 'no-store')   # edits show on reload
        super().end_headers()

    def do_POST(self):
        if self.path not in OUT:
            return self.send_error(404)
        data = json.loads(self.rfile.read(int(self.headers['Content-Length'])))
        OUT[self.path].write_text(json.dumps(data, ensure_ascii=False) + '\n', encoding='utf-8')
        self.send_response(200)
        self.end_headers()
        self.wfile.write(b'ok')


if __name__ == '__main__':
    port = int(sys.argv[1]) if len(sys.argv) > 1 else 8772
    print(f'http://localhost:{port}/?edit')
    http.server.ThreadingHTTPServer(('127.0.0.1', port), Handler).serve_forever()
