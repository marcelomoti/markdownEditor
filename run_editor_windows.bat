@echo off
setlocal EnableExtensions EnableDelayedExpansion
cd /d "%~dp0"

if not exist "logs" mkdir "logs"
for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /value ^| find "="') do (
  for /f "delims=." %%J in ("%%I") do set TS=%%J
)
set "LOG=%~dp0logs\run-%TS%.log"
set "ROOT=%~dp0"
set "PYOK=0"
set "PY_CMD="

echo ========================================== & echo ========================================== >> "%LOG%"
echo Markdown Visual Editor - Execucao          & echo Markdown Visual Editor - Execucao          >> "%LOG%"
echo ========================================== & echo ========================================== >> "%LOG%"
echo Pasta: %ROOT%                              & echo Pasta: %ROOT%                              >> "%LOG%"
echo Log:   %LOG%                               & echo Log:   %LOG%                               >> "%LOG%"
echo.                                           & echo.                                           >> "%LOG%"

echo Verificando Python...  & echo Verificando Python... >> "%LOG%"
where python >nul 2>nul
if not errorlevel 1 set "PY_CMD=python" & set "PYOK=1"
if "!PYOK!"=="0" (
  where py >nul 2>nul
  if not errorlevel 1 set "PY_CMD=py" & set "PYOK=1"
)
if "!PYOK!"=="0" (
  echo [ERRO] Python nao encontrado.              & echo [ERRO] Python nao encontrado. >> "%LOG%"
  echo Instale o Python e adicione ao PATH.       & echo Instale o Python e adicione ao PATH. >> "%LOG%"
  goto :fail
)
echo [OK] Python encontrado: !PY_CMD!  & echo [OK] Python encontrado: !PY_CMD! >> "%LOG%"

if not exist "%ROOT%venv\Scripts\activate.bat" (
  echo [ERRO] Ambiente virtual nao encontrado.       & echo [ERRO] Ambiente virtual nao encontrado. >> "%LOG%"
  echo Execute install_project_windows.bat primeiro. & echo Execute install_project_windows.bat primeiro. >> "%LOG%"
  goto :fail
)

if not exist "%ROOT%assets\milkdown-dist\index.html" (
  echo [ERRO] Build do frontend nao encontrado.      & echo [ERRO] Build do frontend nao encontrado. >> "%LOG%"
  echo Execute install_project_windows.bat primeiro. & echo Execute install_project_windows.bat primeiro. >> "%LOG%"
  goto :fail
)

echo [1/3] Ativando ambiente virtual...  & echo [1/3] Ativando ambiente virtual... >> "%LOG%"
call "%ROOT%venv\Scripts\activate.bat"
if !errorlevel! neq 0 goto :fail

echo [2/3] Iniciando aplicativo desktop...  & echo [2/3] Iniciando app.py... >> "%LOG%"
python "%ROOT%app.py" >> "%LOG%" 2>&1
if !errorlevel! neq 0 goto :fail

echo.                                            & echo. >> "%LOG%"
echo [OK] Aplicativo encerrado normalmente.      & echo [OK] Aplicativo encerrado normalmente. >> "%LOG%"
echo Log salvo em: %LOG%                         & echo Log salvo em: %LOG% >> "%LOG%"
pause
exit /b 0

:fail
echo.                                            & echo. >> "%LOG%"
echo [ERRO] Falha ao executar o editor.          & echo [ERRO] Falha ao executar o editor. >> "%LOG%"
echo Verifique o log: %LOG%                      & echo Verifique o log: %LOG% >> "%LOG%"
pause
exit /b 1