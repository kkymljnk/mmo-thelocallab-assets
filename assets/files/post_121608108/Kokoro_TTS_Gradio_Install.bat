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
call conda create -y -n kokorotts-env python=3.10.16
call conda activate kokorotts-env

:: Clone repositories
git clone https://github.com/PierrunoYT/Kokoro-TTS-Local.git
cd Kokoro-TTS-Local

:: Install dependencies
pip install -r requirements.txt
pip install scipy

:: Create start file
echo @echo off > "%PROJECT_DIR%start_kokorotts.bat"
echo cd /d "%PROJECT_DIR%Kokoro-TTS-Local" >> "%PROJECT_DIR%start_kokorotts.bat"
echo echo Activating conda environment... >> "%PROJECT_DIR%start_kokorotts.bat"
echo call "%PROJECT_DIR%miniconda3\Scripts\activate.bat" >> "%PROJECT_DIR%start_kokorotts.bat"
echo call conda activate kokorotts-env >> "%PROJECT_DIR%start_kokorotts.bat"
echo echo Starting Kokoro TTS Local... >> "%PROJECT_DIR%start_kokorotts.bat"
echo python gradio_interface.py >> "%PROJECT_DIR%start_kokorotts.bat"
echo pause >> "%PROJECT_DIR%start_kokorotts.bat"

:: Create update file
echo @echo off > "%PROJECT_DIR%update_kokorotts.bat"
echo echo Updating Kokoro TTS Local... >> "%PROJECT_DIR%update_kokorotts.bat"
echo cd /d "%PROJECT_DIR%Kokoro-TTS-Local" >> "%PROJECT_DIR%update_kokorotts.bat"
echo call "%PROJECT_DIR%miniconda3\Scripts\activate.bat" >> "%PROJECT_DIR%update_kokorotts.bat"
echo call conda activate kokorotts-env >> "%PROJECT_DIR%update_kokorotts.bat"
echo git pull >> "%PROJECT_DIR%update_kokorotts.bat"
echo pip install -r requirements.txt >> "%PROJECT_DIR%update_kokorotts.bat"
echo pause >> "%PROJECT_DIR%update_kokorotts.bat"


pause
endlocal