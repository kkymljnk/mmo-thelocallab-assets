@echo off
setlocal EnableDelayedExpansion

REM Check if Git is installed
where git >nul 2>nul
if !errorlevel! neq 0 (
    echo Git not found. Downloading and installing...
    curl -k -L -o git-installer.exe "https://github.com/git-for-windows/git/releases/download/v2.44.0.windows.1/Git-2.44.0-64-bit.exe"
    if !errorlevel! neq 0 (
        echo Error downloading Git. Please check your internet connection and try again.
        goto end
    )
    git-installer.exe /VERYSILENT /NORESTART
    if !errorlevel! neq 0 (
        echo Error installing Git. Please try installing it manually.
        goto end
    )
    echo Git installed successfully.
    del git-installer.exe
    set "PATH=%PATH%;C:\Program Files\Git\cmd"
)

REM Check if 7-Zip is installed
if not exist "C:\Program Files\7-Zip\7z.exe" (
    echo 7-Zip not found. Downloading and installing...
    curl -k -L -o 7z2301-x64.exe https://www.7-zip.org/a/7z2301-x64.exe
    if !errorlevel! neq 0 (
        echo Error downloading 7-Zip. Please check your internet connection and try again.
        goto end
    )
    7z2301-x64.exe /S
    if !errorlevel! neq 0 (
        echo Error installing 7-Zip. Please try installing it manually.
        goto end
    )
    echo 7-Zip installed successfully.
    del 7z2301-x64.exe
)

REM Step 1: Download ComfyUI
echo Downloading latest ComfyUI release...
curl -k -L -o ComfyUI_windows_portable_nvidia.7z https://github.com/comfyanonymous/ComfyUI/releases/latest/download/ComfyUI_windows_portable_nvidia.7z
if !errorlevel! neq 0 (
    echo Error downloading ComfyUI. Please check your internet connection and try again.
    goto end
)
echo Download completed successfully.

REM Step 2: Extract
echo Extracting ComfyUI...
"C:\Program Files\7-Zip\7z.exe" x ComfyUI_windows_portable_nvidia.7z
if !errorlevel! neq 0 (
    echo Error extracting the file. The file may be corrupted.
) else (
    echo Extraction completed successfully.
)

REM Step 3: Clone custom nodes
echo Cloning custom nodes...
git clone https://github.com/ltdrdata/ComfyUI-Manager.git "ComfyUI_windows_portable\ComfyUI\custom_nodes\ComfyUI-Manager"
git clone https://github.com/rgthree/rgthree-comfy.git "ComfyUI_windows_portable\ComfyUI\custom_nodes\rgthree-comfy"
git clone https://github.com/TheLocalLab/ComfyUI-SongScribe.git "ComfyUI_windows_portable\ComfyUI\custom_nodes\ComfyUI-SongScribe"

if !errorlevel! neq 0 (
    echo Error cloning the custom nodes repositories. Please check your internet connection and ensure git is installed.
) else (
    echo Custom nodes cloned successfully.
)

REM Step 4: Install requirements
cd ComfyUI_windows_portable
echo Installing requirements...
.\python_embeded\python.exe -m pip install opencv_python==4.10.0.82
.\python_embeded\python.exe -m pip install -r .\ComfyUI\custom_nodes\ComfyUI-Manager\requirements.txt
.\python_embeded\python.exe -m pip install -r .\ComfyUI\custom_nodes\rgthree-comfy\requirements.txt
if exist ".\ComfyUI\custom_nodes\ComfyUI-SongScribe\requirements.txt" .\python_embeded\python.exe -m pip install -r .\ComfyUI\custom_nodes\ComfyUI-SongScribe\requirements.txt
.\python_embeded\python.exe -m pip install torch==2.8.0+cu128 torchvision==0.23.0+cu128 torchaudio==2.8.0+cu128 --index-url https://download.pytorch.org/whl/cu128
.\python_embeded\python.exe -m pip install --no-cache-dir --upgrade numba
.\python_embeded\python.exe -m pip install -U "triton-windows<3.5"

REM ======== Model download menu ========
echo.
echo ============================================================
echo   YuE2 - Model Download Options
echo ============================================================
echo   [B] Standard model (bf16) - best quality, needs more VRAM
echo   [I] Low-VRAM model (int8) - for smaller cards (~6 GB and under)
echo   [S] Skip - I will download models myself
echo ============================================================
echo   (The SheetSage2 encoder for melody-copy downloads with B or I.)
choice /C BIS /M "Choose a download option:"
set MODELOPT=!errorlevel!

if !MODELOPT!==3 (
    echo Skipping model downloads.
    goto post_models
)

echo Downloading models...
if not exist "ComfyUI\models\audio_encoders" mkdir "ComfyUI\models\audio_encoders"
curl -k -L -o ComfyUI\models\audio_encoders\sheetsage2_bf16.safetensors "https://huggingface.co/Comfy-Org/YuE2/resolve/main/audio_encoders/sheetsage2_bf16.safetensors?download=true"

if !MODELOPT!==1 (
    curl -k -L -o ComfyUI\models\checkpoints\yue2_3b_bf16.safetensors "https://huggingface.co/Comfy-Org/YuE2/resolve/main/checkpoints/yue2_3b_bf16.safetensors?download=true"
)
if !MODELOPT!==2 (
    curl -k -L -o ComfyUI\models\checkpoints\yue2_3b_int8_convrot.safetensors "https://huggingface.co/Comfy-Org/YuE2/resolve/main/checkpoints/yue2_3b_int8_convrot.safetensors?download=true"
)

:post_models
cd update
.\update_comfyui.bat
cd ..

echo.
echo Setup complete

REM Keep the window open
pause
