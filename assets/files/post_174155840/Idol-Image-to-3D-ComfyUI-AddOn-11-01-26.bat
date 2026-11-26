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

REM Idol node: reuse it if you already have Nynxz's ComfyUI-Idol, otherwise add it
REM (a different node pack in a folder called ComfyUI-Idol is left alone and Nynxz's goes next to it)
set "IDOLDIR=ComfyUI-Idol"
if exist "ComfyUI\custom_nodes\ComfyUI-Idol" (
    git -C "ComfyUI\custom_nodes\ComfyUI-Idol" remote get-url origin | findstr /I "Nynxz/ComfyUI-Idol" >nul
    if !errorlevel! neq 0 set "IDOLDIR=ComfyUI-Idol-Nynxz"
)
if not exist "ComfyUI\custom_nodes\!IDOLDIR!" git clone https://github.com/Nynxz/ComfyUI-Idol.git "ComfyUI\custom_nodes\!IDOLDIR!"
git -C "ComfyUI\custom_nodes\!IDOLDIR!" fetch
REM Idol node at the tested version
git -C "ComfyUI\custom_nodes\!IDOLDIR!" checkout 4d3a4f6


if !errorlevel! neq 0 (
    echo Error cloning the custom nodes repositories. Please check your internet connection and ensure git is installed.
) else (
    echo Custom nodes cloned successfully.
)

REM Step 4: Install requirements
echo Installing requirements...
.\python_embeded\python.exe -m pip install -r .\ComfyUI\custom_nodes\ComfyUI-Manager\requirements.txt
REM ComfyUI-Idol has no requirements and your torch is not touched

REM Step 5: Add the Idol workflow to the Workflows sidebar + its example picture
echo Adding the workflow...
if not exist "ComfyUI\user\default\workflows" mkdir "ComfyUI\user\default\workflows"
copy /Y "ComfyUI\custom_nodes\!IDOLDIR!\example_workflows\idol_image_to_splat.json" "ComfyUI\user\default\workflows\Idol - Image to 3D Splat (Nynxz default).json" >nul
copy /Y "ComfyUI\custom_nodes\!IDOLDIR!\example_workflows\idol_fox.webp" "ComfyUI\input\idol_fox.webp" >nul
REM Any workflow .json placed next to this installer is added too (the LocalLab tuned workflow ships next to it)
for %%F in ("%~dp0*.json") do copy /Y "%%F" "ComfyUI\user\default\workflows\" >nul


REM ======== Model download menu ========
echo.
echo ============================================================
echo   Idol Image to 3D - Model Download Options
echo ============================================================
echo   Files you already have are kept and not downloaded again.
echo.
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
if not exist "ComfyUI\models\diffusion_models\idol_fp16.safetensors" curl -f -k -L -o ComfyUI\models\diffusion_models\idol_fp16.safetensors "https://huggingface.co/nynxz/Idol/resolve/main/diffusion_models/idol_fp16.safetensors?download=true"
if not exist "ComfyUI\models\vae\idol_decoder_fp16.safetensors" curl -f -k -L -o ComfyUI\models\vae\idol_decoder_fp16.safetensors "https://huggingface.co/nynxz/Idol/resolve/main/vae/idol_decoder_fp16.safetensors?download=true"

REM --- Shared TripoSplat encoders (A) ---
REM FLUX.2 VAE from FLUX.2 [klein] 4B (Apache-2.0): the same weights as the FLUX.2-dev VAE
if !MODELOPT!==1 goto dl_shared
goto skip_shared
:dl_shared
if not exist "ComfyUI\models\clip_vision\dino_v3_vit_h.safetensors" curl -f -k -L -o ComfyUI\models\clip_vision\dino_v3_vit_h.safetensors "https://huggingface.co/VAST-AI/TripoSplat/resolve/main/clip_vision/dino_v3_vit_h.safetensors?download=true"
if not exist "ComfyUI\models\vae\flux2-vae.safetensors" curl -f -k -L -o ComfyUI\models\vae\flux2-vae.safetensors "https://huggingface.co/Comfy-Org/Flux-2-Klein-4B/resolve/main/split_files/vae/flux2-vae.safetensors?download=true"
if not exist "ComfyUI\models\background_removal\birefnet.safetensors" curl -f -k -L -o ComfyUI\models\background_removal\birefnet.safetensors "https://huggingface.co/Comfy-Org/BiRefNet/resolve/main/background_removal/birefnet.safetensors?download=true"
:skip_shared

:post_models
cd update
REM call + nopause: come back here afterwards and skip the updater's own pause
call .\update_comfyui.bat nopause
cd ..

echo.
echo Setup complete
echo Idol uses ComfyUI's TripoSplat nodes. If ComfyUI reports them missing, run update\update_comfyui_and_python_dependencies.bat once.
echo Start ComfyUI with run_nvidia_gpu.bat and open "Idol - Image to 3D Splat (LocalLab)" from the Workflows sidebar.
echo (It is added when it sits next to this installer. The Nynxz default workflow is there too: for it, use mode real, 30 steps, CFG 3.)

:end
REM Keep the window open
pause
