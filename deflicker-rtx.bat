@echo off
setlocal enabledelayedexpansion
chcp 65001 > nul
cls

echo ===================================================
echo   SMART DEFLICKER BATCH PROCESS (AUTO-HARDWARE)
echo ===================================================
echo.

:: AUTO-DETECT NVIDIA GPU
set "gpu_mode=CPU"
set "hw_accel="
set "encoder=-c:v libx264 -crf 18 -preset medium"

wmic path win32_VideoController get name 2>nul | findstr /i "NVIDIA" >nul
if %errorlevel% equ 0 (
    set "gpu_mode=NVIDIA RTX/GTX (Hardware Accelerated)"
    set "hw_accel=-hwaccel cuda"
    set "encoder=-c:v h264_nvenc -preset fast"
)

echo Active Hardware Mode: %gpu_mode%
echo.

:: 1. Filter selection (Safe colors, Default clearly marked)
powershell -Command "Write-Host 'Which Deflicker-Filter do you want to use?' -NoNewline -ForegroundColor Cyan; Write-Host ' (Default is '" -NoNewline; Write-Host '1' -NoNewline -ForegroundColor Yellow; Write-Host ')'"
echo 1. Ultra-fast Express-Filter (Speed: ^>100 FPS on GPU)
echo    Command: -vf "hqdn3d=0:0:60:30"
echo 2. High-End Mask-Formula (Best Quality)
echo    Command: -vf "vflip,tblend=all_mode=average:all_expr='if(gt(abs(A-B)\,15)\,A\,(A+B)/2)',vflip,hqdn3d=0:0:15:10"
echo.
set "filter_choice=1"
set /p "filter_choice=Your choice: "

:: 2. Shutdown selection (Safe colors, Default clearly marked)
echo.
set "shutdown_choice=n"
powershell -Command "Write-Host 'Should the PC shutdown automatically afterwards?' -NoNewline -ForegroundColor Cyan; Write-Host ' (y/[' -NoNewline; Write-Host 'n' -NoNewline -ForegroundColor Red; Write-Host '])'"
set /p "shutdown_choice=Your choice: "

:: Define filter string based on selection
if "%filter_choice%"=="2" (
    set "active_vf=vflip,tblend=all_mode=average:all_expr='if(gt(abs(A-B)\,15)\,A\,(A+B)/2)',vflip,hqdn3d=0:0:15:10"
    echo. & echo -= High-End Mask-Formula active =-
) else (
    set "active_vf=hqdn3d=0:0:60:30"
    echo. & echo -= Ultra-fast Express-Filter active =-
)

echo.
if not exist "Flimmerfrei_Output" mkdir "Flimmerfrei_Output"

:: Loop through all .mov and .mp4 files in the folder
for %%F in (*.mov *.mp4) do (
    set "process_file=y"
    
    :: Check if the output file already exists
    if exist "Flimmerfrei_Output\%%~nF_clean.mp4" (
        
        :: 100% Integrity Check using ffprobe
        ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "Flimmerfrei_Output\%%~nF_clean.mp4" >nul 2>&1
        
        if errorlevel 1 (
            echo.
            powershell -Command "Write-Host 'DETECTED UNFINISHED FILE: \"Flimmerfrei_Output\%%~nF_clean.mp4\" is corrupted.' -ForegroundColor Yellow"
            echo Automatically overwriting to fix the incomplete video...
            set "process_file=y"
        ) else (
            echo.
            powershell -Command "Write-Host 'WARNING: The file \"Flimmerfrei_Output\%%~nF_clean.mp4\" is already 100%% complete.' -ForegroundColor Red"
            set "overwrite_choice=n"
            powershell -Command "Write-Host 'Do you want to overwrite this complete file?' -NoNewline -ForegroundColor Cyan; Write-Host ' (y/[' -NoNewline; Write-Host 'n' -NoNewline -ForegroundColor Red; Write-Host '])'"
            set /p "overwrite_choice=Your choice: "
            
            if /i not "!overwrite_choice!"=="y" (
                set "process_file=n"
                echo File %%F was SKIPPED.
                echo ---------------------------------------------------
            )
        )
    )
    
    :: Run FFmpeg with dynamically selected hardware settings
    if "!process_file!"=="y" (
        echo Processing file: %%F...
        ffmpeg %hw_accel% -i "%%F" -vf "%active_vf%" %encoder% -threads 0 -filter_threads 0 -c:a copy -y "Flimmerfrei_Output\%%~nF_clean.mp4"
        echo ---------------------------------------------------
    )
)

echo.
powershell -Command "Write-Host 'DONE! All videos have been successfully processed.' -ForegroundColor Green"
echo.

:: Play notification sound
powershell -Command "[System.Media.SystemSounds]::Beep.Play()"

