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

::--------------------- Miniconda: Download & Install If Needed ---------------------
if not exist "miniconda3" (
    echo Downloading Miniconda...
    curl -k -L -o miniconda.exe https://repo.anaconda.com/miniconda/Miniconda3-py312_25.5.1-0-Windows-x86_64.exe

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

::--------------------- Conda Environment Setup ---------------------
echo Creating conda environment with Python 3.12...
call miniconda3\Scripts\activate.bat


::--------------------- Clone repositories ---------------------
git clone https://github.com/comfyanonymous/ComfyUI.git
git clone https://github.com/ltdrdata/ComfyUI-Manager.git "ComfyUI\custom_nodes\ComfyUI-Manager"
git clone https://github.com/city96/ComfyUI-GGUF.git "ComfyUI\custom_nodes\ComfyUI-GGUF"
git clone https://github.com/kijai/ComfyUI-KJNodes.git "ComfyUI\custom_nodes\ComfyUI-KJNodes"
git clone https://github.com/rgthree/rgthree-comfy.git "ComfyUI\custom_nodes\rgthree-comfy"
git clone https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite.git "ComfyUI\custom_nodes\ComfyUI-VideoHelperSuite"
git clone https://github.com/chflame163/ComfyUI_LayerStyle.git "ComfyUI\custom_nodes\ComfyUI_LayerStyle"
git clone https://github.com/M1kep/ComfyLiterals.git "ComfyUI\custom_nodes\ComfyLiterals"
git clone https://github.com/kijai/ComfyUI-segment-anything-2.git "ComfyUI\custom_nodes\ComfyUI-segment-anything-2"
git clone https://github.com/Fannovel16/comfyui_controlnet_aux.git "ComfyUI\custom_nodes\comfyui_controlnet_aux"
git clone https://github.com/kijai/ComfyUI-WanVideoWrapper.git "ComfyUI\custom_nodes\ComfyUI-WanVideoWrapper"
git clone https://github.com/yolain/ComfyUI-Easy-Use.git "ComfyUI\custom_nodes\ComfyUI-Easy-Use"

cd ComfyUI

REM Step 4: Install requirements
cd ComfyUI_windows_portable
echo Installing requirements...
pip install -r requirements.txt
pip install opencv_python==4.10.0.82
pip install -r .\custom_nodes\ComfyUI-Manager\requirements.txt
pip uninstall -y torch
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu128
curl -k -L -o flash_attn-2.8.3+cu128torch2.8.0cxx11abiFALSE-cp312-cp312-win_amd64.whl https://github.com/kingbri1/flash-attention/releases/download/v2.8.3/flash_attn-2.8.3+cu128torch2.8.0cxx11abiFALSE-cp312-cp312-win_amd64.whl
curl -k -L -o sageattention-2.2.0+cu128torch2.8.0-cp312-cp312-win_amd64.whl https://github.com/woct0rdho/SageAttention/releases/download/v2.2.0-windows/sageattention-2.2.0+cu128torch2.8.0-cp312-cp312-win_amd64.whl
pip install flash_attn-2.8.3+cu128torch2.8.0cxx11abiFALSE-cp312-cp312-win_amd64.whl
pip install sageattention-2.2.0+cu128torch2.8.0-cp312-cp312-win_amd64.whl
pip install -U "triton-windows<3.5"
pip install -r .\custom_nodes\ComfyUI-GGUF\requirements.txt
pip install -r .\custom_nodes\ComfyUI-KJNodes\requirements.txt
pip install -r .\custom_nodes\rgthree-comfy\requirements.txt
pip install -r .\custom_nodes\ComfyUI-VideoHelperSuite\requirements.txt
pip install -r .\custom_nodes\ComfyUI_LayerStyle\requirements.txt
pip install -r .\custom_nodes\ComfyUI-WanVideoWrapper\requirements.txt
pip install -r .\custom_nodes\comfyui_controlnet_aux\requirements.txt
pip install -r .\custom_nodes\ComfyUI-Easy-Use\requirements.txt
pip install --no-cache-dir --upgrade numba
pip install numpy==1.26.4

::--------------------- Create start and update batch files ---------------------
echo @echo off > "%PROJECT_DIR%start_comfyui.bat"
echo cd /d "%PROJECT_DIR%ComfyUI" >> "%PROJECT_DIR%start_comfyui.bat"
echo echo Activating conda environment... >> "%PROJECT_DIR%start_comfyui.bat"
echo call "%PROJECT_DIR%miniconda3\Scripts\activate.bat" >> "%PROJECT_DIR%start_comfyui.bat"
echo echo Starting ComfyUI... >> "%PROJECT_DIR%start_comfyui.bat"
echo python main.py --use-sage-attention >> "%PROJECT_DIR%start_comfyui.bat"
echo pause >> "%PROJECT_DIR%start_comfyui.bat"

echo @echo off > "%PROJECT_DIR%update_comfyui.bat"
echo echo Updating ComfyUI... >> "%PROJECT_DIR%update_comfyui.bat"
echo cd /d "%PROJECT_DIR%ComfyUI" >> "%PROJECT_DIR%update_comfyui.bat"
echo call "%PROJECT_DIR%miniconda3\Scripts\activate.bat" >> "%PROJECT_DIR%update_comfyui.bat"
echo git pull >> "%PROJECT_DIR%update_comfyui.bat"
echo pip install -r requirements.txt >> "%PROJECT_DIR%update_comfyui.bat"
echo pause >> "%PROJECT_DIR%update_comfyui.bat"

echo Downloading models...
curl -k -L -o ComfyUI\models\vae\wan_2.1_vae.safetensors https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/vae/wan_2.1_vae.safetensors?download=true
curl -k -L -o ComfyUI\models\loras\Wan21_T2V_14B_lightx2v_cfg_step_distill_lora_rank32.safetensors https://huggingface.co/Thelocallab/WAN-2.1-loras/resolve/main/Wan21_T2V_14B_lightx2v_cfg_step_distill_lora_rank32.safetensors?download=true
curl -k -L -o ComfyUI\models\clip\umt5_xxl_fp8_e4m3fn_scaled.safetensors https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/text_encoders/umt5_xxl_fp8_e4m3fn_scaled.safetensors?download=true
curl -k -L -o ComfyUI\models\unet\Wan2.2-Animate-14B-Q2_K.gguf https://huggingface.co/QuantStack/Wan2.2-Animate-14B-GGUF/resolve/main/Wan2.2-Animate-14B-Q2_K.gguf?download=true

:end
echo Setup complete

REM Keep the window open
pause