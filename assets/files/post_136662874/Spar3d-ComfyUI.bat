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
git clone https://github.com/Stability-AI/stable-point-aware-3d.git "ComfyUI\custom_nodes\stable-point-aware-3d"
cd ComfyUI

::--------------------- Install dependencies ---------------------
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu128
pip install -r requirements.txt
pip install -r .\custom_nodes\ComfyUI-Manager\requirements.txt
pip install einops==0.7.0
pip install jaxtyping==0.2.31
pip install omegaconf==2.3.0
pip install transformers==4.42.3
pip install loralib==0.1.2
pip install git+https://github.com/openai/CLIP.git
pip install git+https://github.com/SunzeY/AlphaCLIP.git
pip install trimesh==4.4.1
pip install numpy==1.26.4
pip install huggingface-hub==0.23.4
pip install transparent-background==1.3.3
pip install .\custom_nodes\stable-point-aware-3d\texture_baker\
pip install .\custom_nodes\stable-point-aware-3d\uv_unwrapper\
pip install flet==0.10.2
pip install pynanoinstantmeshes==0.0.3
pip install gpytoolbox==0.3.3
mkdir "%PROJECT_DIR%\ComfyUI\custom_nodes\stable-point-aware-3d\stabilityai\stable-point-aware-3d"

::--------------------- Create start and update batch files ---------------------
echo @echo off > "%PROJECT_DIR%start_comfyui.bat"
echo cd /d "%PROJECT_DIR%ComfyUI" >> "%PROJECT_DIR%start_comfyui.bat"
echo echo Activating conda environment... >> "%PROJECT_DIR%start_comfyui.bat"
echo call "%PROJECT_DIR%miniconda3\Scripts\activate.bat" >> "%PROJECT_DIR%start_comfyui.bat"
echo echo Starting ComfyUI... >> "%PROJECT_DIR%start_comfyui.bat"
echo python main.py >> "%PROJECT_DIR%start_comfyui.bat"
echo pause >> "%PROJECT_DIR%start_comfyui.bat"

echo @echo off > "%PROJECT_DIR%update_comfyui.bat"
echo echo Updating ComfyUI... >> "%PROJECT_DIR%update_comfyui.bat"
echo cd /d "%PROJECT_DIR%ComfyUI" >> "%PROJECT_DIR%update_comfyui.bat"
echo call "%PROJECT_DIR%miniconda3\Scripts\activate.bat" >> "%PROJECT_DIR%update_comfyui.bat"
echo git pull >> "%PROJECT_DIR%update_comfyui.bat"
echo pip install -r requirements.txt >> "%PROJECT_DIR%update_comfyui.bat"
echo pause >> "%PROJECT_DIR%update_comfyui.bat"

pause
endlocal