:: Execute shutdown if "y" was explicitly chosen
if /i "%shutdown_choice%"=="y" (
    powershell -Command "Write-Host 'The PC will shut down automatically in 30 seconds...' -ForegroundColor Red"
    echo Press CTRL+C in the console to abort the shutdown.
    shutdown /s /t 30
) else (
    echo PC stays on.
    pause
)
@echo off
setlocal enabledelayedexpansion
chcp 65001 > nul
cls

echo ===================================================
echo   RTX 3050 HIGH-END DEFLICKER BATCH PROCESS START
echo ===================================================
echo.

:: 1. Filter selection (Safe colors, Default clearly marked)
powershell -Command "Write-Host 'Which Deflicker-Filter do you want to use?' -NoNewline -ForegroundColor Cyan; Write-Host ' (Default is '" -NoNewline; Write-Host '1' -NoNewline -ForegroundColor Yellow; Write-Host ')'"
echo 1. Ultra-fast Express-Filter (Speed: ^>100 FPS)
echo    Command: -vf "hqdn3d=0:0:60:30"
echo 2. High-End Mask-Formula (Best Quality, Speed: ~20 FPS)
echo    Command: -vf "vflip,tblend=all_mode=average:all_expr='if(gt(abs(A-B)\,15)\,A\,(A+B)/2)',vflip,hqdn3d=0:0:15:10"
echo.
set "filter_choice=1"
set /p "filter_choice=Your choice: "

:: 2. Shutdown selection (Safe colors, Default clearly marked)
echo.
set "shutdown_choice=n"
powershell -Command "Write-Host 'Should the PC shutdown automatically afterwards?' -NoNewline -ForegroundColor Cyan; Write-Host ' (y/[' -NoNewline; Write-Host 'n' -NoNewline -ForegroundColor Red; Write-Host '])'"
set /p "shutdown_choice=Your choice: "

:: Define filter string based on selection
if "%filter_choice%"=="2" (
    set "active_vf=vflip,tblend=all_mode=average:all_expr='if(gt(abs(A-B)\,15)\,A\,(A+B)/2)',vflip,hqdn3d=0:0:15:10"
    echo. & echo -= High-End Mask-Formula active =-
) else (
    set "active_vf=hqdn3d=0:0:60:30"
    echo. & echo -= Ultra-fast Express-Filter active =-
)

echo.
if not exist "Flimmerfrei_Output" mkdir "Flimmerfrei_Output"

:: Loop through all .mov and .mp4 files in the folder
for %%F in (*.mov *.mp4) do (
    set "process_file=y"
    
    :: Check if the output file already exists
    if exist "Flimmerfrei_Output\%%~nF_clean.mp4" (
        
        :: 100% Integrity Check using ffprobe (suppressing errors in console)
        ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "Flimmerfrei_Output\%%~nF_clean.mp4" >nul 2>&1
        
        :: If ffprobe returns an error code (not 0), the file is corrupted/unfinished
        if errorlevel 1 (
            echo.
            powershell -Command "Write-Host 'DETECTED UNFINISHED FILE: \"Flimmerfrei_Output\%%~nF_clean.mp4\" is corrupted or incomplete.' -ForegroundColor Yellow"
            echo Automatically overwriting to fix the incomplete video...
            set "process_file=y"
        ) else (
            :: File is 100% complete and healthy -> Ask user
            echo.
            powershell -Command "Write-Host 'WARNING: The file \"Flimmerfrei_Output\%%~nF_clean.mp4\" is already 100%% complete.' -ForegroundColor Red"
            set "overwrite_choice=n"
            powershell -Command "Write-Host 'Do you want to overwrite this complete file?' -NoNewline -ForegroundColor Cyan; Write-Host ' (y/[' -NoNewline; Write-Host 'n' -NoNewline -ForegroundColor Red; Write-Host '])'"
            set /p "overwrite_choice=Your choice: "
            
            if /i not "!overwrite_choice!"=="y" (
                set "process_file=n"
                echo File %%F was SKIPPED.
                echo ---------------------------------------------------
            )
        )
    )
    
    :: Run FFmpeg only if process_file is "y"
    if "!process_file!"=="y" (
        echo Processing file: %%F...
        ffmpeg -hwaccel cuda -i "%%F" -vf "%active_vf%" -c:v h264_nvenc -preset fast -threads 0 -filter_threads 0 -c:a copy -y "Flimmerfrei_Output\%%~nF_clean.mp4"
        echo ---------------------------------------------------
    )
)

echo.
powershell -Command "Write-Host 'DONE! All videos have been successfully processed.' -ForegroundColor Green"
echo.

:: Play notification sound
powershell -Command "[System.Media.SystemSounds]::Beep.Play()"

:: Execute shutdown if "y" was explicitly chosen
if /i "%shutdown_choice%"=="y" (
    powershell -Command "Write-Host 'The PC will shut down automatically in 30 seconds...' -ForegroundColor Red"
    echo Press CTRL+C in the console to abort the shutdown.
    shutdown /s /t 30
) else (
    echo PC stays on.
    pause
)
