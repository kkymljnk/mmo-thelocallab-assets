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
    curl -k -L -o miniconda.exe https://repo.anaconda.com/miniconda/Miniconda3-py310_25.3.1-1-Windows-x86_64.exe

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

::------------------- Conda Initialization -------------------
call miniconda3\Scripts\activate.bat

::--------------------- Clone repositories ---------------------
git clone https://github.com/Lex-au/Orpheus-FastAPI.git
cd Orpheus-FastAPI

::--------------------- Install dependencies ---------------------
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu124
pip install numpy==1.26.4
pip install -r requirements.txt

::--------------------- Create start and update batch files ---------------------
echo @echo off > "%PROJECT_DIR%start_orpheustts.bat"
echo cd /d "%PROJECT_DIR%Orpheus-FastAPI" >> "%PROJECT_DIR%start_orpheustts.bat"
echo echo Activating conda environment... >> "%PROJECT_DIR%start_orpheustts.bat"
echo call "%PROJECT_DIR%miniconda3\Scripts\activate.bat" >> "%PROJECT_DIR%start_orpheustts.bat"
echo echo Starting Orpheus TTS... >> "%PROJECT_DIR%start_orpheustts.bat"
echo python app.py >> "%PROJECT_DIR%start_orpheustts.bat"
echo pause >> "%PROJECT_DIR%start_orpheustts.bat"

echo @echo off > "%PROJECT_DIR%update_orpheustts.bat"
echo echo Updating Orpheus TTS... >> "%PROJECT_DIR%update_orpheustts.bat"
echo cd /d "%PROJECT_DIR%Orpheus-FastAPI" >> "%PROJECT_DIR%update_orpheustts.bat"
echo call "%PROJECT_DIR%miniconda3\Scripts\activate.bat" >> "%PROJECT_DIR%update_orpheustts.bat"
echo git pull >> "%PROJECT_DIR%update_orpheustts.bat"
echo pip install -r requirements.txt >> "%PROJECT_DIR%update_orpheustts.bat"
echo pause >> "%PROJECT_DIR%update_orpheustts.bat"

pause
endlocal
