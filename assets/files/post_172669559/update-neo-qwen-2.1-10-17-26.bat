@echo off
setlocal EnableDelayedExpansion

REM ============================================================
REM  SD Forge Neo updater (adds Qwen-Image 2.1 Turbo) - by TheLocalLab
REM
REM  Run it from the folder that holds sd-webui-forge-neo (where you ran the installer),
REM  or from inside sd-webui-forge-neo. Close Forge Neo first.
REM  Needs an NVIDIA GPU with driver 580+ (Neo now runs PyTorch 2.13 / CUDA 13).
REM
REM  What it does:
REM   - moves Neo to the version TheLocalLab tested (neo 2.30), keeping your webui-user.bat
REM   - older installs ran Python 3.11 + PyTorch 2.8: it builds a fresh Python 3.13 venv
REM     (your old one is kept as venv-old so you can roll back)
REM   - backs up config.json / ui-config.json (Neo asks for this after its breaking update)
REM   - downloads only the Qwen 2.1 files you are missing; your other models stay untouched
REM ============================================================

set "NEO_COMMIT=46af880c003d31846bbea984ce00fc7be247ce5b"
set "UV_VERSION=0.13.0"
set "QWEN=https://huggingface.co/Comfy-Org/Qwen-Image-2.1/resolve/main"

if exist "%~dp0sd-webui-forge-neo\.git" (
    set "PROJECT_DIR=%~dp0"
    set "NEO=%~dp0sd-webui-forge-neo"
) else if exist "%~dp0.git" (
    set "NEO=%~dp0"
    set "NEO=!NEO:~0,-1!"
    for %%P in ("!NEO!\..") do set "PROJECT_DIR=%%~fP\"
) else (
    echo [ERROR] No Forge Neo install found here.
    echo Put this .bat next to the sd-webui-forge-neo folder, or inside it, and run it again.
    goto end
)
echo Forge Neo folder: %NEO%

where git >nul 2>nul
if !errorlevel! neq 0 (
    if exist "%USERPROFILE%\Git\cmd\git.exe" (
        set "PATH=%USERPROFILE%\Git\cmd;!PATH!"
    ) else (
        echo [ERROR] Git not found. Run the installer once, or install Git, then run this again.
        goto end
    )
)

REM ---------------- uv ----------------
cd /d "%PROJECT_DIR%"
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

REM ---------------- Neo code ----------------
cd /d "%NEO%"
echo Fetching Forge Neo...
git fetch origin
if !errorlevel! neq 0 (
    echo [ERROR] Fetch failed. Please check your internet connection.
    goto end
)
REM Keep the user's own launch settings across the update.
if exist webui-user.bat copy /y webui-user.bat webui-user.bat.mine >nul
git checkout -q -f %NEO_COMMIT%
if !errorlevel! neq 0 (
    echo [ERROR] Could not switch to the tested Neo version.
    goto end
)
if exist webui-user.bat.mine move /y webui-user.bat.mine webui-user.bat >nul
echo Neo is now at the tested version (neo 2.30).

REM ---------------- Python 3.13 ----------------
set "PYVER="
if exist "venv\Scripts\python.exe" (
    for /f "delims=" %%V in ('venv\Scripts\python.exe -c "import sys;sys.stdout.write(str(sys.version_info[0])+chr(46)+str(sys.version_info[1]))"') do set "PYVER=%%V"
)
if not "!PYVER!"=="3.13" (
    if exist "venv" (
        echo Your environment is Python !PYVER!; Neo now needs Python 3.13. Building a fresh one...
        if exist "venv-old" rmdir /s /q "venv-old"
        ren venv venv-old
        if exist "venv" (
            echo [ERROR] Could not rename the old venv. Close Forge Neo and any open terminal using it, then run this again.
            goto end
        )
    )
    uv venv venv --python 3.13 --seed
    if !errorlevel! neq 0 (
        echo [ERROR] Could not create the Python 3.13 environment.
        goto end
    )
    echo Fresh Python 3.13 environment ready. The old one is in venv-old: delete it once Neo runs fine.
)

REM ---------------- Settings ----------------
REM Neo 2.x stops with "You are updating from an old version" unless old settings are removed.
set "NEWCONFIG=0"
if exist "config.json" (
    findstr /C:"PY313" config.json >nul
    if !errorlevel! neq 0 (
        echo Backing up your old settings to config.json.old / ui-config.json.old
        move /y config.json config.json.old >nul
        if exist ui-config.json move /y ui-config.json ui-config.json.old >nul
        set "NEWCONFIG=1"
    )
) else (
    set "NEWCONFIG=1"
)

