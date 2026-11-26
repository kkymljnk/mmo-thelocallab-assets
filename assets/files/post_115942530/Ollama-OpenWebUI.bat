@echo off
setlocal EnableDelayedExpansion

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
REM Create a project directory and move into it
mkdir ollama-webui-install
cd ollama-webui-install

REM Download and install Miniconda if not exists
if not exist "miniconda3" (
    echo Downloading Miniconda...
    curl -k -L -o miniconda.exe https://repo.anaconda.com/miniconda/Miniconda3-py311_25.5.1-1-Windows-x86_64.exe
    
    if !errorlevel! neq 0 (
        echo Error downloading Miniconda. Please check your internet connection and try again.
        goto end
    )
    
    echo Installing Miniconda...
    start /wait miniconda.exe /InstallationType=JustMe /RegisterPython=0 /S /D=%CD%\miniconda3
    
    if !errorlevel! neq 0 (
        echo Error installing Miniconda.
        goto end
    )
    
    del miniconda.exe
)

REM Create and activate conda environment
echo Creating conda environment with Python 3.11...
call miniconda3\Scripts\activate.bat

REM Download and extract Ollama
echo Downloading Ollama...
curl -k -L -o ollama-windows-amd64.zip https://github.com/ollama/ollama/releases/latest/download/ollama-windows-amd64.zip

if !errorlevel! neq 0 (
    echo Error downloading Ollama. Please check your internet connection and try again.
    goto end
)

echo Extracting Ollama...
"C:\Program Files\7-Zip\7z.exe" x ollama-windows-amd64.zip

if !errorlevel! neq 0 (
    echo Error extracting Ollama.
    goto end
)

REM Install Open WebUI
echo Installing Open WebUI...
pip install open-webui

if !errorlevel! neq 0 (
    echo Error installing Open WebUI dependencies.
    goto end
)

REM Create startup and management scripts
echo Creating startup and management scripts...

echo @echo off > start-ollama.bat
echo cd /d %%~dp0 >> start-ollama.bat
echo echo Starting Ollama server... >> start-ollama.bat
echo start /b ollama.exe serve >> start-ollama.bat
echo echo Waiting for server to start... >> start-ollama.bat
echo timeout /t 5 /nobreak ^> nul >> start-ollama.bat
echo echo Ollama server is running! >> start-ollama.bat
echo echo. >> start-ollama.bat
echo echo You can now run start-webui.bat to access the web interface >> start-ollama.bat
echo echo or use manage-models.bat to manage your models. >> start-ollama.bat

echo @echo off > start-webui.bat
echo cd /d %%~dp0 >> start-webui.bat
echo call miniconda3\Scripts\activate.bat >> start-webui.bat
echo open-webui serve >> start-webui.bat

REM Clean up
del ollama-windows-amd64.zip

echo Installation completed successfully!
echo To start the services:
echo 1. Run start-ollama.bat
echo 2. Wait a few seconds, then run start-webui.bat
echo The web interface will be available at http://localhost:8080

