@echo off
setlocal enabledelayedexpansion

:: Set the directory for the project to the current directory
set "PROJECT_DIR=%~dp0"
cd "%PROJECT_DIR%"

:: Check if ffmpeg is installed
where ffmpeg >nul 2>&1
if %errorlevel% neq 0 (
    echo ffmpeg is not installed. Attempting to install it now...
    
    :: Download ffmpeg
    powershell -Command "Invoke-WebRequest -Uri 'https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-win64-gpl.zip' -OutFile 'ffmpeg.zip'"
    
    :: Create a directory for ffmpeg
    mkdir ffmpeg
    
    :: Extract ffmpeg
    powershell -Command "Expand-Archive -Path 'ffmpeg.zip' -DestinationPath 'ffmpeg'"
    
    :: Add ffmpeg to path
    setx PATH "%PATH%;%PROJECT_DIR%ffmpeg\ffmpeg-master-latest-win64-gpl\bin"
    
    :: Delete the zip file
    del ffmpeg.zip
    
    echo ffmpeg has been installed.
)

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
    Have you accepted the license agreements on Hugging Face for https://huggingface.co/pyannote/speaker-diarization and https://huggingface.co/pyannote/segmentation?
    del miniconda.exe
)

:: Create and activate conda environment
echo Creating conda environment with Python 3.10...
call miniconda3\Scripts\activate.bat


:: Clone repositories
git clone https://github.com/R3gm/SoniTranslate.git
cd SoniTranslate

:: Install dependencies
python -m pip install pip==24.0
pip install git+https://github.com/m-bain/whisperX.git
pip install ctranslate2==4.4.0
pip install yt-dlp
pip install gradio==4.19.2
pip install pydub==0.25.1
pip install edge_tts==6.1.7
pip install deep_translator==1.11.4
pip install git+https://github.com/R3gm/pyannote-audio.git@3.1.1
pip install git+https://github.com/R3gm/whisperX.git@cuda_11_8
pip install nest_asyncio
pip install gTTS
pip install gradio_client==0.10.1
pip install IPython
pip install fastapi==0.112.2
pip install praat-parselmouth==0.4.3
pip install pyworld==0.3.2
pip install faiss-cpu==1.7.3
pip install torchcrepe==0.0.20
pip install ffmpeg-python==0.2.0
pip install fairseq==0.12.2 
pip install gdown
pip install rarfile
pip install transformers
pip install accelerate
pip install optimum
pip install sentencepiece
pip install srt
pip install git+https://github.com/R3gm/openvoice_package.git@lite
pip install openai==1.14.3
pip install tiktoken==0.6.0
pip install pypdf==4.2.0
pip install python-docx
pip install onnxruntime-gpu
pip install -r requirements_xtts.txt
pip install TTS==0.21.1  --no-deps
pip install torch==2.3.0 torchvision==0.18.0 torchaudio==2.3.0 --index-url https://download.pytorch.org/whl/cu118
pip install numpy==1.26.4

:: Create start file
echo @echo off > "%PROJECT_DIR%start_sonitranslate.bat"
echo cd /d "%PROJECT_DIR%SoniTranslate" >> "%PROJECT_DIR%start_sonitranslate.bat"
echo echo Activating conda environment... >> "%PROJECT_DIR%start_sonitranslate.bat"
echo call "%PROJECT_DIR%miniconda3\Scripts\activate.bat" >> "%PROJECT_DIR%start_sonitranslate.bat"
echo echo Starting SoniTranslate... >> "%PROJECT_DIR%start_sonitranslate.bat"
echo python app_rvc.py >> "%PROJECT_DIR%start_sonitranslate.bat"
echo pause >> "%PROJECT_DIR%start_sonitranslate.bat"

echo @echo off > "%PROJECT_DIR%start_sonitranslate_cpu.bat"
echo cd /d "%PROJECT_DIR%SoniTranslate" >> "%PROJECT_DIR%start_sonitranslate_cpu.bat"
echo echo Activating conda environment... >> "%PROJECT_DIR%start_sonitranslate_cpu.bat"
echo call "%PROJECT_DIR%miniconda3\Scripts\activate.bat" >> "%PROJECT_DIR%start_sonitranslate_cpu.bat"
echo echo Starting SoniTranslate in CPU mode... >> "%PROJECT_DIR%start_sonitranslate_cpu.bat"
echo python app_rvc.py --cpu_mode >> "%PROJECT_DIR%start_sonitranslate_cpu.bat"
echo pause >> "%PROJECT_DIR%start_sonitranslate_cpu.bat"

:; Set Huggingface Token
set /p HUGGINGFACE_TOKEN=Enter your Hugging Face access token: 
echo set HUGGINGFACE_TOKEN=%HUGGINGFACE_TOKEN% > "%PROJECT_DIR%huggingface_token.bat"

echo  (yes/no)
set /p ACCEPTED_LICENSE=
if /i "%ACCEPTED_LICENSE%" neq "yes" (
    echo License agreements are mandatory to use this project. Please accept them and run this script again.
    pause
    exit /b
)



pause
endlocal