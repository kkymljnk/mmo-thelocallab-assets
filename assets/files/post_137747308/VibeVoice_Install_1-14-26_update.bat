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
    curl -k -L -o miniconda.exe https://repo.anaconda.com/miniconda/Miniconda3-py310_25.5.1-0-Windows-x86_64.exe
    
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
echo Creating conda environment with Python 3.10...
call miniconda3\Scripts\activate.bat

:: Clone repositories
git clone https://github.com/TheLocalLab/VibeVoice-Fork.git
cd VibeVoice-Fork/

:: Install dependencies
pip install -e .
pip install torch==2.8.0+cu128 torchvision==0.23.0+cu128 torchaudio==2.8.0+cu128 --index-url https://download.pytorch.org/whl/cu128
curl -k -L -o flash_attn-2.8.3+cu128torch2.8.0cxx11abiFALSE-cp310-cp310-win_amd64.whl https://github.com/kingbri1/flash-attention/releases/download/v2.8.3/flash_attn-2.8.3+cu128torch2.8.0cxx11abiFALSE-cp310-cp310-win_amd64.whl
pip install flash_attn-2.8.3+cu128torch2.8.0cxx11abiFALSE-cp310-cp310-win_amd64.whl
pip install -U "triton-windows<3.5"
pip install gradio==5.50.0

:: Create start file
echo @echo off > "%PROJECT_DIR%start_VibeVoice-1.5B_LowVRAM.bat"
echo cd /d "%PROJECT_DIR%VibeVoice-Fork" >> "%PROJECT_DIR%start_VibeVoice-1.5B_LowVRAM.bat"
echo echo Activating conda environment... >> "%PROJECT_DIR%start_VibeVoice-1.5B_LowVRAM.bat"
echo call "%PROJECT_DIR%miniconda3\Scripts\activate.bat" >> "%PROJECT_DIR%start_VibeVoice-1.5B_LowVRAM.bat"
echo echo Starting VibeVoice with 1.5B Low VRAM Model... >> "%PROJECT_DIR%start_VibeVoice-1.5B_LowVRAM.bat"
echo python demo/gradio_demo.py --model_path microsoft/VibeVoice-1.5B --share >> "%PROJECT_DIR%start_VibeVoice-1.5B_LowVRAM.bat"
echo pause >> "%PROJECT_DIR%start_VibeVoice-1.5B_LowVRAM.bat"

echo @echo off > "%PROJECT_DIR%start_VibeVoice-7B_HighVRAM.bat"
echo cd /d "%PROJECT_DIR%VibeVoice-Fork" >> "%PROJECT_DIR%start_VibeVoice-7B_HighVRAM.bat"
echo echo Activating conda environment... >> "%PROJECT_DIR%start_VibeVoice-7B_HighVRAM.bat"
echo call "%PROJECT_DIR%miniconda3\Scripts\activate.bat" >> "%PROJECT_DIR%start_VibeVoice-7B_HighVRAM.bat"
echo echo Starting VibeVoice with 7B High VRAM Model... >> "%PROJECT_DIR%start_VibeVoice-7B_HighVRAM.bat"
echo python demo/gradio_demo.py --model_path aoi-ot/VibeVoice-Large --share >> "%PROJECT_DIR%start_VibeVoice-7B_HighVRAM.bat"
echo pause >> "%PROJECT_DIR%start_VibeVoice-7B_HighVRAM.bat"

:: Create update file
echo @echo off > "%PROJECT_DIR%update_vibevoice.bat"
echo echo Updating VibeVoice... >> "%PROJECT_DIR%update_vibevoice.bat"
echo cd /d "%PROJECT_DIR%VibeVoice-Fork" >> "%PROJECT_DIR%update_vibevoice.bat"
echo call "%PROJECT_DIR%miniconda3\Scripts\activate.bat" >> "%PROJECT_DIR%update_vibevoice.bat"
echo git pull >> "%PROJECT_DIR%update_vibevoice.bat"
echo pip install -e . >> "%PROJECT_DIR%update_vibevoice.bat"
echo pause >> "%PROJECT_DIR%update_vibevoice.bat"


pause
endlocal