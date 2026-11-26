@echo off
setlocal EnableDelayedExpansion

REM Check if Git is installed
where git >nul 2>nul
if !errorlevel! neq 0 (
    echo Git not found. Downloading and installing...
    
    REM Download Git installer
    curl -L -o git-installer.exe "https://github.com/git-for-windows/git/releases/download/v2.44.0.windows.1/Git-2.44.0-64-bit.exe"
    
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
    curl -L -o 7z2301-x64.exe https://www.7-zip.org/a/7z2301-x64.exe
    
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
REM Get the latest release URL using GitHub API
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
git clone https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite.git "ComfyUI_windows_portable\ComfyUI\custom_nodes\ComfyUI-VideoHelperSuite"
git clone https://github.com/ltdrdata/ComfyUI-Manager.git "ComfyUI_windows_portable\ComfyUI\custom_nodes\ComfyUI-Manager"
git clone https://github.com/Derfuu/Derfuu_ComfyUI_ModdedNodes.git "ComfyUI_windows_portable\ComfyUI\custom_nodes\Derfuu_ComfyUI_ModdedNodes"
git clone https://github.com/WASasquatch/was-node-suite-comfyui.git "ComfyUI_windows_portable\ComfyUI\custom_nodes\was-node-suite-comfyui"
git clone https://github.com/pythongosssss/ComfyUI-Custom-Scripts.git "ComfyUI_windows_portable\ComfyUI\custom_nodes\ComfyUI-Custom-Scripts"
git clone https://github.com/al-swaiti/ComfyUI-OllamaGemini.git "ComfyUI_windows_portable\ComfyUI\custom_nodes\ComfyUI-OllamaGemini"
git clone https://github.com/KoreTeknology/ComfyUI-Universal-Styler.git "ComfyUI_windows_portable\ComfyUI\custom_nodes\ComfyUI-Universal-Styler"
git clone https://github.com/logtd/ComfyUI-LTXTricks.git "ComfyUI_windows_portable\ComfyUI\custom_nodes\ComfyUI-LTXTricks"



if !errorlevel! neq 0 (
    echo Error cloning the custom nodes repositories. Please check your internet connection and ensure git is installed.
) else (
    echo Custom nodes cloned successfully.
)

REM Step 4: Install requirements
cd ComfyUI_windows_portable
echo Installing requirements...
.\python_embeded\python.exe -m pip install opencv_python==4.10.0.82
.\python_embeded\python.exe -m pip install -r .\ComfyUI\custom_nodes\ComfyUI-Manager\requirements.txt
.\python_embeded\python.exe -m pip install -r .\ComfyUI\custom_nodes\ComfyUI-VideoHelperSuite\requirements.
.\python_embeded\python.exe -m pip install -r .\ComfyUI\custom_nodes\Derfuu_ComfyUI_ModdedNodes\requirements.txt
.\python_embeded\python.exe -m pip install -r .\ComfyUI\custom_nodes\was-node-suite-comfyui\requirements.txt
.\python_embeded\python.exe -m pip install -r .\ComfyUI\custom_nodes\ComfyUI-Custom-Scripts\requirements.txt
.\python_embeded\python.exe -m pip install -r .\ComfyUI\custom_nodes\ComfyUI-OllamaGemini\requirements.txt
.\python_embeded\python.exe -m pip install -r .\ComfyUI\custom_nodes\ComfyUI-LTXTricks\requirements.txt

REM Step 5: Download models
echo Downloading models...
curl -L -o ComfyUI\models\checkpoints\ltx-video-2b-v0.9-fp8_e4m3fn.safetensors https://huggingface.co/Symphone/ltx-video-2b-v0.9-fp8/resolve/main/ltx-video-2b-v0.9-fp8_e4m3fn.safetensors?download=true
curl -L -o ComfyUI\models\checkpoints\ltx-video-2b-v0.9-mixed.safetensors https://huggingface.co/Symphone/ltx-video-2b-v0.9-fp8/resolve/main/ltx-video-2b-v0.9-mixed.safetensors?download=true
curl -L -o ComfyUI\models\clip\t5xxl_fp8_e4m3fn.safetensors https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/t5xxl_fp8_e4m3fn.safetensors?download=true


:end
echo Setup complete

REM Keep the window open
pause