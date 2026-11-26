@echo off
setlocal EnableDelayedExpansion

REM Run from the folder this installer is in
cd /d "%~dp0"

REM Check if Git is installed
where git >nul 2>nul
if !errorlevel! neq 0 (
    echo Git not found. Downloading and installing...
    
    REM Download Git installer
    curl -k -L -o git-installer.exe "https://github.com/git-for-windows/git/releases/download/v2.44.0.windows.1/Git-2.44.0-64-bit.exe"
    
    if !errorlevel! neq 0 (
        echo Error downloading Git. Please check your internet connection and try again.
        goto end
    )
    
    REM Install Git silently
    git-installer.exe /VERYSILENT /NORESTART
    
    if !errorlevel! neq 0 (
        echo Error installing Git. Please try installing it manually.
        goto end
    )
    
    echo Git installed successfully.
    
    REM Delete the installer
    del git-installer.exe
    
    REM Add Git to the current PATH
    set "PATH=%PATH%;C:\Program Files\Git\cmd"
)

REM Check if 7-Zip is installed
if not exist "C:\Program Files\7-Zip\7z.exe" (
    echo 7-Zip not found. Downloading and installing...
    
    REM Download 7-Zip
    curl -k -L -o 7z2301-x64.exe https://www.7-zip.org/a/7z2301-x64.exe
    
    if !errorlevel! neq 0 (
        echo Error downloading 7-Zip. Please check your internet connection and try again.
        goto end
    )
    
    REM Install 7-Zip silently
    7z2301-x64.exe /S
    
    if !errorlevel! neq 0 (
        echo Error installing 7-Zip. Please try installing it manually.
        goto end
    )
    
    echo 7-Zip installed successfully.
    
    REM Delete the installer
    del 7z2301-x64.exe
)

REM Step 1: Download ComfyUI 7zip file
echo Downloading latest ComfyUI release...
REM Get the latest release URL using GitHub API
curl -k -L -o ComfyUI_windows_portable_nvidia.7z https://github.com/comfyanonymous/ComfyUI/releases/latest/download/ComfyUI_windows_portable_nvidia.7z


if !errorlevel! neq 0 (
    echo Error downloading ComfyUI. Please check your internet connection and try again.
    goto end
)

echo Download completed successfully.

REM Step 2: Extract the downloaded file using 7-Zip
echo Extracting ComfyUI...
"C:\Program Files\7-Zip\7z.exe" x ComfyUI_windows_portable_nvidia.7z

if !errorlevel! neq 0 (
    echo Error extracting the file. The file may be corrupted.
) else (
    echo Extraction completed successfully.
)


REM Step 3: Clone the custom nodes repository
echo Cloning custom nodes...
git clone https://github.com/ltdrdata/ComfyUI-Manager.git "ComfyUI_windows_portable\ComfyUI\custom_nodes\ComfyUI-Manager"
git clone https://github.com/rgthree/rgthree-comfy.git "ComfyUI_windows_portable\ComfyUI\custom_nodes\rgthree-comfy"


if !errorlevel! neq 0 (
    echo Error cloning the custom nodes repositories. Please check your internet connection and ensure git is installed.
) else (
    echo Custom nodes cloned successfully.
)

REM The Viggle node pack lives inside Viggle's model repo, so its two files are downloaded directly
echo Downloading the Viggle Remake nodes...
if not exist "ComfyUI_windows_portable\ComfyUI\custom_nodes\ComfyUI-Viggle-Remake" mkdir "ComfyUI_windows_portable\ComfyUI\custom_nodes\ComfyUI-Viggle-Remake"
curl -f -k -L -o "ComfyUI_windows_portable\ComfyUI\custom_nodes\ComfyUI-Viggle-Remake\__init__.py" "https://huggingface.co/Viggle/Viggle-Remake/resolve/main/comfyui/ComfyUI-Viggle-Remake/__init__.py?download=true"
curl -f -k -L -o "ComfyUI_windows_portable\ComfyUI\custom_nodes\ComfyUI-Viggle-Remake\nodes.py" "https://huggingface.co/Viggle/Viggle-Remake/resolve/main/comfyui/ComfyUI-Viggle-Remake/nodes.py?download=true"

