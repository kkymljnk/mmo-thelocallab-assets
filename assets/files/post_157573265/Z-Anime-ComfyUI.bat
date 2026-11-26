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
    curl -k -L -o 7z2301-x64.exe "https://www.7-zip.org/a/7z2301-x64.exe"
    
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
curl -k -L -o ComfyUI_windows_portable_nvidia.7z "https://github.com/comfyanonymous/ComfyUI/releases/latest/download/ComfyUI_windows_portable_nvidia.7z"

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
git clone "https://github.com/ltdrdata/ComfyUI-Manager.git" "ComfyUI_windows_portable\ComfyUI\custom_nodes\ComfyUI-Manager"
git clone "https://github.com/city96/ComfyUI-GGUF.git" "ComfyUI_windows_portable\ComfyUI\custom_nodes\ComfyUI-GGUF"
git clone "https://github.com/calcuis/gguf.git" "ComfyUI_windows_portable\ComfyUI\custom_nodes\gguf"
git clone "https://github.com/rgthree/rgthree-comfy.git" "ComfyUI_windows_portable\ComfyUI\custom_nodes\rgthree-comfy"
git clone "https://github.com/ClownsharkBatwing/RES4LYF.git" "ComfyUI_windows_portable\ComfyUI\custom_nodes\RES4LYF"
git clone "https://github.com/rgthree/rgthree-comfy.git" "ComfyUI_windows_portable\ComfyUI\custom_nodes\rgthree-comfy"


if !errorlevel! neq 0 (
    echo Error cloning the custom nodes repositories. Please check your internet connection and ensure git is installed.
) else (
    echo Custom nodes cloned successfully.
)

REM Step 4: Install requirements
cd ComfyUI_windows_portable
echo Installing requirements...
.\python_embeded\python.exe -m pip install opencv_python==4.10.0.82
.\python_embeded\python.exe -m pip install torch==2.8.0+cu128 torchvision==0.23.0+cu128 torchaudio==2.8.0+cu128 --index-url "https://download.pytorch.org/whl/cu128"
.\python_embeded\python.exe -m pip install -r .\ComfyUI\custom_nodes\ComfyUI-Manager\requirements.txt
.\python_embeded\python.exe -m pip install -r .\ComfyUI\custom_nodes\ComfyUI-GGUF\requirements.txt
.\python_embeded\python.exe -m pip install -r .\ComfyUI\custom_nodes\rgthree-comfy\requirements.txt
.\python_embeded\python.exe -m pip install -r .\ComfyUI\custom_nodes\RES4LYF\requirements.txt

REM ======== Ask whether to download models (waits forever) ========
echo.
echo Do you want to download the models now?
choice /C YN /M "Press Y for Yes or N for No:"

REM CHOICE returns 1 for Y, 2 for N with /C YN
if errorlevel 2 goto skip_models
if errorlevel 1 goto download_models

:skip_models
echo Skipping model downloads.
goto end

:download_models
REM Step 5: Download models
echo Downloading models...
cd ComfyUI
curl -k -L -o models\diffusion_models\z-anime-distill-8step-fp8.safetensors https://huggingface.co/SeeSee21/Z-Anime/resolve/main/diffusion_models/z-anime-distill-8step-fp8.safetensors?download=true
curl -k -L -o models\clip\Qwen3-4B-UD-Q5_K_XL.gguf https://huggingface.co/unsloth/Qwen3-4B-GGUF/resolve/main/Qwen3-4B-UD-Q5_K_XL.gguf?download=true
curl -k -L -o models\vae\ae.safetensors https://huggingface.co/Comfy-Org/z_image_turbo/resolve/main/split_files/vae/ae.safetensors?download=true
curl -k -L -o models\upscale_models\1x-SwatKatsLite.pth https://huggingface.co/Thelocallab/1x-SwatKatsLite/resolve/main/1x-SwatKatsLite.pth?download=true
curl -k -L -o models\upscale_models\2xLexicaRRDBNet_Sharp.pth https://huggingface.co/Thelocallab/2xLexicaRRDBNet_Sharp/resolve/main/2xLexicaRRDBNet_Sharp.pth?download=true

:end
echo Setup complete

REM Keep the window open
pause
