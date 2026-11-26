@echo off
setlocal EnableDelayedExpansion

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
echo Downloading ComfyUI...
curl -k -L -o ComfyUI_windows_portable_nvidia.7z https://github.com/comfyanonymous/ComfyUI/releases/latest/download/ComfyUI_windows_portable_nvidia.7z

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
git clone https://github.com/calcuis/gguf.git "ComfyUI_windows_portable\ComfyUI\custom_nodes\gguf"
git clone https://github.com/ltdrdata/ComfyUI-Manager.git "ComfyUI_windows_portable\ComfyUI\custom_nodes\ComfyUI-Manager"
git clone https://github.com/city96/ComfyUI-GGUF.git "ComfyUI_windows_portable\ComfyUI\custom_nodes\ComfyUI-GGUF"
git clone https://github.com/kijai/ComfyUI-Florence2.git "ComfyUI_windows_portable\ComfyUI\custom_nodes\ComfyUI-Florence2"
git clone https://github.com/KoreTeknology/ComfyUI-Universal-Styler.git "ComfyUI_windows_portable\ComfyUI\custom_nodes\ComfyUI-Universal-Styler"
git clone https://github.com/kijai/ComfyUI-KJNodes.git "ComfyUI_windows_portable\ComfyUI\custom_nodes\ComfyUI-KJNodes"
git clone https://github.com/pythongosssss/ComfyUI-Custom-Scripts.git "ComfyUI_windows_portable\ComfyUI\custom_nodes\ComfyUI-Custom-Scripts"

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
.\python_embeded\python.exe -m pip install -r .\ComfyUI\custom_nodes\ComfyUI-Florence2\requirements.txt
.\python_embeded\python.exe -m pip install -r .\ComfyUI\custom_nodes\ComfyUI-KJNodes\requirements.txt



REM Step 5: Download models
echo Downloading models...
curl -L -o ComfyUI\models\unet\hidream-i1-full-Q4_K_S.gguf https://huggingface.co/city96/HiDream-I1-Full-gguf/resolve/main/hidream-i1-full-Q4_K_S.gguf?download=true
curl -L -o ComfyUI\models\clip\clip_g_hidream.safetensors https://huggingface.co/Comfy-Org/HiDream-I1_ComfyUI/resolve/main/split_files/text_encoders/clip_g_hidream.safetensors?download=true
curl -L -o ComfyUI\models\clip\clip_l_hidream.safetensors https://huggingface.co/Comfy-Org/HiDream-I1_ComfyUI/resolve/main/split_files/text_encoders/clip_l_hidream.safetensors?download=true
curl -L -o ComfyUI\models\clip\llama_3.1_8b_instruct_fp8_scaled.safetensors https://huggingface.co/Comfy-Org/HiDream-I1_ComfyUI/resolve/main/split_files/text_encoders/llama_3.1_8b_instruct_fp8_scaled.safetensors?download=true
curl -L -o ComfyUI\models\clip\t5xxl_fp8_e4m3fn_scaled.safetensors https://huggingface.co/Comfy-Org/HiDream-I1_ComfyUI/resolve/main/split_files/text_encoders/t5xxl_fp8_e4m3fn_scaled.safetensors?download=true
curl -L -o ComfyUI\models\vae\ae.safetensors https://huggingface.co/Comfy-Org/HiDream-I1_ComfyUI/resolve/main/split_files/vae/ae.safetensors?download=true
curl -L -o ComfyUI\models\upscale_models\4x_foolhardy_Remacri.pth https://huggingface.co/FacehugmanIII/4x_foolhardy_Remacri/resolve/main/4x_foolhardy_Remacri.pth?download=true

cd update
echo Updating ComfyUI...
.\update_comfyui.bat

:end
echo Setup complete

REM Keep the window open
pause