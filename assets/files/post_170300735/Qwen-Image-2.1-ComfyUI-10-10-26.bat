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
git clone https://github.com/city96/ComfyUI-GGUF.git "ComfyUI_windows_portable\ComfyUI\custom_nodes\ComfyUI-GGUF"
git clone https://github.com/rgthree/rgthree-comfy.git "ComfyUI_windows_portable\ComfyUI\custom_nodes\rgthree-comfy"

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
.\python_embeded\python.exe -m pip install -r .\ComfyUI\custom_nodes\rgthree-comfy\requirements.txt
.\python_embeded\python.exe -m pip install torch==2.8.0+cu128 torchvision==0.23.0+cu128 torchaudio==2.8.0+cu128 --index-url https://download.pytorch.org/whl/cu128

REM ======== Model download menu ========
echo.
echo ============================================================
echo   Qwen-Image 2.1 - Model Download Options
echo ============================================================
echo   Shared models (VAE) download with any choice.
echo.
echo   BASE MODEL:
echo   [1] FP8 (int8) - standard, higher quality, needs ~16 GB VRAM
echo   [2] GGUF (Q5_K_M) - standard, low VRAM, runs on 6-8 GB
echo   [3] TURBO int8 (official Qwen team) - 8-step speed, no LoRA, ~16 GB
echo   [4] TURBO bf16 (official Qwen team) - full precision, ~14 GB file
echo.
echo   TEXT ENCODER:
echo   [A] int8 - standard
echo   [B] w4a8 - extra low VRAM
echo.
echo   TURBO LoRA (optional - 4-6 step editing):
echo   [N] None
echo   [V] Viggle 6-step (by Viggle)
echo   [P] Alibaba-PAI 4-step (by Alibaba-PAI)
echo   [O] Both turbo LoRAs
echo ============================================================
choice /C 1234 /M "Pick a base model (1=FP8, 2=GGUF, 3=Turbo int8, 4=Turbo bf16):"
set BASEOPT=!errorlevel!
choice /C AB /M "Pick a text encoder (A=int8, B=w4a8):"
set ENCOPT=!errorlevel!
choice /C NVPO /M "Pick a turbo LoRA (N=none, V=Viggle, P=Alibaba-PAI, O=both):"
set TURBOOPT=!errorlevel!

echo.
echo Downloading models...

REM --- Shared: VAE (always) ---
curl -k -L -o ComfyUI\models\vae\qwen_image_2.1_vae_bf16.safetensors "https://huggingface.co/Comfy-Org/Qwen-Image-2.1/resolve/main/vae/qwen_image_2.1_vae_bf16.safetensors?download=true"

REM --- Base model ---
if !BASEOPT!==1 curl -k -L -o ComfyUI\models\diffusion_models\qwen_image_2.1_int8_convrot.safetensors "https://huggingface.co/Comfy-Org/Qwen-Image-2.1/resolve/main/diffusion_models/qwen_image_2.1_int8_convrot.safetensors?download=true"
if !BASEOPT!==2 curl -k -L -o ComfyUI\models\unet\qwen_image_2.1_Q5_K_M.gguf "https://huggingface.co/Abiray/Qwen-Image-2.1-GGUF/resolve/main/qwen_image_2.1_Q5_K_M.gguf?download=true"
if !BASEOPT!==3 curl -k -L -o ComfyUI\models\diffusion_models\qwen_image_2.1_turbo_int8_convrot.safetensors "https://huggingface.co/Comfy-Org/Qwen-Image-2.1/resolve/main/diffusion_models/qwen_image_2.1_turbo_int8_convrot.safetensors?download=true"
if !BASEOPT!==4 curl -k -L -o ComfyUI\models\diffusion_models\qwen_image_2.1_turbo_bf16.safetensors "https://huggingface.co/Comfy-Org/Qwen-Image-2.1/resolve/main/diffusion_models/qwen_image_2.1_turbo_bf16.safetensors?download=true"

REM --- Text encoder ---
if !ENCOPT!==1 curl -k -L -o ComfyUI\models\text_encoders\qwen3vl_8b_int8_convrot.safetensors "https://huggingface.co/Comfy-Org/Qwen-Image-2.1/resolve/main/text_encoders/qwen3vl_8b_int8_convrot.safetensors?download=true"
if !ENCOPT!==2 curl -k -L -o ComfyUI\models\text_encoders\qwen3vl_8b_w4a8.safetensors "https://huggingface.co/Comfy-Org/Qwen-Image-2.1/resolve/main/text_encoders/qwen3vl_8b_w4a8.safetensors?download=true"

REM --- Turbo LoRAs (optional) -> models\loras\ ---
if !TURBOOPT!==2 curl -k -L -o ComfyUI\models\loras\Qwen-Image-2.1-viggle-turbo-v0.2.1-6step-lora-r256.safetensors "https://huggingface.co/Viggle/Qwen-Image-2.1-viggle-turbo/resolve/main/Qwen-Image-2.1-viggle-turbo-v0.2.1-6step-lora-r256.safetensors?download=true"
if !TURBOOPT!==3 curl -k -L -o ComfyUI\models\loras\Qwen-Image-2.1-Fun-Acc-4Step.safetensors "https://huggingface.co/alibaba-pai/Qwen-Image-2.1-Fun-Acc-LoRAs/resolve/main/models/Qwen-Image-2.1-Fun-Acc-4Step.safetensors?download=true"
if !TURBOOPT!==4 curl -k -L -o ComfyUI\models\loras\Qwen-Image-2.1-viggle-turbo-v0.2.1-6step-lora-r256.safetensors "https://huggingface.co/Viggle/Qwen-Image-2.1-viggle-turbo/resolve/main/Qwen-Image-2.1-viggle-turbo-v0.2.1-6step-lora-r256.safetensors?download=true"
if !TURBOOPT!==4 curl -k -L -o ComfyUI\models\loras\Qwen-Image-2.1-Fun-Acc-4Step.safetensors "https://huggingface.co/alibaba-pai/Qwen-Image-2.1-Fun-Acc-LoRAs/resolve/main/models/Qwen-Image-2.1-Fun-Acc-4Step.safetensors?download=true"

cd update
.\update_comfyui.bat
cd ..

echo.
echo Setup complete
pause

:end
pause
