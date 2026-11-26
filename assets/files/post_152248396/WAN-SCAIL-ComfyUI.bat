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
git clone https://github.com/kijai/ComfyUI-KJNodes.git "ComfyUI_windows_portable\ComfyUI\custom_nodes\ComfyUI-KJNodes"
git clone https://github.com/rgthree/rgthree-comfy.git "ComfyUI_windows_portable\ComfyUI\custom_nodes\rgthree-comfy"
git clone https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite.git "ComfyUI_windows_portable\ComfyUI\custom_nodes\ComfyUI-VideoHelperSuite"
git clone https://github.com/kijai/ComfyUI-WanVideoWrapper.git "ComfyUI_windows_portable\ComfyUI\custom_nodes\ComfyUI-WanVideoWrapper"
git clone https://github.com/pythongosssss/ComfyUI-Custom-Scripts.git "ComfyUI_windows_portable\ComfyUI\custom_nodes\ComfyUI-Custom-Scripts"
git clone https://github.com/chflame163/ComfyUI_LayerStyle.git "ComfyUI_windows_portable\ComfyUI\custom_nodes\ComfyUI_LayerStyle"
git clone https://github.com/yolain/ComfyUI-Easy-Use.git "ComfyUI_windows_portable\ComfyUI\custom_nodes\ComfyUI-Easy-Use"
git clone https://github.com/kijai/ComfyUI-SCAIL-Pose.git "ComfyUI_windows_portable\ComfyUI\custom_nodes\ComfyUI-SCAIL-Pose"
git clone https://github.com/kijai/ComfyUI-WanAnimatePreprocess.git "ComfyUI_windows_portable\ComfyUI\custom_nodes\ComfyUI-WanAnimatePreprocess"

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
.\python_embeded\python.exe -m pip install -r .\ComfyUI\custom_nodes\ComfyUI-WanVideoWrapper\requirements.txt
.\python_embeded\python.exe -m pip install -r .\ComfyUI\custom_nodes\ComfyUI-KJNodes\requirements.txt
.\python_embeded\python.exe -m pip install -r .\ComfyUI\custom_nodes\rgthree-comfy\requirements.txt
.\python_embeded\python.exe -m pip install -r .\ComfyUI\custom_nodes\ComfyUI-VideoHelperSuite\requirements.txt
.\python_embeded\python.exe -m pip install -r .\ComfyUI\custom_nodes\ComfyUI_LayerStyle\requirements.txt
.\python_embeded\python.exe -m pip install -r .\ComfyUI\custom_nodes\ComfyUI-SCAIL-Pose\requirements.txt
.\python_embeded\python.exe -m pip install -r .\ComfyUI\custom_nodes\ComfyUI-WanAnimatePreprocess\requirements.txt
.\python_embeded\python.exe -m pip install --no-cache-dir --upgrade numba


REM Step 5: Download models
echo Downloading models...
mkdir ComfyUI\models\detection
curl -k -L -o ComfyUI\models\unet\Wan21-14B-SCAIL-preview_comfy-Q3_K_S.gguf https://huggingface.co/vantagewithai/SCAIL-Preview-GGUF/resolve/main/Wan21-14B-SCAIL-preview_comfy-Q3_K_S.gguf?download=true
curl -k -L -o ComfyUI\models\clip\umt5-xxl-enc-fp8_e4m3fn.safetensors https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/umt5-xxl-enc-fp8_e4m3fn.safetensors?download=true
curl -k -L -o ComfyUI\models\vae\wan_2.1_vae.safetensors https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/vae/wan_2.1_vae.safetensors?download=true
curl -k -L -o ComfyUI\models\upscale_models\1x-SwatKatsLite.pth https://huggingface.co/Thelocallab/1x-SwatKatsLite/resolve/main/1x-SwatKatsLite.pth?download=true
curl -k -L -o ComfyUI\models\upscale_models\2xLexicaRRDBNet_Sharp.pth https://huggingface.co/Thelocallab/2xLexicaRRDBNet_Sharp/resolve/main/2xLexicaRRDBNet_Sharp.pth?download=true
curl -k -L -o ComfyUI\models\loras\Wan21_I2V_14B_lightx2v_cfg_step_distill_lora_rank64.safetensors https://huggingface.co/lightx2v/Wan2.1-I2V-14B-720P-StepDistill-CfgDistill-Lightx2v/resolve/main/loras/Wan21_I2V_14B_lightx2v_cfg_step_distill_lora_rank64.safetensors?download=true
curl -k -L -o ComfyUI\models\clip_vision\clip_vision_h.safetensors https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/clip_vision/clip_vision_h.safetensors?download=true
curl -k -L -o ComfyUI\models\detection\vitpose-l-wholebody.onnx https://huggingface.co/JunkyByte/easy_ViTPose/resolve/main/onnx/wholebody/vitpose-l-wholebody.onnx?download=true
curl -k -L -o ComfyUI\models\detection\yolov10m.onnx https://huggingface.co/Wan-AI/Wan2.2-Animate-14B/resolve/main/process_checkpoint/det/yolov10m.onnx?download=true


:end
echo Setup complete

REM Keep the window open