@echo off
setlocal EnableDelayedExpansion

REM ============================================================
REM  Qwen-Image 2.1 Turbo - BFS Face Swap (SUPPORTERS workflow)
REM  One-click Windows installer by TheLocalLab
REM ============================================================

REM Check if Git is installed
where git >nul 2>nul
if !errorlevel! neq 0 (
    echo Git not found. Downloading and installing...
    curl -L -o git-installer.exe "https://github.com/git-for-windows/git/releases/download/v2.44.0.windows.1/Git-2.44.0-64-bit.exe"
    if !errorlevel! neq 0 (
        echo Error downloading Git. Please check your internet connection and try again.
        goto end
    )
    git-installer.exe /VERYSILENT /NORESTART
    if !errorlevel! neq 0 (
        echo Error installing Git. Please try installing it manually.
        goto end
    )
    echo Git installed successfully.
    del git-installer.exe
    set "PATH=%PATH%;C:\Program Files\Git\cmd"
)

REM Check if 7-Zip is installed
if not exist "C:\Program Files\7-Zip\7z.exe" (
    echo 7-Zip not found. Downloading and installing...
    curl -L -o 7z2301-x64.exe https://www.7-zip.org/a/7z2301-x64.exe
    if !errorlevel! neq 0 (
        echo Error downloading 7-Zip. Please check your internet connection and try again.
        goto end
    )
    7z2301-x64.exe /S
    if !errorlevel! neq 0 (
        echo Error installing 7-Zip. Please try installing it manually.
        goto end
    )
    echo 7-Zip installed successfully.
    del 7z2301-x64.exe
)

REM ======== Model download menu ========
echo.
echo ============================================================
echo   Qwen-Image 2.1 Turbo BFS Face Swap - Model Download
echo ============================================================
echo   LoRAs, encoder, VAE and the FaceSegment model always download.
echo.
echo   BASE MODEL:
echo   [1] Turbo int8 (default) - needs NVIDIA driver 580+ (CUDA 13 build of ComfyUI)
echo   [2] Turbo GGUF (Q5_K_M)  - low VRAM / older drivers (CUDA 12.6 build of ComfyUI)
echo ============================================================
choice /C 12 /M "Pick a base model (1=Turbo int8, 2=Turbo GGUF):"
set BASEOPT=!errorlevel!
if !BASEOPT!==1 (set "PORTABLE=ComfyUI_windows_portable_nvidia.7z") else (set "PORTABLE=ComfyUI_windows_portable_nvidia_cu126.7z")

REM Step 1: Download ComfyUI portable (PINNED to v0.38.0)
REM Do NOT change this to "latest". int8 = the CUDA 13 (cu130) build: needs driver 580+. GGUF = the cu126 build: runs on older drivers.
echo Downloading ComfyUI portable v0.38.0...
curl -L -o "!PORTABLE!" https://github.com/Comfy-Org/ComfyUI/releases/download/v0.38.0/!PORTABLE!
if !errorlevel! neq 0 (
    echo Error downloading ComfyUI. Please check your internet connection and try again.
    goto end
)
echo Download completed successfully.

REM Step 2: Extract
echo Extracting ComfyUI...
"C:\Program Files\7-Zip\7z.exe" x "!PORTABLE!"
if !errorlevel! neq 0 (
    echo Error extracting the file. The file may be corrupted.
    goto end
) else (
    echo Extraction completed successfully.
)

