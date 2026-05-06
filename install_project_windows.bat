@echo off
setlocal EnableExtensions EnableDelayedExpansion
cd /d "%~dp0"

set "ROOT=%~dp0"
set "PYEXE="
set "PYVER="
set "LOGDIR=%ROOT%logs"
if not exist "%LOGDIR%" mkdir "%LOGDIR%"
for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /value ^| find "="') do (
  for /f "delims=." %%J in ("%%I") do set "TS=%%J"
)
set "LOG=%LOGDIR%\install-%TS%.log"

>"%LOG%" (
  echo ==========================================
  echo Markdown Visual Editor - Instalacao
  echo ==========================================
  echo Pasta do projeto: %ROOT%
  echo Log: %LOG%
)

echo Verificando Python...
>>"%LOG%" echo Verificando Python...

for %%P in (
  "%ROOT%venv\Scripts\python.exe"
  "%LocalAppData%\Programs\Python\Python313\python.exe"
  "%LocalAppData%\Programs\Python\Python312\python.exe"
  "%LocalAppData%\Programs\Python\Python311\python.exe"
  "%LocalAppData%\Programs\Python\Python310\python.exe"
  "%LocalAppData%\Programs\Python\Python39\python.exe"
  "%LocalAppData%\Programs\Python\Python38\python.exe"
  "%LocalAppData%\Python\bin\python.exe"
  "C:\Program Files\Python313\python.exe"
  "C:\Program Files\Python312\python.exe"
  "C:\Program Files\Python311\python.exe"
  "C:\Program Files\Python310\python.exe"
) do (
  if not defined PYEXE if exist %%~P (
    echo %%P | find /I "WindowsApps" >nul
    if errorlevel 1 (
      set "PYEXE=%%~P"
    )
  )
)

if not defined PYEXE (
  for /f "delims=" %%P in ('where python 2^>nul') do (
    echo %%P | find /I "WindowsApps" >nul
    if errorlevel 1 if not defined PYEXE set "PYEXE=%%P"
  )
)

if not defined PYEXE (
  echo [ERRO] Nenhum Python valido encontrado.
  >>"%LOG%" echo [ERRO] Nenhum Python valido encontrado.
  echo Instale Python 3.13/3.12 do python.org e tente novamente.
  pause
  exit /b 1
)




rem for /f "delims=" %%V in ('"%PYEXE%" -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}.{sys.version_info.micro}')"') do set "PYVER=%%V"
rem for /f "usebackq delims=" %%V in (`call "%PYEXE%" -c "import sys; print('%s.%s.%s' % sys.version_info[:3])"`) do set "PYVER=%%V"
for /f "delims=" %%V in ('"%PYEXE%" -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}.{sys.version_info.micro}')"') do set "PYVER=%%V"

echo [OK] Python encontrado: %PYEXE%
echo [OK] Python encontrado: %PYEXE%>>"%LOG%"
echo [OK] Versao: %PYVER%
echo [OK] Versao: %PYVER%>>"%LOG%"

echo Verificando pip do Python selecionado...
>>"%LOG%" echo Verificando pip do Python selecionado...
"%PYEXE%" -m pip --version >>"%LOG%" 2>&1
if errorlevel 1 goto :pip_fail


echo Verificando estrutura de pastas...
echo Caminho esperado: "%ROOT%frontend\index.html"
if exist "%ROOT%frontend\index.html" (
    echo [OK] index.html encontrado.
) else (
    echo [ERRO] index.html NAO encontrado em "%ROOT%frontend\index.html"
    dir "%ROOT%frontend"
    pause
    exit /b 1
)


echo [OK] Estrutura de pastas correta.
>>"%LOG%" echo [OK] Estrutura de pastas correta.

if not exist "%ROOT%venv\Scripts\python.exe" (
  echo [1/6] Criando ambiente virtual Python...
  >>"%LOG%" echo [1/6] Criando ambiente virtual Python...
  "%PYEXE%" -m venv "%ROOT%venv" >>"%LOG%" 2>&1
  if errorlevel 1 goto :py_fail
) else (
  echo [1/6] Ambiente virtual ja existe.
  >>"%LOG%" echo [1/6] Ambiente virtual ja existe.
)

echo [2/6] Atualizando pip, setuptools e wheel...
>>"%LOG%" echo [2/6] Atualizando pip, setuptools e wheel...
"%ROOT%venv\Scripts\python.exe" -m pip install --upgrade pip setuptools wheel >>"%LOG%" 2>&1
if errorlevel 1 goto :py_fail

echo [3/6] Instalando dependencias Python...
>>"%LOG%" echo [3/6] Instalando dependencias Python...
"%ROOT%venv\Scripts\python.exe" -m pip install -r "%ROOT%requirements.txt" >>"%LOG%" 2>&1
if errorlevel 1 goto :py_fail

echo [4/6] Verificando Node/npm...
>>"%LOG%" echo [4/6] Verificando Node/npm...
where npm >nul 2>nul
if errorlevel 1 goto :missing_npm

if exist "%ROOT%assets\milkdown-dist\index.html" (
  echo [4/6] Frontend ja construido. Pulando npm install e build...
  >>"%LOG%" echo [4/6] Frontend ja construido. Pulando npm install e build...
  goto :done
)

echo [5/6] Instalando dependencias do frontend...
>>"%LOG%" echo [5/6] Instalando dependencias do frontend...
pushd "%ROOT%frontend"
call npm install >>"%LOG%" 2>&1
if errorlevel 1 ( popd & goto :npm_fail )

echo [6/6] Gerando bundle local do frontend...
>>"%LOG%" echo [6/6] Gerando bundle local do frontend...
call npm run build >>"%LOG%" 2>&1
if errorlevel 1 ( popd & goto :npm_fail )
popd

:done
echo.
echo [OK] Instalacao concluida com sucesso!
echo [OK] Instalacao concluida com sucesso!>>"%LOG%"
echo Log salvo em: %LOG%
echo Log salvo em: %LOG%>>"%LOG%"
pause
exit /b 0

:missing_frontend
echo [ERRO] Pasta frontend\ ou arquivos principais nao encontrados.
echo [ERRO] Pasta frontend\ ou arquivos principais nao encontrados.>>"%LOG%"
pause
exit /b 1

:missing_requirements
echo [ERRO] requirements.txt nao encontrado.
echo [ERRO] requirements.txt nao encontrado.>>"%LOG%"
pause
exit /b 1

:missing_npm
echo [ERRO] npm nao encontrado no PATH.
echo [ERRO] npm nao encontrado no PATH.>>"%LOG%"
pause
exit /b 1

:pip_fail
echo [ERRO] Falha ao verificar pip.
echo [ERRO] Falha ao verificar pip.>>"%LOG%"
pause
exit /b 1

:py_fail
echo [ERRO] Falha na etapa Python/venv.
echo [ERRO] Falha na etapa Python/venv.>>"%LOG%"
pause
exit /b 1

:npm_fail
echo [ERRO] Falha na etapa npm.
echo [ERRO] Falha na etapa npm.>>"%LOG%"
pause
exit /b 1