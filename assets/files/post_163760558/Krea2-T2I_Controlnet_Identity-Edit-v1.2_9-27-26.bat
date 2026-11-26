@echo off
setlocal EnableDelayedExpansion

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
git clone https://github.com/city96/ComfyUI-GGUF.git "ComfyUI_windows_portable\ComfyUI\custom_nodes\ComfyUI-GGUF"
git clone https://github.com/kijai/ComfyUI-KJNodes.git "ComfyUI_windows_portable\ComfyUI\custom_nodes\ComfyUI-KJNodes"
git clone https://github.com/rgthree/rgthree-comfy.git "ComfyUI_windows_portable\ComfyUI\custom_nodes\rgthree-comfy"
git clone https://github.com/lbouaraba/comfyui-krea2edit.git "ComfyUI_windows_portable\ComfyUI\custom_nodes\comfyui-krea2edit"
git clone https://github.com/facok/comfyui-krea2-controlnet.git "ComfyUI_windows_portable\ComfyUI\custom_nodes\comfyui-krea2-controlnet"
git clone https://github.com/Fannovel16/comfyui_controlnet_aux.git "ComfyUI_windows_portable\ComfyUI\custom_nodes\comfyui_controlnet_aux"
git clone https://github.com/pythongosssss/ComfyUI-Custom-Scripts.git "ComfyUI_windows_portable\ComfyUI\custom_nodes\ComfyUI-Custom-Scripts"
git clone https://github.com/lumenastrum/clio-style-preview "ComfyUI_windows_portable\ComfyUI\custom_nodes\clio-style-node"

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
.\python_embeded\python.exe -m pip install -r .\ComfyUI\custom_nodes\ComfyUI-GGUF\requirements.txt
.\python_embeded\python.exe -m pip install -r .\ComfyUI\custom_nodes\ComfyUI-KJNodes\requirements.txt
.\python_embeded\python.exe -m pip install -r .\ComfyUI\custom_nodes\rgthree-comfy\requirements.txt
.\python_embeded\python.exe -m pip install -r .\ComfyUI\custom_nodes\comfyui_controlnet_aux\requirements.txt
.\python_embeded\python.exe -m pip install torch==2.8.0+cu128 torchvision==0.23.0+cu128 torchaudio==2.8.0+cu128 --index-url https://download.pytorch.org/whl/cu128
.\python_embeded\python.exe -m pip install --no-cache-dir --upgrade numba
.\python_embeded\python.exe -m pip install -U "triton-windows<3.5"

REM ======== Model download menu ========
echo.
echo ============================================================
echo   Krea 2 - Model Download Options
echo ============================================================
echo   Shared models (text encoder + VAE) download with any choice.
echo.
echo   BASE MODEL:
echo   [1] GGUF (Q4) - low VRAM, smaller download
echo   [2] FP8 - higher quality, needs more VRAM
echo.
echo   Then you'll choose which LoRAs to add.
echo ============================================================
choice /C 12 /M "Pick a base model (1=GGUF, 2=FP8):"
set BASEOPT=!errorlevel!

echo.
echo   LoRA OPTIONS:
echo   [A] All LoRAs (Identity Edit + Depth ControlNet + 2-Step Turbo)
echo   [I] Identity Edit + Depth ControlNet only (no turbo)
echo   [T] 2-Step Turbo LoRA only
echo   [N] No LoRAs - base model only
choice /C AITN /M "Pick your LoRAs:"
set LORAOPT=!errorlevel!

echo.
echo Downloading models...

REM --- Shared models (always) ---
curl -k -L -o ComfyUI\models\clip\qwen3vl_4b_fp8_scaled.safetensors "https://huggingface.co/Comfy-Org/Qwen3-VL/resolve/main/text_encoders/qwen3vl_4b_fp8_scaled.safetensors?download=true"
curl -k -L -o ComfyUI\models\vae\qwen_image_vae.safetensors "https://huggingface.co/Comfy-Org/Qwen-Image_ComfyUI/resolve/main/split_files/vae/qwen_image_vae.safetensors?download=true"

REM --- Base model ---
if !BASEOPT!==1 curl -k -L -o ComfyUI\models\unet\krea2_turbo-Q4_0.gguf "https://huggingface.co/vantagewithai/Krea-2-Turbo-GGUF/resolve/main/krea2_turbo-Q4_0.gguf?download=true"
if !BASEOPT!==2 curl -k -L -o ComfyUI\models\diffusion_models\krea2_turbo_fp8.safetensors "https://huggingface.co/AlperKTS/Krea2_FP8/resolve/main/krea2_turbo_fp8.safetensors?download=true"

REM --- Identity Edit + Depth ControlNet (options A, I) ---
if !LORAOPT!==1 goto dl_edit
if !LORAOPT!==2 goto dl_edit
goto skip_edit
:dl_edit
curl -k -L -o ComfyUI\models\loras\krea2_identity_edit_v1_2.safetensors "https://huggingface.co/conradlocke/krea2-identity-edit/resolve/main/krea2_identity_edit_v1_2.safetensors?download=true"
curl -k -L -o ComfyUI\models\loras\depth-control-lora.safetensors "https://huggingface.co/Patil/Krea-2-depth-controlnet/resolve/main/depth-control-lora.safetensors?download=true"
:skip_edit

REM --- 2-Step Turbo LoRA (options A, T) ---
if !LORAOPT!==1 goto dl_turbo
if !LORAOPT!==3 goto dl_turbo
goto skip_turbo
:dl_turbo
curl -k -L -o ComfyUI\models\loras\krea2_turbo_2step_rank_64_lora_comfyui.safetensors "https://huggingface.co/lvladikov/Krea2-Turbo-Distill-2step-LoRA/resolve/main/krea2_turbo_2step_rank_64_lora_comfyui.safetensors?download=true"
:skip_turbo

cd update
.\update_comfyui.bat
cd ..

echo.
echo Setup complete
pause