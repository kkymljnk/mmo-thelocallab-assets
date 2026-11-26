@echo off
setlocal EnableDelayedExpansion

REM This add-on goes in your ComfyUI_windows_portable folder (next to python_embeded and the ComfyUI folder)
cd /d "%~dp0"
if not exist "python_embeded\python.exe" (
    echo python_embeded not found. Put this file in your ComfyUI_windows_portable folder and run it again.
    goto end
)

REM Check if Git is installed
where git >nul 2>nul
if !errorlevel! neq 0 (
    echo Git not found. Downloading and installing...

    REM Download Git installer
    curl -k -L -o git-installer.exe "https://github.com/git-for-windows/git/releases/download/v2.44.0.windows.1/Git-2.44.0-64-bit.exe"

    if !errorlevel! neq 0 (
        echo Error downloading Git. Please check your internet connection and try again.
        goto end
    )

    REM Install Git silently
    git-installer.exe /VERYSILENT /NORESTART

    if !errorlevel! neq 0 (
        echo Error installing Git. Please try installing it manually.
        goto end
    )

    echo Git installed successfully.

    REM Delete the installer
    del git-installer.exe

    REM Add Git to the current PATH
    set "PATH=%PATH%;C:\Program Files\Git\cmd"
)

REM Step 3: Clone the custom nodes repository
echo Cloning custom nodes...
if not exist "ComfyUI\custom_nodes\ComfyUI-Manager" git clone https://github.com/ltdrdata/ComfyUI-Manager.git "ComfyUI\custom_nodes\ComfyUI-Manager"
if not exist "ComfyUI\custom_nodes\rgthree-comfy" git clone https://github.com/rgthree/rgthree-comfy.git "ComfyUI\custom_nodes\rgthree-comfy"
if not exist "ComfyUI\custom_nodes\Nvidia_RTX_Nodes_ComfyUI" git clone https://github.com/Comfy-Org/Nvidia_RTX_Nodes_ComfyUI.git "ComfyUI\custom_nodes\Nvidia_RTX_Nodes_ComfyUI"
if not exist "ComfyUI\custom_nodes\ComfyUI-Qwen-TTS" git clone https://github.com/flybirdxx/ComfyUI-Qwen-TTS.git "ComfyUI\custom_nodes\ComfyUI-Qwen-TTS"
if not exist "ComfyUI\custom_nodes\ComfyUI-VideoHelperSuite" git clone https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite.git "ComfyUI\custom_nodes\ComfyUI-VideoHelperSuite"

REM Voice node at the tested version (it changes fast and has broken with new transformers versions)
git -C "ComfyUI\custom_nodes\ComfyUI-Qwen-TTS" checkout 374c2e0


if !errorlevel! neq 0 (
    echo Error cloning the custom nodes repositories. Please check your internet connection and ensure git is installed.
) else (
    echo Custom nodes cloned successfully.
)

REM Step 4: Install requirements
echo Installing requirements...
.\python_embeded\python.exe -m pip install -r .\ComfyUI\custom_nodes\ComfyUI-Manager\requirements.txt
.\python_embeded\python.exe -m pip install -r .\ComfyUI\custom_nodes\ComfyUI-VideoHelperSuite\requirements.txt
.\python_embeded\python.exe -m pip install librosa soundfile tiktoken sox
.\python_embeded\python.exe -m pip install "transformers==5.20.2"
.\python_embeded\python.exe -m pip install -U --no-build-isolation nvidia-vfx --index-url https://pypi.nvidia.com


REM ======== Model download menu ========
echo.
echo ============================================================
echo   Talking Character Add-on - Voice Model Download Options
echo ============================================================
echo   Your FastH3 Omni models stay as they are. The voice tokenizer
echo   (~0.7 GB) downloads with any choice.
echo.
echo   [A] Everything ....................... ~12 GB total
echo        voice cloning 1.7B + voice design 1.7B + low-VRAM 0.6B
echo   [B] Standard (recommended) ........... ~10 GB
echo        voice cloning 1.7B + voice design 1.7B
echo   [C] Low VRAM voice ................... ~3 GB
echo        voice cloning 0.6B (no voice design)
echo   [S] Skip - I will download models myself
echo ============================================================
choice /C ABCS /M "Choose a download option:"
set MODELOPT=!errorlevel!

if !MODELOPT!==4 (
    echo Skipping model downloads.
    goto post_models
)

echo Downloading models...