if !errorlevel! neq 0 (
    echo Error downloading the Viggle Remake nodes. Please check your internet connection and try again.
    goto end
)

REM Step 4: Install requirements
cd ComfyUI_windows_portable
echo Installing requirements...
.\python_embeded\python.exe -m pip install -r .\ComfyUI\custom_nodes\ComfyUI-Manager\requirements.txt
.\python_embeded\python.exe -m pip install torch==2.11.0+cu130 torchvision==0.26.0+cu130 torchaudio==2.11.0+cu130 --index-url https://download.pytorch.org/whl/cu130

REM Step 5: Any workflow .json placed next to this installer is added to the Workflows sidebar
echo Adding the workflow...
if not exist "ComfyUI\user\default\workflows" mkdir "ComfyUI\user\default\workflows"
for %%F in ("%~dp0*.json") do copy /Y "%%F" "ComfyUI\user\default\workflows\" >nul


REM ======== Model download menu ========
echo.
echo ============================================================
echo   Viggle Remake Character Swap - Model Download Options
echo ============================================================
echo   [A] Everything ....................... ~43 GB
echo        Viggle swap model, text encoder and both VAEs
echo   [B] Viggle swap model only ........... ~21 GB
echo        if you already have the MiniMax H3 text encoder
echo        (nvfp4) and both VAEs
echo   [S] Skip - I will download models myself
echo ============================================================
choice /C ABS /M "Choose a download option:"
set MODELOPT=!errorlevel!

if !MODELOPT!==3 (
    echo Skipping model downloads.
    goto post_models
)

echo Downloading models...

if not exist "ComfyUI\models\diffusion_models" mkdir "ComfyUI\models\diffusion_models"
if not exist "ComfyUI\models\text_encoders" mkdir "ComfyUI\models\text_encoders"
if not exist "ComfyUI\models\vae" mkdir "ComfyUI\models\vae"

REM --- Viggle swap model (A, B) ---
curl -f -k -L -o ComfyUI\models\diffusion_models\viggle_remake_swap_pruned_int8_convrot.safetensors "https://huggingface.co/Viggle/Viggle-Remake/resolve/main/int8/viggle_remake_swap_pruned_int8_convrot.safetensors?download=true"

REM --- Text encoder and VAEs (A) ---
if !MODELOPT!==1 goto dl_shared
goto skip_shared
:dl_shared
curl -f -k -L -o ComfyUI\models\text_encoders\qwen3vl_32b_minimax_h3_nvfp4_awq.safetensors "https://huggingface.co/Comfy-Org/MiniMax-H3/resolve/main/text_encoders/qwen3vl_32b_minimax_h3_nvfp4_awq.safetensors?download=true"
curl -f -k -L -o ComfyUI\models\vae\minimax_h3_video_vae_fp16.safetensors "https://huggingface.co/Comfy-Org/MiniMax-H3/resolve/main/vae/minimax_h3_video_vae_fp16.safetensors?download=true"
curl -f -k -L -o ComfyUI\models\vae\minimax_h3_audio_vae_fp32.safetensors "https://huggingface.co/Comfy-Org/MiniMax-H3/resolve/main/vae/minimax_h3_audio_vae_fp32.safetensors?download=true"
:skip_shared

:post_models
cd update
REM call + nopause: come back here afterwards and skip the updater's own pause
call .\update_comfyui.bat nopause
cd ..

echo.
echo Setup complete
echo Start ComfyUI with run_nvidia_gpu.bat and open "Viggle-Remake-Swap-LocalLab" from the Workflows sidebar.
echo (It is added when it sits next to this installer. It uses PyTorch for CUDA 13, so update your NVIDIA driver to 580 or newer.)

:end
REM Keep the window open
pause
