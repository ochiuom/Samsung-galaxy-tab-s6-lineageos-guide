# Termux + Ubuntu 24.04 Chroot Setup — SM-T860

Runs a full Ubuntu 24.04 LTS desktop (XFCE4) inside a chroot on the rooted Tab S6, displayed via Termux-X11. Also covers terminal-only chroot access, SD card mounting, media packages, and shell theming.

Reference: [LinuxDroidMaster Termux Desktops](https://github.com/LinuxDroidMaster/Termux-Desktops/blob/main/Documentation/chroot/ubuntu_chroot.md)

---

## Contents

1. [Termux Base Setup](#1-termux-base-setup)
2. [Create Chroot Directory and Download Rootfs](#2-create-chroot-directory-and-download-rootfs)
3. [First Boot into Chroot — Initial Configuration](#3-first-boot-into-chroot--initial-configuration)
4. [Create User](#4-create-user)
5. [Install XFCE4 Desktop](#5-install-xfce4-desktop)
6. [Update Chroot Script for Desktop Launch](#6-update-chroot-script-for-desktop-launch)
7. [Install Termux-X11 and Create Desktop Launcher](#7-install-termux-x11-and-create-desktop-launcher)
8. [Add External SD Card Support](#8-add-external-sd-card-support)
9. [Final Script State](#9-final-script-state)
10. [Terminal-Only Chroot Access](#10-terminal-only-chroot-access)
11. [Media Packages](#11-media-packages)
12. [Shell Theming — Zsh + Powerlevel10k](#12-shell-theming--zsh--powerlevel10k)

---

## 1. Termux Base Setup

Open Termux and install required packages:

```bash
pkg update
pkg install x11-repo
pkg install root-repo
pkg install termux-x11-nightly
pkg update
pkg install tsu pulseaudio sudo wget
```

---

## 2. Create Chroot Directory and Download Rootfs

```bash
su
mkdir -p /data/local/chroot/ubuntu
chmod 755 /data/local/chroot/ubuntu
chown root:root /data/local/chroot/ubuntu
cd /data/local/chroot/ubuntu
```

Download Ubuntu 24.04 LTS ARM64 base rootfs:

```bash
curl https://cdimage.ubuntu.com/ubuntu-base/releases/24.04/release/ubuntu-base-24.04.4-base-arm64.tar.gz \
  -o ubuntu.tar.gz
```

Extract and create the sdcard mountpoint:

```bash
tar xpvf ubuntu.tar.gz --numeric-owner
mkdir -p sdcard
```

Create the initial chroot startup script. At this stage it just drops you into a root shell so you can configure the system:

```bash
cd /data/local/chroot
busybox vi start_ubuntu_xfce.sh
```

```sh
#!/bin/sh
UBUNTUPATH="/data/local/chroot/ubuntu"

busybox mount -o remount,dev,suid /data
busybox mount --bind /dev $UBUNTUPATH/dev
busybox mount --bind /sys $UBUNTUPATH/sys
busybox mount --bind /proc $UBUNTUPATH/proc
busybox mount -t devpts devpts $UBUNTUPATH/dev/pts

mkdir -p $UBUNTUPATH/dev/shm
busybox mount -t tmpfs -o size=256M tmpfs $UBUNTUPATH/dev/shm

busybox mount --bind /sdcard $UBUNTUPATH/sdcard

# chroot into Ubuntu as root for initial setup
busybox chroot $UBUNTUPATH /bin/su - root
```

Make it executable and run it:

```bash
chmod +x start_ubuntu_xfce.sh
sh start_ubuntu_xfce.sh
```

The prompt changes to `root@localhost`.

---

## 3. First Boot into Chroot — Initial Configuration

You are now inside the Ubuntu chroot as root. Configure networking and Android-specific groups:

```bash
echo "nameserver 8.8.8.8" > /etc/resolv.conf
echo "127.0.0.1 localhost
::1 localhost" > /etc/hosts

groupadd -g 3003 aid_inet
groupadd -g 3004 aid_net_raw
groupadd -g 1003 aid_graphics
usermod -g 3003 -G 3003,3004 -a _apt
usermod -G 3003 -a root

apt update && apt upgrade
apt install nano vim net-tools sudo git
```

Fix PATH permanently:

```bash
echo 'export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin' >> /etc/profile
```

---

## 4. Create User

Still inside the chroot as root:

```bash
groupadd storage
groupadd wheel
useradd -m -g users -G wheel,audio,video,storage,aid_inet -s /bin/bash ochiuom
passwd ochiuom
```

Configure passwordless sudo:

```bash
echo "ochiuom ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/ochiuom
chmod 440 /etc/sudoers.d/ochiuom
```

Switch to the new user and set locale:

```bash
su - ochiuom
sudo apt install locales
sudo locale-gen en_US.UTF-8
```

---

## 5. Install XFCE4 Desktop

```bash
sudo apt install xubuntu-desktop
```

Disable snapd — it cannot run inside a chroot:

```bash
sudo apt-get autopurge snapd

cat <<EOF | sudo tee /etc/apt/preferences.d/nosnap.pref
Package: snapd
Pin: release a=*
Pin-Priority: -10
EOF
```

Exit the chroot completely:

```bash
exit   # exit ochiuom back to root
exit   # exit chroot back to Termux
```

force-stop it from Android settings, then relaunch — this clears any stale session state before proceeding
---

## 6. Update Chroot Script for Desktop Launch

Now that the user and desktop are configured, update `start_ubuntu_xfce.sh` to launch XFCE4 instead of dropping to a root shell:

```bash
vi /data/local/chroot/start_ubuntu_xfce.sh
```

Comment out the old last line and replace it:

```sh
#!/bin/sh
UBUNTUPATH="/data/local/chroot/ubuntu"

busybox mount -o remount,dev,suid /data
busybox mount --bind /dev $UBUNTUPATH/dev
busybox mount --bind /sys $UBUNTUPATH/sys
busybox mount --bind /proc $UBUNTUPATH/proc
busybox mount -t devpts devpts $UBUNTUPATH/dev/pts

mkdir -p $UBUNTUPATH/dev/shm
busybox mount -t tmpfs -o size=256M tmpfs $UBUNTUPATH/dev/shm

busybox mount --bind /sdcard $UBUNTUPATH/sdcard

# chroot into Ubuntu as root for initial setup
#busybox chroot $UBUNTUPATH /bin/su - root
busybox chroot $UBUNTUPATH /bin/su - ochiuom \
  -c "DISPLAY=:0 PULSE_SERVER=tcp:127.0.0.1:4713 dbus-launch --exit-with-session startxfce4"
```

---

## 7. Install Termux-X11 and Create Desktop Launcher

Install the Termux-X11 APK from [github.com/termux/termux-x11/releases](https://github.com/termux/termux-x11/releases), open it once, then minimize it.

Back in Termux, download the base launcher script:

```bash
wget https://raw.githubusercontent.com/LinuxDroidMaster/Termux-Desktops/refs/heads/main/scripts/chroot/ubuntu/startxfce4_chrootubuntu.sh
```

Edit it — the only change needed is the last line:

```bash
nano startxfce4_chrootubuntu.sh
```

Final content:

```bash
#!/bin/bash

# Kill previous session leftovers
pkill -9 -f com.termux.x11
killall -9 termux-x11 Xwayland pulseaudio virgl_test_server_android termux-wake-lock

# Start Termux-X11
am start --user 0 -n com.termux.x11/com.termux.x11.MainActivity

# Mount tmp
su -c "mkdir -p /data/local/chroot/ubuntu/tmp"
su -c "busybox mount -t tmpfs -o size=64M tmpfs /data/local/chroot/ubuntu/tmp"
su -c "chmod 1777 /data/local/chroot/ubuntu/tmp"

# Start X server
XDG_RUNTIME_DIR=${TMPDIR} termux-x11 :0 -ac &

sleep 3

# Mount X11 socket into chroot after X server is up
su -c "mkdir -p /data/local/chroot/ubuntu/tmp/.X11-unix"
su -c "busybox mount --bind $TMPDIR/.X11-unix /data/local/chroot/ubuntu/tmp/.X11-unix"

# Start PulseAudio
pulseaudio --start \
  --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" \
  --exit-idle-time=-1
pacmd load-module module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1

# Execute chroot Ubuntu script
su -c "sh /data/local/chroot/start_ubuntu_xfce.sh"
```

```bash
chmod +x startxfce4_chrootubuntu.sh
./startxfce4_chrootubuntu.sh
```

The XFCE4 desktop should appear in the Termux-X11 window. If it works, press **Ctrl+Z** to background Termux, then force-stop Termux from Android and reopen it — this clears any stale session state.

---

## 8. Add External SD Card Support

Check your external SD card label in X-plore or any file manager — it will show something like `B279-3DEA`. Replace this with your actual label below.

From Termux, add the user to the `media_rw` group:

```bash
su -c "busybox chroot /data/local/chroot/ubuntu /bin/bash -c \
  'groupadd -g 1023 media_rw && usermod -aG media_rw ochiuom'"

su -c "chmod 777 /data/local/chroot/ubuntu/sdcard_ext"
```

---

## 9. Final Script State

After adding SD card support, update both chroot scripts to their final form.

### `/data/local/chroot/start_ubuntu_xfce.sh`

```bash
su -c "busybox vi /data/local/chroot/start_ubuntu_xfce.sh"
```

```sh
#!/bin/sh
UBUNTUPATH="/data/local/chroot/ubuntu"

busybox mount -o remount,dev,suid /data
busybox mount --bind /dev $UBUNTUPATH/dev
busybox mount --bind /sys $UBUNTUPATH/sys
busybox mount --bind /proc $UBUNTUPATH/proc
busybox mount -t devpts devpts $UBUNTUPATH/dev/pts

mkdir -p $UBUNTUPATH/dev/shm
busybox mount -t tmpfs -o size=256M tmpfs $UBUNTUPATH/dev/shm

busybox mount --bind /sdcard $UBUNTUPATH/sdcard

mkdir -p $UBUNTUPATH/sdcard_ext
busybox mount --bind /mnt/media_rw/B279-3DEA $UBUNTUPATH/sdcard_ext
busybox mount -t vfat -o remount,rw,uid=1000,gid=100,fmask=0000,dmask=0000 \
  $UBUNTUPATH/sdcard_ext

busybox chroot $UBUNTUPATH /bin/su - ochiuom \
  -c "DISPLAY=:0 PULSE_SERVER=tcp:127.0.0.1:4713 dbus-launch --exit-with-session startxfce4"
```

> Replace `B279-3DEA` with your SD card label. Replace `ochiuom` with your username.

---

## 10. Terminal-Only Chroot Access

For accessing the Ubuntu chroot without launching the GUI desktop.

### `/data/local/chroot/start_ubuntu_terminal.sh`

```bash
su -c "busybox vi /data/local/chroot/start_ubuntu_terminal.sh"
```

```sh
#!/bin/sh
UBUNTUPATH="/data/local/chroot/ubuntu"

busybox mount -o remount,dev,suid /data
busybox mount --bind /dev $UBUNTUPATH/dev
busybox mount --bind /sys $UBUNTUPATH/sys
busybox mount --bind /proc $UBUNTUPATH/proc
busybox mount -t devpts devpts $UBUNTUPATH/dev/pts

mkdir -p $UBUNTUPATH/dev/shm
busybox mount -t tmpfs -o size=256M tmpfs $UBUNTUPATH/dev/shm

busybox mount --bind /sdcard $UBUNTUPATH/sdcard

mkdir -p $UBUNTUPATH/sdcard_ext
busybox mount --bind /mnt/media_rw/B279-3DEA $UBUNTUPATH/sdcard_ext
busybox mount -t vfat -o remount,rw,uid=1000,gid=100,fmask=0000,dmask=0000 \
  $UBUNTUPATH/sdcard_ext

busybox chroot $UBUNTUPATH /bin/su - ochiuom
```

### `~/start_terminal.sh`

```bash
nano ~/start_terminal.sh
```

```bash
#!/bin/bash
su -c "sh /data/local/chroot/start_ubuntu_terminal.sh"
```

```bash
chmod +x ~/start_terminal.sh
./start_terminal.sh
```

Inside the chroot:

```bash
cd /sdcard      # internal storage
cd /sdcard_ext  # external SD card
```

---

## 11. Media Packages

Inside the Ubuntu chroot:

```bash
sudo apt install \
  gstreamer1.0-tools gstreamer1.0-plugins-base gstreamer1.0-plugins-good \
  gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly gstreamer1.0-libav \
  gstreamer1.0-alsa gstreamer1.0-pulseaudio gstreamer1.0-vaapi \
  ffmpeg libavcodec-extra libavformat-dev libavfilter-dev \
  ubuntu-restricted-extras vlc mpv yt-dlp celluloid \
  pipewire pipewire-pulse wireplumber pipewire-alsa pipewire-jack
```

---

## 12. Shell Theming — Zsh + Powerlevel10k

The same setup applies to both Termux and the Ubuntu chroot.

### Install packages

**Termux:**

```bash
pkg install zsh git curl wget nano vim fzf fd bat eza zoxide fish
```

**Ubuntu chroot:**

```bash
sudo apt install zsh git curl wget fzf zoxide
```

### Oh My Zsh

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

### Plugins

```bash
git clone https://github.com/zsh-users/zsh-autosuggestions \
  ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

git clone https://github.com/zsh-users/zsh-syntax-highlighting \
  ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

git clone https://github.com/zsh-users/zsh-history-substring-search \
  ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-history-substring-search
```

### Powerlevel10k theme

```bash
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
  ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
```

### Set Zsh as default shell

```bash
# Termux
chsh -s zsh

# Ubuntu chroot (run as root)
sudo chsh -s /bin/zsh ochiuom
```

### `.zshrc`

This is the final `.zshrc` for both Termux and the Ubuntu chroot. The `fzf` plugin is disabled in the chroot because fzf keybindings are wired manually instead — avoids sourcing errors.

```zsh
typeset -g POWERLEVEL9K_INSTANT_PROMPT=off

if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
  zsh-history-substring-search
  # fzf   # disabled in chroot; keybindings wired manually below
)

source $ZSH/oh-my-zsh.sh

HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history
setopt HIST_IGNORE_DUPS
setopt SHARE_HISTORY
setopt HIST_IGNORE_SPACE

alias ls='eza --icons'
alias ll='eza -lah --icons'
alias lt='eza --tree --icons'

eval "$(zoxide init zsh)"

export FZF_DEFAULT_OPTS='--height 40% --reverse --border'
bindkey '^R' history-incremental-search-backward

export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
```

In Termux you can keep `fzf` in the plugins list and source `~/.fzf.zsh` instead of the manual bindkey line.

Run `p10k configure` on first launch to set up the prompt interactively.

> **Note:** `eza` is not in Ubuntu 24.04 default repos. Install the binary from [github.com/eza-community/eza/releases](https://github.com/eza-community/eza/releases).

---

## Previous Step

← [flashing-custom-rom.md](./flashing-custom-rom.md) — LineageOS flash and Magisk root
