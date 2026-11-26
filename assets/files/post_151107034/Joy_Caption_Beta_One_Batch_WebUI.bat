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

:: Download and install Miniconda if not exists
if not exist "miniconda3" (
    echo Downloading Miniconda...
    curl -k -L -o miniconda.exe https://repo.anaconda.com/miniconda/Miniconda3-py311_25.5.1-1-Windows-x86_64.exe
    
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

::--------------------- Initialize Conda (PATH + activation script) -----------------
echo Creating conda environment with Python 3.11...
set "CONDA_ROOT=%CD%\miniconda3"
set "PATH=%CONDA_ROOT%;%CONDA_ROOT%\Scripts;%CONDA_ROOT%\Library\bin;%PATH%"

:: Activate base environment
call "%CONDA_ROOT%\Scripts\activate.bat"

::--------------------- Accept Anaconda ToS (non-interactive) -----------------------
echo Accepting Anaconda Terms of Service...
call conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main
call conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r
call conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/msys2

:: Optional: enable auto-accept ToS for future runs
call conda config --set plugins.auto_accept_tos yes


:: Clone repositories
git clone https://github.com/Arnold2006/Jay_Caption_Beta_one_Batch_WebUI.git
cd Jay_Caption_Beta_one_Batch_WebUI


:: Create start file
echo @echo off > "%PROJECT_DIR%start_WebUI.bat"
echo cd /d "%PROJECT_DIR%Jay_Caption_Beta_one_Batch_WebUI" >> "%PROJECT_DIR%start_WebUI.bat"
echo echo Activating conda environment... >> "%PROJECT_DIR%start_WebUI.bat"
echo call "%PROJECT_DIR%miniconda3\Scripts\activate.bat" >> "%PROJECT_DIR%start_WebUI.bat"
echo echo Starting Jay Caption Beta One... >> "%PROJECT_DIR%start_WebUI.bat"
echo python app.py >> "%PROJECT_DIR%start_WebUI.bat"
echo pause >> "%PROJECT_DIR%start_WebUI.bat"


:: Install dependencies
pip install -r requirements.txt
pip install torch==2.8.0+cu128 torchvision==0.23.0+cu128 torchaudio==2.8.0+cu128 --index-url https://download.pytorch.org/whl/cu128


pause
endlocal