@echo off
setlocal enabledelayedexpansion

:: Set the directory for the project to the current directory
set "PROJECT_DIR=%~dp0"
cd "%PROJECT_DIR%"

::--------------------- GIT: Check and Install If Needed ----------------------------
where git >nul 2>nul
if errorlevel 1 (
    echo Git not found. Downloading and installing Git...
    set "GIT_INSTALLER=Git-setup.exe"
    curl -L -k -o "%GIT_INSTALLER%" https://github.com/git-for-windows/git/releases/latest/download/Git-2.45.2-64-bit.exe

    :: Install Git for current user silently (no admin rights), add to PATH
    start /wait "" "%GIT_INSTALLER%" /VERYSILENT /NORESTART /NOCANCEL /DIR="%USERPROFILE%\Git"

    if errorlevel 1 (
        echo Error installing Git.
        goto end
    )

    del "%GIT_INSTALLER%"

    :: Add Git to current session's PATH
    set "PATH=%USERPROFILE%\Git\cmd;%PATH%"
) else (
    echo Git found.
)

git --version

:: Download and install Miniconda if not exists
if not exist "miniconda3" (
    echo Downloading Miniconda...
    curl -k -L -o miniconda.exe https://repo.anaconda.com/miniconda/Miniconda3-py311_25.5.1-1-Windows-x86_64.exe
    
    if !errorlevel! neq 0 (
        echo Error downloading Miniconda. Please check your internet connection and try again.
        goto end
    )
    
    echo Installing Miniconda...
    start /wait miniconda.exe /InstallationType=JustMe /RegisterPython=0 /S /D=%CD%\miniconda3
    
    if !errorlevel! neq 0 (
        echo Error installing Miniconda.
        goto end
    )
    
    del miniconda.exe
)

:: Create and activate conda environment
echo Creating conda environment with Python 3.11...
call miniconda3\Scripts\activate.bat

:: Clone repositories
git clone https://github.com/Haoming02/sd-webui-forge-classic sd-webui-forge-neo --branch neo
cd sd-webui-forge-neo
git checkout 93503c7
call python -m venv venv
call venv\Scripts\activate.bat

:: Create start file
echo @echo off > "%PROJECT_DIR%start_sd-forge-neo.bat"
echo cd /d "%PROJECT_DIR%sd-webui-forge-neo" >> "%PROJECT_DIR%start_sd-forge-neo.bat"
echo echo Activating conda environment... >> "%PROJECT_DIR%start_sd-forge-neo.bat"
echo call "%PROJECT_DIR%miniconda3\Scripts\activate.bat" >> "%PROJECT_DIR%start_sd-forge-neo.bat"
echo echo Starting SD Forge Neo WebUI... >> "%PROJECT_DIR%start_sd-forge-neo.bat"
echo .\webui-user.bat >> "%PROJECT_DIR%start_sd-forge-neo.bat"
echo pause >> "%PROJECT_DIR%start_sd-forge-neo.bat"

:: Download models
echo Downloading models...

:: Prompt for model download
echo The Defualt Krea 2 Models are about 20 GB in size. Do you want to download them automatically? [Y/n]
set /p DOWNLOAD_MODELS=Enter Y for auto download, N for manual (default: Y):

if /I "%DOWNLOAD_MODELS%"=="N" (
    echo Skipping model download. Please download models manually and place them in the correct folders.
) else (
    echo Downloading models...
    curl -k -L -o models\Stable-diffusion\krea2_turbo-Q3_K_M.gguf https://huggingface.co/vantagewithai/Krea-2-Turbo-GGUF/resolve/main/krea2_turbo-Q3_K_M.gguf?download=true
    curl -k -L -o models\text_encoder\qwen3vl_4b_fp8_scaled.safetensors https://huggingface.co/Comfy-Org/Qwen3-VL/resolve/main/text_encoders/qwen3vl_4b_fp8_scaled.safetensors?download=true
    curl -k -L -o models\VAE\qwen_image_vae.safetensors https://huggingface.co/Comfy-Org/Qwen-Image_ComfyUI/resolve/main/split_files/vae/qwen_image_vae.safetensors?download=true
)

:: Install dependencies
pip install insightface
pip install GitPython==3.1.44
pip install Pillow==11.3.0
pip install accelerate==1.10.1
pip install clean-fid==0.1.35
pip install diffusers==0.35.1
pip install diskcache==5.6.3
pip install einops==0.8.1
pip install facexlib==0.3.0
pip install fastapi==0.112.4
pip install httpcore==0.15.0
pip install httpx==0.24.1
pip install huggingface-hub==0.34.1
pip install inflection==0.5.1
pip install joblib==1.5.1
pip install jsonmerge==1.8.0
pip install kornia==0.6.7
pip install lark==1.2.2
pip install lightning==2.5.1
pip install loadimg==0.1.2
pip install numpy==1.26.4
pip install omegaconf==2.2.3
pip install open-clip-torch==2.32.0
pip install opencv-python==4.8.1.78
pip install peft==0.17.1
pip install piexif==1.1.3
pip install pillow-heif==0.22.0
pip install protobuf==4.25.7
pip install psutil==5.9.8
pip install pydantic-core==2.23.4
pip install pydantic==2.9.2
pip install resize-right==0.0.2
pip install safetensors==0.6.2
pip install scikit-image==0.25.2
pip install setuptools==69.5.1
pip install spandrel-extra-arches==0.2.0
pip install spandrel==0.4.1
pip install tomesd==0.1.3
pip install torchdiffeq==0.2.5
pip install torchsde==0.2.6
pip install tqdm==4.67.1
pip install transformers==4.56.2
pip install torch==2.8.0+cu128 torchvision==0.23.0+cu128 torchaudio==2.8.0+cu128 --index-url https://download.pytorch.org/whl/cu128
curl -k -L -o flash_attn-2.8.3+cu128torch2.8.0cxx11abiFALSE-cp311-cp311-win_amd64.whl https://github.com/kingbri1/flash-attention/releases/download/v2.8.3/flash_attn-2.8.3+cu128torch2.8.0cxx11abiFALSE-cp311-cp311-win_amd64.whl
curl -k -L -o sageattention-2.2.0+cu128torch2.8.0.post2-cp39-abi3-win_amd64.whl https://github.com/woct0rdho/SageAttention/releases/download/v2.2.0-windows.post2/sageattention-2.2.0+cu128torch2.8.0.post2-cp39-abi3-win_amd64.whl
pip install flash_attn-2.8.3+cu128torch2.8.0cxx11abiFALSE-cp311-cp311-win_amd64.whl
pip install sageattention-2.2.0+cu128torch2.8.0.post2-cp39-abi3-win_amd64.whl
pip install -U "triton-windows<3.5"
git checkout neo
.\webui-user.bat

pause
endlocal