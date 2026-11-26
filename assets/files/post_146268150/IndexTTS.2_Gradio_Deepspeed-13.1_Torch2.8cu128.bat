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

::--------------------- Conda Environment Setup ---------------------
echo Creating conda environment with Python 3.10...
call miniconda3\Scripts\activate.bat
call conda create -n indextts-gradio -y python=3.10
call conda activate indextts-gradio
call conda install -y -n indextts-gradio -c conda-forge pynini==2.1.6

::--------------------- Clone repositories ---------------------
git clone https://github.com/index-tts/index-tts.git
cd index-tts

REM Step 4: Install requirements
echo Installing requirements...
curl -k -L -o deepspeed-0.13.1+cu121-cp310-cp310-win_amd64.whl https://github.com/daswer123/deepspeed-windows-wheels/releases/download/13.1/deepspeed-0.13.1+cu121-cp310-cp310-win_amd64.whl
pip install deepspeed-0.13.1+cu121-cp310-cp310-win_amd64.whl
pip install torch==2.8.0+cu128 torchvision==0.23.0+cu128 torchaudio==2.8.0+cu128 --index-url https://download.pytorch.org/whl/cu128
pip install -U uv
pip install accelerate==1.8.1
pip install cn2an==0.5.22
pip install cython==3.0.7
pip install descript-audiotools==0.7.2
pip install "einops>=0.8.1"
pip install ffmpeg-python==0.2.0
pip install g2p-en==2.1.0
pip install jieba==0.42.1
pip install json5==0.10.0
pip install keras==2.9.0
pip install librosa==0.10.2.post1
pip install matplotlib==3.8.2
pip install modelscope==1.27.0
pip install munch==4.0.0
pip install numba==0.58.1
pip install numpy==1.26.2
pip install "omegaconf>=2.3.0"
pip install opencv-python==4.9.0.80
pip install pandas==2.3.2
pip install safetensors==0.5.2
pip install "sentencepiece>=0.2.1"
pip install tensorboard==2.9.1
pip install "textstat>=0.7.10"
pip install tokenizers==0.21.0
pip install "tqdm>=4.67.1"
pip install transformers==4.52.1
pip install "wetext>=0.0.9"
pip install gradio==5.45.0
uv tool install "huggingface-hub[cli,hf_xet]"
hf download IndexTeam/IndexTTS-2 --local-dir=checkpoints



::--------------------- Create start and update batch files ---------------------
echo @echo off > "%PROJECT_DIR%start_IndexTTS.bat"
echo echo Activating conda environment... >> "%PROJECT_DIR%start_IndexTTS.bat"
echo call "%PROJECT_DIR%miniconda3\Scripts\activate.bat" >> "%PROJECT_DIR%start_IndexTTS.bat"
echo call conda activate indextts-gradio >> "%PROJECT_DIR%start_IndexTTS.bat"
echo cd /d "%PROJECT_DIR%index-tts" >> "%PROJECT_DIR%start_IndexTTS.bat"
echo echo Starting IndexTTS... >> "%PROJECT_DIR%start_IndexTTS.bat"
echo call python webui.py >> "%PROJECT_DIR%start_IndexTTS.bat"
echo pause >> "%PROJECT_DIR%start_IndexTTS.bat"

call python webui.py

:end
echo Setup complete

REM Keep the window open
pause