@echo off
setlocal enabledelayedexpansion

:: Set the directory for the project to the current directory
set "PROJECT_DIR=%~dp0"
cd "%PROJECT_DIR%"

::--------------------- GIT: Check and Install If Needed ----------------------------
where git >nul 2>nul
if errorlevel 1 (
    echo Git not found. Downloading and installing Git...
    set "GIT_INSTALLER=Git-setup.exe"
    curl -L -k -o "%GIT_INSTALLER%" https://github.com/git-for-windows/git/releases/latest/download/Git-2.45.2-64-bit.exe

    :: Install Git for current user silently (no admin rights), add to PATH
    start /wait "" "%GIT_INSTALLER%" /VERYSILENT /NORESTART /NOCANCEL /DIR="%USERPROFILE%\Git"

    if errorlevel 1 (
        echo Error installing Git.
        goto end
    )

    del "%GIT_INSTALLER%"

    :: Add Git to current session's PATH
    set "PATH=%USERPROFILE%\Git\cmd;%PATH%"
) else (
    echo Git found.
)

git --version

:: Download and install Miniconda if not exists
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

:: Create and activate conda environment
echo Creating conda environment with Python 3.11...
call miniconda3\Scripts\activate.bat

:: Clone repositories
git clone https://github.com/Haoming02/sd-webui-forge-classic sd-webui-forge-neo --branch neo
cd sd-webui-forge-neo

:: Create start file
echo @echo off > "%PROJECT_DIR%start_sd-forge-neo.bat"
echo cd /d "%PROJECT_DIR%sd-webui-forge-neo" >> "%PROJECT_DIR%start_sd-forge-neo.bat"
echo echo Activating conda environment... >> "%PROJECT_DIR%start_sd-forge-neo.bat"
echo call "%PROJECT_DIR%miniconda3\Scripts\activate.bat" >> "%PROJECT_DIR%start_sd-forge-neo.bat"
echo echo Starting SD Forge Neo WebUI... >> "%PROJECT_DIR%start_sd-forge-neo.bat"
echo .\webui-user.bat >> "%PROJECT_DIR%start_sd-forge-neo.bat"
echo pause >> "%PROJECT_DIR%start_sd-forge-neo.bat"


:: Install dependencies
.\webui-user.bat

pause
endlocal