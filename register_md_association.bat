@echo off
setlocal EnableExtensions EnableDelayedExpansion
cd /d "%~dp0"

set "APP=%~dp0run_editor_windows.bat"
set "FILETYPE=MarkdownEditorFile"
set "LOGDIR=%~dp0logs"
if not exist "%LOGDIR%" mkdir "%LOGDIR%"

for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /value ^| find "="') do (
  for /f "delims=." %%J in ("%%I") do set TS=%%J
)
set "LOG=%LOGDIR%\register-%TS%.log"

echo Registrando associacao para .md... > "%LOG%"
echo APP=%APP% >> "%LOG%"
echo FILETYPE=%FILETYPE% >> "%LOG%"

assoc .md=%FILETYPE% >> "%LOG%" 2>&1
ftype %FILETYPE%="%APP%" "%%1" >> "%LOG%" 2>&1

echo Associacao criada para .md apontando para:
echo %APP%
echo.
echo Agora voce pode testar abrindo um arquivo .md por duplo clique.
echo Log salvo em: %LOG%
pause