>  webui.settings.bat echo @echo off
>> webui.settings.bat echo set "PATH=%PROJECT_DIR%uv;%%PATH%%"
>> webui.settings.bat echo set "UV_PYTHON_INSTALL_DIR=%PROJECT_DIR%uv\python"
>> webui.settings.bat echo set "UV_CACHE_DIR=%PROJECT_DIR%uv\cache"
>> webui.settings.bat echo set "COMMANDLINE_ARGS=%%COMMANDLINE_ARGS%% --uv %%NEO_FAST_ARGS%%"
>> webui.settings.bat echo if exist "%%~dp0webui.models.bat" call "%%~dp0webui.models.bat"

REM ---------------- Qwen 2.1 models (only what is missing) ----------------
echo.
echo ============================================================
echo   Qwen-Image 2.1 Turbo - Model Download (files you already have are skipped)
echo ============================================================
echo   [1] Recommended - Turbo int8 + w4a8 text encoder (about 14 GB download)
echo       best speed and quality for most PCs
echo   [2] Lowest RAM - Turbo GGUF Q5 + w4a8 text encoder (about 12 GB download)
echo       for PCs with 16 GB of system RAM; about half the speed
echo   [3] Full - Turbo int8 + int8 text encoder (about 16 GB download)
echo       for PCs with 32 GB+ of system RAM
echo   [4] Skip - update Neo only
echo ============================================================
choice /C 1234 /M "Pick a setup"
set BASEOPT=!errorlevel!
set "INT8=qwen_image_2.1_turbo_int8_convrot.safetensors"
set "GGUF=qwen_image_2.1_turbo_Q5_K_M.gguf"
set "BASE_FILE=%INT8%"
set "BASE_URL=%QWEN%/diffusion_models/%INT8%"
set "TE_FILE=qwen3vl_8b_w4a8.safetensors"
if !BASEOPT!==2 set "BASE_FILE=%GGUF%"
if !BASEOPT!==2 set "BASE_URL=https://huggingface.co/Abiray/Qwen-Image-2.1-Turbo-GGUF/resolve/main/%GGUF%"
if !BASEOPT!==3 set "TE_FILE=qwen3vl_8b_int8_convrot.safetensors"
set "VAE_FILE=qwen_image_2.1_vae_bf16.safetensors"
if !BASEOPT!==4 goto done

call :get "models\Stable-diffusion\!BASE_FILE!" "!BASE_URL!" || goto end
call :get "models\text_encoder\%TE_FILE%" "%QWEN%/text_encoders/%TE_FILE%" || goto end
call :get "models\VAE\%VAE_FILE%" "%QWEN%/vae/%VAE_FILE%" || goto end
if "!NEWCONFIG!"=="1" call :writeconfig

:done
cd /d "%PROJECT_DIR%"
>  start_sd-forge-neo.bat echo @echo off
>> start_sd-forge-neo.bat echo set "NEO_FAST_ARGS=--disable-sage"
>> start_sd-forge-neo.bat echo cd /d "%PROJECT_DIR%sd-webui-forge-neo"
>> start_sd-forge-neo.bat echo call webui-user.bat
REM Plain launcher passes --disable-sage: once Sage is installed Neo would otherwise use it everywhere.
REM Optional faster launcher: Sage Attention + memory flags (Sage + Triton install on its first start).
>  start_sd-forge-neo-FAST.bat echo @echo off
>> start_sd-forge-neo-FAST.bat echo set "NEO_FAST_ARGS=--sage --cuda-malloc --cuda-stream --pin-shared-memory"
>> start_sd-forge-neo-FAST.bat echo cd /d "%PROJECT_DIR%sd-webui-forge-neo"
>> start_sd-forge-neo-FAST.bat echo call webui-user.bat
cd /d "%NEO%"
echo.
echo ============================================================
echo  Update done. Start Forge Neo with start_sd-forge-neo.bat
echo  (or start_sd-forge-neo-FAST.bat for Sage Attention + memory flags).
echo  The first start reinstalls PyTorch 2.13: 10-30 minutes depending on your internet.
echo  If something breaks: delete venv, rename venv-old to venv, and tell us on Patreon.
echo ============================================================
goto end

REM ---------------- helpers ----------------
:get
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
>> config.json echo  "qwen21_t2i_sampler": "ER SDE", "qwen21_i2i_sampler": "LCM",
>> config.json echo  "qwen21_t2i_scheduler": "Linear Quadratic", "qwen21_i2i_scheduler": "Bong Tangent",
>> config.json echo  "qwen21_t2i_width": 1664, "qwen21_t2i_height": 1152,
>> config.json echo  "quicksettings_list": ["qwen21_do_reference"]
>> config.json echo }
exit /b 0

:end
echo.
pause
endlocal
