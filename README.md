# DeFlickery 🚀
### High-End Deflicker Script Family for Windows, Linux and Mac

A highly optimized Windows Batch script (`.bat`) utilizing **FFmpeg** and **NVIDIA CUDA/NVENC** (tested on an RTX 3050 Laptop GPU) to eliminate aggressive **50Hz power-line / theater light flickering** from **60 FPS (NTSC)** video recordings.

## 💡 The Problem: 50Hz Light vs. 60 FPS Camera
When shooting video at 60 FPS (NTSC standard) in regions with a 50Hz power grid (like Europe/PAL), artificial lights and theater spotlights pulse 50 times per second. This frequency mismatch causes an interference pattern resulting in rolling light waves or severe flickering horizontal bands across the video frames. Standard deflicker filters fail because the brightness changes locally rather than globally.

## 🧠 The Solution: Adaptive Temporal Threshold Mask
This script provides two industry-grade workflows to fix this issue directly in the command line:

1. **Ultra-fast Express-Filter (`hqdn3d=0:0:60:30`):** Fully accelerated via GPU, processing videos at **>100 FPS**. It uses high-frequency temporal blending to flatten the flicker instantly.
2. **High-End Mask-Formula:** Emulates modern AI-based and commercial deflickering software architectures. By twisting the frame matrix (`vflip`) and applying a mathematical threshold mask (`all_expr='if(gt(abs(A-B),15),A,(A+B)/2)'`), it isolates and deletes the moving 50Hz light waves while **completely preserving sharp edges on moving objects**. This guarantees **zero ghosting or double-images** (e.g., on microphones or moving people in the foreground).

---

## ✨ Features
* 🧠 **Smart Auto-Hardware Detection:** Automatically scans for NVIDIA GPUs to enable full acceleration (CUDA/NVENC), falling back to optimized CPU mode (`libx264`, `-crf 18`) if unavailable.
* 🔍 **Phase 1: Pre-Render Diagnostics:** Instantly scans the folder before processing and lists the exact status of all files (`[COMPLETE]`, `[INCOMPLETE]`, or `[NEW FILE]`) in a clean, color-coded overview.
* 🛡️ **Phase 2: Intelligent Task Queue:** Uses `ffprobe` duration matching to detect aborted or corrupted files. Incomplete files are auto-repaired, while 100% finished files are safely skipped without user intervention.
* 📊 **Interactive Menu:** Select between high-speed filters or high-end mask formulas instantly.
* 🎨 **Color-Coded CLI:** Clear turquoise prompts with intuitive green, red, and orange indicators.
* 💤 **Auto-Shutdown Option:** Optional prompt to shut down the PC after the queue finishes.
* 🔔 **Audio Notification:** Plays a Windows system chime upon completion.

---

## 🛠️ System Requirements & Setup
1. **Operating System:** Windows 10 / 11.
2. **Hardware:** 
   * **NVIDIA Mode:** GeForce RTX/GTX card (`h264_nvenc`/`cuda`).
   * **CPU Mode:** Any Intel/AMD processor fallback.
3. **Software:** **FFmpeg Git-Master-Build** (Standard releases like *FFmpeg 8.0.1* will cause syntax errors; requires builds with Vulkan and CUDA/NVENC support). Ensure `ffmpeg`, `ffplay`, and `ffprobe` are in your Windows **System Environment Path**.

---

## 🚀 How to Use

Copy the script for your operating system into the folder containing your `.mov` or `.mp4` video files. Upon launch, it will guide you through 3 options (Filter selection, Overwrite policy, and Auto-shutdown). All cleaned files will be stored safely in the `flickerfree_output` subfolder.

*   **🪟 Windows:** Double-click `deflickery-win.bat`.
*   **🐧 Linux:** Open your terminal in the video folder, make it executable via `chmod +x deflickery-linux.sh` and run `./deflickery-linux.sh`.
*   **🍎 macOS:** Open your terminal in the video folder, make it executable via `chmod +x deflickery-mac.sh` and run `./deflickery-mac.sh`. (Utilizes high-speed Apple Silicon *VideoToolbox* acceleration).

---

## 🎥 Pro-Tip: How to Avoid Flickering in the Future (The PAL Rule)
To prevent 50Hz light flickering from getting baked into your footage in the first place when shooting in Europe (or any other 50Hz grid region), configure your camera with the following settings **before** pressing record:

1. **Switch to PAL Mode:** Go to your camera or smartphone video settings and change the video standard from NTSC to **PAL**.
2. **Choose the Right Framerate:** Shoot at either **25 FPS** (for a cinematic look) or **50 FPS** (for smooth movement/slow-motion).
3. **Lock your Shutter Speed:** Set your shutter manually to exactly **1/50s** (when shooting 25 FPS) or **1/100s** (when shooting 50 FPS).

By aligning your camera's frame rate with the 50Hz pulse of the power grid, your sensor catches the exact same light phase in every single frame, resulting in perfectly stable, flicker-free footage straight out of the camera!

---
*Created out of pure frustration with church/theater lighting interference. Feel free to contribute, fork, or open an issue!*
