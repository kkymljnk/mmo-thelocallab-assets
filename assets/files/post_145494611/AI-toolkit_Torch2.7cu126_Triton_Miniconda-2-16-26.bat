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
    curl -k -L -o miniconda.exe https://repo.anaconda.com/miniconda/Miniconda3-py310_25.9.1-1-Windows-x86_64.exe
    
    if !errorlevel! neq 0 (
        echo Error downloading Miniconda. Please check your internet connection and try again.
        goto end
    )
    
    echo Installing Miniconda...
    start /wait "" miniconda.exe /InstallationType=JustMe /RegisterPython=0 /S /D=%CD%\miniconda3
    
    if !errorlevel! neq 0 (
        echo Error installing Miniconda.
        goto end
    )
    
    del miniconda.exe
)

::--------------------- Initialize Conda (PATH + activation script) -----------------
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

::--------------------- Conda Environment Setup ---------------------
echo Creating conda environment with Python 3.10 and Node JS v18...
call conda create -n aitoolkit python=3.10 nodejs=18 -y

:: Activate the newly created environment
call conda activate aitoolkit

::--------------------- Clone repositories ---------------------
git clone https://github.com/ostris/ai-toolkit.git
cd ai-toolkit

REM Step 4: Install requirements
cd AI-Toolkit
echo Installing requirements...
pip install -r requirements.txt
pip install --no-cache-dir torch==2.7.0 torchvision==0.22.0 torchaudio==2.7.0 --index-url https://download.pytorch.org/whl/cu126
pip install -U "triton-windows<3.5"

::--------------------- Create start and update batch files ---------------------
echo @echo off > "%PROJECT_DIR%start_AI-Toolkit.bat"
echo cd /d "%PROJECT_DIR%AI-Toolkit" >> "%PROJECT_DIR%start_AI-Toolkit.bat"
echo echo Activating conda environment... >> "%PROJECT_DIR%start_AI-Toolkit.bat"
echo call "%PROJECT_DIR%miniconda3\Scripts\activate.bat" >> "%PROJECT_DIR%start_AI-Toolkit.bat"
echo call conda activate aitoolkit >> "%PROJECT_DIR%start_AI-Toolkit.bat"
echo echo Starting AI-Toolkit... >> "%PROJECT_DIR%start_AI-Toolkit.bat"
echo cd ui >> "%PROJECT_DIR%start_AI-Toolkit.bat"
echo call npm run build_and_start >> "%PROJECT_DIR%start_AI-Toolkit.bat"
echo pause >> "%PROJECT_DIR%start_AI-Toolkit.bat"

echo @echo off > "%PROJECT_DIR%update_AI-Toolkit.bat"
echo cd /d "%PROJECT_DIR%AI-Toolkit" >> "%PROJECT_DIR%update_AI-Toolkit.bat"
echo echo Activating conda environment... >> "%PROJECT_DIR%update_AI-Toolkit.bat"
echo call "%PROJECT_DIR%miniconda3\Scripts\activate.bat" >> "%PROJECT_DIR%update_AI-Toolkit.bat"
echo call conda activate aitoolkit >> "%PROJECT_DIR%update_AI-Toolkit.bat"
echo echo Updating AI-Toolkit... >> "%PROJECT_DIR%update_AI-Toolkit.bat"
echo git pull >> "%PROJECT_DIR%update_AI-Toolkit.bat"
echo pip install -r requirements.txt >> "%PROJECT_DIR%update_AI-Toolkit.bat"
echo pause >> "%PROJECT_DIR%update_AI-Toolkit.bat"

cd ui
call npm run build_and_start

:end
echo Setup complete

REM Keep the window open
pause