REM Step 3: Clone custom nodes
echo Cloning custom nodes...
set CLONEFAIL=0
git clone https://github.com/ltdrdata/ComfyUI-Manager.git "ComfyUI_windows_portable\ComfyUI\custom_nodes\ComfyUI-Manager" || set CLONEFAIL=1
git clone https://github.com/city96/ComfyUI-GGUF.git "ComfyUI_windows_portable\ComfyUI\custom_nodes\ComfyUI-GGUF" || set CLONEFAIL=1
git clone https://github.com/rgthree/rgthree-comfy.git "ComfyUI_windows_portable\ComfyUI\custom_nodes\rgthree-comfy" || set CLONEFAIL=1
git clone https://github.com/kijai/ComfyUI-KJNodes.git "ComfyUI_windows_portable\ComfyUI\custom_nodes\ComfyUI-KJNodes" || set CLONEFAIL=1
git clone https://github.com/ClownsharkBatwing/RES4LYF.git "ComfyUI_windows_portable\ComfyUI\custom_nodes\RES4LYF" || set CLONEFAIL=1
git clone https://github.com/1038lab/ComfyUI-RMBG.git "ComfyUI_windows_portable\ComfyUI\custom_nodes\ComfyUI-RMBG" || set CLONEFAIL=1
git clone https://github.com/lquesada/ComfyUI-Inpaint-CropAndStitch.git "ComfyUI_windows_portable\ComfyUI\custom_nodes\ComfyUI-Inpaint-CropAndStitch" || set CLONEFAIL=1

if !CLONEFAIL!==1 (
    echo Error cloning the custom nodes repositories. Please check your internet connection and ensure git is installed.
) else (
    echo Custom nodes cloned successfully.
)

REM Step 4: Install requirements
cd ComfyUI_windows_portable
echo Installing requirements...
.\python_embeded\python.exe -m pip install opencv_python==4.10.0.82
.\python_embeded\python.exe -m pip install -r .\ComfyUI\custom_nodes\ComfyUI-Manager\requirements.txt
.\python_embeded\python.exe -m pip install -r .\ComfyUI\custom_nodes\ComfyUI-GGUF\requirements.txt
.\python_embeded\python.exe -m pip install -r .\ComfyUI\custom_nodes\rgthree-comfy\requirements.txt
.\python_embeded\python.exe -m pip install -r .\ComfyUI\custom_nodes\ComfyUI-KJNodes\requirements.txt
.\python_embeded\python.exe -m pip install -r .\ComfyUI\custom_nodes\RES4LYF\requirements.txt
REM ComfyUI-RMBG: its SAM2/SAM3 extras (hydra-core, omegaconf, iopath, groundingdino-py) have to be
REM built from source, and that build fails in the portable's embedded Python. This workflow only
REM uses FaceSegment, so install everything else first, then try the extras without stopping.
findstr /V /I /C:"groundingdino" /C:"hydra-core" /C:"omegaconf" /C:"iopath" .\ComfyUI\custom_nodes\ComfyUI-RMBG\requirements.txt > rmbg-req.txt
.\python_embeded\python.exe -m pip install -r rmbg-req.txt
del rmbg-req.txt
.\python_embeded\python.exe -m pip install --no-build-isolation hydra-core omegaconf iopath
REM If the extras are still missing, switch off the two RMBG nodes that need them. One file that
REM fails to load takes the whole RMBG pack down with it (FaceSegment included).
.\python_embeded\python.exe -c "import hydra, iopath" 2>nul
if !errorlevel! neq 0 (
    echo RMBG SAM2/SAM3 extras unavailable - disabling those two nodes. FaceSegment is not affected.
    if exist .\ComfyUI\custom_nodes\ComfyUI-RMBG\py\AILab_SAM2Segment.py ren .\ComfyUI\custom_nodes\ComfyUI-RMBG\py\AILab_SAM2Segment.py AILab_SAM2Segment.py.off
    if exist .\ComfyUI\custom_nodes\ComfyUI-RMBG\py\AILab_SAM3Segment.py ren .\ComfyUI\custom_nodes\ComfyUI-RMBG\py\AILab_SAM3Segment.py AILab_SAM3Segment.py.off
)
REM ComfyUI-Inpaint-CropAndStitch has no requirements file (no extra packages needed).
REM Triton (speeds up torch.compile / some KJNodes). PyTorch 2.14 in the v0.38.0 portable pairs with
REM Triton 3.8, so pin below 3.9 (the old "<3.5" pin is for PyTorch 2.8).
.\python_embeded\python.exe -m pip install -U "triton-windows<3.9"
REM Triton also needs the Python "include" and "libs" folders next to the embedded Python.
if not exist .\python_embeded\libs (
    curl -L -o py_include_libs.zip "https://github.com/woct0rdho/triton-windows/releases/download/v3.0.0-windows.post1/python_3.13.2_include_libs.zip"
    "C:\Program Files\7-Zip\7z.exe" x py_include_libs.zip -o.\python_embeded -y
    del py_include_libs.zip
)
REM (torch is NOT reinstalled: the v0.38.0 portable ships its own matched build)

