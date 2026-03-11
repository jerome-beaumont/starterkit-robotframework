@echo off
REM Vérifier si un argument a été passé
if "%1"=="" (
    echo Usage: run_local.bat ^<TAG^> [--web ^<selenium^|playwright^>] [--headless] [--history] [--env ^<env_name^>]
    echo.
    echo Examples:
    echo   run_local.bat smoke
    echo   run_local.bat smoke --web selenium
    echo   run_local.bat regression --browser edge --web playwright --env QUALIF --headless --history
    echo.
    exit /b 1
)


cd %cd%
REM Définit le répertoire de travail (compatible Jenkins)
set WORKSPACE=%cd%
REM Récupère le chemin de base du socle
set "PATH2RESOURCE=%cd%\src\ressources\socle"

REM Valeurs par défaut des options
set WEB_DRIVER=playwright
set HEADLESS_MODE=false
set HISTORY_MODE=false
set BROWSER=edge

REM Parcours tous les arguments
set "TAG=%~1"
shift

:parse_args
if "%~1"=="" goto args_done

if /i "%~1"=="--web" (
    set "WEB_DRIVER=%~2"
    shift
) else if "%~1"=="--headless" (
    set HEADLESS_MODE=true
) else if "%~1"=="--history" (
    set HISTORY_MODE=true
) else if "%~1"=="--browser" (
    set BROWSER=%~2
    shift
) else if "%~1"=="--env" (
    set "MY_ENV=%~2"
    shift
) else (
    echo Unknown option: %~1
    echo Usage: run_local.bat ^<TAG^> [--web ^<selenium^|playwright^>] [--headless] [--history] [--env ^<env_name^>]
    exit /b 1
)

shift
goto parse_args

:args_done

REM Choix du répertoire selon WEB_DRIVER
set "PATH2RESOURCE=%PATH2RESOURCE%;%PATH2RESOURCE%/%WEB_DRIVER%"

REM Construire la commande robot
set ROBOT_OPTS= ^
  --outputdir "%WORKSPACE%/output" ^
  --listener allure_robotframework  ^
  --include %TAG% ^
  --language fr ^
  --loglevel TRACE ^
  --variablefile "%WORKSPACE%\settings.yml" ^
  --variable HEADLESS_MODE:%HEADLESS_MODE% ^
  --variable MY_BROWSER:%BROWSER% ^
  --pythonpath "%PATH2RESOURCE%"

REM Ajouter timestampoutputs si HISTORY_MODE est activé
if "%HISTORY_MODE%"=="true" (
    set "ROBOT_OPTS=%ROBOT_OPTS% --timestampoutputs"
)

python ^
  -m robot ^
  %ROBOT_OPTS% ^
  "%cd%\src\test-suites"