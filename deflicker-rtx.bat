@echo off
setlocal enabledelayedexpansion
chcp 65001 > nul
cls

echo ===================================================
echo   SMART DEFLICKER BATCH PROCESS (AUTO-HARDWARE)
echo ===================================================
echo.

:: 1. SAFE AUTO-DETECT NVIDIA GPU VIA POWERSHELL
set "gpu_mode=CPU"
set "hw_accel="
set "encoder=-c:v libx264 -crf 18 -preset medium"

powershell -Command "Get-CimInstance Win32_VideoController | Select-Object -ExpandProperty Name" 2>nul | findstr /i "NVIDIA" >nul
if !errorlevel! equ 0 (
    set "gpu_mode=NVIDIA RTX/GTX (Hardware Accelerated)"
    set "hw_accel=-hwaccel cuda"
    set "encoder=-c:v h264_nvenc -preset fast"
)

echo Active Hardware Mode: %gpu_mode%
echo.

:: 2. Filter selection (Safe colors, Default clearly marked)
powershell -Command "Write-Host 'Which Deflicker-Filter do you want to use?' -NoNewline -ForegroundColor Cyan; Write-Host ' (Default is '" -NoNewline; Write-Host '1' -NoNewline -ForegroundColor Yellow; Write-Host ')'"
echo 1. Ultra-fast Express-Filter (Speed: ^>100 FPS on GPU)
echo    Command: -vf "hqdn3d=0:0:60:30"
echo 2. High-End Mask-Formula (Best Quality)
echo    Command: -vf "vflip,tblend=all_mode=average:all_expr='if(gt(abs(A-B)\,15)\,A\,(A+B)/2)',vflip,hqdn3d=0:0:15:10"
echo.
set "filter_choice=1"
set /p "filter_choice=Your choice: "

:: 3. Overwrite Policy selection (Default: 1 - Automated Smart-Skip)
echo.
powershell -Command "Write-Host 'How should existing files be handled?' -NoNewline -ForegroundColor Cyan; Write-Host ' (Default is '" -NoNewline; Write-Host '1' -NoNewline -ForegroundColor Yellow; Write-Host ')'"
echo 1. Automated Smart-Skip (Auto-repair broken files / Auto-skip finished files)
echo 2. Ask for each completed file (Interactive)
echo.
set "policy_choice=1"
set /p "policy_choice=Your choice: "

:: 4. Shutdown selection (Safe colors, Default clearly marked)
echo.
set "shutdown_choice=n"
powershell -Command "Write-Host 'Should the PC shutdown automatically afterwards?' -NoNewline -ForegroundColor Cyan; Write-Host ' (y/[' -NoNewline; Write-Host 'n' -NoNewline -ForegroundColor Red; Write-Host '])'"
set /p "shutdown_choice=Your choice: "

:: Linear variable assignment to prevent Windows Batch bracket syntax crashes
set "active_vf=hqdn3d=0:0:60:30"
if "%filter_choice%"=="2" set "active_vf=vflip,tblend=all_mode=average:all_expr='if(gt(abs(A-B)\,15)\,A\,(A+B)/2)',vflip,hqdn3d=0:0:15:10"

echo.
if "%filter_choice%"=="2" (echo -= High-End Mask-Formula active =-) else (echo -= Ultra-fast Express-Filter active =-)

echo.
if not exist "flickerfree_output" mkdir "flickerfree_output"

echo ===================================================
echo   PHASE 1: SCANNING AND ANALYZING FILES...
echo ===================================================
echo.

:: --- PRE-SCAN PROCESS (Just listing everything first) ---
for %%F in (*.mov *.mp4) do (
    set "filename=%%~nxF"
    if /i not "!filename!"=="output.mp4" (
        if /i not "!filename:~-10!"=="_clean.mp4" (
            if exist "flickerfree_output\%%~nF_clean.mp4" (
                :: Integrity Check
                for /f "tokens=1 delims=." %%A in ('ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "%%F" 2^>nul') do set "dur_orig=%%A"
                for /f "tokens=1 delims=." %%A in ('ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "flickerfree_output\%%~nF_clean.mp4" 2^>nul') do set "dur_dest=%%A"
                
                if NOT "!dur_orig!"=="!dur_dest!" (
                    powershell -Command "Write-Host '[INCOMPLETE] ' -NoNewline -ForegroundColor Red; Write-Host '%%F (Will be re-rendered)'"
                ) else (
                    powershell -Command "Write-Host '[COMPLETE]   ' -NoNewline -ForegroundColor Green; Write-Host '%%F (Will be skipped)'"
                )
            ) else (
                echo [NEW FILE]   %%F ^(Will be processed^)
            )
        )
    )
)

echo.
echo ===================================================
echo   PHASE 2: EXECUTING TASK QUEUE...
echo ===================================================
echo.

:: --- ACTUAL PROCESSING LOOP ---
for %%F in (*.mov *.mp4) do (
    set "process_file=y"
    set "filename=%%~nxF"
    
    if /i "!filename!"=="output.mp4" set "process_file=n"
    if /i "!filename:~-10!"=="_clean.mp4" set "process_file=n"
    
    if "!process_file!"=="y" (
        if exist "flickerfree_output\%%~nF_clean.mp4" (
            for /f "tokens=1 delims=." %%A in ('ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "%%F" 2^>nul') do set "dur_orig=%%A"
            for /f "tokens=1 delims=." %%A in ('ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "flickerfree_output\%%~nF_clean.mp4" 2^>nul') do set "dur_dest=%%A"
            
            if NOT "!dur_orig!"=="!dur_dest!" (
                set "process_file=y"
            ) else (
                if "%policy_choice%"=="1" (
                    set "process_file=n"
                ) else (
                    echo.
                    powershell -Command "Write-Host 'WARNING: The file \"flickerfree_output\%%~nF_clean.mp4\" is already 100%% complete.' -ForegroundColor Yellow"
                    set "overwrite_choice=n"
                    powershell -Command "Write-Host 'Do you want to overwrite this complete file? (y/[n])' -ForegroundColor Cyan"
                    set /p "overwrite_choice=Your choice: "
                    if /i not "!overwrite_choice!"=="y" set "process_file=n"
                )
            )
        )
        
        if "!process_file!"=="y" (
            echo Processing file: %%F...
            ffmpeg !hw_accel! -i "%%F" -vf "!active_vf!" !encoder! -threads 0 -filter_threads 0 -c:a copy -y "flickerfree_output\%%~nF_clean.mp4"
            echo ---------------------------------------------------
        )
    )
)

echo.
powershell -Command "Write-Host 'DONE! All videos have been successfully processed.' -ForegroundColor Green"
echo.

powershell -Command "[System.Media.SystemSounds]::Beep.Play()"

if /i "%shutdown_choice%"=="y" (
    powershell -Command "Write-Host 'The PC will shut down automatically in 30 seconds...' -ForegroundColor Red"
    echo Press CTRL+C in the console to abort the shutdown.
    shutdown /s /t 30
) else (
    echo PC stays on.
    pause
)
