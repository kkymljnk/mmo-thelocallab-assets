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
REM Packs you already have are kept: older ones are moved up to the version checked on 11-19-26, newer ones are left as they are
echo Cloning custom nodes...
if not exist "ComfyUI\custom_nodes\ComfyUI-Manager" git clone https://github.com/ltdrdata/ComfyUI-Manager.git "ComfyUI\custom_nodes\ComfyUI-Manager"
call :addnode https://github.com/rgthree/rgthree-comfy.git rgthree-comfy bc48c6aaeca87bedbc14245d89f9bc6be37a630e
call :addnode https://github.com/kijai/ComfyUI-KJNodes.git ComfyUI-KJNodes aa2b5ea5e7f61b51f5d26d726f23c1d74e951016
call :addnode https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite.git ComfyUI-VideoHelperSuite 4d907bee61e92c2e65af3bd6383a4e4d356126d1
call :addnode https://github.com/Kablex/ComfyUI-Ref2VA-VSA.git ComfyUI-Ref2VA-VSA 323a0a5f7c636cc70f95464145732f81f04a72e9
REM The 2D upscaler node needs commit 87d8822 or newer (2D conv v1 support): f34cadb is newer
call :addnode https://github.com/LBH-123-AI/Comfyui_Minimax_h3_latent_Upscaler.git Comfyui_Minimax_h3_latent_Upscaler f34cadb19f10fee7e36091b690cac39b4eb40573
REM Memory Cleanup and the RTX nodes go by other folder names when they came from the Manager: use the folder you already have
set "MEMDIR=Comfyui-Memory_Cleanup"
if exist "ComfyUI\custom_nodes\comfyui_memory_cleanup" set "MEMDIR=comfyui_memory_cleanup"
call :addnode https://github.com/LAOGOU-666/Comfyui-Memory_Cleanup.git %MEMDIR% 58de13a6090e04408e343501ff8902c034d9f518
set "RTXDIR=ComfyUI_Nvidia_VFX_Nodes"
if exist "ComfyUI\custom_nodes\Nvidia_RTX_Nodes_ComfyUI" set "RTXDIR=Nvidia_RTX_Nodes_ComfyUI"
if exist "ComfyUI\custom_nodes\comfyui_nvidia_rtx_nodes" set "RTXDIR=comfyui_nvidia_rtx_nodes"
call :addnode https://github.com/Comfy-Org/ComfyUI_Nvidia_VFX_Nodes.git %RTXDIR% 38d790ded00650681fa3645362efe28c8560cf40

REM Step 4: Install requirements (node requirements only: your torch is not touched)
echo Installing requirements...
.\python_embeded\python.exe -m pip install -r .\ComfyUI\custom_nodes\ComfyUI-Manager\requirements.txt
.\python_embeded\python.exe -m pip install -r .\ComfyUI\custom_nodes\ComfyUI-KJNodes\requirements.txt
.\python_embeded\python.exe -m pip install -r .\ComfyUI\custom_nodes\ComfyUI-VideoHelperSuite\requirements.txt
.\python_embeded\python.exe -m pip install -r .\ComfyUI\custom_nodes\%MEMDIR%\requirements.txt
REM The RTX upscaler needs nvidia-vfx, which comes from NVIDIA's own package index (about 440 MB)
.\python_embeded\python.exe -m pip install -r .\ComfyUI\custom_nodes\%RTXDIR%\requirements.txt --extra-index-url https://pypi.nvidia.com
REM Ref2VA-VSA only lists torch and safetensors, the upscaler and rgthree list nothing: ComfyUI already has them

REM Step 5: Any workflow .json placed next to this add-on is added to the Workflows sidebar (your torch is not touched)
echo Adding the workflow...
if not exist "ComfyUI\user\default\workflows" mkdir "ComfyUI\user\default\workflows"
for %%F in ("%~dp0*.json") do copy /Y "%%F" "ComfyUI\user\default\workflows\" >nul


REM ======== Model download menu ========
echo.
echo ============================================================
echo   MiniMax H3 Lip Sync - Model Download Options
echo ============================================================
echo   Files you already have are kept and not downloaded again.
echo.
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

