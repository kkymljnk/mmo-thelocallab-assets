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
git clone https://github.com/resemble-ai/chatterbox.git
cd chatterbox

:: Install dependencies
pip install chatterbox-tts
pip install -e .
pip install --upgrade gradio gradio_client

:: Create start file with user selection
echo @echo off > "%PROJECT_DIR%start_chatterbox_cpu.bat"
echo cd /d "%PROJECT_DIR%chatterbox" >> "%PROJECT_DIR%start_chatterbox_cpu.bat"
echo echo Activating conda environment... >> "%PROJECT_DIR%start_chatterbox_cpu.bat"
echo call "%PROJECT_DIR%miniconda3\Scripts\activate.bat" >> "%PROJECT_DIR%start_chatterbox_cpu.bat"
echo echo. >> "%PROJECT_DIR%start_chatterbox_cpu.bat"
echo echo Select the mode to start: >> "%PROJECT_DIR%start_chatterbox_cpu.bat"
echo echo 1. Text-to-Speech Synthesis Gradio UI >> "%PROJECT_DIR%start_chatterbox_cpu.bat"
echo echo 2. Voice Conversion Gradio UI >> "%PROJECT_DIR%start_chatterbox_cpu.bat"
echo set /p mode=Enter 1 or 2: >> "%PROJECT_DIR%start_chatterbox_cpu.bat"
echo if "%%mode%%"=="1" ( >> "%PROJECT_DIR%start_chatterbox_cpu.bat"
echo     python gradio_tts_app.py >> "%PROJECT_DIR%start_chatterbox_cpu.bat"
echo ) else if "%%mode%%"=="2" ( >> "%PROJECT_DIR%start_chatterbox_cpu.bat"
echo     python gradio_vc_app.py >> "%PROJECT_DIR%start_chatterbox_cpu.bat"
echo ) else ( >> "%PROJECT_DIR%start_chatterbox_cpu.bat"
echo     echo Invalid selection. Exiting. >> "%PROJECT_DIR%start_chatterbox_cpu.bat"
echo ) >> "%PROJECT_DIR%start_chatterbox_cpu.bat"
echo pause >> "%PROJECT_DIR%start_chatterbox_cpu.bat"

:: Create update file
echo @echo off > "%PROJECT_DIR%update_chatterbox_cpu.bat"
echo echo Updating Chatterbox Standard CPU Version... >> "%PROJECT_DIR%update_chatterbox_cpu.bat"
echo cd /d "%PROJECT_DIR%chatterbox" >> "%PROJECT_DIR%update_chatterbox_cpu.bat"
echo call "%PROJECT_DIR%miniconda3\Scripts\activate.bat" >> "%PROJECT_DIR%update_chatterbox_cpu.bat"
echo git pull >> "%PROJECT_DIR%update_chatterbox_cpu.bat"
echo pip install chatterbox-tts >> "%PROJECT_DIR%update_chatterbox_cpu.bat"
echo pip install --force-reinstall -e . >> "%PROJECT_DIR%update_chatterbox_cpu.bat"
echo pip install --upgrade gradio gradio_client >> "%PROJECT_DIR%update_chatterbox_cpu.bat"
echo pause >> "%PROJECT_DIR%update_chatterbox_cpu.bat"

pause
endlocal
