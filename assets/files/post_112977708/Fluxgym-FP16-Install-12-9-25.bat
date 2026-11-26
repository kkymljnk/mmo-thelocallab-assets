@echo off
setlocal enabledelayedexpansion

:: Set the directory for the project to the current directory
set "PROJECT_DIR=%~dp0"
cd "%PROJECT_DIR%"

:: Check if Python 3.10 is installed
python --version 2>NUL | findstr /C:"Python 3.10" >NUL
if %errorlevel% neq 0 (
    echo Python 3.10 is not installed. Attempting to install it now...
    
    :: Download Python 3.10 installer
    powershell -Command "Invoke-WebRequest -Uri 'https://www.python.org/ftp/python/3.10.11/python-3.10.11-amd64.exe' -OutFile 'python_installer.exe'"
    
    :: Run the installer
    start /wait python_installer.exe /quiet InstallAllUsers=1 PrependPath=1 Include_test=0
    
    :: Delete the installer
    del python_installer.exe
    
    :: Refresh environment variables
    call refreshenv.cmd
    
    :: Check if Python 3.10 is now installed
    python --version 2>NUL | findstr /C:"Python 3.10" >NUL
    if %errorlevel% neq 0 (
        echo Failed to install Python 3.10. Please install it manually and run this script again.
        pause
        exit /b
    )
)

:: Clone repositories
git clone https://github.com/cocktailpeanut/fluxgym
cd fluxgym
git clone -b sd3 https://github.com/kohya-ss/sd-scripts

:: Create and activate virtual environment
python -m venv env
call env\Scripts\activate.bat

:: Install dependencies
cd sd-scripts
python -m pip install --upgrade pip
pip install -r requirements.txt
cd ..
pip install -r requirements.txt

:: Install PyTorch Nightly
pip install --pre torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121

:: Create start file
echo @echo off > "%PROJECT_DIR%start_fluxgym.bat"
echo cd "%PROJECT_DIR%fluxgym" >> "%PROJECT_DIR%start_fluxgym.bat"
echo call env\Scripts\activate.bat >> "%PROJECT_DIR%start_fluxgym.bat"
echo start http://localhost:7860 >> "%PROJECT_DIR%start_fluxgym.bat"
echo python app.py >> "%PROJECT_DIR%start_fluxgym.bat"
echo pause >> "%PROJECT_DIR%start_fluxgym.bat"

:: Create update file
echo @echo off > "%PROJECT_DIR%update_fluxgym.bat"
echo cd "%PROJECT_DIR%fluxgym" >> "%PROJECT_DIR%update_fluxgym.bat"
echo git pull >> "%PROJECT_DIR%update_fluxgym.bat"
echo cd sd-scripts >> "%PROJECT_DIR%update_fluxgym.bat"
echo git pull >> "%PROJECT_DIR%update_fluxgym.bat"
echo cd .. >> "%PROJECT_DIR%update_fluxgym.bat"
echo call env\Scripts\activate.bat >> "%PROJECT_DIR%update_fluxgym.bat"
echo pip install -r requirements.txt >> "%PROJECT_DIR%update_fluxgym.bat"
echo cd sd-scripts >> "%PROJECT_DIR%update_fluxgym.bat"
echo pip install -r requirements.txt >> "%PROJECT_DIR%update_fluxgym.bat"
echo cd .. >> "%PROJECT_DIR%update_fluxgym.bat"
echo pip install --pre torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121 >> "%PROJECT_DIR%update_fluxgym.bat"
echo echo Update completed. >> "%PROJECT_DIR%update_fluxgym.bat"
echo pause >> "%PROJECT_DIR%update_fluxgym.bat"

:: Start the application
start http://localhost:7860
python app.py

:: Deactivate virtual environment
deactivate

endlocal