import { Crepe } from '@milkdown/crepe';
import '@milkdown/crepe/theme/common/style.css';
import '@milkdown/crepe/theme/nord.css';

const openBtn = document.getElementById('open-file');
const saveBtn = document.getElementById('save-file');
const toggleCodeBtn = document.getElementById('toggle-code');
const statusEl = document.getElementById('status');
const filePathEl = document.getElementById('file-path');
const modeBadgeEl = document.getElementById('mode-badge');
const editorErrorEl = document.getElementById('editor-error');
const editorRootEl = document.getElementById('editor-root');
const fallbackEditorEl = document.getElementById('fallback-editor');
const codePanelEl = document.getElementById('code-panel');
const codeEditorEl = document.getElementById('code-editor');
const workspaceEl = document.getElementById('workspace');
const editorPanelEl = document.getElementById('editor-panel');
const splitterEl = document.getElementById('splitter');

let currentPath = null;
let dirty = false;
let currentMarkdown = '# Markdown Visual Editor\n\nAbra um arquivo .md para começar.';
let crepe = null;
let useFallback = false;
let codeVisible = true;
let splitRatio = 0.5;
let dragging = false;

function setStatus(message, isError = false) { statusEl.textContent = message; statusEl.classList.toggle('error', !!isError); }
function setFilePath(path) { filePathEl.textContent = path || 'Nenhum arquivo aberto.'; }
function markDirty(value) { dirty = value; document.title = dirty ? 'Markdown Visual Editor *' : 'Markdown Visual Editor'; }

function syncCodeEditor() {
  const markdown = getMarkdown();
  if (codeEditorEl.value !== markdown) {
    codeEditorEl.value = markdown;
  }
}

function updateSplitLayout() {
  if (!codeVisible) return;
  const left = Math.max(20, Math.min(80, splitRatio * 100));
  editorPanelEl.style.flexBasis = `${left}%`;
  codePanelEl.style.flexBasis = `${100 - left}%`;
  splitterEl.style.left = `${left}%`;
}

function toggleCodeVisibility() {
  codeVisible = !codeVisible;
  codePanelEl.classList.toggle('hidden', !codeVisible);
  splitterEl.classList.toggle('hidden', !codeVisible);
  toggleCodeBtn.textContent = codeVisible ? 'Ocultar código' : 'Mostrar código';
}

async function waitForBridge(timeoutMs = 10000) {
  const start = Date.now();
  return new Promise((resolve, reject) => {
    const timer = setInterval(() => {
      if (window.pywebview && window.pywebview.api) { clearInterval(timer); resolve(window.pywebview.api); return; }
      if (Date.now() - start > timeoutMs) { clearInterval(timer); reject(new Error('API indisponível')); }
    }, 100);
  });
}

async function getApiMethod(name) {
  const api = await waitForBridge();
  if (typeof api[name] === 'function') return api[name].bind(api);
  if (window.pywebview?.api && typeof window.pywebview.api[name] === 'function') return window.pywebview.api[name].bind(window.pywebview.api);
  throw new Error(`Metodo ${name} nao encontrado.`);
}

function getMarkdown() {
  if (useFallback) return fallbackEditorEl.value;
  if (crepe && typeof crepe.getMarkdown === 'function') { try { return crepe.getMarkdown(); } catch (_) {} }
  return currentMarkdown;
}

async function mountCrepe(markdown) {
  editorRootEl.classList.remove('hidden'); fallbackEditorEl.classList.add('hidden'); editorRootEl.innerHTML = '';
  if (crepe) { try { crepe.destroy(); } catch (_) {} crepe = null; }
  const root = document.createElement('div'); root.className = 'crepe-host'; editorRootEl.appendChild(root);
  crepe = new Crepe({ root, defaultValue: markdown });
  await crepe.create();
  useFallback = false; currentMarkdown = markdown; modeBadgeEl.textContent = 'Milkdown';
  
  const sync = () => { currentMarkdown = crepe.getMarkdown(); markDirty(true); syncCodeEditor(); };
  root.addEventListener('input', sync, true);
  root.addEventListener('keyup', sync, true);
  root.addEventListener('paste', () => setTimeout(sync, 0), true);
}

async function reloadEditor(markdown) {
  currentMarkdown = markdown;
  if (useFallback) fallbackEditorEl.value = markdown;
  else await mountCrepe(markdown);
  syncCodeEditor();
}

async function openFile() {
  try {
    if (dirty && !confirm('Salvar alterações antes de abrir novo arquivo?')) return;
    const openMethod = await getApiMethod('open_file');
    const result = await openMethod();
    if (!result || result.error) return setStatus(`Erro: ${result?.error}`, true);
    currentPath = result.path; currentMarkdown = result.content;
    setFilePath(currentPath); await reloadEditor(currentMarkdown); markDirty(false);
  } catch (e) { setStatus(e.message, true); }
}

async function saveFile() {
  try {
    const saveMethod = await getApiMethod('save_file');
    const result = await saveMethod({ path: currentPath, content: getMarkdown() });
    if (!result || result.error) return setStatus(`Erro: ${result?.error}`, true);
    currentPath = result.path; markDirty(false); setStatus('Salvo!');
  } catch (e) { setStatus(e.message, true); }
}

codeEditorEl.addEventListener('input', () => {
  const newMd = codeEditorEl.value;
  currentMarkdown = newMd;
  markDirty(true);
  if (useFallback) fallbackEditorEl.value = newMd;
  else { crepe.destroy(); mountCrepe(newMd); }
});

splitterEl.addEventListener('mousedown', (e) => {
  dragging = true;
  const onMove = (e) => { if (!dragging) return; const rect = workspaceEl.getBoundingClientRect(); splitRatio = Math.max(0.2, Math.min(0.8, (e.clientX - rect.left) / rect.width)); updateSplitLayout(); };
  const onUp = () => { dragging = false; document.removeEventListener('mousemove', onMove); document.removeEventListener('mouseup', onUp); };
  document.addEventListener('mousemove', onMove); document.addEventListener('mouseup', onUp);
});

openBtn.addEventListener('click', openFile); saveBtn.addEventListener('click', saveFile);
toggleCodeBtn.addEventListener('click', toggleCodeVisibility);
setFilePath(null); reloadEditor(currentMarkdown);