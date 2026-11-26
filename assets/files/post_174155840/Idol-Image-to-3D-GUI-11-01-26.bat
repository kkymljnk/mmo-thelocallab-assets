@echo off
setlocal enabledelayedexpansion

:: Set the directory for the project to the current directory
set "PROJECT_DIR=%~dp0"
cd /d "%PROJECT_DIR%"

::--------------------- GIT: Check and Install If Needed ----------------------------
where git >nul 2>nul
if errorlevel 1 (
    echo Git not found. Downloading and installing Git...
    set "GIT_INSTALLER=Git-setup.exe"
    curl -L -k -o "!GIT_INSTALLER!" https://github.com/git-for-windows/git/releases/download/v2.44.0.windows.1/Git-2.44.0-64-bit.exe

    REM Install Git for current user silently (no admin rights), add to PATH
    start /wait "" "!GIT_INSTALLER!" /VERYSILENT /NORESTART /NOCANCEL /DIR="%USERPROFILE%\Git"

    if errorlevel 1 (
        echo Error installing Git.
        goto end
    )

    del "!GIT_INSTALLER!"

    REM Add Git to current session's PATH
    set "PATH=%USERPROFILE%\Git\cmd;%PATH%"
) else (
    echo Git found.
)

git --version

:: Brackets in the folder path break the install (cmd and the Miniconda installer refuse them)
if not "%CD%"=="%CD:(=%" goto badpath
if not "%CD%"=="%CD:)=%" goto badpath
set "MINI_DIR=%CD%\miniconda3"

:: Download and install Miniconda if not exists
if not exist "miniconda3" (
    echo Downloading Miniconda...
    curl -k -L -o miniconda.exe https://repo.anaconda.com/miniconda/Miniconda3-py312_25.11.1-1-Windows-x86_64.exe
    
    if !errorlevel! neq 0 (
        echo Error downloading Miniconda. Please check your internet connection and try again.
        goto end
    )
    
    echo Installing Miniconda...
    start /wait miniconda.exe /InstallationType=JustMe /RegisterPython=0 /S /D=!MINI_DIR!
    
    if !errorlevel! neq 0 (
        echo Error installing Miniconda.
        goto end
    )
    
    del miniconda.exe
)

::--------------------- Initialize Conda (PATH + activation script) -----------------
echo Setting up conda with Python 3.12...
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


:: Clone repositories
if not exist "idol-sdk" git clone https://github.com/speridlabs/idol-sdk.git
cd idol-sdk
:: Idol app at the tested version
git checkout 4702a7f


:: Create start file (standard: no compiling, works on every NVIDIA card)
:: TEMP/TMP point at outputs\: the app saves each .ply in a temp folder, and Windows temp cleanup can delete it mid-session
echo @echo off > "%PROJECT_DIR%start_Idol_GUI.bat"
echo cd /d "%PROJECT_DIR%idol-sdk\demo" >> "%PROJECT_DIR%start_Idol_GUI.bat"
echo echo Activating conda environment... >> "%PROJECT_DIR%start_Idol_GUI.bat"
echo call "%PROJECT_DIR%miniconda3\Scripts\activate.bat" >> "%PROJECT_DIR%start_Idol_GUI.bat"
echo set "IDOL_WEIGHTS=%PROJECT_DIR%models" >> "%PROJECT_DIR%start_Idol_GUI.bat"
echo set "HF_HUB_OFFLINE=1" >> "%PROJECT_DIR%start_Idol_GUI.bat"
echo if not exist "%PROJECT_DIR%outputs" mkdir "%PROJECT_DIR%outputs" >> "%PROJECT_DIR%start_Idol_GUI.bat"
echo set "TEMP=%PROJECT_DIR%outputs" >> "%PROJECT_DIR%start_Idol_GUI.bat"
echo set "TMP=%PROJECT_DIR%outputs" >> "%PROJECT_DIR%start_Idol_GUI.bat"
echo echo Your 3D files are saved in "%PROJECT_DIR%outputs" >> "%PROJECT_DIR%start_Idol_GUI.bat"
echo set "SPACES_ZERO_GPU=1" >> "%PROJECT_DIR%start_Idol_GUI.bat"
echo echo Starting Idol... open http://127.0.0.1:7860 in your browser once the models have loaded >> "%PROJECT_DIR%start_Idol_GUI.bat"
echo python app.py >> "%PROJECT_DIR%start_Idol_GUI.bat"
echo pause >> "%PROJECT_DIR%start_Idol_GUI.bat"

:: Create FAST start file (torch.compile with Triton: faster per object, the first object takes a few minutes to compile)
echo @echo off > "%PROJECT_DIR%start_Idol_GUI_FAST.bat"
echo cd /d "%PROJECT_DIR%idol-sdk\demo" >> "%PROJECT_DIR%start_Idol_GUI_FAST.bat"
echo echo Activating conda environment... >> "%PROJECT_DIR%start_Idol_GUI_FAST.bat"
echo call "%PROJECT_DIR%miniconda3\Scripts\activate.bat" >> "%PROJECT_DIR%start_Idol_GUI_FAST.bat"
echo set "IDOL_WEIGHTS=%PROJECT_DIR%models" >> "%PROJECT_DIR%start_Idol_GUI_FAST.bat"
echo set "HF_HUB_OFFLINE=1" >> "%PROJECT_DIR%start_Idol_GUI_FAST.bat"
echo if not exist "%PROJECT_DIR%outputs" mkdir "%PROJECT_DIR%outputs" >> "%PROJECT_DIR%start_Idol_GUI_FAST.bat"
echo set "TEMP=%PROJECT_DIR%outputs" >> "%PROJECT_DIR%start_Idol_GUI_FAST.bat"
echo set "TMP=%PROJECT_DIR%outputs" >> "%PROJECT_DIR%start_Idol_GUI_FAST.bat"
echo echo Your 3D files are saved in "%PROJECT_DIR%outputs" >> "%PROJECT_DIR%start_Idol_GUI_FAST.bat"
echo echo Starting Idol FAST... the first object compiles for a few minutes, then every object is faster >> "%PROJECT_DIR%start_Idol_GUI_FAST.bat"
echo echo Open http://127.0.0.1:7860 in your browser once the models have loaded >> "%PROJECT_DIR%start_Idol_GUI_FAST.bat"
echo python app.py >> "%PROJECT_DIR%start_Idol_GUI_FAST.bat"
echo pause >> "%PROJECT_DIR%start_Idol_GUI_FAST.bat"


