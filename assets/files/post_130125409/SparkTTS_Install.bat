@echo off
setlocal enabledelayedexpansion

:: Set the directory for the project to the current directory
set "PROJECT_DIR=%~dp0"
cd "%PROJECT_DIR%"


:: Download and install Miniconda if not exists
if not exist "miniconda3" (
    echo Downloading Miniconda...
    curl -L -o miniconda.exe https://repo.anaconda.com/miniconda/Miniconda3-py312_25.5.1-1-Windows-x86_64.exe
    
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
echo Creating conda environment with Python 3.12...
call miniconda3\Scripts\activate.bat

:: Clone repositories
git clone https://github.com/SparkAudio/Spark-TTS.git
cd Spark-TTS
mkdir pretrained_models

:: Install dependencies
pip install -r requirements.txt
pip install --upgrade gradio gradio_client
pip install --upgrade torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118
git clone https://huggingface.co/SparkAudio/Spark-TTS-0.5B pretrained_models/Spark-TTS-0.5B

:: Create start file
echo @echo off > "%PROJECT_DIR%start_spark-tts.bat"
echo cd /d "%PROJECT_DIR%spark-tts" >> "%PROJECT_DIR%start_spark-tts.bat"
echo echo Activating conda environment... >> "%PROJECT_DIR%start_spark-tts.bat"
echo call "%PROJECT_DIR%miniconda3\Scripts\activate.bat" >> "%PROJECT_DIR%start_spark-tts.bat"
echo echo Starting Spark TTS... >> "%PROJECT_DIR%start_spark-tts.bat"
echo python webui.py >> "%PROJECT_DIR%start_spark-tts.bat"
echo pause >> "%PROJECT_DIR%start_spark-tts.bat"

:: Create update file
echo @echo off > "%PROJECT_DIR%update_spark-tts.bat"
echo echo Updating Spark TTS... >> "%PROJECT_DIR%update_spark-tts.bat"
echo cd /d "%PROJECT_DIR%spark-tts" >> "%PROJECT_DIR%update_spark-tts.bat"
echo call "%PROJECT_DIR%miniconda3\Scripts\activate.bat" >> "%PROJECT_DIR%update_spark-tts.bat"
echo git pull >> "%PROJECT_DIR%update_spark-tts.bat"
echo pip install -r requirements.txt >> "%PROJECT_DIR%update_spark-tts.bat"
echo pause >> "%PROJECT_DIR%update_spark-tts.bat"


pause
endlocal