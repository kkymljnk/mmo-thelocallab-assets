@echo off
setlocal EnableDelayedExpansion

REM ============================================================
REM  Forge Neo - use the models you already have (nothing is copied or moved)
REM  by TheLocalLab
REM
REM  Put this .bat next to the sd-webui-forge-neo folder (or inside it) and run it.
REM  It tells Neo to also load models from your ComfyUI folder, or from an
REM  Automatic1111 / older Forge folder. Your own Neo models folder keeps working too.
REM  Run it again to change the folder, or pick [3] to remove the link.
REM ============================================================

if exist "%~dp0sd-webui-forge-neo\webui.bat" (
    set "NEO=%~dp0sd-webui-forge-neo"
) else if exist "%~dp0webui.bat" (
    set "NEO=%~dp0"
    set "NEO=!NEO:~0,-1!"
) else (
    echo [ERROR] No Forge Neo install found here.
    echo Put this .bat next to the sd-webui-forge-neo folder, or inside it, and run it again.
    goto end
)

echo.
echo ============================================================
echo   Where are your models?
echo ============================================================
echo   [1] A ComfyUI install    (diffusion_models, text_encoders, vae, loras ...)
echo   [2] Automatic1111 or an older Forge (Stable-diffusion, text_encoder, VAE, Lora ...)
echo   [3] Remove the link
echo ============================================================
choice /C 123 /M "Pick one"
set OPT=!errorlevel!

if !OPT!==3 (
    if exist "%NEO%\webui.models.bat" del "%NEO%\webui.models.bat"
    echo Link removed. Neo now uses only its own models folder.
    goto end
)

echo.
echo Paste the folder path. Either the main folder or its models folder works,
echo for example  D:\ComfyUI_windows_portable\ComfyUI
set "MP="
set /p "MP=Folder: "
set "MP=!MP:"=!"
if "!MP!"=="" (
    echo [ERROR] No folder entered.
    goto end
)
if "!MP:~-1!"=="\" set "MP=!MP:~0,-1!"
if not exist "!MP!\" (
    echo [ERROR] Folder not found: !MP!
    goto end
)

if !OPT!==1 (
    set "FLAG=--forge-ref-comfy-home"
    set "FOUND=0"
    for %%D in (diffusion_models checkpoints unet text_encoders vae loras) do (
        if exist "!MP!\%%D\" set "FOUND=1"
        if exist "!MP!\models\%%D\" set "FOUND=1"
    )
) else (
    set "FLAG=--forge-ref-a1111-home"
    set "FOUND=0"
    for %%D in (Stable-diffusion text_encoder VAE Lora) do (
        if exist "!MP!\%%D\" set "FOUND=1"
        if exist "!MP!\models\%%D\" set "FOUND=1"
    )
)
if "!FOUND!"=="0" (
    echo [ERROR] No model folders found in !MP!
    echo Pick the folder that contains "models", or the models folder itself.
    goto end
)

REM webui.models.bat is loaded by webui.settings.bat on every start; updates never touch it.
>  "%NEO%\webui.models.bat" echo @echo off
>> "%NEO%\webui.models.bat" echo set "COMMANDLINE_ARGS=%%COMMANDLINE_ARGS%% !FLAG! "!MP!""

REM Make sure webui.settings.bat loads it (older installs may not have this line yet).
findstr /C:"webui.models.bat" "%NEO%\webui.settings.bat" >nul 2>nul
if !errorlevel! neq 0 (
    >> "%NEO%\webui.settings.bat" echo if exist "%%~dp0webui.models.bat" call "%%~dp0webui.models.bat"
)

echo.
echo Done. Forge Neo will also load models from:
echo   !MP!
echo Restart Forge Neo, then pick your model, text encoder and VAE at the top of the page.

:end
echo.
pause
endlocal