REM --- MiniMax H3 Ref2VA model (A, C); the MiniMax H3 All-In-One installer put it in models\unet, so that folder counts too ---
if !MODELOPT!==2 goto skip_ref2va
if not exist "ComfyUI\models\diffusion_models\minimax_h3_ref2va_pruned_int8_convrot.safetensors" if not exist "ComfyUI\models\unet\minimax_h3_ref2va_pruned_int8_convrot.safetensors" curl -f -k -L -o ComfyUI\models\diffusion_models\minimax_h3_ref2va_pruned_int8_convrot.safetensors "https://huggingface.co/Comfy-Org/MiniMax-H3/resolve/main/diffusion_models/minimax_h3_ref2va_pruned_int8_convrot.safetensors?download=true"
:skip_ref2va

REM --- Text encoder and VAEs (A); a text encoder in models\clip counts too ---
if !MODELOPT!==1 goto dl_shared
goto skip_shared
:dl_shared
if not exist "ComfyUI\models\text_encoders\qwen3vl_32b_minimax_h3_nvfp4_awq.safetensors" if not exist "ComfyUI\models\clip\qwen3vl_32b_minimax_h3_nvfp4_awq.safetensors" curl -f -k -L -o ComfyUI\models\text_encoders\qwen3vl_32b_minimax_h3_nvfp4_awq.safetensors "https://huggingface.co/Comfy-Org/MiniMax-H3/resolve/main/text_encoders/qwen3vl_32b_minimax_h3_nvfp4_awq.safetensors?download=true"
if not exist "ComfyUI\models\vae\minimax_h3_video_vae_fp16.safetensors" curl -f -k -L -o ComfyUI\models\vae\minimax_h3_video_vae_fp16.safetensors "https://huggingface.co/Comfy-Org/MiniMax-H3/resolve/main/vae/minimax_h3_video_vae_fp16.safetensors?download=true"
if not exist "ComfyUI\models\vae\minimax_h3_audio_vae_fp32.safetensors" curl -f -k -L -o ComfyUI\models\vae\minimax_h3_audio_vae_fp32.safetensors "https://huggingface.co/Comfy-Org/MiniMax-H3/resolve/main/vae/minimax_h3_audio_vae_fp32.safetensors?download=true"
:skip_shared

:post_models
REM Brings the MiniMax H3 core nodes and comfy-kitchen up to date (it never changes torch)
cd update
REM call + nopause: come back here afterwards and skip the updater's own pause
call .\update_comfyui.bat nopause
cd ..

REM Fast Gate needs PyTorch for CUDA 13: check only, your torch is not changed
.\python_embeded\python.exe -c "import sys, torch; v = torch.version.cuda or '0'; sys.exit(0 if int(v.split('.')[0]) >= 13 else 1)" >nul 2>nul
if !errorlevel! neq 0 (
    echo.
    echo NOTE: this ComfyUI does not run PyTorch for CUDA 13. The Fast Gate node needs it,
    echo with an NVIDIA driver 580 or newer. The full installer sets up a ComfyUI portable that has it.
)

echo.
echo Setup complete
echo Start ComfyUI with run_nvidia_gpu.bat and open "MiniMax-H3-LipSync-FastGate-Refine-11-19-26" from the Workflows sidebar.
echo (This add-on leaves your torch alone.)
echo.
echo IMPORTANT: update your NVIDIA graphics driver to version 580 or newer before you start ComfyUI.
echo This workflow runs on PyTorch for CUDA 13, which needs that driver (nvidia.com/drivers or the NVIDIA app).

:end
REM Keep the window open
pause
goto :eof

REM ======== Add one custom node pack: git URL, folder in custom_nodes, tested commit ========
:addnode
set "NODEDIR=ComfyUI\custom_nodes\%~2"
if not exist "!NODEDIR!" (
    git clone %1 "!NODEDIR!"
    git -C "!NODEDIR!" checkout -q %3
) else if exist "!NODEDIR!\.git" (
    git -C "!NODEDIR!" fetch -q
    git -C "!NODEDIR!" merge-base --is-ancestor %3 HEAD 2>nul || git -C "!NODEDIR!" checkout -q %3
) else (
    echo %~2 was not installed with git, so it is left as it is. If a node shows as missing, update it in the Manager.
)
goto :eof
