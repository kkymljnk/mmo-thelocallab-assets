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
git clone https://github.com/Nynxz/ComfyUI-Idol.git "ComfyUI_windows_portable\ComfyUI\custom_nodes\ComfyUI-Idol"

REM Idol node at the tested version
git -C "ComfyUI_windows_portable\ComfyUI\custom_nodes\ComfyUI-Idol" checkout 4d3a4f6


if !errorlevel! neq 0 (
    echo Error cloning the custom nodes repositories. Please check your internet connection and ensure git is installed.
) else (
    echo Custom nodes cloned successfully.
)

REM Step 4: Install requirements
cd ComfyUI_windows_portable
echo Installing requirements...
.\python_embeded\python.exe -m pip install -r .\ComfyUI\custom_nodes\ComfyUI-Manager\requirements.txt
REM ComfyUI-Idol has no requirements: it runs Idol on ComfyUI's built-in TripoSplat nodes, so the portable's own torch stays as it is

REM Step 5: Add the Idol workflow to the Workflows sidebar + its example picture
echo Adding the workflow...
if not exist "ComfyUI\user\default\workflows" mkdir "ComfyUI\user\default\workflows"
copy /Y "ComfyUI\custom_nodes\ComfyUI-Idol\example_workflows\idol_image_to_splat.json" "ComfyUI\user\default\workflows\Idol - Image to 3D Splat (Nynxz default).json" >nul
copy /Y "ComfyUI\custom_nodes\ComfyUI-Idol\example_workflows\idol_fox.webp" "ComfyUI\input\idol_fox.webp" >nul
REM Any workflow .json placed next to this installer is added too (the LocalLab tuned workflow ships next to it)
for %%F in ("%~dp0*.json") do copy /Y "%%F" "ComfyUI\user\default\workflows\" >nul


REM ======== Model download menu ========
echo.
echo ============================================================
echo   Idol Image to 3D - Model Download Options
echo ============================================================
echo   [A] Everything ....................... ~3.8 GB
echo        Idol model + decoder, DINOv3 image encoder,
echo        FLUX.2 VAE and BiRefNet background removal
echo   [B] Idol only ........................ ~1.3 GB
echo        if you already run TripoSplat in ComfyUI
echo        (dino_v3_vit_h, flux2-vae and birefnet)
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
if not exist "ComfyUI\models\vae" mkdir "ComfyUI\models\vae"
if not exist "ComfyUI\models\clip_vision" mkdir "ComfyUI\models\clip_vision"
if not exist "ComfyUI\models\background_removal" mkdir "ComfyUI\models\background_removal"

REM --- Idol model + decoder (A, B) ---
curl -f -k -L -o ComfyUI\models\diffusion_models\idol_fp16.safetensors "https://huggingface.co/nynxz/Idol/resolve/main/diffusion_models/idol_fp16.safetensors?download=true"
curl -f -k -L -o ComfyUI\models\vae\idol_decoder_fp16.safetensors "https://huggingface.co/nynxz/Idol/resolve/main/vae/idol_decoder_fp16.safetensors?download=true"

REM --- Shared TripoSplat encoders (A) ---
REM FLUX.2 VAE from FLUX.2 [klein] 4B (Apache-2.0): the same weights as the FLUX.2-dev VAE
if !MODELOPT!==1 goto dl_shared
goto skip_shared
:dl_shared
curl -f -k -L -o ComfyUI\models\clip_vision\dino_v3_vit_h.safetensors "https://huggingface.co/VAST-AI/TripoSplat/resolve/main/clip_vision/dino_v3_vit_h.safetensors?download=true"
curl -f -k -L -o ComfyUI\models\vae\flux2-vae.safetensors "https://huggingface.co/Comfy-Org/Flux-2-Klein-4B/resolve/main/split_files/vae/flux2-vae.safetensors?download=true"
curl -f -k -L -o ComfyUI\models\background_removal\birefnet.safetensors "https://huggingface.co/Comfy-Org/BiRefNet/resolve/main/background_removal/birefnet.safetensors?download=true"
:skip_shared

:post_models
cd update
REM call + nopause: come back here afterwards and skip the updater's own pause
call .\update_comfyui.bat nopause
cd ..

echo.
echo Setup complete
echo Start ComfyUI with run_nvidia_gpu.bat and open "Idol - Image to 3D Splat (LocalLab)" from the Workflows sidebar.
echo (It is added when it sits next to this installer. The Nynxz default workflow is there too: for it, use mode real, 30 steps, CFG 3.)

:end
REM Keep the window open
pause
