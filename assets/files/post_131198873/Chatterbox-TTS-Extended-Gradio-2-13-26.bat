@echo off
setlocal enabledelayedexpansion

:: Set the directory for the project to the current directory
set "PROJECT_DIR=%~dp0"
cd "%PROJECT_DIR%"


:: Download and install Miniconda if not exists
if not exist "miniconda3" (
    echo Downloading Miniconda...
    curl -k -L -o miniconda.exe https://repo.anaconda.com/miniconda/Miniconda3-py310_25.5.1-0-Windows-x86_64.exe
    
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
git clone https://github.com/petermg/Chatterbox-TTS-Extended.git
cd Chatterbox-TTS-Extended

:: Install dependencies
python -m pip install --upgrade pip
pip install antlr4-python3-runtime --use-pep517
pip install -r requirements.txt

:: Create start file
echo @echo off > "%PROJECT_DIR%start_chatterbox.bat"
echo cd /d "%PROJECT_DIR%chatterbox" >> "%PROJECT_DIR%start_chatterbox.bat"
echo echo Activating conda environment... >> "%PROJECT_DIR%start_chatterbox.bat"
echo call "%PROJECT_DIR%miniconda3\Scripts\activate.bat" >> "%PROJECT_DIR%start_chatterbox.bat"
echo echo Starting Chatterbox TTS Extended... >> "%PROJECT_DIR%start_chatterbox.bat"
echo cd Chatterbox-TTS-Extended >> "%PROJECT_DIR%start_chatterbox.bat"
echo python Chatter.py >> "%PROJECT_DIR%start_chatterbox.bat"
echo pause >> "%PROJECT_DIR%start_chatterbox.bat"

:: Create update file
echo @echo off > "%PROJECT_DIR%update_chatterbox.bat"
echo echo Updating Chatterbox TTS Extended... >> "%PROJECT_DIR%update_chatterbox.bat"
echo cd /d "%PROJECT_DIR%chatterbox" >> "%PROJECT_DIR%update_chatterbox.bat"
echo call "%PROJECT_DIR%miniconda3\Scripts\activate.bat" >> "%PROJECT_DIR%update_chatterbox.bat"
echo git pull >> "%PROJECT_DIR%update_chatterbox.bat"
echo pip install --force-reinstall -r requirements.txt >> "%PROJECT_DIR%update_chatterbox.bat"
echo pause >> "%PROJECT_DIR%update_chatterbox.bat"


pause
endlocal