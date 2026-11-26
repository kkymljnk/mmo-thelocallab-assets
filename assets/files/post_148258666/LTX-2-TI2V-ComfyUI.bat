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
git clone https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite.git "ComfyUI_windows_portable\ComfyUI\custom_nodes\ComfyUI-VideoHelperSuite"
git clone https://github.com/Lightricks/ComfyUI-LTXVideo.git "ComfyUI_windows_portable\ComfyUI\custom_nodes\ComfyUI-LTXVideo"
git clone https://github.com/ClownsharkBatwing/RES4LYF.git "ComfyUI_windows_portable\ComfyUI\custom_nodes\RES4LYF"
git clone https://github.com/kijai/ComfyUI-MelBandRoFormer.git "ComfyUI_windows_portable\ComfyUI\custom_nodes\ComfyUI-MelBandRoFormer"
git clone https://github.com/theUpsider/ComfyUI-Logic.git "ComfyUI_windows_portable\ComfyUI\custom_nodes\ComfyUI-Logic"
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
.\python_embeded\python.exe -m pip install torch==2.8.0+cu128 torchvision==0.23.0+cu128 torchaudio==2.8.0+cu128 --index-url https://download.pytorch.org/whl/cu128
.\python_embeded\python.exe -m pip install -r .\ComfyUI\custom_nodes\ComfyUI-Manager\requirements.txt
.\python_embeded\python.exe -m pip install -r .\ComfyUI\custom_nodes\ComfyUI-GGUF\requirements.txt
.\python_embeded\python.exe -m pip install -r .\ComfyUI\custom_nodes\ComfyUI-KJNodes\requirements.txt
.\python_embeded\python.exe -m pip install -r .\ComfyUI\custom_nodes\rgthree-comfy\requirements.txt
.\python_embeded\python.exe -m pip install -r .\ComfyUI\custom_nodes\ComfyUI-VideoHelperSuite\requirements.txt
.\python_embeded\python.exe -m pip install -r .\ComfyUI\custom_nodes\ComfyUI-LTXVideo\requirements.txt
.\python_embeded\python.exe -m pip install -r .\ComfyUI\custom_nodes\RES4LYF\requirements.txt
.\python_embeded\python.exe -m pip install -r .\ComfyUI\custom_nodes\ComfyUI-MelBandRoFormer\requirements.txt
.\python_embeded\python.exe -m pip install -r .\ComfyUI\custom_nodes\ComfyUI-Logic\requirements.txt
.\python_embeded\python.exe -m pip install -r .\ComfyUI\custom_nodes\rgthree-comfy\requirements.txt

REM Step 5: Download models
echo Downloading models...
curl -k -L -o ComfyUI\models\unet\LTX-2-dev-Q3_K_S.gguf https://huggingface.co/QuantStack/LTX-2-GGUF/resolve/main/LTX-2-dev/LTX-2-dev-Q3_K_S.gguf?download=true
curl -k -L -o ComfyUI\models\clip\ltx-2-19b-embeddings_connector_dev_bf16.safetensors https://huggingface.co/Kijai/LTXV2_comfy/resolve/main/text_encoders/ltx-2-19b-embeddings_connector_dev_bf16.safetensors?download=true
curl -k -L -o ComfyUI\models\clip\gemma-3-12b-it-UD-Q4_K_XL.gguf https://huggingface.co/unsloth/gemma-3-12b-it-GGUF/resolve/main/gemma-3-12b-it-UD-Q4_K_XL.gguf?download=true
curl -k -L -o ComfyUI\models\vae\LTX2_audio_vae_bf16.safetensors https://huggingface.co/Kijai/LTXV2_comfy/resolve/main/VAE/LTX2_audio_vae_bf16.safetensors?download=true
curl -k -L -o ComfyUI\models\vae\LTX2_video_vae_bf16.safetensors https://huggingface.co/Kijai/LTXV2_comfy/resolve/main/VAE/LTX2_video_vae_bf16.safetensors?download=true
curl -k -L -o ComfyUI\models\latent_upscale_models\ltx-2-spatial-upscaler-x2-1.0.safetensors https://huggingface.co/Lightricks/LTX-2/resolve/main/ltx-2-spatial-upscaler-x2-1.0.safetensors?download=true
curl -k -L -o ComfyUI\models\latent_upscale_models\ltx-2-temporal-upscaler-x2-1.0.safetensors https://huggingface.co/Lightricks/LTX-2/resolve/main/ltx-2-temporal-upscaler-x2-1.0.safetensors?download=true
curl -k -L -o ComfyUI\models\loras\ltx-2-19b-ic-lora-detailer.safetensors https://huggingface.co/Lightricks/LTX-2-19b-IC-LoRA-Detailer/resolve/main/ltx-2-19b-ic-lora-detailer.safetensors?download=true
curl -k -L -o ComfyUI\models\loras\ltx-2-19b-distilled-lora-384.safetensors https://huggingface.co/Lightricks/LTX-2/resolve/main/ltx-2-19b-distilled-lora-384.safetensors?download=true
curl -k -L -o ComfyUI\models\loras\ltx-2-19b-lora-camera-control-static.safetensors https://huggingface.co/Lightricks/LTX-2-19b-LoRA-Camera-Control-Static/resolve/main/ltx-2-19b-lora-camera-control-static.safetensors?download=true
curl -k -L -o ComfyUI\models\diffusion_models\MelBandRoformer_fp32.safetensors https://huggingface.co/Kijai/MelBandRoFormer_comfy/resolve/main/MelBandRoformer_fp32.safetensors?download=true


:end
echo Setup complete

REM Keep the window open
pause