REM --- Voice tokenizer (needed by every voice model) ---
if not exist "ComfyUI\models\qwen-tts\Qwen3-TTS-Tokenizer-12Hz" mkdir "ComfyUI\models\qwen-tts\Qwen3-TTS-Tokenizer-12Hz"
curl -k -L -o ComfyUI\models\qwen-tts\Qwen3-TTS-Tokenizer-12Hz\config.json "https://huggingface.co/Qwen/Qwen3-TTS-Tokenizer-12Hz/resolve/main/config.json?download=true"
curl -k -L -o ComfyUI\models\qwen-tts\Qwen3-TTS-Tokenizer-12Hz\configuration.json "https://huggingface.co/Qwen/Qwen3-TTS-Tokenizer-12Hz/resolve/main/configuration.json?download=true"
curl -k -L -o ComfyUI\models\qwen-tts\Qwen3-TTS-Tokenizer-12Hz\model.safetensors "https://huggingface.co/Qwen/Qwen3-TTS-Tokenizer-12Hz/resolve/main/model.safetensors?download=true"
curl -k -L -o ComfyUI\models\qwen-tts\Qwen3-TTS-Tokenizer-12Hz\preprocessor_config.json "https://huggingface.co/Qwen/Qwen3-TTS-Tokenizer-12Hz/resolve/main/preprocessor_config.json?download=true"

REM --- Qwen3-TTS 1.7B voice cloning (A, B) ---
if !MODELOPT!==1 goto dl_clone
if !MODELOPT!==2 goto dl_clone
goto skip_clone
:dl_clone
if not exist "ComfyUI\models\qwen-tts\Qwen3-TTS-12Hz-1.7B-Base" mkdir "ComfyUI\models\qwen-tts\Qwen3-TTS-12Hz-1.7B-Base"
if not exist "ComfyUI\models\qwen-tts\Qwen3-TTS-12Hz-1.7B-Base\speech_tokenizer" mkdir "ComfyUI\models\qwen-tts\Qwen3-TTS-12Hz-1.7B-Base\speech_tokenizer"
curl -k -L -o ComfyUI\models\qwen-tts\Qwen3-TTS-12Hz-1.7B-Base\config.json "https://huggingface.co/Qwen/Qwen3-TTS-12Hz-1.7B-Base/resolve/main/config.json?download=true"
curl -k -L -o ComfyUI\models\qwen-tts\Qwen3-TTS-12Hz-1.7B-Base\generation_config.json "https://huggingface.co/Qwen/Qwen3-TTS-12Hz-1.7B-Base/resolve/main/generation_config.json?download=true"
curl -k -L -o ComfyUI\models\qwen-tts\Qwen3-TTS-12Hz-1.7B-Base\merges.txt "https://huggingface.co/Qwen/Qwen3-TTS-12Hz-1.7B-Base/resolve/main/merges.txt?download=true"
curl -k -L -o ComfyUI\models\qwen-tts\Qwen3-TTS-12Hz-1.7B-Base\model.safetensors "https://huggingface.co/Qwen/Qwen3-TTS-12Hz-1.7B-Base/resolve/main/model.safetensors?download=true"
curl -k -L -o ComfyUI\models\qwen-tts\Qwen3-TTS-12Hz-1.7B-Base\preprocessor_config.json "https://huggingface.co/Qwen/Qwen3-TTS-12Hz-1.7B-Base/resolve/main/preprocessor_config.json?download=true"
curl -k -L -o ComfyUI\models\qwen-tts\Qwen3-TTS-12Hz-1.7B-Base\tokenizer_config.json "https://huggingface.co/Qwen/Qwen3-TTS-12Hz-1.7B-Base/resolve/main/tokenizer_config.json?download=true"
curl -k -L -o ComfyUI\models\qwen-tts\Qwen3-TTS-12Hz-1.7B-Base\vocab.json "https://huggingface.co/Qwen/Qwen3-TTS-12Hz-1.7B-Base/resolve/main/vocab.json?download=true"
curl -k -L -o ComfyUI\models\qwen-tts\Qwen3-TTS-12Hz-1.7B-Base\speech_tokenizer\config.json "https://huggingface.co/Qwen/Qwen3-TTS-12Hz-1.7B-Base/resolve/main/speech_tokenizer/config.json?download=true"
curl -k -L -o ComfyUI\models\qwen-tts\Qwen3-TTS-12Hz-1.7B-Base\speech_tokenizer\configuration.json "https://huggingface.co/Qwen/Qwen3-TTS-12Hz-1.7B-Base/resolve/main/speech_tokenizer/configuration.json?download=true"
curl -k -L -o ComfyUI\models\qwen-tts\Qwen3-TTS-12Hz-1.7B-Base\speech_tokenizer\model.safetensors "https://huggingface.co/Qwen/Qwen3-TTS-12Hz-1.7B-Base/resolve/main/speech_tokenizer/model.safetensors?download=true"
curl -k -L -o ComfyUI\models\qwen-tts\Qwen3-TTS-12Hz-1.7B-Base\speech_tokenizer\preprocessor_config.json "https://huggingface.co/Qwen/Qwen3-TTS-12Hz-1.7B-Base/resolve/main/speech_tokenizer/preprocessor_config.json?download=true"
:skip_clone

