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
curl -k -L -o ComfyUI_windows_portable_nvidia.7z https://github.com/comfyanonymous/ComfyUI/releases/download/v0.3.43/ComfyUI_windows_portable_nvidia.7z

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
git clone https://github.com/ltdrdata/ComfyUI-Manager.git "ComfyUI_windows_portable/ComfyUI/custom_nodes/ComfyUI-Manager" 
git clone https://github.com/kijai/ComfyUI-Hunyuan3DWrapper.git "ComfyUI_windows_portable/ComfyUI/custom_nodes/ComfyUI-Hunyuan3DWrapper"
git clone https://github.com/cubiq/ComfyUI_essentials.git "ComfyUI_windows_portable/ComfyUI/custom_nodes/ComfyUI_essentials"
git clone https://github.com/Derfuu/Derfuu_ComfyUI_ModdedNodes.git "ComfyUI_windows_portable\ComfyUI\custom_nodes\Derfuu_ComfyUI_ModdedNodes"
git clone https://github.com/WASasquatch/was-node-suite-comfyui.git "ComfyUI_windows_portable\ComfyUI\custom_nodes\was-node-suite-comfyui"
git clone https://github.com/KoreTeknology/ComfyUI-Universal-Styler.git "ComfyUI_windows_portable\ComfyUI\custom_nodes\ComfyUI-Universal-Styler"

if !errorlevel! neq 0 (
    echo Error cloning the custom nodes repositories. Please check your internet connection and ensure git is installed.
) else (
    echo Custom nodes cloned successfully.
)

REM Step 4: Install requirements
cd ComfyUI_windows_portable
echo Installing requirements...
curl -k -L "https://huggingface.co/Thelocallab/Custom_Rasterizer_0.1-cp312-cp312-win/resolve/main/custom_rasterizer-0.1-cp312-cp312-win_amd64.whl?download=true" > ComfyUI\custom_nodes\ComfyUI-Hunyuan3DWrapper\wheels\custom_rasterizer-0.1-cp312-cp312-win_amd64.whl
.\python_embeded\python.exe -m pip install torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu118
.\python_embeded\python.exe -m pip install -r .\ComfyUI\custom_nodes\ComfyUI-Hunyuan3DWrapper\requirements.txt
.\python_embeded\python.exe -m pip install -r .\ComfyUI\custom_nodes\ComfyUI_essentials\requirements.txt
.\python_embeded\python.exe -m pip install -r .\ComfyUI\custom_nodes\was-node-suite-comfyui\requirements.txt
.\python_embeded\python.exe -m pip install ComfyUI\custom_nodes\ComfyUI-Hunyuan3DWrapper\wheels\custom_rasterizer-0.1-cp312-cp312-win_amd64.whl


REM Step 6: Download models
echo Downloading models...
curl -k -L -o ComfyUI\models\diffusion_models\hunyuan3d-dit-v2-0-fp16.safetensors https://huggingface.co/tencent/Hunyuan3D-2/resolve/main/hunyuan3d-dit-v2-0/model.fp16.safetensors?download=true
curl -k -L -o ComfyUI\models\upscale_models\4x_foolhardy_Remacri.pth https://huggingface.co/FacehugmanIII/4x_foolhardy_Remacri/resolve/main/4x_foolhardy_Remacri.pth?download=true


:end
echo Setup complete

REM Keep the window open
pause