REM Create manage-models.bat
echo @echo off > manage-models.bat
echo setlocal EnableDelayedExpansion >> manage-models.bat
echo cd /d %%~dp0 >> manage-models.bat
echo. >> manage-models.bat
echo :menu >> manage-models.bat
echo cls >> manage-models.bat
echo echo Ollama Model Manager >> manage-models.bat
echo echo =================== >> manage-models.bat
echo echo. >> manage-models.bat
echo echo 1. List installed models >> manage-models.bat
echo echo 2. Download new model >> manage-models.bat
echo echo 3. Run a model >> manage-models.bat
echo echo 4. Remove a model >> manage-models.bat
echo echo 5. Show model information >> manage-models.bat
echo echo 6. Open Ollama Model Library in browser >> manage-models.bat
echo echo 7. Exit >> manage-models.bat
echo echo. >> manage-models.bat
echo set /p choice="Enter your choice (1-7): " >> manage-models.bat
echo. >> manage-models.bat
echo if "%%choice%%"=="1" goto list_models >> manage-models.bat
echo if "%%choice%%"=="2" goto download_model >> manage-models.bat
echo if "%%choice%%"=="3" goto run_model >> manage-models.bat
echo if "%%choice%%"=="4" goto remove_model >> manage-models.bat
echo if "%%choice%%"=="5" goto show_model >> manage-models.bat
echo if "%%choice%%"=="6" goto open_library >> manage-models.bat
echo if "%%choice%%"=="7" goto end >> manage-models.bat
echo goto menu >> manage-models.bat
echo. >> manage-models.bat
echo :list_models >> manage-models.bat
echo cls >> manage-models.bat
echo echo Currently installed models: >> manage-models.bat
echo echo ========================= >> manage-models.bat
echo ollama list >> manage-models.bat
echo echo. >> manage-models.bat
echo pause >> manage-models.bat
echo goto menu >> manage-models.bat
echo. >> manage-models.bat
echo :download_model >> manage-models.bat
echo cls >> manage-models.bat
echo echo Download New Model >> manage-models.bat
echo echo ================= >> manage-models.bat
echo echo. >> manage-models.bat
echo echo Visit https://ollama.com/library to see available models >> manage-models.bat
echo echo Example models: mistral, llama2, codellama, gemma >> manage-models.bat
echo echo. >> manage-models.bat
echo set /p model_name="Enter model name to download: " >> manage-models.bat
echo echo. >> manage-models.bat
echo echo Downloading %%model_name%%... >> manage-models.bat
echo ollama pull %%model_name%% >> manage-models.bat
echo echo. >> manage-models.bat
echo pause >> manage-models.bat
echo goto menu >> manage-models.bat
echo. >> manage-models.bat
echo :run_model >> manage-models.bat
echo cls >> manage-models.bat
echo echo Run Model >> manage-models.bat
echo echo ========= >> manage-models.bat
echo echo. >> manage-models.bat
echo echo Available models: >> manage-models.bat
echo ollama list >> manage-models.bat
echo echo. >> manage-models.bat
echo set /p model_name="Enter model name to run: " >> manage-models.bat
echo echo. >> manage-models.bat
echo echo Starting chat with %%model_name%%... >> manage-models.bat
echo echo Type 'exit' to end the chat >> manage-models.bat
echo echo. >> manage-models.bat
echo ollama run %%model_name%% >> manage-models.bat
echo goto menu >> manage-models.bat
echo. >> manage-models.bat
echo :remove_model >> manage-models.bat
echo cls >> manage-models.bat
echo echo Remove Model >> manage-models.bat
echo echo ============ >> manage-models.bat
echo echo. >> manage-models.bat
echo echo Available models: >> manage-models.bat
echo ollama list >> manage-models.bat
echo echo. >> manage-models.bat
echo set /p model_name="Enter model name to remove: " >> manage-models.bat
echo echo. >> manage-models.bat
echo ollama rm %%model_name%% >> manage-models.bat
echo echo. >> manage-models.bat
echo pause >> manage-models.bat
echo goto menu >> manage-models.bat
echo. >> manage-models.bat
echo :show_model >> manage-models.bat
echo cls >> manage-models.bat
echo echo Show Model Information >> manage-models.bat
echo echo ===================== >> manage-models.bat
echo echo. >> manage-models.bat
echo echo Available models: >> manage-models.bat
echo ollama list >> manage-models.bat
echo echo. >> manage-models.bat
echo set /p model_name="Enter model name to show information: " >> manage-models.bat
echo echo. >> manage-models.bat
echo ollama show %%model_name%% >> manage-models.bat
echo echo. >> manage-models.bat
echo pause >> manage-models.bat
echo goto menu >> manage-models.bat
echo. >> manage-models.bat
echo :open_library >> manage-models.bat
echo start https://ollama.com/library >> manage-models.bat
echo goto menu >> manage-models.bat
echo. >> manage-models.bat
echo :end >> manage-models.bat
echo exit >> manage-models.bat

REM Create run-model.bat
echo @echo off > run-model.bat
echo cd /d %%~dp0 >> run-model.bat
echo echo Available models: >> run-model.bat
echo echo =============== >> run-model.bat
echo ollama list >> run-model.bat
echo echo. >> run-model.bat
echo set /p model_name="Enter model name to run: " >> run-model.bat
echo echo. >> run-model.bat
echo echo Starting chat with %%model_name%%... >> run-model.bat
echo echo Type 'exit' to end the chat >> run-model.bat
echo echo. >> run-model.bat
echo ollama run %%model_name%% >> run-model.bat
echo pause >> run-model.bat

REM Clean up
del ollama-windows-amd64.zip

echo Installation completed successfully!
echo To start the services:
echo 1. Run start-ollama.bat
echo 2. Wait a few seconds, then run start-webui.bat
echo The web interface will be available at http://localhost:8080
echo.
echo To manage models:
echo - Use manage-models.bat for a menu-driven interface
echo - Use run-model.bat for quick model chat access

