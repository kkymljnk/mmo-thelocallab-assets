@echo off
setlocal enabledelayedexpansion

:: Set the directory for the project to the current directory
set "PROJECT_DIR=%~dp0"
cd "%PROJECT_DIR%"


:: Download and install Miniconda if not exists
if not exist "miniconda3" (
    echo Downloading Miniconda...
    curl -L -o miniconda.exe https://repo.anaconda.com/miniconda/Miniconda3-latest-Windows-x86_64.exe
    
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
echo Creating conda environment with Python 3.10.16...
call miniconda3\Scripts\activate.bat
call conda create -y -n ACE-Step-env python=3.10.16
call conda activate ACE-Step-env

:: Clone repositories
git clone https://github.com/ace-step/ACE-Step.git
cd ACE-Step

:: Install dependencies
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu126
pip install -e .

:: Create start file
echo @echo off > "%PROJECT_DIR%start_ACE-Step.bat"
echo cd /d "%PROJECT_DIR%ACE-Step" >> "%PROJECT_DIR%start_ACE-Step.bat"
echo echo Activating conda environment... >> "%PROJECT_DIR%start_ACE-Step.bat"
echo call "%PROJECT_DIR%miniconda3\Scripts\activate.bat" >> "%PROJECT_DIR%start_ACE-Step.bat"
echo call conda activate ACE-Step-env >> "%PROJECT_DIR%start_ACE-Step.bat"
echo echo Starting ACE-Step... >> "%PROJECT_DIR%start_ACE-Step.bat"
echo acestep --port 7865 --share true >> "%PROJECT_DIR%start_ACE-Step.bat"
echo pause >> "%PROJECT_DIR%start_ACE-Step.bat"

:: Create update file
echo @echo off > "%PROJECT_DIR%update_ACE-Step.bat"
echo echo Updating ACE-Step... >> "%PROJECT_DIR%update_ACE-Step.bat"
echo cd /d "%PROJECT_DIR%ACE-Step" >> "%PROJECT_DIR%update_ACE-Step.bat"
echo call "%PROJECT_DIR%miniconda3\Scripts\activate.bat" >> "%PROJECT_DIR%update_ACE-Step.bat"
echo call conda activate ACE-Step-env >> "%PROJECT_DIR%update_ACE-Step.bat"
echo git pull >> "%PROJECT_DIR%update_ACE-Step.bat"
echo pip install -e . >> "%PROJECT_DIR%update_ACE-Step.bat"
echo pause >> "%PROJECT_DIR%update_ACE-Step.bat"


pause
endlocal