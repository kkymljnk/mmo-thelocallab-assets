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
git clone https://github.com/Comfy-Org/Nvidia_RTX_Nodes_ComfyUI.git "ComfyUI_windows_portable\ComfyUI\custom_nodes\Nvidia_RTX_Nodes_ComfyUI"
git clone https://github.com/LAOGOU-666/Comfyui-Memory_Cleanup.git "ComfyUI_windows_portable\ComfyUI\custom_nodes\Comfyui-Memory_Cleanup"
git clone https://github.com/fearnworks/ComfyUI_FearnworksNodes.git "ComfyUI_windows_portable\ComfyUI\custom_nodes\ComfyUI_FearnworksNodes"
git clone https://github.com/xmarre/ComfyUI-Spectrum-MiniMax-H3.git "ComfyUI_windows_portable\ComfyUI\custom_nodes\ComfyUI-Spectrum-MiniMax-H3"
git clone https://github.com/Larryvrh/ComfyUI-MiniMax-H3-Turbo.git "ComfyUI_windows_portable\ComfyUI\custom_nodes\ComfyUI-MiniMax-H3-Turbo"
git clone https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite.git "ComfyUI_windows_portable\ComfyUI\custom_nodes\ComfyUI-VideoHelperSuite"


if !errorlevel! neq 0 (
    echo Error cloning the custom nodes repositories. Please check your internet connection and ensure git is installed.
) else (
    echo Custom nodes cloned successfully.
)

REM Step 4: Install requirements
cd ComfyUI_windows_portable
echo Installing requirements...
.\python_embeded\python.exe -m pip install opencv_python==4.10.0.82
.\python_embeded\python.exe -m pip install -r .\ComfyUI\custom_nodes\ComfyUI-Manager\requirements.txt
.\python_embeded\python.exe -m pip install -r .\ComfyUI\custom_nodes\ComfyUI-KJNodes\requirements.txt
.\python_embeded\python.exe -m pip install -r .\ComfyUI\custom_nodes\Comfyui-Memory_Cleanup\requirements.txt
.\python_embeded\python.exe -m pip install -r .\ComfyUI\custom_nodes\ComfyUI_FearnworksNodes\requirements.txt
.\python_embeded\python.exe -m pip install -r .\ComfyUI\custom_nodes\ComfyUI-Spectrum-MiniMax-H3\requirements.txt
.\python_embeded\python.exe -m pip install -r .\ComfyUI\custom_nodes\ComfyUI-MiniMax-H3-Turbo\requirements.txt
.\python_embeded\python.exe -m pip install -r .\ComfyUI\custom_nodes\ComfyUI-VideoHelperSuite\requirements.txt
.\python_embeded\python.exe -m pip install torch==2.8.0+cu128 torchvision==0.23.0+cu128 torchaudio==2.8.0+cu128 --index-url https://download.pytorch.org/whl/cu128
.\python_embeded\python.exe -m pip install -U --no-build-isolation nvidia-vfx --index-url https://pypi.nvidia.com
.\python_embeded\python.exe -m pip install --no-cache-dir --upgrade numba
.\python_embeded\python.exe -m pip install -U "triton-windows<3.5"

                                                                                                       

REM ======== Model download menu ========
echo.
echo ============================================================
echo   MiniMax H3 - Model Download Options
echo ============================================================
echo   Shared models (text encoder + VAEs) are ~21.5 GB and are
echo   needed by every workflow, so they download with any choice.
echo.
echo   [A] Everything ....................... ~66 GB total
echo        Both diffusion models + both turbo LoRAs
echo   [B] Standard only ................... ~63 GB
echo        Fl2va + Ref2va diffusion models, no turbo LoRAs
echo   [C] Turbo only ...................... ~45 GB
echo        Fl2va diffusion model + both turbo LoRAs
echo   [D] Ref2va only (lip sync / image-to-video) . ~44 GB
echo        Ref2va diffusion model + lightx2v turbo LoRA
echo   [E] Fused Turbo only (no LoRA nodes needed) . ~43 GB
        echo        Single fused model - base + turbo + motion LoRA in one
        echo   [S] Skip - I will download models myself
echo ============================================================
choice /C ABCDES /M "Choose a download option:"
set MODELOPT=!errorlevel!

if !MODELOPT!==6 (
    echo Skipping model downloads.
    goto post_models
)

echo Downloading models...

