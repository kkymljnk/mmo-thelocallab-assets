@echo off
setlocal enabledelayedexpansion

:: Set the directory for the project to the current directory
set "PROJECT_DIR=%~dp0"
cd /d "%PROJECT_DIR%"

:: Download and install Miniconda if not exists
if not exist "miniconda3" (
    echo Downloading Miniconda...
    curl -k -L -o miniconda.exe https://repo.anaconda.com/miniconda/Miniconda3-py310_25.5.1-0-Windows-x86_64.exe
    
    if errorlevel 1 (
        echo Error downloading Miniconda. Please check your internet connection and try again.
        pause
        goto end
    )
    
    echo Installing Miniconda silently...
    start /wait "" miniconda.exe /InstallationType=JustMe /RegisterPython=0 /AddToPath=1 /S /D=%CD%\miniconda3
    
    if errorlevel 1 (
        echo Error installing Miniconda.
        pause
        goto end
    )
    
    del miniconda.exe
)

:: Initialize conda for this shell session
call "%PROJECT_DIR%miniconda3\Scripts\activate.bat"

:: Create and activate conda environment with Python 3.10.16
echo Creating conda environment 'iopaint-env' with Python 3.10...
call miniconda3\Scripts\activate.bat

if errorlevel 1 (
    echo Error occurred during conda environment creation. See conda_create.log for details.
    pause
    goto end
)

:: Install dependencies
echo Installing PyTorch with CUDA support (for GPU users)...
pip install torch==2.1.2 torchvision==0.16.2 --index-url https://download.pytorch.org/whl/cu118

echo Installing IOPaint package...
pip install rembg
pip install onnxruntime
pip install realesrgan
pip install gfpgan
pip install iopaint

:: Create start_iopaint.bat to launch the web UI
(
echo @echo off
echo cd /d "%PROJECT_DIR%"
echo echo Activating conda environment...
echo call "%PROJECT_DIR%miniconda3\Scripts\activate.bat"
echo echo Starting IOPaint web UI...
echo python -m iopaint start --model=lama --enable-remove-bg --device=cpu --port=8080 --enable-realesrgan --realesrgan-model RealESRGAN_x4plus --realesrgan-device cuda --enable-interactive-seg --interactive-seg-model=sam2_base  --interactive-seg-device=cuda --enable-gfpgan --gfpgan-device cuda --enable-restoreformer --restoreformer-device cuda --enable-anime-seg
echo pause
) > "%PROJECT_DIR%start_iopaint.bat"

:: Create update_iopaint.bat to update the pip-installed IOPaint package
(
echo @echo off
echo echo Updating IOPaint package...
echo call "%PROJECT_DIR%miniconda3\Scripts\activate.bat"
echo pip install --upgrade iopaint
echo pause
) > "%PROJECT_DIR%update_iopaint.bat"

echo Installation and setup complete.
echo To start IOPaint, run start_iopaint.bat
echo To update IOPaint, run update_iopaint.bat

pause
:end
endlocal
