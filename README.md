# Markdown Visual Editor - etapa 2

Agora o projeto já está preparado para usar **Milkdown localmente** no frontend e **pywebview** no desktop.

## Estrutura

- `app.py`: app desktop Python; abre o build local se ele existir.
- `frontend/`: projeto Vite com Milkdown.
- `assets/milkdown-dist/`: saída do build do frontend.
- `editor.html`: fallback simples da etapa 1.

## Como instalar

### 1) Dependência Python

```bash
pip install -r requirements.txt
```

### 2) Dependências do frontend

Entre em `frontend/` e rode:

```bash
npm install
```

Isso baixa o `@milkdown/crepe`, que é a interface pronta do Milkdown para edição visual [web:71].

## Como gerar o bundle local

Dentro de `frontend/`:

```bash
npm run build
```

O Vite vai gerar os arquivos compilados em:

```text
assets/milkdown-dist/
```

Depois disso, o `app.py` passa a abrir automaticamente esse build local, sem depender de internet em runtime [web:69][web:71].

## Como rodar o app

```bash
python app.py
```

## Fluxo offline

- A internet é necessária apenas para baixar dependências inicialmente com `npm install`.
- Depois do build pronto, o app roda localmente usando os arquivos compilados do disco [web:71][web:33].

## Observação importante

Como eu não executei `npm install` aqui no sandbox, o bundle final do Milkdown ainda **não está compilado**. Mas a estrutura inteira da etapa 2 já está pronta para você compilar no seu desktop.

## Próximo ajuste recomendado

Os pontos que normalmente ajustamos na etapa 3 são:

- detectar com mais precisão o evento de mudança do editor;
- adicionar atalhos de teclado como `Ctrl+S`;
- barra superior com Novo/Abrir/Salvar;
- suporte a imagens locais;
- empacotamento final em `.exe`.
