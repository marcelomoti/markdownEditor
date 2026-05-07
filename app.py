from pathlib import Path
import sys
import logging

import webview

BASE_DIR = Path(__file__).resolve().parent
FRONTEND_DIR = BASE_DIR / 'assets' / 'milkdown-dist'
LOG_DIR = BASE_DIR / 'logs'
LOG_DIR.mkdir(exist_ok=True)

logging.basicConfig(
    level=logging.DEBUG,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler(LOG_DIR / 'app.log'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)
window = None
initial_file = None


class Api:
    def get_initial_file(self):
        """Retorna o arquivo que deve ser aberto ao iniciar."""
        logger.info(f'get_initial_file chamado, retornando: {initial_file}')
        if initial_file:
            return initial_file
        return None

    def open_file(self):
        logger.info('open_file chamado')
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
        logger.info(f'open_path chamado com: {path}')
        if not path:
            msg = 'Nenhum caminho de arquivo informado.'
            logger.error(msg)
            return {'error': msg}
        try:
            resolved = str(Path(path).resolve())
            logger.info(f'Caminho resolvido para: {resolved}')
            if not Path(resolved).exists():
                msg = f'Arquivo nao existe: {resolved}'
                logger.error(msg)
                return {'error': msg}
            with open(resolved, 'r', encoding='utf-8') as f:
                content = f.read()
            logger.info(f'Arquivo aberto com sucesso: {resolved} ({len(content)} caracteres)')
            return {'path': resolved, 'content': content}
        except Exception as e:
            logger.error(f'Erro ao abrir arquivo: {str(e)}', exc_info=True)
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
    global window, initial_file
    logger.info(f'app.py iniciado com {len(sys.argv)} argumentos')
    logger.info(f'sys.argv = {sys.argv}')
    logger.info(f'BASE_DIR = {BASE_DIR}')
    logger.info(f'FRONTEND_DIR = {FRONTEND_DIR}')
    
    index_file = FRONTEND_DIR / 'index.html'
    if not index_file.exists():
        msg = f'Arquivo nao encontrado: {index_file}'
        logger.error(msg)
        raise FileNotFoundError(msg)

    if len(sys.argv) > 1:
        raw_arg = sys.argv[1]
        logger.info(f'Argumento bruto recebido: {raw_arg}')
        logger.info(f'Tipo do argumento: {type(raw_arg)}')
        logger.info(f'Comprimento da string: {len(raw_arg)}')
        file_arg = str(Path(raw_arg).resolve())
        logger.info(f'Arquivo resolvido: {file_arg}')
        logger.info(f'Arquivo existe? {Path(file_arg).exists()}')
        initial_file = file_arg
        logger.info(f'initial_file definido para: {initial_file}')

    index_uri = index_file.as_uri()
    logger.info(f'URL do index: {index_uri}')

    api = Api()
    logger.info(f'Criando janela com URL: {index_uri}')
    window = webview.create_window(
        'Markdown Visual Editor',
        index_uri,
        js_api=api,
        width=1280,
        height=900,
    )
    logger.info('Janela criada, iniciando webview.start()')
    webview.start(debug=True)
    logger.info('Aplicacao finalizada normalmente')


if __name__ == '__main__':
    main()
