@echo off
setlocal EnableDelayedExpansion

REM ============================================================
REM  SD Forge Neo + Qwen-Image 2.1 Turbo - one-click Windows installer
REM  by TheLocalLab
REM
REM  Put this .bat in its own EMPTY folder on a short path (e.g. C:\ForgeNeo\) and run it.
REM  Needs an NVIDIA GPU with driver 580+ (Neo now runs PyTorch 2.13 / CUDA 13).
REM ============================================================

set "PROJECT_DIR=%~dp0"
cd /d "%PROJECT_DIR%"

REM Neo version tested by TheLocalLab (neo 2.30, 2026-10-14). Newer commits can break things;
REM the update .bat moves you to the next tested version.
set "NEO_COMMIT=46af880c003d31846bbea984ce00fc7be247ce5b"
set "UV_VERSION=0.13.0"
set "QWEN=https://huggingface.co/Comfy-Org/Qwen-Image-2.1/resolve/main"

REM ---------------- Git ----------------
where git >nul 2>nul
if !errorlevel! neq 0 (
    echo Git not found. Downloading Git...
    curl -fL -o Git-setup.exe "https://github.com/git-for-windows/git/releases/download/v2.45.2.windows.1/Git-2.45.2-64-bit.exe"
    if !errorlevel! neq 0 (
        echo Error downloading Git. Please check your internet connection and try again.
        goto end
    )
    start /wait "" Git-setup.exe /VERYSILENT /NORESTART /NOCANCEL /DIR="%USERPROFILE%\Git"
    del Git-setup.exe
    set "PATH=%USERPROFILE%\Git\cmd;!PATH!"
)
git --version
if !errorlevel! neq 0 (
    echo Git is not working. Please install Git manually and run this again.
    goto end
)

REM ---------------- uv (installs Python 3.13 + packages, fast) ----------------
if not exist "uv\uv.exe" (
    echo Downloading uv %UV_VERSION%...
    curl -fL -o uv.zip "https://github.com/astral-sh/uv/releases/download/%UV_VERSION%/uv-x86_64-pc-windows-msvc.zip"
    if !errorlevel! neq 0 (
        echo Error downloading uv. Please check your internet connection and try again.
        goto end
    )
    if not exist uv mkdir uv
    tar -xf uv.zip -C uv
    del uv.zip
)
if not exist "uv\uv.exe" (
    echo uv did not unpack. Please try again.
    goto end
)
set "PATH=%PROJECT_DIR%uv;%PATH%"
set "UV_PYTHON_INSTALL_DIR=%PROJECT_DIR%uv\python"
set "UV_CACHE_DIR=%PROJECT_DIR%uv\cache"

REM ---------------- Forge Neo ----------------
if not exist "sd-webui-forge-neo\.git" (
    echo Cloning SD Forge Neo...
    git clone --branch neo https://github.com/Haoming02/sd-webui-forge-classic sd-webui-forge-neo
    if !errorlevel! neq 0 (
        echo Error cloning Forge Neo. Please check your internet connection and try again.
        goto end
    )
)
cd /d "%PROJECT_DIR%sd-webui-forge-neo"
git checkout -q %NEO_COMMIT%
if !errorlevel! neq 0 (
    echo Could not switch to the tested Neo version.
    goto end
)

