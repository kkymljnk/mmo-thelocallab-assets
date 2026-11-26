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
echo Downloading ComfyUI...
curl -k -L -o ComfyUI_windows_portable_nvidia.7z https://github.com/comfyanonymous/ComfyUI/releases/download/v0.3.49/ComfyUI_windows_portable_nvidia.7z

if !errorlevel! neq 0 (
    echo Error downloading ComfyUI. Please check your internet connection and try again.
    goto end
)

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
git clone https://github.com/city96/ComfyUI-GGUF.git "ComfyUI_windows_portable\ComfyUI\custom_nodes\ComfyUI-GGUF"
git clone https://github.com/ltdrdata/ComfyUI-Manager.git "ComfyUI_windows_portable\ComfyUI\custom_nodes\ComfyUI-Manager"
git clone https://github.com/sipie800/ComfyUI-PuLID-Flux-Enhanced.git "ComfyUI_windows_portable\ComfyUI\custom_nodes\ComfyUI-PuLID-Flux-Enhanced"
git clone https://github.com/pythongosssss/ComfyUI-Custom-Scripts.git "ComfyUI_windows_portable\ComfyUI\custom_nodes\ComfyUI-Custom-Scripts"
git clone https://github.com/cubiq/PuLID_ComfyUI.git "ComfyUI_windows_portable\ComfyUI\custom_nodes\PuLID_ComfyUI"
git clone https://github.com/al-swaiti/ComfyUI-OllamaGemini.git "ComfyUI_windows_portable\ComfyUI\custom_nodes\ComfyUI-OllamaGemini"
git clone https://github.com/KoreTeknology/ComfyUI-Universal-Styler.git "ComfyUI_windows_portable\ComfyUI\custom_nodes\ComfyUI-Universal-Styler"
git clone https://github.com/WASasquatch/was-node-suite-comfyui.git "ComfyUI_windows_portable\ComfyUI\custom_nodes\was-node-suite-comfyui"
git clone https://github.com/mirabarukaso/ComfyUI_Mira.git "ComfyUI_windows_portable\ComfyUI\custom_nodes\ComfyUI_Mira"
curl -L --ssl-no-revoke -o ComfyUI_windows_portable/insightface-0.7.3-cp312-cp312-win_amd64.whl https://github.com/Gourieff/Assets/raw/refs/heads/main/Insightface/insightface-0.7.3-cp312-cp312-win_amd64.whl

if !errorlevel! neq 0 (
    echo Error cloning the ComfyUI-GGUF repository. Please check your internet connection and ensure git is installed.
) else (
    echo ComfyUI-GGUF cloned successfully.
)

REM Step 4: Install requirements
cd ComfyUI_windows_portable
echo Installing requirements...
.\python_embeded\python.exe -m pip install -r .\ComfyUI\custom_nodes\ComfyUI-Manager\requirements.txt
.\python_embeded\python.exe -m pip install -r .\ComfyUI\custom_nodes\ComfyUI-GGUF\requirements.txt
.\python_embeded\python.exe -m pip install --no-use-pep517 git+https://github.com/rodjjo/filterpy.git
.\python_embeded\python.exe -m pip install insightface-0.7.3-cp312-cp312-win_amd64.whl
.\python_embeded\python.exe -m pip install facexlib
.\python_embeded\python.exe -m pip install --no-cache-dir --upgrade tifffile
.\python_embeded\python.exe -m pip install --no-cache-dir --upgrade matplotlib
.\python_embeded\python.exe -m pip install -r .\ComfyUI\custom_nodes\ComfyUI-PuLID-Flux-Enhanced\requirements.txt
.\python_embeded\python.exe -m pip install -r .\ComfyUI\custom_nodes\PuLID_ComfyUI\requirements.txt
.\python_embeded\python.exe -m pip install -r .\ComfyUI\custom_nodes\ComfyUI-OllamaGemini\requirements.txt
.\python_embeded\python.exe -m pip install --no-cache-dir --upgrade numba
.\python_embeded\python.exe -m pip install -r .\ComfyUI\custom_nodes\was-node-suite-comfyui\requirements.txt
.\python_embeded\python.exe -m pip install  numpy==1.26.4
.\python_embeded\python.exe -c "import fileinput; filename='ComfyUI\\custom_nodes\\ComfyUI-OllamaGemini\\prompt_styler.py'; [print(line.replace('with j.open(\'r\') as f:', 'with j.open(\'r\', encoding=\'utf-8\') as f:'), end='') for line in fileinput.input(filename, inplace=True)]"
.\python_embeded\python.exe -m pip install scikit-image==0.24.0
.\python_embeded\python.exe -m pip install --upgrade albumentations
.\python_embeded\python.exe -m pip install piexif

REM Step 5: Download models
echo Downloading models...
mkdir "ComfyUI\models\pulid" "ComfyUI\models\insightface\models\antelopev2"
curl -L -o ComfyUI\models\unet\flux1-dev-Q4_0.gguf https://huggingface.co/city96/FLUX.1-dev-gguf/resolve/main/flux1-dev-Q4_0.gguf?download=true
curl -L -o ComfyUI\models\clip\clip_l.safetensors https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/clip_l.safetensors?download=true
curl -L -o ComfyUI\models\clip\t5xxl_fp8_e4m3fn.safetensors https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/t5xxl_fp8_e4m3fn.safetensors?download=true
curl -L -o ComfyUI\models\vae\flux_vae.safetensors https://huggingface.co/nerualdreming/flux_vae/resolve/main/diffusion_pytorch_model.safetensors?download=true
curl -L -o ComfyUI\models\loras\flux-RealismLora.safetensors https://huggingface.co/XLabs-AI/flux-RealismLora/resolve/main/lora.safetensors?download=true
curl -L -o ComfyUI\models\upscale_models\4x_foolhardy_Remacri.pth https://huggingface.co/FacehugmanIII/4x_foolhardy_Remacri/resolve/main/4x_foolhardy_Remacri.pth?download=true
curl -L -o ComfyUI\models\pulid\pulid_flux_v0.9.1.safetensors https://huggingface.co/guozinan/PuLID/resolve/main/pulid_flux_v0.9.1.safetensors?download=true
curl -L -o ComfyUI\models\insightface\models\antelopev2\1k3d68.onnx https://huggingface.co/DIAMONIK7777/antelopev2/resolve/main/1k3d68.onnx?download=true
curl -L -o ComfyUI\models\insightface\models\antelopev2\2d106det.onnx https://huggingface.co/DIAMONIK7777/antelopev2/resolve/main/2d106det.onnx?download=true
curl -L -o ComfyUI\models\insightface\models\antelopev2\genderage.onnx https://huggingface.co/DIAMONIK7777/antelopev2/resolve/main/genderage.onnx?download=true
curl -L -o ComfyUI\models\insightface\models\antelopev2\glintr100.onnx https://huggingface.co/DIAMONIK7777/antelopev2/resolve/main/glintr100.onnx?download=true
curl -L -o ComfyUI\models\insightface\models\antelopev2\scrfd_10g_bnkps.onnx https://huggingface.co/DIAMONIK7777/antelopev2/resolve/main/scrfd_10g_bnkps.onnx?download=true

:end
echo Setup complete

REM Keep the window open
pause