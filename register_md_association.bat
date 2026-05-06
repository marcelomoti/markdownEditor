@echo off
setlocal EnableExtensions EnableDelayedExpansion
cd /d "%~dp0"

set "APP=%~dp0run_editor_windows.bat"
set "FILETYPE=MarkdownEditorFile"

assoc .md=%FILETYPE%
ftype %FILETYPE%="%APP%" "%%1"

echo Associacao criada para .md apontando para:
 echo %APP%

echo.
echo Agora voce pode testar abrindo um arquivo .md por duplo clique.
pause
