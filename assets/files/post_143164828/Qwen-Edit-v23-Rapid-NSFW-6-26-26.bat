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
git clone https://github.com/calcuis/gguf.git "ComfyUI_windows_portable\ComfyUI\custom_nodes\gguf"
git clone https://github.com/rgthree/rgthree-comfy.git "ComfyUI_windows_portable\ComfyUI\custom_nodes\rgthree-comfy"
git clone https://github.com/chflame163/ComfyUI_LayerStyle.git "ComfyUI_windows_portable\ComfyUI\custom_nodes\ComfyUI_LayerStyle"
git clone https://github.com/pythongosssss/ComfyUI-Custom-Scripts.git "ComfyUI_windows_portable\ComfyUI\custom_nodes\ComfyUI-Custom-Scripts"
git clone https://github.com/ClownsharkBatwing/RES4LYF.git "ComfyUI_windows_portable\ComfyUI\custom_nodes\RES4LYF"
git clone https://github.com/MNeMoNiCuZ/ComfyUI-mnemic-nodes.git "ComfyUI_windows_portable\ComfyUI\custom_nodes\ComfyUI-mnemic-nodes"


if !errorlevel! neq 0 (
    echo Error cloning the custom nodes repositories. Please check your internet connection and ensure git is installed.
) else (
    echo Custom nodes cloned successfully.
)

REM Step 4: Install requirements
cd ComfyUI_windows_portable
echo Installing requirements...
.\python_embeded\python.exe -m pip install meson meson-python
.\python_embeded\python.exe -m pip install opencv_python==4.10.0.82
.\python_embeded\python.exe -m pip install -r .\ComfyUI\custom_nodes\ComfyUI-Manager\requirements.txt
.\python_embeded\python.exe -m pip install -r .\ComfyUI\custom_nodes\ComfyUI-GGUF\requirements.txt
.\python_embeded\python.exe -m pip install -r .\ComfyUI\custom_nodes\rgthree-comfy\requirements.txt
.\python_embeded\python.exe -m pip install -r .\ComfyUI\custom_nodes\ComfyUI_LayerStyle\requirements.txt
.\python_embeded\python.exe -m pip install -r .\ComfyUI\custom_nodes\RES4LYF\requirements.txt
.\python_embeded\python.exe -m pip install -r .\ComfyUI\custom_nodes\ComfyUI-mnemic-nodes\requirements.txt
.\python_embeded\python.exe -m pip install --no-cache-dir --upgrade numba
.\python_embeded\python.exe -m pip install --upgrade anyio
.\python_embeded\python.exe -m pip install --upgrade imageio
.\python_embeded\python.exe -m pip install torch==2.8.0+cu128 torchvision==0.23.0+cu128 torchaudio==2.8.0+cu128 --index-url https://download.pytorch.org/whl/cu128
.\python_embeded\python.exe -m pip install -U "triton-windows<3.5"

REM ======== Ask whether to download models ========
echo.
choice /C YN /M "Press Y for Yes or N for No:"
if errorlevel 2 goto skip_models
if errorlevel 1 goto download_models
goto end

REM Step 5: Download models
:download_models
echo Downloading models...
curl -k -L -o ComfyUI\models\unet\Qwen-Rapid-NSFW-v23_Q3_K.gguf https://huggingface.co/Novice25/Qwen-Image-Edit-Rapid-AIO-GGUF/resolve/main/v23/Qwen-Rapid-NSFW-v23_Q3_K.gguf?download=true
curl -k -L -o ComfyUI\models\text_encoders\qwen_2.5_vl_7b_fp8_scaled.safetensors https://huggingface.co/Comfy-Org/Qwen-Image_ComfyUI/resolve/main/split_files/text_encoders/qwen_2.5_vl_7b_fp8_scaled.safetensors?download=true
curl -k -L -o ComfyUI\models\text_encoders\Qwen2.5-VL-7B-Instruct-mmproj-F16.gguf https://huggingface.co/unsloth/Qwen2.5-VL-7B-Instruct-GGUF/resolve/main/mmproj-F16.gguf?download=true
curl -k -L -o ComfyUI\models\vae\qwen_image_vae.safetensors https://huggingface.co/Comfy-Org/Qwen-Image_ComfyUI/resolve/main/split_files/vae/qwen_image_vae.safetensors?download=true
curl -k -L -o ComfyUI\models\upscale_models\2xLexicaRRDBNet_Sharp.pth https://huggingface.co/Thelocallab/2xLexicaRRDBNet_Sharp/resolve/main/2xLexicaRRDBNet_Sharp.pth?download=true
cd update
.\update_comfyui.bat
goto end

:skip_models
echo Skipping model downloads.
cd update
.\update_comfyui.bat
goto end

:end
echo Setup complete

REM Keep the window open
pause