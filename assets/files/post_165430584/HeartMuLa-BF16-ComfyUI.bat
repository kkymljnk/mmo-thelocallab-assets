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
git clone https://github.com/crazyma99/ComfyUI-HeartMuLa.git "ComfyUI_windows_portable\ComfyUI\custom_nodes\ComfyUI-HeartMuLa"
git clone https://github.com/rgthree/rgthree-comfy.git "ComfyUI_windows_portable\ComfyUI\custom_nodes\rgthree-comfy"
git clone https://github.com/benjiyaya/HeartMuLa_ComfyUI.git "ComfyUI_windows_portable\ComfyUI\custom_nodes\HeartMuLa_ComfyUI"
git clone https://github.com/pythongosssss/ComfyUI-Custom-Scripts.git "ComfyUI_windows_portable\ComfyUI\custom_nodes\ComfyUI-Custom-Scripts"

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
.\python_embeded\python.exe -m pip install -r .\ComfyUI\custom_nodes\HeartMuLa_ComfyUI\requirements.txt
.\python_embeded\python.exe -m pip install -r .\ComfyUI\custom_nodes\ComfyUI-HeartMuLa\requirements.txt
.\python_embeded\python.exe -m pip install -r .\ComfyUI\custom_nodes\rgthree-comfy\requirements.txt
.\python_embeded\python.exe -m pip install torch==2.8.0+cu128 torchvision==0.23.0+cu128 torchaudio==2.8.0+cu128 --index-url https://download.pytorch.org/whl/cu128
.\python_embeded\python.exe -m pip install --extra-index-url https://pypi.nvidia.com nvidia-vfx
.\python_embeded\python.exe -m pip install --no-cache-dir --upgrade numba
.\python_embeded\python.exe -m pip install -U "triton-windows<3.5"

                                                                                                       
REM ======== Ask whether to download models ========
echo.
echo Do you want to download the models now?
choice /C YN /M "Press Y for Yes or N for No:"

if errorlevel 2 (
    echo Skipping model downloads.
    cd update
    .\update_comfyui.bat
) else (
    if not exist "ComfyUI\models\HeartMuLa" mkdir "ComfyUI\models\HeartMuLa"
    echo Downloading models...
    curl -k -L -o ComfyUI\models\checkpoints\HeartCodec-oss-merged-fp16.safetensors "https://huggingface.co/Thelocallab/HeartMuLa-oss-ComfyUI/resolve/main/HeartCodec-oss-merged-fp16.safetensors?download=true"
    curl -k -L -o ComfyUI\models\checkpoints\HeartMuLa-oss-3B-merged-bf16.safetensors "https://huggingface.co/Thelocallab/HeartMuLa-oss-ComfyUI/resolve/main/HeartMuLa-oss-3B-merged-bf16.safetensors?download=true"
    curl -k -L --create-dirs -o ComfyUI\models\HeartMuLa\HeartTranscriptor-oss\config.json "https://huggingface.co/HeartMuLa/HeartTranscriptor-oss/resolve/main/config.json?download=true"
    curl -k -L --create-dirs -o ComfyUI\models\HeartMuLa\HeartTranscriptor-oss\generation_config.json "https://huggingface.co/HeartMuLa/HeartTranscriptor-oss/resolve/main/generation_config.json?download=true"
    curl -k -L --create-dirs -o ComfyUI\models\HeartMuLa\HeartTranscriptor-oss\preprocessor_config.json "https://huggingface.co/HeartMuLa/HeartTranscriptor-oss/resolve/main/preprocessor_config.json?download=true"
    curl -k -L --create-dirs -o ComfyUI\models\HeartMuLa\HeartTranscriptor-oss\tokenizer.json "https://huggingface.co/HeartMuLa/HeartTranscriptor-oss/resolve/main/tokenizer.json?download=true"
    curl -k -L --create-dirs -o ComfyUI\models\HeartMuLa\HeartTranscriptor-oss\tokenizer_config.json "https://huggingface.co/HeartMuLa/HeartTranscriptor-oss/resolve/main/tokenizer_config.json?download=true"
    curl -k -L --create-dirs -o ComfyUI\models\HeartMuLa\HeartTranscriptor-oss\special_tokens_map.json "https://huggingface.co/HeartMuLa/HeartTranscriptor-oss/resolve/main/special_tokens_map.json?download=true"
    curl -k -L --create-dirs -o ComfyUI\models\HeartMuLa\HeartTranscriptor-oss\added_tokens.json "https://huggingface.co/HeartMuLa/HeartTranscriptor-oss/resolve/main/added_tokens.json?download=true"
    curl -k -L --create-dirs -o ComfyUI\models\HeartMuLa\HeartTranscriptor-oss\normalizer.json "https://huggingface.co/HeartMuLa/HeartTranscriptor-oss/resolve/main/normalizer.json?download=true"
    curl -k -L --create-dirs -o ComfyUI\models\HeartMuLa\HeartTranscriptor-oss\vocab.json "https://huggingface.co/HeartMuLa/HeartTranscriptor-oss/resolve/main/vocab.json?download=true"
    curl -k -L --create-dirs -o ComfyUI\models\HeartMuLa\HeartTranscriptor-oss\merges.txt "https://huggingface.co/HeartMuLa/HeartTranscriptor-oss/resolve/main/merges.txt?download=true"
    curl -k -L --create-dirs -o ComfyUI\models\HeartMuLa\HeartTranscriptor-oss\model.safetensors "https://huggingface.co/HeartMuLa/HeartTranscriptor-oss/resolve/main/model.safetensors?download=true"
    cd update
    .\update_comfyui.bat
)

echo Setup complete

REM Keep the window open
pause