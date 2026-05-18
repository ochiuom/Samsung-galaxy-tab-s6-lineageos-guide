# Samsung Galaxy Tab S6 (SM-T860) — LineageOS + Ubuntu Chroot Guide
 
Complete guide for Samsung Galaxy Tab S6 Wi-Fi (SM-T860) covering LineageOS 22.2 GSI installation, Magisk root, speaker fix, Adreno driver update, app setup, and running a full Ubuntu 24.04 desktop via Termux chroot.
 
---
 
## Contents
 
1. [Requirements](#requirements)
2. [Firmware & Unlock](#firmware--unlock)
3. [TWRP Installation](#twrp-installation)
4. [LineageOS 22.2 GSI](#linageos-222-gsi)
5. [Magisk Root](#magisk-root)
6. [Speaker Fix](#speaker-fix)
7. [Adreno Driver Update](#adreno-driver-update)
8. [App Setup](#app-setup)
9. [Termux + Ubuntu 24.04 Chroot](#termux--ubuntu-2404-chroot)
---
 
## Requirements
 
- Samsung Galaxy Tab S6 SM-T860 (Wi-Fi model)
- Windows PC for Odin flashing
- USB cable
- Unlocked bootloader
- [Odin](https://odindownload.com/)
- [TWRP for Tab S6](https://twrp.me/samsung/samsunggalaxytabs6wifi.html)
- [LineageOS 22.2 GSI (ARM64 A/B)](https://github.com/phhusson/treble_experimentations/releases)
- [Magisk APK](https://github.com/topjohnwu/Magisk/releases)
- [BuiltIn-BusyBox Magisk module](https://github.com/Magisk-Modules-Alt-Repo/BuiltIn-BusyBox/releases)
---
 
## Firmware & Unlock
 
1. Flash the latest stock firmware for SM-T860 via Odin to ensure a clean base.
2. Enable **Developer Options** → **OEM Unlocking**.
3. Boot into Download Mode (`Vol Down + Vol Up` while connecting USB) and perform a long press to unlock the bootloader.
> **Warning:** Bootloader unlock wipes the device.
 
---
 
## TWRP Installation
 
1. Download the TWRP image for SM-T860.
2. Boot into Download Mode and flash via Odin (`AP` slot).
3. Reboot into recovery.
---
 
## LineageOS 22.2 GSI
 
1. In TWRP, wipe **System**, **Data**, **Cache**, **Dalvik**.
2. Flash the LineageOS 22.2 ARM64 A/B GSI zip.
3. Flash the appropriate GApps package if needed.
4. Reboot system.
---
 
## Magisk Root
 
1. Copy the `boot.img` from the GSI package to the device.
2. Install **Magisk APK**, patch the boot image from within the app.
3. Flash the patched boot image via Odin (`AP` slot) in Download Mode.
4. After boot, open Magisk and confirm root status.
5. Install the **BuiltIn-BusyBox** module from Magisk → Modules.
---
 
## Speaker Fix
 
> LineageOS GSIs may ship with broken or low-volume speaker output on the Tab S6.
 
Install the speaker fix Magisk module appropriate for SM-T860 and reboot.
 
---
 
## Adreno Driver Update
 
1. Download updated Adreno drivers compatible with the SM-T860 GPU.
2. Flash via Magisk module or apply through the **Adreno Tools** app.
3. Reboot and verify via a GPU benchmark or `glxinfo`-equivalent.
---
 
## App Setup
 
Recommended baseline:
 
- **F-Droid** — open source app repository
- **Termux** (from F-Droid) — terminal emulator, required for chroot
- **Termux-X11** (nightly APK) — X11 display server for desktop GUI
- **X-plore** — file manager (useful for identifying SD card labels)
- **MiXplorer** — alternative file manager with root support
---
 
## Termux + Ubuntu 24.04 Chroot
 
Runs a full Ubuntu 24.04 LTS desktop (XFCE4) inside a chroot on the rooted tablet, displayed via Termux-X11.
