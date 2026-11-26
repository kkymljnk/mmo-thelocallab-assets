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
git clone https://github.com/rgthree/rgthree-comfy.git "ComfyUI_windows_portable\ComfyUI\custom_nodes\rgthree-comfy"
git clone https://github.com/kijai/ComfyUI-KJNodes.git "ComfyUI_windows_portable\ComfyUI\custom_nodes\ComfyUI-KJNodes"
git clone https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite.git "ComfyUI_windows_portable\ComfyUI\custom_nodes\ComfyUI-VideoHelperSuite"
git clone https://github.com/Kablex/ComfyUI-Ref2VA-VSA.git "ComfyUI_windows_portable\ComfyUI\custom_nodes\ComfyUI-Ref2VA-VSA"
git clone https://github.com/LBH-123-AI/Comfyui_Minimax_h3_latent_Upscaler.git "ComfyUI_windows_portable\ComfyUI\custom_nodes\Comfyui_Minimax_h3_latent_Upscaler"
git clone https://github.com/LAOGOU-666/Comfyui-Memory_Cleanup.git "ComfyUI_windows_portable\ComfyUI\custom_nodes\Comfyui-Memory_Cleanup"
git clone https://github.com/Comfy-Org/ComfyUI_Nvidia_VFX_Nodes.git "ComfyUI_windows_portable\ComfyUI\custom_nodes\ComfyUI_Nvidia_VFX_Nodes"

REM Custom nodes at the versions checked on 11-19-26 (the Manager stays on its latest, as before)
git -C "ComfyUI_windows_portable\ComfyUI\custom_nodes\rgthree-comfy" checkout -q bc48c6aaeca87bedbc14245d89f9bc6be37a630e
git -C "ComfyUI_windows_portable\ComfyUI\custom_nodes\ComfyUI-KJNodes" checkout -q aa2b5ea5e7f61b51f5d26d726f23c1d74e951016
git -C "ComfyUI_windows_portable\ComfyUI\custom_nodes\ComfyUI-VideoHelperSuite" checkout -q 4d907bee61e92c2e65af3bd6383a4e4d356126d1
git -C "ComfyUI_windows_portable\ComfyUI\custom_nodes\ComfyUI-Ref2VA-VSA" checkout -q 323a0a5f7c636cc70f95464145732f81f04a72e9
git -C "ComfyUI_windows_portable\ComfyUI\custom_nodes\Comfyui_Minimax_h3_latent_Upscaler" checkout -q f34cadb19f10fee7e36091b690cac39b4eb40573
git -C "ComfyUI_windows_portable\ComfyUI\custom_nodes\Comfyui-Memory_Cleanup" checkout -q 58de13a6090e04408e343501ff8902c034d9f518
git -C "ComfyUI_windows_portable\ComfyUI\custom_nodes\ComfyUI_Nvidia_VFX_Nodes" checkout -q 38d790ded00650681fa3645362efe28c8560cf40


if !errorlevel! neq 0 (
    echo Error cloning the custom nodes repositories. Please check your internet connection and ensure git is installed.
) else (
    echo Custom nodes cloned successfully.
)

REM Step 4: Install requirements
cd ComfyUI_windows_portable
echo Installing requirements...
.\python_embeded\python.exe -m pip install -r .\ComfyUI\custom_nodes\ComfyUI-Manager\requirements.txt
.\python_embeded\python.exe -m pip install -r .\ComfyUI\custom_nodes\ComfyUI-KJNodes\requirements.txt
.\python_embeded\python.exe -m pip install -r .\ComfyUI\custom_nodes\ComfyUI-VideoHelperSuite\requirements.txt
.\python_embeded\python.exe -m pip install -r .\ComfyUI\custom_nodes\Comfyui-Memory_Cleanup\requirements.txt
REM The RTX upscaler needs nvidia-vfx, which comes from NVIDIA's own package index (about 440 MB)
.\python_embeded\python.exe -m pip install -r .\ComfyUI\custom_nodes\ComfyUI_Nvidia_VFX_Nodes\requirements.txt --extra-index-url https://pypi.nvidia.com
REM Ref2VA-VSA only lists torch and safetensors, the upscaler and rgthree list nothing: the portable already has them
REM The portable already ships PyTorch for CUDA 13, so its torch is kept as it is

REM Step 5: Any workflow .json placed next to this installer is added to the Workflows sidebar
echo Adding the workflow...
if not exist "ComfyUI\user\default\workflows" mkdir "ComfyUI\user\default\workflows"
for %%F in ("%~dp0*.json") do copy /Y "%%F" "ComfyUI\user\default\workflows\" >nul


REM ======== Model download menu ========
echo.
echo ============================================================
echo   MiniMax H3 Lip Sync - Model Download Options
echo ============================================================
echo   [A] Everything ....................... ~49 GB
echo        MiniMax H3 Ref2VA model, text encoder, both VAEs,
echo        4-step LoRA, Fast Gate and latent upscaler
echo   [B] New lip sync files only .......... ~6.2 GB
echo        4-step LoRA, Fast Gate and latent upscaler, if you
echo        already have the MiniMax H3 Ref2VA model (int8),
echo        text encoder (nvfp4) and both VAEs
echo   [C] New files + Ref2VA model ......... ~27 GB
echo        if you already have the MiniMax H3 text encoder
echo        (nvfp4) and both VAEs, e.g. from the Viggle installer
echo   [S] Skip - I will download models myself
echo ============================================================
choice /C ABCS /M "Choose a download option:"
set MODELOPT=!errorlevel!

