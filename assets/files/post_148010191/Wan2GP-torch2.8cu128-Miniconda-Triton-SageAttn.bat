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
    start /wait miniconda.exe /InstallationType=JustMe /RegisterPython=0 /S /D=%CD%\miniconda3
    
    if !errorlevel! neq 0 (
        echo Error installing Miniconda.
        goto end
    )
    
    del miniconda.exe
)

:: Create and activate conda environment
echo Creating conda environment with Python 3.10...
call miniconda3\Scripts\activate.bat

:: Clone repositories
git clone https://github.com/deepbeepmeep/Wan2GP.git
cd Wan2GP

:: Install dependencies
pip install torch==2.8.0+cu128 torchvision==0.23.0+cu128 torchaudio==2.8.0+cu128 --index-url https://download.pytorch.org/whl/cu128
pip install -r requirements.txt
pip install -U "triton-windows<3.5"
curl -k -L -o sageattention-2.2.0+cu128torch2.8.0-cp310-cp310-win_amd64.whl https://github.com/woct0rdho/SageAttention/releases/download/v2.2.0-windows/sageattention-2.2.0+cu128torch2.8.0-cp310-cp310-win_amd64.whl
pip install sageattention-2.2.0+cu128torch2.8.0-cp310-cp310-win_amd64.whl

:: Create start file
echo @echo off > "%PROJECT_DIR%start_WAN2GP.bat"
echo cd /d "%PROJECT_DIR%WAN2GP" >> "%PROJECT_DIR%start_WAN2GP.bat"
echo echo Activating conda environment... >> "%PROJECT_DIR%start_WAN2GP.bat"
echo call "%PROJECT_DIR%miniconda3\Scripts\activate.bat" >> "%PROJECT_DIR%start_WAN2GP.bat"
echo echo Starting WAN2GP... >> "%PROJECT_DIR%start_WAN2GP.bat"
echo python wgp.py >> "%PROJECT_DIR%start_WAN2GP.bat"
echo pause >> "%PROJECT_DIR%start_WAN2GP.bat"

:: Create update file
echo @echo off > "%PROJECT_DIR%update_WAN2GP.bat"
echo echo Updating WAN2GP... >> "%PROJECT_DIR%update_WAN2GP.bat"
echo cd /d "%PROJECT_DIR%WAN2GP" >> "%PROJECT_DIR%update_WAN2GP.bat"
echo call "%PROJECT_DIR%miniconda3\Scripts\activate.bat" >> "%PROJECT_DIR%update_WAN2GP.bat"
echo git pull >> "%PROJECT_DIR%update_WAN2GP.bat"
echo pip install -r requirements.txt >> "%PROJECT_DIR%update_WAN2GP.bat"
echo pause >> "%PROJECT_DIR%update_WAN2GP.bat"


pause
endlocal