REM Create update-services.bat
echo @echo off > update-services.bat
echo setlocal EnableDelayedExpansion >> update-services.bat
echo cd /d %%~dp0 >> update-services.bat
echo. >> update-services.bat
echo :menu >> update-services.bat
echo cls >> update-services.bat
echo echo Update Manager >> update-services.bat
echo echo ============== >> update-services.bat
echo echo. >> update-services.bat
echo echo 1. Update Ollama >> update-services.bat
echo echo 2. Update Open WebUI >> update-services.bat
echo echo 3. Update Both >> update-services.bat
echo echo 4. Check Current Versions >> update-services.bat
echo echo 5. Exit >> update-services.bat
echo echo. >> update-services.bat
echo set /p choice="Enter your choice (1-5): " >> update-services.bat
echo. >> update-services.bat
echo if "%%choice%%"=="1" goto update_ollama >> update-services.bat
echo if "%%choice%%"=="2" goto update_webui >> update-services.bat
echo if "%%choice%%"=="3" goto update_both >> update-services.bat
echo if "%%choice%%"=="4" goto check_versions >> update-services.bat
echo if "%%choice%%"=="5" goto end >> update-services.bat
echo goto menu >> update-services.bat
echo. >> update-services.bat
echo :update_ollama >> update-services.bat
echo cls >> update-services.bat
echo echo Updating Ollama... >> update-services.bat
echo. >> update-services.bat
echo taskkill /F /IM ollama.exe ^> nul 2^>^&1 >> update-services.bat
echo curl -k -L -o ollama-windows-amd64.zip https://github.com/ollama/ollama/releases/latest/download/ollama-windows-amd64.zip >> update-services.bat
echo "C:\Program Files\7-Zip\7z.exe" x -y -aoa ollama-windows-amd64.zip >> update-services.bat
echo del ollama-windows-amd64.zip >> update-services.bat
echo echo Ollama updated successfully! >> update-services.bat
echo pause >> update-services.bat
echo goto menu >> update-services.bat
echo. >> update-services.bat
echo :update_webui >> update-services.bat
echo cls >> update-services.bat
echo echo Updating Open WebUI... >> update-services.bat
echo call miniconda3\Scripts\activate.bat >> update-services.bat
echo pip install --upgrade open-webui >> update-services.bat
echo echo Open WebUI updated successfully! >> update-services.bat
echo pause >> update-services.bat
echo goto menu >> update-services.bat
echo. >> update-services.bat
echo :update_both >> update-services.bat
echo cls >> update-services.bat
echo echo Updating both services... >> update-services.bat
echo. >> update-services.bat
echo echo Step 1: Updating Ollama >> update-services.bat
echo taskkill /F /IM ollama.exe ^> nul 2^>^&1 >> update-services.bat
echo curl -k -L -o ollama-windows-amd64.zip https://github.com/ollama/ollama/releases/latest/download/ollama-windows-amd64.zip >> update-services.bat
echo "C:\Program Files\7-Zip\7z.exe" x -y -aoa ollama-windows-amd64.zip >> update-services.bat
echo del ollama-windows-amd64.zip >> update-services.bat
echo. >> update-services.bat
echo echo Step 2: Updating Open WebUI >> update-services.bat
echo call miniconda3\Scripts\activate.bat >> update-services.bat
echo pip install --upgrade open-webui >> update-services.bat
echo. >> update-services.bat
echo echo Both services updated successfully! >> update-services.bat
echo pause >> update-services.bat
echo goto menu >> update-services.bat
echo. >> update-services.bat
echo :check_versions >> update-services.bat
echo cls >> update-services.bat
echo echo Current Versions >> update-services.bat
echo echo =============== >> update-services.bat
echo echo. >> update-services.bat
echo echo Ollama Version: >> update-services.bat
echo ollama --version >> update-services.bat
echo echo. >> update-services.bat
echo echo Open WebUI Version: >> update-services.bat
echo call miniconda3\Scripts\activate.bat >> update-services.bat
echo pip show open-webui ^| findstr Version >> update-services.bat
echo echo. >> update-services.bat
echo pause >> update-services.bat
echo goto menu >> update-services.bat
echo. >> update-services.bat
echo :end >> update-services.bat
echo exit >> update-services.bat

:end
pause