REM Python 3.13 venv (Neo's recommended setup). uv downloads Python itself - no system Python needed.
if not exist "venv\Scripts\python.exe" (
    echo Creating the Python 3.13 environment...
    uv venv venv --python 3.13 --seed
    if !errorlevel! neq 0 (
        echo Error creating the Python 3.13 environment.
        goto end
    )
)

REM Launch flags + uv path. webui.bat loads webui.settings.bat on every start, and updates never
REM overwrite it. Flags are ADDED to whatever you put in webui-user.bat.
>  webui.settings.bat echo @echo off
>> webui.settings.bat echo set "PATH=%PROJECT_DIR%uv;%%PATH%%"
>> webui.settings.bat echo set "UV_PYTHON_INSTALL_DIR=%PROJECT_DIR%uv\python"
>> webui.settings.bat echo set "UV_CACHE_DIR=%PROJECT_DIR%uv\cache"
>> webui.settings.bat echo set "COMMANDLINE_ARGS=%%COMMANDLINE_ARGS%% --uv --sage"

REM ---------------- Models ----------------
echo.
echo ============================================================
echo   Qwen-Image 2.1 Turbo - Model Download
echo ============================================================
echo   The text encoder (8.9 GB) and VAE (0.6 GB) always download.
echo.
echo   BASE MODEL:
echo   [1] Turbo int8 (default, 6.9 GB) - best quality
echo   [2] Turbo GGUF Q5_K_M (4.8 GB)   - low VRAM
echo   [3] Skip - I will add models myself
echo ============================================================
choice /C 123 /M "Pick a base model"
set BASEOPT=!errorlevel!

if !BASEOPT!==1 set "BASE_FILE=qwen_image_2.1_turbo_int8_convrot.safetensors"
if !BASEOPT!==1 set "BASE_URL=%QWEN%/diffusion_models/qwen_image_2.1_turbo_int8_convrot.safetensors"
if !BASEOPT!==2 set "BASE_FILE=qwen_image_2.1_turbo_Q5_K_M.gguf"
if !BASEOPT!==2 set "BASE_URL=https://huggingface.co/Abiray/Qwen-Image-2.1-Turbo-GGUF/resolve/main/qwen_image_2.1_turbo_Q5_K_M.gguf"
set "TE_FILE=qwen3vl_8b_int8_convrot.safetensors"
set "VAE_FILE=qwen_image_2.1_vae_bf16.safetensors"

if !BASEOPT!==3 goto launcher

call :get "models\Stable-diffusion\!BASE_FILE!" "!BASE_URL!" || goto end
call :get "models\text_encoder\%TE_FILE%" "%QWEN%/text_encoders/%TE_FILE%" || goto end
call :get "models\VAE\%VAE_FILE%" "%QWEN%/vae/%VAE_FILE%" || goto end

REM Pre-set the Qwen 2.1 preset with the Turbo settings (8 steps, CFG 1) and these models,
REM and put the Edit/img2img switch in Quicksettings. Only on a fresh install (no config.json yet).
if not exist "config.json" call :writeconfig

:launcher
cd /d "%PROJECT_DIR%"
>  start_sd-forge-neo.bat echo @echo off
>> start_sd-forge-neo.bat echo cd /d "%PROJECT_DIR%sd-webui-forge-neo"
>> start_sd-forge-neo.bat echo call webui-user.bat

echo.
echo ============================================================
echo  Install done. Starting Forge Neo for the first time.
echo  The first start installs PyTorch, Sage Attention and Triton (about 10 minutes).
echo  Next time, run start_sd-forge-neo.bat
echo ============================================================
cd /d "%PROJECT_DIR%sd-webui-forge-neo"
call webui-user.bat
goto end

REM ---------------- helpers ----------------
:get
REM %1 = target file, %2 = URL. Skips files that are already there.
if exist "%~1" (
    echo Already have %~nx1
    exit /b 0
)
echo Downloading %~nx1...
curl -fL --retry 3 -o "%~1" "%~2"
if !errorlevel! neq 0 (
    echo Error downloading %~nx1. Please check your internet connection and run this again.
    if exist "%~1" del "%~1"
    exit /b 1
)
exit /b 0

:writeconfig
set "NEO=%CD%"
set "JM=%NEO:\=\\%\\models"
>  config.json echo {
>> config.json echo  "VERSION_UID": "PY313",
>> config.json echo  "forge_preset": "qwen21",
>> config.json echo  "sd_model_checkpoint": "%BASE_FILE%",
>> config.json echo  "forge_checkpoint_qwen21": "%BASE_FILE%",
>> config.json echo  "forge_additional_modules": ["%JM%\\text_encoder\\%TE_FILE%", "%JM%\\VAE\\%VAE_FILE%"],
>> config.json echo  "forge_additional_modules_qwen21": ["%JM%\\text_encoder\\%TE_FILE%", "%JM%\\VAE\\%VAE_FILE%"],
>> config.json echo  "qwen21_t2i_step": 8, "qwen21_t2i_hr_step": 8, "qwen21_i2i_step": 8,
>> config.json echo  "qwen21_t2i_cfg": 1.0, "qwen21_t2i_hr_cfg": 1.0, "qwen21_i2i_cfg": 1.0,
>> config.json echo  "quicksettings_list": ["qwen21_do_reference"]
>> config.json echo }
exit /b 0

:end
echo.
pause
endlocal
