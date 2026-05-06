from pathlib import Path
import sys
from urllib.parse import quote

import webview

BASE_DIR = Path(__file__).resolve().parent
FRONTEND_DIR = BASE_DIR / 'assets' / 'milkdown-dist'
window = None


class Api:
    def open_file(self):
        global window
        result = window.create_file_dialog(
            webview.OPEN_DIALOG,
            allow_multiple=False,
            file_types=('Markdown files (*.md;*.markdown)', 'All files (*.*)')
        )
        if not result:
            return None
        path = result[0] if isinstance(result, (list, tuple)) else result
        try:
            with open(path, 'r', encoding='utf-8') as f:
                content = f.read()
            return {'path': path, 'content': content}
        except Exception as e:
            return {'error': str(e)}

    def open_path(self, path):
        if not path:
            return {'error': 'Nenhum caminho de arquivo informado.'}
        try:
            resolved = str(Path(path).resolve())
            with open(resolved, 'r', encoding='utf-8') as f:
                content = f.read()
            return {'path': resolved, 'content': content}
        except Exception as e:
            return {'error': str(e)}

    def save_file(self, payload=None):
        global window
        payload = payload or {}
        path = payload.get('path')
        content = payload.get('content', '')
        if not path:
            result = window.create_file_dialog(
                webview.SAVE_DIALOG,
                save_filename='documento.md',
                file_types=('Markdown files (*.md)', 'All files (*.*)')
            )
            if not result:
                return None
            path = result[0] if isinstance(result, (list, tuple)) else result
        try:
            with open(path, 'w', encoding='utf-8', newline='') as f:
                f.write(content)
            return {'path': path}
        except Exception as e:
            return {'error': str(e)}


def main():
    global window
    index_file = FRONTEND_DIR / 'index.html'
    if not index_file.exists():
        raise FileNotFoundError(f'Arquivo nao encontrado: {index_file}')

    file_arg = None
    if len(sys.argv) > 1:
        file_arg = str(Path(sys.argv[1]).resolve())

    index_uri = index_file.as_uri()
    if file_arg:
        index_uri += '?file=' + quote(file_arg, safe='')

    api = Api()
    window = webview.create_window(
        'Markdown Visual Editor',
        index_uri,
        js_api=api,
        width=1280,
        height=900,
    )
    webview.start(debug=True)


if __name__ == '__main__':
    main()