REM --- Qwen3-TTS 1.7B voice design (A, B) ---
if !MODELOPT!==1 goto dl_design
if !MODELOPT!==2 goto dl_design
goto skip_design
:dl_design
if not exist "ComfyUI\models\qwen-tts\Qwen3-TTS-12Hz-1.7B-VoiceDesign" mkdir "ComfyUI\models\qwen-tts\Qwen3-TTS-12Hz-1.7B-VoiceDesign"
if not exist "ComfyUI\models\qwen-tts\Qwen3-TTS-12Hz-1.7B-VoiceDesign\speech_tokenizer" mkdir "ComfyUI\models\qwen-tts\Qwen3-TTS-12Hz-1.7B-VoiceDesign\speech_tokenizer"
curl -k -L -o ComfyUI\models\qwen-tts\Qwen3-TTS-12Hz-1.7B-VoiceDesign\config.json "https://huggingface.co/Qwen/Qwen3-TTS-12Hz-1.7B-VoiceDesign/resolve/main/config.json?download=true"
curl -k -L -o ComfyUI\models\qwen-tts\Qwen3-TTS-12Hz-1.7B-VoiceDesign\generation_config.json "https://huggingface.co/Qwen/Qwen3-TTS-12Hz-1.7B-VoiceDesign/resolve/main/generation_config.json?download=true"
curl -k -L -o ComfyUI\models\qwen-tts\Qwen3-TTS-12Hz-1.7B-VoiceDesign\merges.txt "https://huggingface.co/Qwen/Qwen3-TTS-12Hz-1.7B-VoiceDesign/resolve/main/merges.txt?download=true"
curl -k -L -o ComfyUI\models\qwen-tts\Qwen3-TTS-12Hz-1.7B-VoiceDesign\model.safetensors "https://huggingface.co/Qwen/Qwen3-TTS-12Hz-1.7B-VoiceDesign/resolve/main/model.safetensors?download=true"
curl -k -L -o ComfyUI\models\qwen-tts\Qwen3-TTS-12Hz-1.7B-VoiceDesign\preprocessor_config.json "https://huggingface.co/Qwen/Qwen3-TTS-12Hz-1.7B-VoiceDesign/resolve/main/preprocessor_config.json?download=true"
curl -k -L -o ComfyUI\models\qwen-tts\Qwen3-TTS-12Hz-1.7B-VoiceDesign\tokenizer_config.json "https://huggingface.co/Qwen/Qwen3-TTS-12Hz-1.7B-VoiceDesign/resolve/main/tokenizer_config.json?download=true"
curl -k -L -o ComfyUI\models\qwen-tts\Qwen3-TTS-12Hz-1.7B-VoiceDesign\vocab.json "https://huggingface.co/Qwen/Qwen3-TTS-12Hz-1.7B-VoiceDesign/resolve/main/vocab.json?download=true"
curl -k -L -o ComfyUI\models\qwen-tts\Qwen3-TTS-12Hz-1.7B-VoiceDesign\speech_tokenizer\config.json "https://huggingface.co/Qwen/Qwen3-TTS-12Hz-1.7B-VoiceDesign/resolve/main/speech_tokenizer/config.json?download=true"
curl -k -L -o ComfyUI\models\qwen-tts\Qwen3-TTS-12Hz-1.7B-VoiceDesign\speech_tokenizer\configuration.json "https://huggingface.co/Qwen/Qwen3-TTS-12Hz-1.7B-VoiceDesign/resolve/main/speech_tokenizer/configuration.json?download=true"
curl -k -L -o ComfyUI\models\qwen-tts\Qwen3-TTS-12Hz-1.7B-VoiceDesign\speech_tokenizer\model.safetensors "https://huggingface.co/Qwen/Qwen3-TTS-12Hz-1.7B-VoiceDesign/resolve/main/speech_tokenizer/model.safetensors?download=true"
curl -k -L -o ComfyUI\models\qwen-tts\Qwen3-TTS-12Hz-1.7B-VoiceDesign\speech_tokenizer\preprocessor_config.json "https://huggingface.co/Qwen/Qwen3-TTS-12Hz-1.7B-VoiceDesign/resolve/main/speech_tokenizer/preprocessor_config.json?download=true"
:skip_design