REM --- Shared models (always needed) ---
curl -k -L -o ComfyUI\models\clip\qwen3vl_32b_minimax_h3_nvfp4_awq.safetensors "https://huggingface.co/Comfy-Org/MiniMax-H3/resolve/main/text_encoders/qwen3vl_32b_minimax_h3_nvfp4_awq.safetensors?download=true"
curl -k -L -o ComfyUI\models\vae\minimax_h3_video_vae_fp16.safetensors "https://huggingface.co/Comfy-Org/MiniMax-H3/resolve/main/vae/minimax_h3_video_vae_fp16.safetensors?download=true"
curl -k -L -o ComfyUI\models\vae\minimax_h3_audio_vae_fp32.safetensors "https://huggingface.co/Comfy-Org/MiniMax-H3/resolve/main/vae/minimax_h3_audio_vae_fp32.safetensors?download=true"

REM --- Semantic Bridge adapter + node (tiny, included with every download option) ---
if not exist "ComfyUI\models\semantic_bridge" mkdir "ComfyUI\models\semantic_bridge"
curl -k -L -o ComfyUI\models\semantic_bridge\MiniMaxH3_SemanticBridge_v1.safetensors "https://huggingface.co/speach1sdef178/MiniMax-H3-Semantic-Bridge/resolve/main/MiniMaxH3_SemanticBridge_v1.safetensors?download=true"
curl -k -L -o MiniMax_H3_Semantic_Bridge_v1.0.zip "https://huggingface.co/speach1sdef178/MiniMax-H3-Semantic-Bridge/resolve/main/MiniMax_H3_Semantic_Bridge_v1.0.zip?download=true"
"C:\Program Files\7-Zip\7z.exe" x MiniMax_H3_Semantic_Bridge_v1.0.zip -o"ComfyUI\custom_nodes\" -y
del MiniMax_H3_Semantic_Bridge_v1.0.zip

REM --- Fl2va diffusion model (A, B, C) ---
if !MODELOPT!==1 goto dl_fl2va
if !MODELOPT!==2 goto dl_fl2va
if !MODELOPT!==3 goto dl_fl2va
goto skip_fl2va
:dl_fl2va
curl -k -L -o ComfyUI\models\unet\minimax_h3_fl2va_pruned_int8_convrot.safetensors "https://huggingface.co/Comfy-Org/MiniMax-H3/resolve/main/diffusion_models/minimax_h3_fl2va_pruned_int8_convrot.safetensors?download=true"
:skip_fl2va

REM --- Ref2va diffusion model (A, B, D) ---
if !MODELOPT!==1 goto dl_ref2va
if !MODELOPT!==2 goto dl_ref2va
if !MODELOPT!==4 goto dl_ref2va
goto skip_ref2va
:dl_ref2va
curl -k -L -o ComfyUI\models\unet\minimax_h3_ref2va_pruned_int8_convrot.safetensors "https://huggingface.co/Comfy-Org/MiniMax-H3/resolve/main/diffusion_models/minimax_h3_ref2va_pruned_int8_convrot.safetensors?download=true"
:skip_ref2va

REM --- Larryvrh turbo LoRA (A, C) ---
if !MODELOPT!==1 goto dl_larry
if !MODELOPT!==3 goto dl_larry
goto skip_larry
:dl_larry
curl -k -L -o ComfyUI\models\loras\minimax_h3_turbo_v4_step600.safetensors "https://huggingface.co/larryvrh/MiniMax-H3-Turbo-Lora/resolve/main/minimax_h3_turbo_v4_step600.safetensors?download=true"
:skip_larry

REM --- lightx2v turbo LoRA (A, C, D) ---
if !MODELOPT!==1 goto dl_lightx
if !MODELOPT!==3 goto dl_lightx
if !MODELOPT!==4 goto dl_lightx
goto skip_lightx
:dl_lightx
curl -k -L -o ComfyUI\models\loras\minimax_h3_fl2v_turbo_8step_v1.0_768p_comfyui_bf16.safetensors "https://huggingface.co/lightx2v/Minimax-h3-Turbo/resolve/main/minimax_h3_fl2v_turbo_8step_v1.0_768p_comfyui_bf16.safetensors?download=true"
:skip_lightx

REM --- Fused Turbo diffusion model (E) - no LoRA nodes needed ---
if !MODELOPT!==5 goto dl_fused
goto skip_fused
:dl_fused
curl -k -L -o ComfyUI\models\unet\minimax_h3_fused_refdelta_r1024_turbo8_mystic07_int8_convrot.safetensors "https://huggingface.co/MATLOWAI/minimax-h3-fused-turbo-int8-convrot/resolve/main/diffusion_models/minimax_h3_fused_refdelta_r1024_turbo8_mystic07_int8_convrot.safetensors?download=true"
:skip_fused

:post_models
cd update
.\update_comfyui.bat
cd ..

echo.
echo Setup complete

REM Keep the window open
pause
