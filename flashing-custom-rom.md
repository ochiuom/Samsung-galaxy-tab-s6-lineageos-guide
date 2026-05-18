# Samsung Galaxy Tab S6 (SM-T860 Wi-Fi) — LineageOS 22.2 GSI Install Guide

> **Device**: Samsung Galaxy Tab S6 SM-T860 (Wi-Fi)  
> **Target ROM**: LineageOS 22.2 GSI (with GApps)  
> **Host OS**: Windows 11 + Linux (for SD card formatting)  
> **Prerequisites**: Bootloader already unlocked

---

## Downloads Checklist

| # | File | Source |
|---|------|--------|
| 1 | `LineageOS-22.2-20260105-GAPPS-EXT4-GSI.7z` | [MisterZtr LineageOS GSI Releases](https://github.com/MisterZtr/LineageOS_gsi/releases) |
| 2 | Stock firmware matching your region (e.g. `T860XXU5DXJ1` for BTU/UK) | [samfw.com](https://samfw.com/firmware/SM-T860/BTU) |
| 3 | TWRP: `twrp-3.7.0_9-0-gts6lwifi.img` + `.img.tar` | [dl.twrp.me/gts6lwifi](https://dl.twrp.me/gts6lwifi/) |
| 4 | Magisk APK v30.7 | [topjohnwu/Magisk releases](https://github.com/topjohnwu/Magisk/releases/tag/v30.7) |
| 5 | Odin3 v3.14.1 (patched) | [XDA thread](https://xdaforums.com/t/patched-odin-3-13-1.3762572/) |
| 6 | Android Platform Tools (Windows) | [developer.android.com](https://developer.android.com/tools/releases/platform-tools) |

> **Firmware note**: Check **Settings → About tablet** to confirm your CSC/region code before downloading firmware. UK units show `BTU`. Do not use a mismatched region firmware.  
> **Firmware download tip**: Use the Google Drive mirror on samfw.com if the direct download keeps disconnecting.

---

## Step 1 — Prepare the AP File (Magisk-patch it)

1. Extract the downloaded stock firmware zip (e.g. `T860XXU5DXJ1`).
2. Locate the `AP_*.tar` file inside the extracted folder.
3. Copy the `AP` file to the Galaxy Tab S6.
4. Install the **Magisk APK** on the tablet (device does not need to be rooted for this step).
5. Open Magisk (from Home tab) → **Install → Select and Patch a File** → choose the AP file.
6. Magisk will create a patched file in the `Downloads` folder (e.g. `magisk_patched_xxxxx.tar`).
7. Copy the patched AP file back to your Windows PC.

---

## Step 2 — Set Up ADB on Windows

1. Extract the Platform Tools zip anywhere on your PC.
2. Open a terminal/PowerShell in that folder.
3. Enable **Developer Options** on the tablet: Settings → About → tap Build Number 7 times.
4. Enable **USB Debugging** under Developer Options.
5. Connect the tablet to the PC via USB (USB 3.0 port → USB-C preferred — Odin is sensitive to slow transfers).
6. When prompted on the tablet, tap **Allow** / **Trust this computer**.
7. Verify connection:

```bash
./adb devices
```

The tablet should appear in the list.

---

## Step 3 — Flash Stock ROM with Patched AP via Odin

1. Reboot the tablet into **Download Mode**: hold **Volume Down + Volume Up + Power** while USB is plugged in.
2. Open **Odin3 v3.14.1 (patched)**.
3. Load files:
   - **BL** → `BL_*.tar` from the extracted firmware folder
   - **AP** → the Magisk-patched AP file
   - **CSC** → `CSC_*.tar` (**not** `HOME_CSC`)
4. In the **Options** tab: **disable Auto Reboot**.
5. Click **Start**.
6. When Odin shows `PASS` (green), go to the Options tab → click **Return to Download Mode**.

---

## Step 4 — Flash TWRP via Odin

1. You should be back in Download Mode.
2. In Odin, clear previous slots and set:
   - **AP** → `twrp-3.7.0_9-0-gts6lwifi.img.tar`
3. In **Options**: **enable Auto Reboot**.
4. Click **Start**.
5. When Odin reboots the device, immediately hold **Volume Up + Power** to boot directly into TWRP.

---

## Step 5 — Wipe and Flash LineageOS GSI

### Wipe

In TWRP:

1. On the initial screen, swipe to allow modifications.
2. **Main Menu → Wipe → Format Data** → confirm. Use the Android back button (not TWRP's) to return to the previous screen.
3. **Main Menu → Wipe → Advanced Wipe**
4. Select: **Dalvik, System, Data, Cache** → swipe to confirm.

### Copy the GSI Image

- On Windows, extract `LineageOS-22.2-20260105-GAPPS-EXT4-GSI.7z` using 7-Zip to get the `.img` file.
- Copy `LineageOS-22.2-20260105-GAPPS-EXT4-GSI.img` to the tablet's internal storage (via MTP or USB OTG — both work).

### Flash

In TWRP:

1. **Main Menu → Install Image**
2. Select Storage → navigate to the `.img` file.
3. Tap **Install Image** → select the LineageOS `.img` → choose **System Image** → swipe to confirm.
4. After flashing completes, **Reboot to System**.
5. TWRP will warn that no OS is installed — this is a false positive. Swipe to ignore.

> ⚠️ **Do not flash the Magisk zip yet.** Boot fully into LineageOS first and complete the initial setup before proceeding.

---

## Step 6 — Install Magisk (Root)

1. Boot back into TWRP: hold **Power + Volume Up** during reboot.
2. Rename `Magisk-v30.7.apk` → `Magisk-v30.7.zip` (on Windows).
3. In TWRP: **Install → select the zip → swipe to confirm**.
4. Reboot to System.
5. Open the **Magisk app** — if it shows no pending updates or re-installs, root is fully working.

---

## Step 7 — Post-Install Fixes

### Fix Low Brightness

1. Install the **Treble app** (available on F-Droid / Play Store).
2. Open it → **Samsung Settings → Enable Extend Brightness Range**.

### Fix All 4 Speakers

1. Download the speaker fix Magisk module from: [XDA thread](https://xdaforums.com/t/gsi-4-speaker-fix-for-galaxy-tab-s6.4780990/)
2. In Magisk → **Modules → Install from storage** → select the module zip → reboot.
3. Works in both portrait and landscape.

### Update Adreno GPU Drivers

1. Download the Adreno driver Magisk module from: [XDA thread](https://xdaforums.com/t/adreno-driver-update-magisk-module-for-tab-s6.4767424/)
2. In Magisk → **Modules → Install from storage** → select the zip → reboot.

---

## Step 8 — SD Card Setup

> Windows 11 formats SD cards as NTFS or exFAT by default — the Tab S6 will not read these correctly.

- Use **Linux** to format your SD card as **FAT32**:

```bash
# Replace /dev/sdX1 with your actual SD card partition
sudo mkfs.vfat -F 32 /dev/sdX1
```

---

## Step 9 — Recommended Apps

### Via Google Play Store
- **Brave Browser**

### F-Droid (get the client at [f-droid.org](https://f-droid.org/en/packages/org.fdroid.fdroid/))

| App | Purpose |
|-----|---------|
| ProtonVPN | VPN |
| Nextcloud | Cloud storage sync |
| Immich | Photo backup |
| AdAway | System-level ad blocking (requires root) |
| Termux | Terminal emulator |
| Murena Launcher | Privacy-focused launcher |
| Jellyfin | Media streaming |
| Chaka | (e-reader / document viewer) |
| Delta Chat | Messaging over email |
| Orion Viewer | PDF/DjVu reader |
| Thunderbird | Email client |

---

## Notes

- Tested on SM-T860 (Wi-Fi), firmware `T860XXU5DXJ1` (BTU/UK region).
- GSI build `LineageOS-22.2-20260105-GAPPS-EXT4-GSI` was stable at time of flashing; newer builds may be buggy — check the release thread.
- Last official Samsung security patch on this device: **August 2023**.
