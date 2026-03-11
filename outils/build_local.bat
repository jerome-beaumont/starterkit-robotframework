@echo off
chcp 65001 >nul
setlocal ENABLEDELAYEDEXPANSION

REM ============================================
REM  Vérification / création du venv
REM ============================================
echo === Vérification du venv ===
if not exist .venv (
    echo Création du venv...
    py -3.12 -m venv .venv
) else (
    echo Le venv existe déjà.
)

REM ============================================
REM  Chemins vers les exécutables du venv
REM ============================================
set PYVENV=.venv\Scripts\python.exe

if not exist "%PYVENV%" (
    echo ERREUR : Python dans le venv est introuvable.
    exit /b 1
)

REM ============================================
REM  Vérification version Python
REM ============================================
echo.
echo === Vérification version Python ===
for /f "tokens=* usebackq" %%v in (`"%PYVENV%" --version`) do set PYVER=%%v
echo Version détectée : !PYVER!

echo !PYVER! | find "3.12.10" >nul
if not !errorlevel! == 0 (
    echo ERREUR : Python doit être en version 3.12.10
    exit /b 1
)

REM ============================================
REM  Mise à jour pip
REM ============================================
echo.
echo === Mise à jour pip ===
"%PYVENV%" -m pip install --upgrade pip
if not %errorlevel% == 0 (
    echo ERREUR lors de la mise à jour de pip
    exit /b 1
)

REM ============================================
REM  Installation des dépendances
REM ============================================
echo.
echo === Installation des requirements ===
if exist requirements.txt (
    "%PYVENV%" -m pip install -r requirements.txt
    if not %errorlevel% == 0 (
        echo ERREUR lors de l'installation des requirements
        exit /b 1
    )
) else (
    echo ERREUR : requirements.txt introuvable.
    exit /b 1
)

REM ============================================
REM  Vérification version de Robot Framework
REM ============================================
echo.
echo === Vérification Robot Framework ===
for /f "tokens=* usebackq" %%v in (`"%PYVENV%" -m robot --version`) do set ROBOVER=%%v
echo Version détectée : !ROBOVER!

echo !ROBOVER! | find "Robot Framework 7.4.1" > nul
if not !errorlevel! == 0 (
    echo ERREUR : La version de Robot Framework doit être 7.4.1
    exit /b 1
)


echo.
echo === Vérification de l'installation Playwright (chromium) ===

dir /b /ad "%cd%%\.venv\Lib\site-packages\Browser\wrapper\node_modules\playwright-core\.local-browsers" | findstr /i "^chromium" >nul
if not errorlevel 1 (
    echo Chromium détecté.
) else (
    echo Chromium absent, installation...
    ".venv\Scripts\python.exe" -m Browser.entry install
)



echo.
echo === Initialisation terminée avec succès ===
endlocal
exit /b 0