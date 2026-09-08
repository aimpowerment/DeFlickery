# High-End Deflicker Batch Script for Windows 🚀

A highly optimized Windows Batch script (`.bat`) utilizing **FFmpeg** and **NVIDIA CUDA/NVENC** (tested on an RTX 3050 Laptop GPU) to eliminate aggressive **50Hz power-line / theater light flickering** from **60 FPS (NTSC)** video recordings.

## 💡 The Problem: 50Hz Light vs. 60 FPS Camera
When shooting video at 60 FPS (NTSC standard) in regions with a 50Hz power grid (like Europe/PAL), artificial lights and theater spotlights pulse 50 times per second. This frequency mismatch causes an interference pattern resulting in rolling light waves or severe flickering horizontal bands across the video frames. Standard deflicker filters fail because the brightness changes locally rather than globally.

## 🧠 The Solution: Adaptive Temporal Threshold Mask
This script provides two industry-grade workflows to fix this issue directly in the command line:

1. **Ultra-fast Express-Filter (`hqdn3d=0:0:60:30`):** Fully accelerated via GPU, processing videos at **>100 FPS**. It uses high-frequency temporal blending to flatten the flicker instantly.
2. **High-End Mask-Formula:** Emulates modern AI-based and commercial deflickering software architectures. By twisting the frame matrix (`vflip`) and applying a mathematical threshold mask (`all_expr='if(gt(abs(A-B),15),A,(A+B)/2)'`), it isolates and deletes the moving 50Hz light waves while **completely preserving sharp edges on moving objects**. This guarantees **zero ghosting or double-images** (e.g., on microphones or moving people in the foreground).

---

## ✨ Features
* 📊 **Interactive Menu:** Choose between the high-speed filter or the high-end mask formula right at the start.
* 🎨 **Color-Coded CLI:** Interactive turquoise questions with clear green/red default value markers.
* 🛡️ **100% Integrity Check:** Automatically uses `ffprobe` to scan the output directory. If it detects a broken or partially rendered video (e.g., from a previously aborted process), it **automatically overwrites** and repairs it. It only asks for confirmation on 100% complete files.
* 💤 **Auto-Shutdown Option:** Prompt at startup to automatically shut down the PC once the whole queue is done.
* 🔔 **Audio Notification:** Plays a native Windows system chime upon completion.

---

## 🛠️ System Requirements & Setup
1. **Operating System:** Windows 10 / 11.
2. **Hardware:** NVIDIA GeForce RTX Graphics Card (Optimized for RTX 3050 and up using `h264_nvenc`).
3. **Software:** **FFmpeg Git-Master-Build (Crucial!)**. 
   * Standard release builds (like *FFmpeg 8.0.1 Essentials*) will **not** work and will cause syntax errors. 
   * You strictly need the latest Git-Master-Build (e.g., from BtbN or Gyan.dev Git Master) that includes full **Vulkan API** and **CUDA/NVENC** hardware-acceleration libraries.
   * Ensure `ffmpeg`, `ffplay`, and `ffprobe` are added to your Windows **System Environment Path** (without a trailing backslash!).

---

## 🚀 How to Use
1. Copy the `deflicker-rtx.bat` file into the folder containing your flimmery `.mov` or `.mp4` video files.
2. Double-click the script.
3. Choose your filter, decide on the auto-shutdown option, and let your RTX card do the heavy lifting in the background! Cleaned files will be saved in a new subfolder called `Flimmerfrei_Output`.

---

---

## 🎥 Pro-Tip: How to Avoid Flickering in the Future (The PAL Rule)
To prevent 50Hz light flickering from getting baked into your footage in the first place when shooting in Europe (or any other 50Hz grid region), configure your camera with the following settings **before** pressing record:

1. **Switch to PAL Mode:** Go to your camera or smartphone video settings and change the video standard from NTSC to **PAL**.
2. **Choose the Right Framerate:** Shoot at either **25 FPS** (for a cinematic look) or **50 FPS** (for smooth movement/slow-motion).
3. **Lock your Shutter Speed:** Set your shutter manually to exactly **1/50s** (when shooting 25 FPS) or **1/100s** (when shooting 50 FPS).

By aligning your camera's frame rate with the 50Hz pulse of the power grid, your sensor catches the exact same light phase in every single frame, resulting in perfectly stable, flicker-free footage straight out of the camera!

---
*Created out of pure frustration with church/theater lighting interference. Feel free to contribute, fork, or open an issue!*