:: Install dependencies (torch first, so pip keeps the CUDA build)
pip install torch==2.11.0+cu128 torchvision==0.26.0+cu128 --index-url https://download.pytorch.org/whl/cu128
pip install -e .
pip install gradio==5.49.1 accelerate
:: Triton for the FAST launcher (triton-windows 3.7 goes with torch 2.11)
pip install -U "triton-windows<3.8"

cd /d "%PROJECT_DIR%"


REM ======== Model download menu ========
echo.
echo ============================================================
echo   Idol Image to 3D - Model Download Options
echo ============================================================
echo   No Hugging Face account or gated access needed.
echo.
echo   [A] Everything ....................... ~4.9 GB
echo        Idol model, DINOv3 image encoder, FLUX.2 VAE
echo        and BiRefNet background removal
echo   [S] Skip - I will download models myself
echo ============================================================
choice /C AS /M "Choose a download option:"
set MODELOPT=!errorlevel!

if !MODELOPT!==2 (
    echo Skipping model downloads.
    goto post_models
)

echo Downloading models...
if not exist "models\dinov3-vith16plus" mkdir "models\dinov3-vith16plus"
if not exist "models\flux2-klein4b\vae" mkdir "models\flux2-klein4b\vae"

REM --- Idol (speridlabs/idol, Apache-2.0) ---
curl -f -k -L -o models\config.json "https://huggingface.co/speridlabs/idol/resolve/main/config.json?download=true"
if not exist "models\denoiser.safetensors" curl -f -k -L -o models\denoiser.safetensors "https://huggingface.co/speridlabs/idol/resolve/main/denoiser.safetensors?download=true"
if not exist "models\decoder.safetensors" curl -f -k -L -o models\decoder.safetensors "https://huggingface.co/speridlabs/idol/resolve/main/decoder.safetensors?download=true"
if not exist "models\decoder_gs.safetensors" curl -f -k -L -o models\decoder_gs.safetensors "https://huggingface.co/speridlabs/idol/resolve/main/decoder_gs.safetensors?download=true"
if not exist "models\birefnet.safetensors" curl -f -k -L -o models\birefnet.safetensors "https://huggingface.co/speridlabs/idol/resolve/main/birefnet.safetensors?download=true"

REM --- DINOv3 ViT-H+/16 image encoder (Meta DINOv3 License, ungated copy) ---
if not exist "models\dinov3-vith16plus\model.safetensors" curl -f -k -L -o models\dinov3-vith16plus\model.safetensors "https://huggingface.co/VAST-AI/TripoSplat/resolve/main/clip_vision/dino_v3_vit_h.safetensors?download=true"
curl -f -k -L -o models\dinov3-vith16plus\config.json "https://huggingface.co/onnx-community/dinov3-vith16plus-pretrain-lvd1689m-ONNX/resolve/main/config.json?download=true"
curl -f -k -L -o models\dinov3-vith16plus\LICENSE.md "https://raw.githubusercontent.com/facebookresearch/dinov3/main/LICENSE.md"

REM --- FLUX.2 VAE from FLUX.2 [klein] 4B (Apache-2.0): the same weights as the FLUX.2-dev VAE ---
if not exist "models\flux2-klein4b\vae\diffusion_pytorch_model.safetensors" curl -f -k -L -o models\flux2-klein4b\vae\diffusion_pytorch_model.safetensors "https://huggingface.co/black-forest-labs/FLUX.2-klein-4B/resolve/main/vae/diffusion_pytorch_model.safetensors?download=true"
curl -f -k -L -o models\flux2-klein4b\vae\config.json "https://huggingface.co/black-forest-labs/FLUX.2-klein-4B/resolve/main/vae/config.json?download=true"
curl -f -k -L -o models\flux2-klein4b\LICENSE.md "https://huggingface.co/black-forest-labs/FLUX.2-klein-4B/resolve/main/LICENSE.md?download=true"

REM --- Point Idol at the local encoders instead of the gated Hugging Face repos ---
python -c "import json,os;p=r'models\config.json';d=os.path.dirname(os.path.abspath(p));c=json.load(open(p));c['image_encoders']={'dinov3':os.path.join(d,'dinov3-vith16plus'),'flux2_vae':os.path.join(d,'flux2-klein4b')};json.dump(c,open(p,'w'),indent=2)"

:post_models
echo.
echo Setup complete
echo Start Idol with start_Idol_GUI.bat, or start_Idol_GUI_FAST.bat for faster objects after a one-time compile.

goto end

:badpath
echo.
echo This folder path has brackets in it: "%CD%"
echo Move the installer to a folder like C:\Idol and run it again.

:end
pause
endlocal
