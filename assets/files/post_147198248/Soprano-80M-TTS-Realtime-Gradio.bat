@echo off
setlocal enabledelayedexpansion

:: Set the directory for the project to the current directory
set "PROJECT_DIR=%~dp0"
cd "%PROJECT_DIR%"

::--------------------- GIT: Check and Install If Needed ----------------------------
where git >nul 2>nul
if errorlevel 1 (
    echo Git not found. Downloading and installing Git...
    set "GIT_INSTALLER=Git-setup.exe"
    curl -L -k -o "%GIT_INSTALLER%" https://github.com/git-for-windows/git/releases/latest/download/Git-2.45.2-64-bit.exe

    :: Install Git for current user silently (no admin rights), add to PATH
    start /wait "" "%GIT_INSTALLER%" /VERYSILENT /NORESTART /NOCANCEL /DIR="%USERPROFILE%\Git"

    if errorlevel 1 (
        echo Error installing Git.
        goto end
    )

    del "%GIT_INSTALLER%"

    :: Add Git to current session's PATH
    set "PATH=%USERPROFILE%\Git\cmd;%PATH%"
) else (
    echo Git found.
)

git --version

::--------------------- Miniconda: Download & Install If Needed ---------------------
if not exist "miniconda3" (
    echo Downloading Miniconda...
    curl -k -L -o miniconda.exe https://repo.anaconda.com/miniconda/Miniconda3-py312_25.5.1-0-Windows-x86_64.exe

    if !errorlevel! neq 0 (
        echo Error downloading Miniconda. Please check your internet connection and try again.
        goto end
    )

    echo Installing Miniconda...
    start /wait miniconda.exe /InstallationType=JustMe /RegisterPython=0 /S /D=%CD%\miniconda3

    if !errorlevel! neq 0 (
        echo Error installing Miniconda.
        goto end
    )

    del miniconda.exe
)

::--------------------- Conda Environment Setup ---------------------
echo Creating conda environment with Python 3.10...
call miniconda3\Scripts\activate.bat
call conda create -n soprano -y python=3.10
call conda activate soprano

git clone https://github.com/groxaxo/soprano.git --branch copilot/redesign-front-page

REM Step 4: Install requirements
cd soprano
echo Installing requirements...
pip install -e .
pip uninstall -y torch
pip install torch==2.8.0 --index-url https://download.pytorch.org/whl/cu126
pip install pydantic==2.10.6

::--------------------- Create start and update batch files ---------------------
echo @echo off > "%PROJECT_DIR%start_Soprano_Gradio.bat"
echo cd /d "%PROJECT_DIR%Soprano" >> "%PROJECT_DIR%start_Soprano_Gradio.bat"
echo echo Activating conda environment... >> "%PROJECT_DIR%start_Soprano_Gradio.bat"
echo call "%PROJECT_DIR%miniconda3\Scripts\activate.bat" >> "%PROJECT_DIR%start_Soprano_Gradio.bat"
echo call conda activate soprano >> "%PROJECT_DIR%start_Soprano_Gradio.bat"
echo echo Starting Soprano... >> "%PROJECT_DIR%start_Soprano_Gradio.bat"
echo python app.py >> "%PROJECT_DIR%start_Soprano_Gradio.bat"
echo pause >> "%PROJECT_DIR%start_Soprano_Gradio.bat"

echo @echo off > "%PROJECT_DIR%start_Soprano_API-Server.bat"
echo cd /d "%PROJECT_DIR%Soprano" >> "%PROJECT_DIR%start_Soprano_API-Server.bat"
echo echo Activating conda environment... >> "%PROJECT_DIR%start_Soprano_API-Server.bat"
echo call "%PROJECT_DIR%miniconda3\Scripts\activate.bat" >> "%PROJECT_DIR%start_Soprano_API-Server.bat"
echo call conda activate soprano >> "%PROJECT_DIR%start_Soprano_API-Server.bat"
echo echo Starting Soprano... >> "%PROJECT_DIR%start_Soprano_API-Server.bat"
echo python api_server.py >> "%PROJECT_DIR%start_Soprano_API-Server.bat"
echo pause >> "%PROJECT_DIR%start_Soprano_API-Server.bat"

echo @echo off > "%PROJECT_DIR%update_Soprano.bat"
echo echo Updating Soprano... >> "%PROJECT_DIR%update_Soprano.bat"
echo cd /d "%PROJECT_DIR%Soprano" >> "%PROJECT_DIR%update_Soprano.bat"
echo call "%PROJECT_DIR%miniconda3\Scripts\activate.bat" >> "%PROJECT_DIR%update_Soprano.bat"
echo call conda activate soprano >> "%PROJECT_DIR%update_Soprano.bat"
echo git pull >> "%PROJECT_DIR%update_Soprano.bat"
echo pip install -e . >> "%PROJECT_DIR%update_Soprano.bat"
echo pause >> "%PROJECT_DIR%update_Soprano.bat"


:end
echo Setup complete

REM Keep the window open
pause