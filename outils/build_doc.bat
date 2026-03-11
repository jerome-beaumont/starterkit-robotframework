REM  Extraction de la documentation à partir des resources robot
REM    https://robotframework.org/robotframework/latest/RobotFrameworkUserGuide.html#general-usage
REM
REM    usage: make_doc.bat features/steps/surveillance_relance.resource 
REM #TODO Mode Annule et remplace

set ROBOT_DOC=%cd%/doc
set ROBOT_DEPLOY=%cd%\src

REM  Etape formattage des ressources
robocop format

REM Etape Extraction de la  la documentation
cd %cd%

for /R "%ROBOT_DEPLOY%" %%F in (*.resource) do (
    echo Generation documentation pour %%F

    python -m robot.libdoc ^
        --format html ^
        --docformat robot ^
        "%%F" ^
        "%ROBOT_DOC%\%%~nF.html"
)
