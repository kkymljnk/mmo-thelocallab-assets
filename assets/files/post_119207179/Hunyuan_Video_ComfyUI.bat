@echo off
setlocal EnableDelayedExpansion

REM Check if Git is installed
where git >nul 2>nul
if !errorlevel! neq 0 (
    echo Git not found. Downloading and installing...
    
    REM Download Git installer
    curl -L -o git-installer.exe "https://github.com/git-for-windows/git/releases/download/v2.44.0.windows.1/Git-2.44.0-64-bit.exe"
    
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
git clone https://github.com/ltdrdata/ComfyUI-Manager.git "ComfyUI_windows_portable/ComfyUI/custom_nodes/ComfyUI-Manager" 
git clone https://github.com/city96/ComfyUI-GGUF.git "ComfyUI_windows_portable/ComfyUI/custom_nodes/ComfyUI-GGUF"
git clone https://github.com/al-swaiti/ComfyUI-OllamaGemini.git "ComfyUI_windows_portable/ComfyUI/custom_nodes/ComfyUI-OllamaGemini"
git clone https://github.com/stavsap/comfyui-ollama.git "ComfyUI_windows_portable/ComfyUI/custom_nodes/comfyui-ollama"
git clone https://github.com/jjkramhoeft/ComfyUI-Jjk-Nodes.git "ComfyUI_windows_portable/ComfyUI/custom_nodes/ComfyUI-Jjk-Nodes"
git clone https://github.com/kijai/ComfyUI-KJNodes.git "ComfyUI_windows_portable/ComfyUI/custom_nodes/ComfyUI-KJNodes"
git clone https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite.git "ComfyUI_windows_portable/ComfyUI/custom_nodes/ComfyUI-VideoHelperSuite"
git clone https://github.com/kijai/ComfyUI-HunyuanVideoWrapper.git "ComfyUI_windows_portable/ComfyUI/custom_nodes/ComfyUI-HunyuanVideoWrapper"



if !errorlevel! neq 0 (
    echo Error cloning the custom nodes repositories. Please check your internet connection and ensure git is installed.
) else (
    echo Custom nodes cloned successfully.
)

REM Step 4: Install requirements
cd ComfyUI_windows_portable
echo Installing requirements...
.\python_embeded\python.exe -m pip install -r .\ComfyUI\custom_nodes\ComfyUI-GGUF\requirements.txt
.\python_embeded\python.exe -m pip install opencv_python==4.10.0.82
.\python_embeded\python.exe -m pip install sageattention
.\python_embeded\python.exe -m pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118
.\python_embeded\python.exe -m pip install -r .\ComfyUI\custom_nodes\ComfyUI-Manager\requirements.txt
.\python_embeded\python.exe -m pip install -r .\ComfyUI\custom_nodes\ComfyUI-VideoHelperSuite\requirements.txt
.\python_embeded\python.exe -m pip install -r .\ComfyUI\custom_nodes\ComfyUI-OllamaGemini\requirements.txt
.\python_embeded\python.exe -m pip install -r .\ComfyUI\custom_nodes\ComfyUI-KJNodes\requirements.txt
.\python_embeded\python.exe -m pip install -r .\ComfyUI\custom_nodes\ComfyUI-HunyuanVideoWrapper\requirements.txt
.\python_embeded\python.exe -m pip install -r .\ComfyUI\custom_nodes\comfyui-ollama\requirements.txt

REM Step 5: Download models
echo Downloading models...

REM Prompt user for model download choice
echo Choose which models to download:
echo 1. FastVideo Model (Requires ~25 GB of space)
echo 2. GGUF Model (Requires ~19 GB of space)
echo 3. Both Models (Requires ~44 GB of space)
set /p "choice=Enter your choice (1, 2, or 3): "

if "%choice%"=="1" (
    echo Downloading FastVideo model and its dependencies...
    curl -L -o ComfyUI\models\diffusion_models\hunyuan_video_FastVideo_720_fp8_e4m3fn.safetensors https://huggingface.co/Kijai/HunyuanVideo_comfy/resolve/main/hunyuan_video_FastVideo_720_fp8_e4m3fn.safetensors?download=true
    curl -L -o ComfyUI\models\vae\hunyuan_video_vae_fp32.safetensors https://huggingface.co/Kijai/HunyuanVideo_comfy/resolve/main/hunyuan_video_vae_fp32.safetensors?download=true
    curl -L -o ComfyUI\models\clip\clip_l.safetensors https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/clip_l.safetensors?download=true
    curl -L -o ComfyUI\models\clip\llava_llama3_fp8_scaled.safetensors https://huggingface.co/Comfy-Org/HunyuanVideo_repackaged/resolve/main/split_files/text_encoders/llava_llama3_fp8_scaled.safetensors?download=true
    curl -L -o ComfyUI\models\loras\SECRET_SAUCE_B3_Hunyuan.safetensors https://huggingface.co/Thelocallab/SECRET_SAUCE_B3_Hunyuan/resolve/main/SECRET_SAUCE_B3_Hunyuan.safetensors?download=true
) else if "%choice%"=="2" (
    echo Downloading GGUF model and its dependencies...
    curl -L -o ComfyUI\models\unet\hunyuan-video-t2v-720p-Q4_K_M.gguf https://huggingface.co/city96/HunyuanVideo-gguf/resolve/main/hunyuan-video-t2v-720p-Q4_K_M.gguf?download=true
    curl -L -o ComfyUI\models\vae\hunyuan_video_vae_fp32.safetensors https://huggingface.co/Kijai/HunyuanVideo_comfy/resolve/main/hunyuan_video_vae_fp32.safetensors?download=true
    curl --ssl-no-revoke -L -o ComfyUI\models\clip\clip-vit-large-patch14.safetensors https://huggingface.co/openai/clip-vit-large-patch14/resolve/main/model.safetensors?download=true
    curl -L -o ComfyUI\models\clip\llava_llama3_fp8_scaled.safetensors https://huggingface.co/Comfy-Org/HunyuanVideo_repackaged/resolve/main/split_files/text_encoders/llava_llama3_fp8_scaled.safetensors?download=true
    curl -L -o ComfyUI\models\loras\hyvideo_FastVideo_LoRA-fp8.safetensors https://huggingface.co/Kijai/HunyuanVideo_comfy/resolve/main/hyvideo_FastVideo_LoRA-fp8.safetensors?download=true
    curl -L -o ComfyUI\models\loras\SECRET_SAUCE_B3_Hunyuan.safetensors https://huggingface.co/Thelocallab/SECRET_SAUCE_B3_Hunyuan/resolve/main/SECRET_SAUCE_B3_Hunyuan.safetensors?download=true
) else if "%choice%"=="3" (
    echo Downloading both models and their dependencies...
    curl -L -o ComfyUI\models\unet\hunyuan-video-t2v-720p-Q4_K_M.gguf https://huggingface.co/city96/HunyuanVideo-gguf/resolve/main/hunyuan-video-t2v-720p-Q4_K_M.gguf?download=true
    curl -L -o ComfyUI\models\diffusion_models\hunyuan_video_FastVideo_720_fp8_e4m3fn.safetensors https://huggingface.co/Kijai/HunyuanVideo_comfy/resolve/main/hunyuan_video_FastVideo_720_fp8_e4m3fn.safetensors?download=true
    curl -L -o ComfyUI\models\vae\hunyuan_video_vae_fp32.safetensors https://huggingface.co/Kijai/HunyuanVideo_comfy/resolve/main/hunyuan_video_vae_fp32.safetensors?download=true
    curl -L -o ComfyUI\models\clip\clip_l.safetensors https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/clip_l.safetensors?download=true
    curl --ssl-no-revoke -L -o ComfyUI\models\clip\clip-vit-large-patch14.safetensors https://huggingface.co/openai/clip-vit-large-patch14/resolve/main/model.safetensors?download=true
    curl -L -o ComfyUI\models\clip\llava_llama3_fp8_scaled.safetensors https://huggingface.co/Comfy-Org/HunyuanVideo_repackaged/resolve/main/split_files/text_encoders/llava_llama3_fp8_scaled.safetensors?download=true
    curl -L -o ComfyUI\models\loras\hyvideo_FastVideo_LoRA-fp8.safetensors https://huggingface.co/Kijai/HunyuanVideo_comfy/resolve/main/hyvideo_FastVideo_LoRA-fp8.safetensors?download=true
    curl -L -o ComfyUI\models\loras\SECRET_SAUCE_B3_Hunyuan.safetensors https://huggingface.co/Thelocallab/SECRET_SAUCE_B3_Hunyuan/resolve/main/SECRET_SAUCE_B3_Hunyuan.safetensors?download=true
) else (
    echo Invalid choice. No models will be downloaded.
)

:end
echo Setup complete

REM Keep the window open
pause