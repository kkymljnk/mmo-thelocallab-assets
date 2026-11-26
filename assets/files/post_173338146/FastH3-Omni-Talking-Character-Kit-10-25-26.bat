@echo off
setlocal EnableDelayedExpansion

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

REM Check if 7-Zip is installed
if not exist "C:\Program Files\7-Zip\7z.exe" (
    echo 7-Zip not found. Downloading and installing...

    REM Download 7-Zip
    curl -k -L -o 7z2301-x64.exe https://www.7-zip.org/a/7z2301-x64.exe

    if !errorlevel! neq 0 (
        echo Error downloading 7-Zip. Please check your internet connection and try again.
        goto end
    )

    REM Install 7-Zip silently
    7z2301-x64.exe /S

    if !errorlevel! neq 0 (
        echo Error installing 7-Zip. Please try installing it manually.
        goto end
    )

    echo 7-Zip installed successfully.

    REM Delete the installer
    del 7z2301-x64.exe
)

REM Step 1: Download ComfyUI 7zip file
echo Downloading latest ComfyUI release...
curl -k -L -o ComfyUI_windows_portable_nvidia.7z https://github.com/comfyanonymous/ComfyUI/releases/latest/download/ComfyUI_windows_portable_nvidia.7z


if !errorlevel! neq 0 (
    echo Error downloading ComfyUI. Please check your internet connection and try again.
    goto end
)

echo Download completed successfully.

REM Step 2: Extract the downloaded file using 7-Zip
echo Extracting ComfyUI...
"C:\Program Files\7-Zip\7z.exe" x ComfyUI_windows_portable_nvidia.7z

if !errorlevel! neq 0 (
    echo Error extracting the file. The file may be corrupted.
) else (
    echo Extraction completed successfully.
)


REM Step 3: Clone the custom nodes repository
echo Cloning custom nodes...
git clone https://github.com/ltdrdata/ComfyUI-Manager.git "ComfyUI_windows_portable\ComfyUI\custom_nodes\ComfyUI-Manager"
git clone https://github.com/rgthree/rgthree-comfy.git "ComfyUI_windows_portable\ComfyUI\custom_nodes\rgthree-comfy"
git clone https://github.com/Comfy-Org/Nvidia_RTX_Nodes_ComfyUI.git "ComfyUI_windows_portable\ComfyUI\custom_nodes\Nvidia_RTX_Nodes_ComfyUI"
git clone https://github.com/flybirdxx/ComfyUI-Qwen-TTS.git "ComfyUI_windows_portable\ComfyUI\custom_nodes\ComfyUI-Qwen-TTS"
git clone https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite.git "ComfyUI_windows_portable\ComfyUI\custom_nodes\ComfyUI-VideoHelperSuite"

REM Voice node at the tested version (it changes fast and has broken with new transformers versions)
git -C "ComfyUI_windows_portable\ComfyUI\custom_nodes\ComfyUI-Qwen-TTS" checkout 374c2e0


if !errorlevel! neq 0 (
    echo Error cloning the custom nodes repositories. Please check your internet connection and ensure git is installed.
) else (
    echo Custom nodes cloned successfully.
)

REM Step 4: Install requirements
cd ComfyUI_windows_portable
echo Installing requirements...
.\python_embeded\python.exe -m pip install -r .\ComfyUI\custom_nodes\ComfyUI-Manager\requirements.txt
.\python_embeded\python.exe -m pip install -r .\ComfyUI\custom_nodes\ComfyUI-VideoHelperSuite\requirements.txt
.\python_embeded\python.exe -m pip install librosa soundfile tiktoken sox
.\python_embeded\python.exe -m pip install "transformers==5.20.2"
.\python_embeded\python.exe -m pip install torch==2.11.0+cu130 torchvision==0.26.0+cu130 torchaudio==2.11.0+cu130 --index-url https://download.pytorch.org/whl/cu130
.\python_embeded\python.exe -m pip install -U --no-build-isolation nvidia-vfx --index-url https://pypi.nvidia.com


REM ======== Model download menu ========
echo.
echo ============================================================
echo   FastH3 Omni Talking Character - Model Download Options
echo ============================================================
echo   FastH3 Omni (model + text encoder + VAEs) is ~41 GB and the
echo   voice tokenizer is ~0.7 GB.
echo.
echo   [A] Everything ....................... ~54 GB total
echo        FastH3 Omni + voice cloning + voice design + low-VRAM voice
echo   [B] Standard (recommended) ........... ~51 GB
echo        FastH3 Omni + voice cloning 1.7B + voice design 1.7B
echo   [C] Low VRAM voice ................... ~45 GB
echo        FastH3 Omni + voice cloning 0.6B (no voice design)
echo   [D] Voice models only ................ ~10 GB
echo        I already have FastH3 Omni - voice cloning + voice design 1.7B
echo   [S] Skip - I will download models myself
echo ============================================================
choice /C ABCDS /M "Choose a download option:"
set MODELOPT=!errorlevel!

if !MODELOPT!==5 (
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

REM --- FastH3 Omni model, text encoder and VAEs (A, B, C) ---
if !MODELOPT!==1 goto dl_omni
if !MODELOPT!==2 goto dl_omni
if !MODELOPT!==3 goto dl_omni
goto skip_omni
:dl_omni
curl -k -L -o ComfyUI\models\diffusion_models\fasth3_omniref_8step_pruned_int8_convrot.safetensors "https://huggingface.co/FastVideo/FastH3-Omni-Comfy/resolve/main/diffusion_models/fasth3_omniref_8step_pruned_int8_convrot.safetensors?download=true"
curl -k -L -o ComfyUI\models\text_encoders\qwen3vl_32b_minimax_h3_nvfp4_awq.safetensors "https://huggingface.co/FastVideo/FastH3-Omni-Comfy/resolve/main/text_encoders/qwen3vl_32b_minimax_h3_nvfp4_awq.safetensors?download=true"
curl -k -L -o ComfyUI\models\vae\minimax_h3_video_vae_int8_convrot.safetensors "https://huggingface.co/FastVideo/FastH3-Omni-Comfy/resolve/main/vae/minimax_h3_video_vae_int8_convrot.safetensors?download=true"
curl -k -L -o ComfyUI\models\vae\minimax_h3_audio_vae_fp32.safetensors "https://huggingface.co/FastVideo/FastH3-Omni-Comfy/resolve/main/vae/minimax_h3_audio_vae_fp32.safetensors?download=true"
:skip_omni

REM --- Qwen3-TTS 1.7B voice cloning (A, B, D) ---
if !MODELOPT!==1 goto dl_clone
if !MODELOPT!==2 goto dl_clone
if !MODELOPT!==4 goto dl_clone
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

REM --- Qwen3-TTS 1.7B voice design (A, B, D) ---
if !MODELOPT!==1 goto dl_design
if !MODELOPT!==2 goto dl_design
if !MODELOPT!==4 goto dl_design
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