if !MODELOPT!==4 (
    echo Skipping model downloads.
    goto post_models
)

echo Downloading models...

if not exist "ComfyUI\models\diffusion_models" mkdir "ComfyUI\models\diffusion_models"
if not exist "ComfyUI\models\text_encoders" mkdir "ComfyUI\models\text_encoders"
if not exist "ComfyUI\models\vae" mkdir "ComfyUI\models\vae"
if not exist "ComfyUI\models\loras" mkdir "ComfyUI\models\loras"
if not exist "ComfyUI\models\latent_upscale_models" mkdir "ComfyUI\models\latent_upscale_models"

REM --- New lip sync files: 4-step LoRA, Fast Gate and latent upscaler (A, B, C) ---
if not exist "ComfyUI\models\loras\minimax_h3_ref2v_turbo_4step_v1.0_768p_comfyui_bf16.safetensors" curl -f -k -L -o ComfyUI\models\loras\minimax_h3_ref2v_turbo_4step_v1.0_768p_comfyui_bf16.safetensors "https://huggingface.co/lightx2v/Minimax-h3-Turbo/resolve/main/minimax_h3_ref2v_turbo_4step_v1.0_768p_comfyui_bf16.safetensors?download=true"
if not exist "ComfyUI\models\loras\fasth3_vsa_gate.safetensors" curl -f -k -L -o ComfyUI\models\loras\fasth3_vsa_gate.safetensors "https://huggingface.co/barelymining/ComfyUI-MiniMax-H3-FastVideo/resolve/main/fasth3_vsa_gate.safetensors?download=true"
if not exist "ComfyUI\models\latent_upscale_models\minimax_h3_latent_upscaler_2d_conv_v1_fp16.safetensors" curl -f -k -L -o ComfyUI\models\latent_upscale_models\minimax_h3_latent_upscaler_2d_conv_v1_fp16.safetensors "https://huggingface.co/LBH-123-AI/Minimax_h3_latent_Upscaler/resolve/main/minimax_h3_latent_upscaler_2d_conv_v1/minimax_h3_latent_upscaler_2d_conv_v1_fp16.safetensors?download=true"

REM --- MiniMax H3 Ref2VA model (A, C) ---
if !MODELOPT!==2 goto skip_ref2va
if not exist "ComfyUI\models\diffusion_models\minimax_h3_ref2va_pruned_int8_convrot.safetensors" curl -f -k -L -o ComfyUI\models\diffusion_models\minimax_h3_ref2va_pruned_int8_convrot.safetensors "https://huggingface.co/Comfy-Org/MiniMax-H3/resolve/main/diffusion_models/minimax_h3_ref2va_pruned_int8_convrot.safetensors?download=true"
:skip_ref2va

REM --- Text encoder and VAEs (A) ---
if !MODELOPT!==1 goto dl_shared
goto skip_shared
:dl_shared
if not exist "ComfyUI\models\text_encoders\qwen3vl_32b_minimax_h3_nvfp4_awq.safetensors" curl -f -k -L -o ComfyUI\models\text_encoders\qwen3vl_32b_minimax_h3_nvfp4_awq.safetensors "https://huggingface.co/Comfy-Org/MiniMax-H3/resolve/main/text_encoders/qwen3vl_32b_minimax_h3_nvfp4_awq.safetensors?download=true"
if not exist "ComfyUI\models\vae\minimax_h3_video_vae_fp16.safetensors" curl -f -k -L -o ComfyUI\models\vae\minimax_h3_video_vae_fp16.safetensors "https://huggingface.co/Comfy-Org/MiniMax-H3/resolve/main/vae/minimax_h3_video_vae_fp16.safetensors?download=true"
if not exist "ComfyUI\models\vae\minimax_h3_audio_vae_fp32.safetensors" curl -f -k -L -o ComfyUI\models\vae\minimax_h3_audio_vae_fp32.safetensors "https://huggingface.co/Comfy-Org/MiniMax-H3/resolve/main/vae/minimax_h3_audio_vae_fp32.safetensors?download=true"
:skip_shared

:post_models
cd update
REM call + nopause: come back here afterwards and skip the updater's own pause
call .\update_comfyui.bat nopause
cd ..

echo.
echo Setup complete
echo Start ComfyUI with run_nvidia_gpu.bat and open "MiniMax-H3-LipSync-FastGate-Refine-11-19-26" from the Workflows sidebar.
echo (It is added when it sits next to this installer.)
echo.
echo IMPORTANT: update your NVIDIA graphics driver to version 580 or newer before you start ComfyUI.
echo This workflow runs on PyTorch for CUDA 13, which needs that driver (nvidia.com/drivers or the NVIDIA app).

:end
REM Keep the window open
pause
