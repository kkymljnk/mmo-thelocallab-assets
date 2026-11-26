@echo off
setlocal ENABLEDELAYEDEXPANSION

set REPO_BRANCH=neo
set VENV_DIR=venv
set LAST_STEP=Starting

echo ===============================
echo  SD Forge Neo Updater
echo ===============================
echo Working directory: %CD%
echo.

REM 1. CHECK .GIT
set LAST_STEP=Checking .git
if not exist ".git" (
    echo [ERROR] .git folder not found.
    goto End
)

REM 2. SHOW BRANCH
set LAST_STEP=Detecting branch
for /f "delims=" %%B in ('git rev-parse --abbrev-ref HEAD 2^>nul') do set CUR_BRANCH=%%B
echo Current git branch: %CUR_BRANCH%

REM 3. FETCH
set LAST_STEP=Fetching
echo Fetching from remote...
git fetch origin
if errorlevel 1 goto EndFailFetch

REM 4. COMPARE COMMITS
set LAST_STEP=Reading commits
for /f "delims=" %%A in ('git rev-parse HEAD') do set LOCAL_COMMIT=%%A
for /f "delims=" %%A in ('git rev-parse origin/%REPO_BRANCH%') do set REMOTE_COMMIT=%%A

echo Local: %LOCAL_COMMIT%
echo Remote: %REMOTE_COMMIT%
echo.

if "%LOCAL_COMMIT%"=="%REMOTE_COMMIT%" (
    echo Already up to date.
    goto CheckVenv
)

REM 5. SIMPLE UPDATE (NO PULL)
echo Local repo behind remote.
set LAST_STEP=Fetch + reset
echo Fetching and resetting to latest remote...
git fetch origin %REPO_BRANCH%
git reset --hard origin/%REPO_BRANCH%


echo Git updated successfully!
echo.


:CheckVenv
REM 6. VENV
echo ===============================
echo  Python venv setup
echo ===============================

set LAST_STEP=Check venv
if not exist "%VENV_DIR%\Scripts\python.exe" (
    echo Creating venv...
    python -m venv "%VENV_DIR%"
    if errorlevel 1 goto EndFailVenv
)

echo Python version:
"%VENV_DIR%\Scripts\python.exe" --version
echo.

set LAST_STEP=Install requirements.txt
if exist requirements.txt (
    echo Installing requirements.txt...
    "%VENV_DIR%\Scripts\pip.exe" install -r requirements.txt --quiet
)

echo ===============================
echo  DONE - Ready to run webui!
echo  Run: webui-user.bat
echo ===============================
goto End

:EndFailFetch
echo [ERROR] Fetch failed.
goto End

:EndFailVenv
echo [ERROR] Failed to create/setup venv.
goto End

:End
echo.
echo Last step: %LAST_STEP%
echo.
pause
endlocal



