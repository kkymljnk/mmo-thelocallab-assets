@echo off
setlocal enabledelayedexpansion

::--------------------- Basic setup ----------------------------
:: Set the directory for the project to the current directory
set "PROJECT_DIR=%~dp0"
cd /d "%PROJECT_DIR%"

::--------------------- GIT: Check and Install If Needed --------
where git >nul 2>&1
if errorlevel 1 (
    echo Git not found. Downloading and installing Git...
    set "GIT_INSTALLER=Git-setup.exe"

    curl -L -k -o "%GIT_INSTALLER%" https://github.com/git-for-windows/git/releases/latest/download/Git-2.45.2-64-bit.exe
    if errorlevel 1 (
        echo Error downloading Git installer.
        goto end
    )

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

::--------------------- Miniconda: Download & Install If Needed --
if not exist "miniconda3\Scripts\activate.bat" (
    echo Downloading Miniconda...
    curl -k -L -o miniconda.exe https://repo.anaconda.com/miniconda/Miniconda3-py312_25.11.1-1-Windows-x86_64.exe
    if errorlevel 1 (
        echo Error downloading Miniconda. Please check your internet connection and try again.
        goto end
    )

    echo Installing Miniconda...
    start /wait "" miniconda.exe /InstallationType=JustMe /RegisterPython=0 /S /D=%CD%\miniconda3
    if errorlevel 1 (
        echo Error installing Miniconda.
        goto end
    )

    del miniconda.exe
) else (
    echo Miniconda already installed.
)

::--------------------- Conda base + venv ------------------------
echo Activating Miniconda base environment...
call miniconda3\Scripts\activate.bat
if errorlevel 1 (
    echo Failed to activate Miniconda base environment.
    goto end
)

::--------------------- Clone and setup project ------------------
if not exist "Voice-Clone-Studio" (
    echo Cloning Voice-Clone-Studio...
    git clone https://github.com/FranckyB/Voice-Clone-Studio.git
    if errorlevel 1 (
        echo Error cloning Voice-Clone-Studio repository.
        goto end
    )
) else (
    echo Voice-Clone-Studio folder already exists. Skipping clone.
)

cd /d "%PROJECT_DIR%Voice-Clone-Studio"

echo Creating virtual environment...
call python -m venv venv
if errorlevel 1 (
    echo Error creating virtual environment.
    goto end
)

echo Activating virtual environment...
call venv\Scripts\activate.bat
if errorlevel 1 (
    echo Error activating virtual environment.
    goto end
)

echo Upgrading pip...
python -m pip install --upgrade pip
if errorlevel 1 (
    echo Error upgrading pip.
    goto end
)

::--------------------- Install dependencies ---------------------
echo Upgrading setuptools...
pip install --upgrade setuptools
if errorlevel 1 (
    echo Error upgrading setuptools.
    goto end
)

echo Installing requirements...
pip install -r requirements.txt
if errorlevel 1 (
    echo Error installing requirements from requirements.txt.
    goto end
)

echo Installing PyTorch CUDA 12.8 builds...
pip install torch==2.8.0+cu128 torchvision==0.23.0+cu128 torchaudio==2.8.0+cu128 --index-url https://download.pytorch.org/whl/cu128
if errorlevel 1 (
    echo Error installing PyTorch CUDA packages.
    goto end
)

echo Downloading flash-attn wheel...
curl -k -L -o flash_attn-2.8.3+cu128torch2.8.0cxx11abiFALSE-cp312-cp312-win_amd64.whl ^
https://github.com/kingbri1/flash-attention/releases/download/v2.8.3/flash_attn-2.8.3+cu128torch2.8.0cxx11abiFALSE-cp312-cp312-win_amd64.whl
if errorlevel 1 (
    echo Error downloading flash-attn wheel.
    goto end
)

echo Installing flash-attn...
pip install flash_attn-2.8.3+cu128torch2.8.0cxx11abiFALSE-cp312-cp312-win_amd64.whl
if errorlevel 1 (
    echo Error installing flash-attn.
    goto end
)

del flash_attn-2.8.3+cu128torch2.8.0cxx11abiFALSE-cp312-cp312-win_amd64.whl 2>nul

echo.
echo Setup completed successfully.
goto done

:end
echo.
echo Script failed. See messages above for details.

:done
echo.
pause
endlocal
exit /b
