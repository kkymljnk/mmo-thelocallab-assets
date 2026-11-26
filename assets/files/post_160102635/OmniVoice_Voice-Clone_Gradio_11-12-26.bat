@echo off
setlocal enabledelayedexpansion

:: Set the directory for the project to the current directory
set "PROJECT_DIR=%~dp0"
cd "%PROJECT_DIR%"

:: Download and install Miniconda if not exists
if not exist "miniconda3" (
    echo Downloading Miniconda...
    curl -k -L -o miniconda.exe https://repo.anaconda.com/miniconda/Miniconda3-py311_26.3.2-2-Windows-x86_64.exe

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

::--------------------- Initialize Conda (PATH + activation script) -----------------
set "CONDA_ROOT=%CD%\miniconda3"
set "PATH=%CONDA_ROOT%;%CONDA_ROOT%\Scripts;%CONDA_ROOT%\Library\bin;%PATH%"

:: Activate base environment
call "%CONDA_ROOT%\Scripts\activate.bat"

::--------------------- Accept Anaconda ToS (non-interactive) -----------------------
echo Accepting Anaconda Terms of Service...
call conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main
call conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r
call conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/msys2

:: Optional: enable auto-accept ToS for future runs
call conda config --set plugins.auto_accept_tos yes

::--------------------- Create conda environment ------------------------------------
echo Creating conda environment "omnivoice" with Python 3.11...
call conda create -n omnivoice python=3.11 -y

if !errorlevel! neq 0 (
    echo Error creating conda environment.
    goto end
)

call conda activate omnivoice

::--------------------- Install dependencies ----------------------------------------
pip install omnivoice
pip install torch==2.8.0+cu128 torchaudio==2.8.0+cu128 --extra-index-url https://download.pytorch.org/whl/cu128
pip install numpy==1.26.4
pip install pandas==2.2.2

::--------------------- Create start_WebUI.bat --------------------------------------
echo Creating start_WebUI.bat...
(
echo @echo off
echo setlocal
echo set "BASE_DIR=%%~dp0"
echo set "CONDA_ROOT=%%BASE_DIR%%miniconda3"
echo set "PATH=%%CONDA_ROOT%%;%%CONDA_ROOT%%\Scripts;%%CONDA_ROOT%%\Library\bin;%%PATH%%"
echo call "%%CONDA_ROOT%%\Scripts\activate.bat"
echo call conda activate omnivoice
echo echo =========================================
echo echo  OmniVoice - Windows Launcher
echo echo =========================================
echo echo.
echo omnivoice-demo --ip 0.0.0.0 --port 8001
echo echo.
echo echo Process exited with code: %%errorlevel%%
echo pause
echo endlocal
) > "%PROJECT_DIR%start_WebUI.bat"

echo.
echo =========================================
echo  Installation complete!
echo  Run start_WebUI.bat to launch OmniVoice.
echo  Open browser to: http://localhost:8001
echo =========================================
echo.

:end
pause
endlocal
