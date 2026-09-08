#!/bin/bash

# Ensure UTF-8 formatting and clear screen
export LANG=en_US.UTF-8
clear

echo "=========================================================="
echo "  ___  ____ ____ _    _ ____ _  _ ____ ____ ____ _  _ "
echo "  |  \ |___ |___ |    | |___ |_/  |___ |__/  |__|  "
echo "  |__/ |___ |    |___ | |___ | \_ |___ |  \    |  "
echo "            BY ALBERTO SONO | VERSION 1.0            "
echo "               🌐 albertosono.page.gd                "
echo "=========================================================="
echo "  UNIVERSAL LINUX BATCH PROCESS | SMART HARDWARE MODE"
echo "=========================================================="
echo ""

# 1. SAFE AUTO-DETECT NVIDIA GPU VIA LSPCI
GPU_MODE="CPU"
HW_ACCEL=""
ENCODER="-c:v libx264 -crf 18 -preset medium"

if lspci 2>/dev/null | grep -i "NVIDIA" >/dev/null; then
    GPU_MODE="NVIDIA RTX/GTX (Hardware Accelerated)"
    HW_ACCEL="-hwaccel cuda"
    ENCODER="-c:v h264_nvenc -preset fast"
fi

echo -e "Active Hardware Mode: \033[33m$GPU_MODE\033[0m"
echo ""

# 2. Filter selection (Cyan question, Yellow default)
echo -e "\033[36mWhich Deflicker-Filter do you want to use?\033[0m (\033[1;33mDefault is 1\033[0m)"
echo "1. Ultra-fast Express-Filter (Speed: >100 FPS on GPU)"
echo "   Command: -vf \"hqdn3d=0:0:60:30\""
echo "2. High-End Mask-Formula (Best Quality)"
echo "   Command: -vf \"vflip,tblend=all_mode=average:all_expr='if(gt(abs(A-B),15),A,(A+B)/2)',vflip,hqdn3d=0:0:15:10\""
echo ""
read -p "Your choice: " filter_choice
filter_choice=${filter_choice:-1}

# 3. Overwrite Policy selection
echo ""
echo -e "\033[36mHow should existing files be handled?\033[0m (\033[1;33mDefault is 1\033[0m)"
echo "1. Automated Smart-Skip (Auto-repair broken files / Auto-skip finished files)"
echo "2. Ask for each completed file (Interactive)"
echo ""
read -p "Your choice: " policy_choice
policy_choice=${policy_choice:-1}

# 4. Shutdown selection
echo ""
echo -e "\033[36mShould the PC shutdown automatically afterwards?\033[0m (y/[\033[1;31mn\033[0m])"
read -p "Your choice [n]: " shutdown_choice
shutdown_choice=${shutdown_choice:-n}

# Define filter string based on selection
if [ "$filter_choice" -eq 2 ]; then
    ACTIVE_VF="vflip,tblend=all_mode=average:all_expr='if(gt(abs(A-B),15),A,(A+B)/2)',vflip,hqdn3d=0:0:15:10"
    echo -e "\n\033[32m-= High-End Mask-Formula active =-\033[0m"
else
    ACTIVE_VF="hqdn3d=0:0:60:30"
    echo -e "\n\033[32m-= Ultra-fast Express-Filter active =-\033[0m"
fi

echo ""
mkdir -p "flickerfree_output"

echo "=========================================================="
echo "  PHASE 1: SCANNING AND ANALYZING FILES..."
echo "=========================================================="
echo ""

# --- PHASE 1: PRE-SCAN ---
# Enable case-insensitive globbing for extensions
shopt -s -q nocaseglob

for file in *.mp4 *.mov; do
    # Skip if no files match the pattern
    [ -e "$file" ] || continue
    
    filename=$(basename "$file")
    
    # Skip temporary or output files
    if [ "$filename" = "output.mp4" ] || [[ "$filename" == *_clean.mp4 ]]; then
        continue
    fi
    
    dest_file="flickerfree_output/${filename%.*}_clean.mp4"
    
    if [ -f "$dest_file" ]; then
        # Precise duration check using ffprobe
        dur_orig=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$file" | cut -d. -f1)
        dur_dest=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$dest_file" | cut -d. -f1)
        
        if [ "$dur_orig" != "$dur_dest" ]; then
            echo -e "\033[31m[INCOMPLETE]\033[0m $file (Will be re-rendered)"
        else
            echo -e "\033[32m[COMPLETE]\033[0m   $file (Will be skipped)"
        fi
    else
        echo "[NEW FILE]   $file (Will be processed)"
    fi
done

echo ""
echo "=========================================================="
echo "  PHASE 2: EXECUTING TASK QUEUE..."
echo "=========================================================="
echo ""

# --- PHASE 2: PROCESSING ---
for file in *.mp4 *.mov; do
    [ -e "$file" ] || continue
    
    filename=$(basename "$file")
    if [ "$filename" = "output.mp4" ] || [[ "$filename" == *_clean.mp4 ]]; then
        continue
    fi
    
    dest_file="flickerfree_output/${filename%.*}_clean.mp4"
    process_file="y"
    
    if [ -f "$dest_file" ]; then
        dur_orig=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$file" | cut -d. -f1)
        dur_dest=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$dest_file" | cut -d. -f1)
        
        if [ "$dur_orig" != "$dur_dest" ]; then
            echo ""
            echo -e "\033[31mDETECTED INCOMPLETE FILE: \"$dest_file\" is corrupted.\033[0m"
            echo "Automatically overwriting to fix the incomplete video..."
            process_file="y"
        else
            if [ "$policy_choice" -eq 1 ]; then
                process_file="n"
            else
                echo ""
                echo -e "\033[33mWARNING: The file \"$dest_file\" is already 100% complete.\033[0m"
                echo -e "\033[36mDo you want to overwrite this complete file?\033[0m (y/[\033[1;31mn\033[0m])"
                read -p "Your choice: " overwrite_choice
                overwrite_choice=${overwrite_choice:-n}
                if [ "$overwrite_choice" != "y" ]; then
                    process_file="n"
                    echo "File $file was SKIPPED."
                    echo "----------------------------------------------------------"
                fi
            fi
        fi
    fi
    
    if [ "$process_file" = "y" ]; then
        echo "Processing file: $file..."
        # Execute FFmpeg with array expanded variables safely
        ffmpeg $HW_ACCEL -i "$file" -vf "$ACTIVE_VF" $ENCODER -threads 0 -filter_threads 0 -c:a copy -y "$dest_file"
        echo "----------------------------------------------------------"
    fi
done

echo ""
echo -e "\033[32mDONE! All videos have been successfully processed.\033[0m"
echo ""

# Native Linux Bell Sound
echo -e "\a"

# Handle automated shutdown (requires root/sudo permissions on Linux)
if [ "$shutdown_choice" = "y" ]; then
    echo -e "\033[31mThe PC will shut down automatically in 30 seconds...\033[0m"
    echo "Press CTRL+C in the terminal to abort the shutdown."
    sleep 30
    sudo shutdown -h now
fi

shopt -u nocaseglob
