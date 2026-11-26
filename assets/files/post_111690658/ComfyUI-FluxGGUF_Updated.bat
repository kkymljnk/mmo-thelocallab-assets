@echo off
setlocal EnableDelayedExpansion

REM Check if 7-Zip is installed
if not exist "C:\Program Files\7-Zip\7z.exe" (
    echo 7-Zip not found. Downloading and installing...
    
    REM Download 7-Zip
    curl -L -o 7z2301-x64.exe https://www.7-zip.org/a/7z2301-x64.exe
    
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
echo Downloading ComfyUI...
curl -k -L -o ComfyUI_windows_portable_nvidia.7z https://github.com/comfyanonymous/ComfyUI/releases/latest/download/ComfyUI_windows_portable_nvidia.7z

if !errorlevel! neq 0 (
    echo Error downloading ComfyUI. Please check your internet connection and try again.
    goto end
)

REM Step 2: Extract the downloaded file using 7-Zip
echo Extracting ComfyUI...
"C:\Program Files\7-Zip\7z.exe" x ComfyUI_windows_portable_nvidia.7z

if !errorlevel! neq 0 (
    echo Error extracting the file. The file may be corrupted.
) else (
    echo Extraction completed successfully.
)


REM Step 3: Clone the custom nodes repository
echo Cloning ComfyUI-GGUF...
git clone https://github.com/city96/ComfyUI-GGUF.git "ComfyUI_windows_portable\ComfyUI\custom_nodes\ComfyUI-GGUF"

if !errorlevel! neq 0 (
    echo Error cloning the ComfyUI-GGUF repository. Please check your internet connection and ensure git is installed.
) else (
    echo ComfyUI-GGUF cloned successfully.
)

REM Step 5: Install requirements
cd ComfyUI_windows_portable
echo Installing requirements...
.\python_embeded\python.exe -m pip install -r .\ComfyUI\custom_nodes\ComfyUI-GGUF\requirements.txt

REM Step 6: Download models
echo Downloading models...
curl -L -o ComfyUI\models\unet\flux1-dev-Q4_0.gguf https://huggingface.co/city96/FLUX.1-dev-gguf/resolve/main/flux1-dev-Q4_0.gguf?download=true
curl -L -o ComfyUI\models\clip\clip-vit-large-patch14.safetensors https://huggingface.co/openai/clip-vit-large-patch14/resolve/main/model.safetensors?download=true
curl -L -o ComfyUI\models\clip\t5xxl_fp8_e4m3fn.safetensors https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/t5xxl_fp8_e4m3fn.safetensors?download=true
curl -L -o ComfyUI\models\vae\flux_vae.safetensors https://huggingface.co/nerualdreming/flux_vae/resolve/main/diffusion_pytorch_model.safetensors?download=true
curl -L -o ComfyUI\models\loras\flux-RealismLora.safetensors https://huggingface.co/XLabs-AI/flux-RealismLora/resolve/main/lora.safetensors?download=true

:end
echo Setup complete

REM Keep the window open
pause
