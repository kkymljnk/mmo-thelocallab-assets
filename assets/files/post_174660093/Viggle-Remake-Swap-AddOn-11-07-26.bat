@echo off
setlocal EnableDelayedExpansion

REM This add-on goes in your ComfyUI_windows_portable folder (next to python_embeded and the ComfyUI folder)
cd /d "%~dp0"
if not exist "python_embeded\python.exe" (
    echo python_embeded not found. Put this file in your ComfyUI_windows_portable folder and run it again.
    goto end
)

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

REM Step 3: Clone the custom nodes repository
echo Cloning custom nodes...
if not exist "ComfyUI\custom_nodes\ComfyUI-Manager" git clone https://github.com/ltdrdata/ComfyUI-Manager.git "ComfyUI\custom_nodes\ComfyUI-Manager"
if not exist "ComfyUI\custom_nodes\rgthree-comfy" git clone https://github.com/rgthree/rgthree-comfy.git "ComfyUI\custom_nodes\rgthree-comfy"

REM The Viggle node pack lives inside Viggle's model repo, so its two files are downloaded directly
echo Downloading the Viggle Remake nodes...
if not exist "ComfyUI\custom_nodes\ComfyUI-Viggle-Remake" mkdir "ComfyUI\custom_nodes\ComfyUI-Viggle-Remake"
curl -f -k -L -o "ComfyUI\custom_nodes\ComfyUI-Viggle-Remake\__init__.py" "https://huggingface.co/Viggle/Viggle-Remake/resolve/main/comfyui/ComfyUI-Viggle-Remake/__init__.py?download=true"
curl -f -k -L -o "ComfyUI\custom_nodes\ComfyUI-Viggle-Remake\nodes.py" "https://huggingface.co/Viggle/Viggle-Remake/resolve/main/comfyui/ComfyUI-Viggle-Remake/nodes.py?download=true"

if !errorlevel! neq 0 (
    echo Error downloading the Viggle Remake nodes. Please check your internet connection and try again.
    goto end
)

REM Step 5: Any workflow .json placed next to this add-on is added to the Workflows sidebar (your torch is not touched)
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
if not exist "ComfyUI\models\diffusion_models\viggle_remake_swap_pruned_int8_convrot.safetensors" curl -f -k -L -o ComfyUI\models\diffusion_models\viggle_remake_swap_pruned_int8_convrot.safetensors "https://huggingface.co/Viggle/Viggle-Remake/resolve/main/int8/viggle_remake_swap_pruned_int8_convrot.safetensors?download=true"

REM --- Text encoder and VAEs (A) ---
if !MODELOPT!==1 goto dl_shared
goto skip_shared
:dl_shared
if not exist "ComfyUI\models\text_encoders\qwen3vl_32b_minimax_h3_nvfp4_awq.safetensors" curl -f -k -L -o ComfyUI\models\text_encoders\qwen3vl_32b_minimax_h3_nvfp4_awq.safetensors "https://huggingface.co/Comfy-Org/MiniMax-H3/resolve/main/text_encoders/qwen3vl_32b_minimax_h3_nvfp4_awq.safetensors?download=true"
if not exist "ComfyUI\models\vae\minimax_h3_video_vae_fp16.safetensors" curl -f -k -L -o ComfyUI\models\vae\minimax_h3_video_vae_fp16.safetensors "https://huggingface.co/Comfy-Org/MiniMax-H3/resolve/main/vae/minimax_h3_video_vae_fp16.safetensors?download=true"
if not exist "ComfyUI\models\vae\minimax_h3_audio_vae_fp32.safetensors" curl -f -k -L -o ComfyUI\models\vae\minimax_h3_audio_vae_fp32.safetensors "https://huggingface.co/Comfy-Org/MiniMax-H3/resolve/main/vae/minimax_h3_audio_vae_fp32.safetensors?download=true"
:skip_shared

:post_models
echo.
echo Setup complete
echo Start ComfyUI with run_nvidia_gpu.bat and open "Viggle-Remake-Swap-LocalLab" from the Workflows sidebar.
echo (This add-on leaves your torch alone. I tested on PyTorch for CUDA 13, which was about twice as fast as CUDA 12.8.)

:end
REM Keep the window open
pause