REM --- Qwen3-TTS 0.6B low-VRAM voice cloning (A, C) ---
if !MODELOPT!==1 goto dl_small
if !MODELOPT!==3 goto dl_small
goto skip_small
:dl_small
if not exist "ComfyUI\models\qwen-tts\Qwen3-TTS-12Hz-0.6B-Base" mkdir "ComfyUI\models\qwen-tts\Qwen3-TTS-12Hz-0.6B-Base"
if not exist "ComfyUI\models\qwen-tts\Qwen3-TTS-12Hz-0.6B-Base\speech_tokenizer" mkdir "ComfyUI\models\qwen-tts\Qwen3-TTS-12Hz-0.6B-Base\speech_tokenizer"
curl -k -L -o ComfyUI\models\qwen-tts\Qwen3-TTS-12Hz-0.6B-Base\config.json "https://huggingface.co/Qwen/Qwen3-TTS-12Hz-0.6B-Base/resolve/main/config.json?download=true"
curl -k -L -o ComfyUI\models\qwen-tts\Qwen3-TTS-12Hz-0.6B-Base\generation_config.json "https://huggingface.co/Qwen/Qwen3-TTS-12Hz-0.6B-Base/resolve/main/generation_config.json?download=true"
curl -k -L -o ComfyUI\models\qwen-tts\Qwen3-TTS-12Hz-0.6B-Base\merges.txt "https://huggingface.co/Qwen/Qwen3-TTS-12Hz-0.6B-Base/resolve/main/merges.txt?download=true"
curl -k -L -o ComfyUI\models\qwen-tts\Qwen3-TTS-12Hz-0.6B-Base\model.safetensors "https://huggingface.co/Qwen/Qwen3-TTS-12Hz-0.6B-Base/resolve/main/model.safetensors?download=true"
curl -k -L -o ComfyUI\models\qwen-tts\Qwen3-TTS-12Hz-0.6B-Base\preprocessor_config.json "https://huggingface.co/Qwen/Qwen3-TTS-12Hz-0.6B-Base/resolve/main/preprocessor_config.json?download=true"
curl -k -L -o ComfyUI\models\qwen-tts\Qwen3-TTS-12Hz-0.6B-Base\tokenizer_config.json "https://huggingface.co/Qwen/Qwen3-TTS-12Hz-0.6B-Base/resolve/main/tokenizer_config.json?download=true"
curl -k -L -o ComfyUI\models\qwen-tts\Qwen3-TTS-12Hz-0.6B-Base\vocab.json "https://huggingface.co/Qwen/Qwen3-TTS-12Hz-0.6B-Base/resolve/main/vocab.json?download=true"
curl -k -L -o ComfyUI\models\qwen-tts\Qwen3-TTS-12Hz-0.6B-Base\speech_tokenizer\config.json "https://huggingface.co/Qwen/Qwen3-TTS-12Hz-0.6B-Base/resolve/main/speech_tokenizer/config.json?download=true"
curl -k -L -o ComfyUI\models\qwen-tts\Qwen3-TTS-12Hz-0.6B-Base\speech_tokenizer\configuration.json "https://huggingface.co/Qwen/Qwen3-TTS-12Hz-0.6B-Base/resolve/main/speech_tokenizer/configuration.json?download=true"
curl -k -L -o ComfyUI\models\qwen-tts\Qwen3-TTS-12Hz-0.6B-Base\speech_tokenizer\model.safetensors "https://huggingface.co/Qwen/Qwen3-TTS-12Hz-0.6B-Base/resolve/main/speech_tokenizer/model.safetensors?download=true"
curl -k -L -o ComfyUI\models\qwen-tts\Qwen3-TTS-12Hz-0.6B-Base\speech_tokenizer\preprocessor_config.json "https://huggingface.co/Qwen/Qwen3-TTS-12Hz-0.6B-Base/resolve/main/speech_tokenizer/preprocessor_config.json?download=true"
:skip_small


:post_models
cd update
.\update_comfyui.bat
cd ..

echo.
echo Setup complete

:end
REM Keep the window open
pause