REM Step 5: Make the folders the supporters workflow expects
if not exist "ComfyUI\models\loras\realism" mkdir "ComfyUI\models\loras\realism"
if not exist "ComfyUI\models\RMBG\segformer_face" mkdir "ComfyUI\models\RMBG\segformer_face"



echo.
echo Downloading models...

REM --- Base model ---
if !BASEOPT!==1 curl -L -o ComfyUI\models\diffusion_models\qwen_image_2.1_turbo_int8_convrot.safetensors "https://huggingface.co/Comfy-Org/Qwen-Image-2.1/resolve/main/diffusion_models/qwen_image_2.1_turbo_int8_convrot.safetensors?download=true"
if !BASEOPT!==2 curl -L -o ComfyUI\models\unet\qwen_image_2.1_turbo_Q5_K_M.gguf "https://huggingface.co/Abiray/Qwen-Image-2.1-Turbo-GGUF/resolve/main/qwen_image_2.1_turbo_Q5_K_M.gguf?download=true"

REM --- Shared: text encoder + VAE ---
curl -L -o ComfyUI\models\text_encoders\qwen3vl_8b_int8_convrot.safetensors "https://huggingface.co/Comfy-Org/Qwen-Image-2.1/resolve/main/text_encoders/qwen3vl_8b_int8_convrot.safetensors?download=true"
curl -L -o ComfyUI\models\vae\qwen_image_2.1_vae_bf16.safetensors "https://huggingface.co/Comfy-Org/Qwen-Image-2.1/resolve/main/vae/qwen_image_2.1_vae_bf16.safetensors?download=true"

REM --- BFS head LoRA + realism LoRA ---
curl -L -o ComfyUI\models\loras\bfs_head_v1.1_qwen_2.1.safetensors "https://huggingface.co/Alissonerdx/BFS-Best-Face-Swap/resolve/main/bfs_head_v1.1_qwen_2.1.safetensors?download=true"
curl -L -o ComfyUI\models\loras\realism\realism-qwen-image-2.1-edit-v2.safetensors "https://huggingface.co/houseofboern/realism-qwen-image-2.1-edit-v2/resolve/main/realism-qwen-image-2.1-edit-v2.safetensors?download=true"

REM --- FaceSegment model (pre-download so the first run works offline) ---
curl -L -o ComfyUI\models\RMBG\segformer_face\config.json "https://huggingface.co/1038lab/segformer_face/resolve/main/config.json?download=true"
curl -L -o ComfyUI\models\RMBG\segformer_face\model.safetensors "https://huggingface.co/1038lab/segformer_face/resolve/main/model.safetensors?download=true"
curl -L -o ComfyUI\models\RMBG\segformer_face\preprocessor_config.json "https://huggingface.co/1038lab/segformer_face/resolve/main/preprocessor_config.json?download=true"

REM NOTE: ComfyUI is intentionally kept on v0.38.0 - do NOT run update_comfyui.bat.
REM Updating pulls v0.39+, which forces a CUDA 13 driver upgrade to run.

echo.
echo Setup complete - ComfyUI pinned to v0.38.0. Do not run the updater.

:end
pause
