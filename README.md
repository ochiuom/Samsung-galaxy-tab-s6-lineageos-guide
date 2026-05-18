# Samsung Galaxy Tab S6 (SM-T860) — LineageOS + Ubuntu Chroot Guide

This repo documents everything needed to turn a stock Samsung Galaxy Tab S6 Wi-Fi (SM-T860) into a fully rooted Linux machine — running LineageOS 22.2 GSI with Magisk root, and a complete Ubuntu 24.04 LTS desktop environment via Termux chroot.

---

## What This Covers

### Part 1 — [Flashing LineageOS & Rooting](./flashing-custom-rom.md)

Starting from stock Android, this guide walks through:

- Flashing the correct stock firmware via Odin as a clean base
- Unlocking the bootloader and installing TWRP recovery
- Flashing LineageOS 22.2 GSI (ARM64 A/B, with GApps)
- Rooting with Magisk v30.7 and installing BusyBox
- Fixing the speaker output (broken on most GSIs for this device)
- Updating Adreno GPU drivers via Magisk module
- Setting up essential apps: F-Droid, Termux, Termux-X11, file managers

### Part 2 — [Termux + Ubuntu 24.04 Chroot](./termux_ubuntu_chroot.md)

With the tablet rooted, this guide sets up a full Ubuntu desktop:

- Ubuntu 24.04 LTS ARM64 rootfs inside a chroot at `/data/local/chroot/ubuntu`
- XFCE4 desktop displayed via Termux-X11
- PulseAudio bridged over TCP for working audio
- Internal storage (`/sdcard`) and external SD card (`/sdcard_ext`) mounted inside the chroot
- Media packages: GStreamer, FFmpeg, VLC, MPV, yt-dlp, PipeWire
- Shell theming with Zsh, Oh My Zsh, Powerlevel10k, and fzf/zoxide/eza

---

## Downloads Checklist

| # | File | Source |
|---|------|--------|
| 1 | `LineageOS-22.2-20260105-GAPPS-EXT4-GSI.7z` | [MisterZtr LineageOS GSI Releases](https://github.com/MisterZtr/LineageOS_gsi/releases) |
| 2 | Stock firmware for your region (e.g. `T860XXU5DXJ1` BTU/UK) | [samfw.com](https://samfw.com/firmware/SM-T860/BTU) |
| 3 | `twrp-3.7.0_9-0-gts6lwifi.img` + `.img.tar` | [dl.twrp.me/gts6lwifi](https://dl.twrp.me/gts6lwifi/) |
| 4 | Magisk APK v30.7 | [topjohnwu/Magisk releases](https://github.com/topjohnwu/Magisk/releases/tag/v30.7) |
| 5 | Odin3 v3.14.1 (patched) | [XDA thread](https://xdaforums.com/t/patched-odin-3-13-1.3762572/) |
| 6 | Android Platform Tools (Windows) | [developer.android.com](https://developer.android.com/tools/releases/platform-tools) |
| 7 | BuiltIn-BusyBox Magisk module | [Magisk-Modules-Alt-Repo](https://github.com/Magisk-Modules-Alt-Repo/BuiltIn-BusyBox/releases) |
| 8 | Speaker fix Magisk module | [XDA thread](https://xdaforums.com/t/gsi-4-speaker-fix-for-galaxy-tab-s6.4780990/) |
| 9 | Adreno driver Magisk module | [XDA thread](https://xdaforums.com/t/adreno-driver-update-magisk-module-for-tab-s6.4767424/) |
| 10 | Termux-X11 nightly APK | [github.com/termux/termux-x11](https://github.com/termux/termux-x11/releases) |

---

## Device

**Samsung Galaxy Tab S6 SM-T860** (Wi-Fi only)  
SoC: Snapdragon 855 · GPU: Adreno 640 · RAM: 6/8 GB · Android base: rooted LineageOS 22.2 GSI
