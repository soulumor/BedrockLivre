@echo off
title Instalador - Bedrock Livre
color 0B

REM Obt??m o diret??rio onde o script est?? localizado
set SCRIPT_DIR=%~dp0
cd /d "%SCRIPT_DIR%"

echo ========================================
echo    INSTALADOR - Bedrock Livre
echo    Por SouLumor
echo ========================================
echo.

REM Verifica se est?? executando como administrador
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERRO] Execute como Administrador!
    echo.
    echo Clique com botao direito no arquivo e selecione
    echo "Executar como administrador"
    echo.
    pause
    exit /b 1
)

REM Detecta caminho do Minecraft
set MINECRAFT_PATH=
if exist "C:\XboxGames\Minecraft for Windows\Content" (
    set MINECRAFT_PATH=C:\XboxGames\Minecraft for Windows\Content
) else if exist "%LOCALAPPDATA%\Packages\Microsoft.MinecraftUWP_8wekyb3d8bbwe\LocalState\games\com.mojang" (
    set MINECRAFT_PATH=%LOCALAPPDATA%\Packages\Microsoft.MinecraftUWP_8wekyb3d8bbwe\LocalState\games\com.mojang
) else (
    echo [AVISO] Minecraft nao encontrado automaticamente.
    echo.
    set /p MINECRAFT_PATH="Digite o caminho da pasta do Minecraft: "
    if not exist "%MINECRAFT_PATH%" (
        echo [ERRO] Caminho invalido!
        pause
        exit /b 1
    )
)

echo [OK] Minecraft encontrado: %MINECRAFT_PATH%
echo.

REM Verifica se a DLL existe (usando caminho relativo ao script)
if not exist "%SCRIPT_DIR%DLL\LumorDesbloqueio.dll" (
    echo [ERRO] DLL nao encontrada!
    echo Procurando em: %SCRIPT_DIR%DLL\LumorDesbloqueio.dll
    echo Certifique-se de que todos os arquivos estao na pasta correta.
    pause
    exit /b 1
)

REM Verifica Launcher
if not exist "%SCRIPT_DIR%Launcher\launcher.exe" (
    echo [ERRO] Launcher nao encontrado!
    echo Procurando em: %SCRIPT_DIR%Launcher\launcher.exe
    echo Certifique-se de que todos os arquivos estao na pasta correta.
    pause
    exit /b 1
)

REM Copia DLL
echo Copiando arquivos...
copy /Y "%SCRIPT_DIR%DLL\LumorDesbloqueio.dll" "%MINECRAFT_PATH%\LumorDesbloqueio.dll" >nul
if %ERRORLEVEL% EQU 0 (
    echo [OK] DLL instalada com sucesso!
) else (
    echo [ERRO] Falha ao copiar DLL!
    echo Tente executar novamente como Administrador.
    pause
    exit /b 1
)

REM Copia vcruntime140_1.dll (SEMPRE da pasta DLL do projeto)
echo Copiando vcruntime140_1.dll...
if exist "%SCRIPT_DIR%DLL\vcruntime140_1.dll" (
    copy /Y "%SCRIPT_DIR%DLL\vcruntime140_1.dll" "%MINECRAFT_PATH%\vcruntime140_1.dll"
    if %ERRORLEVEL% EQU 0 (
        echo [OK] vcruntime140_1.dll copiada (da pasta DLL)
    ) else (
        echo [ERRO] Falha ao copiar vcruntime140_1.dll!
        echo Execute como Administrador.
        pause
        exit /b 1
    )
) else (
    echo [ERRO] vcruntime140_1.dll nao encontrada na pasta DLL!
    echo.
    echo Certifique-se de que a vcruntime140_1.dll esta em:
    echo   %SCRIPT_DIR%DLL\vcruntime140_1.dll
    echo.
    pause
    exit /b 1
)

echo.
echo ========================================
echo    INJETANDO DLL NO MINECRAFT
echo ========================================
echo.
echo IMPORTANTE: O Minecraft precisa estar RODANDO!
echo.
echo Aguardando o Minecraft iniciar...
echo.

REM Aguarda o Minecraft estar rodando (at?? 60 segundos)
set MINECRAFT_RUNNING=0
for /L %%i in (1,1,60) do (
    tasklist /FI "IMAGENAME eq Minecraft.Windows.exe" 2>NUL | find /I /N "Minecraft.Windows.exe">NUL
    if "%%ERRORLEVEL%%"=="0" (
        set MINECRAFT_RUNNING=1
        goto :minecraft_found
    )
    timeout /t 1 /nobreak >nul
    echo Aguardando... (%%i/60)
)

:minecraft_found
if %MINECRAFT_RUNNING%==0 (
    echo.
    echo [AVISO] Minecraft nao esta rodando!
    echo.
    echo Por favor:
    echo   1. Abra o Minecraft
    echo   2. Execute este script novamente
    echo   3. Ou execute Launcher\launcher.exe manualmente
    echo.
    pause
    exit /b 1
)

echo [OK] Minecraft encontrado!
echo.
echo Injetando DLL no processo...
echo.

REM Executa o launcher para injetar a DLL
cd /d "%SCRIPT_DIR%Launcher"
start /wait launcher.exe
cd /d "%SCRIPT_DIR%"

echo.
echo ========================================
echo    INSTALACAO CONCLUIDA!
echo ========================================
echo.
echo A DLL foi injetada no Minecraft!
echo O jogo agora esta desbloqueado.
echo.
pause
