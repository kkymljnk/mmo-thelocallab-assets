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
REM Get the latest release URL using GitHub API
curl -k -L -o ComfyUI_windows_portable_nvidia.7z https://github.com/comfyanonymous/ComfyUI/releases/download/v0.3.49/ComfyUI_windows_portable_nvidia.7z

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
git clone https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite.git "ComfyUI_windows_portable/ComfyUI/custom_nodes/ComfyUI-VideoHelperSuite"
git clone https://github.com/numz/ComfyUI-SeedVR2_VideoUpscaler.git "ComfyUI_windows_portable/ComfyUI/custom_nodes/ComfyUI-SeedVR2_VideoUpscaler"


if !errorlevel! neq 0 (
    echo Error cloning the custom nodes repositories. Please check your internet connection and ensure git is installed.
) else (
    echo Custom nodes cloned successfully.
)

REM Step 4: Install requirements
cd ComfyUI_windows_portable
echo Installing requirements...
.\python_embeded\python.exe -m pip install -r .\ComfyUI\custom_nodes\ComfyUI-Manager\requirements.txt
.\python_embeded\python.exe -m pip install -r .\ComfyUI\custom_nodes\rgthree-comfy\requirements.txt
.\python_embeded\python.exe -m pip install -r .\ComfyUI\custom_nodes\ComfyUI-VideoHelperSuite\requirements.txt
.\python_embeded\python.exe -m pip install -r .\ComfyUI\custom_nodes\ComfyUI-SeedVR2_VideoUpscaler\requirements.txt
.\python_embeded\python.exe -m pip uninstall torch -y
.\python_embeded\python.exe -m pip install torch==2.6.0 torchvision==0.21.0 torchaudio==2.6.0 --index-url https://download.pytorch.org/whl/cu124
curl -k -L --ssl-no-revoke -o flash_attn-2.7.4.post1+cu124torch2.6.0cxx11abiFALSE-cp312-cp312-win_amd64.whl https://github.com/kingbri1/flash-attention/releases/download/v2.7.4.post1/flash_attn-2.7.4.post1+cu124torch2.6.0cxx11abiFALSE-cp312-cp312-win_amd64.whl
.\python_embeded\python.exe -m pip install flash_attn-2.7.4.post1+cu124torch2.6.0cxx11abiFALSE-cp312-cp312-win_amd64.whl
.\python_embeded\python.exe -m pip install --no-cache-dir --upgrade numba
.\python_embeded\python.exe -m pip install -U "triton-windows<3.5"
cd update
.\update_comfyui.bat


:end
echo Setup complete

REM Keep the window open
pause