# Ubuntu 24.04 Chroot on Samsung Galaxy Tab S6 (T860) via Termux

Full Ubuntu 24.04 LTS desktop environment running inside a chroot on a rooted Samsung Galaxy Tab S6 (Wi-Fi, SM-T860), accessed via Termux + Termux-X11. Covers everything from rootfs setup to XFCE4 desktop, audio, external SD card access, and shell theming.

---

## Requirements

- Samsung Galaxy Tab S6 SM-T860 (Wi-Fi), rooted via Magisk
- [Termux](https://github.com/termux/termux-app) (from F-Droid, **not** Play Store)
- [Termux-X11](https://github.com/termux/termux-x11) (nightly APK)
- [BuiltIn-BusyBox Magisk module](https://github.com/Magisk-Modules-Alt-Repo/BuiltIn-BusyBox/releases)
- Reference: [LinuxDroidMaster's chroot guide](https://github.com/LinuxDroidMaster/Termux-Desktops/blob/main/Documentation/chroot/ubuntu_chroot.md)

---

## 1. Termux Base Setup

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

Run as root inside Termux:

```bash
su
mkdir -p /data/local/chroot/ubuntu
chmod 755 /data/local/chroot/ubuntu
chown root:root /data/local/chroot/ubuntu
cd /data/local/chroot/ubuntu
```

Download Ubuntu 24.04 LTS ARM64 base:

```bash
curl https://cdimage.ubuntu.com/ubuntu-base/releases/24.04/release/ubuntu-base-24.04.4-base-arm64.tar.gz \
  -o ubuntu.tar.gz
```

Extract and create sdcard mountpoint:

```bash
tar xpvf ubuntu.tar.gz --numeric-owner
mkdir -p sdcard
```

---

## 3. Scripts

### 3.1 Chroot Startup Script (XFCE4 Desktop)

Location: `/data/local/chroot/start_ubuntu_xfce.sh`

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

> **Note:** Replace `B279-3DEA` with your actual external SD card label (check via a file manager like X-plore).  
> Replace `ochiuom` with your preferred username throughout.

---

### 3.2 Chroot Startup Script (Terminal Only)

Location: `/data/local/chroot/start_ubuntu_terminal.sh`

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

---

### 3.3 Termux Launcher Script (XFCE4)

Download the base script and modify:

```bash
wget https://raw.githubusercontent.com/LinuxDroidMaster/Termux-Desktops/refs/heads/main/scripts/chroot/ubuntu/startxfce4_chrootubuntu.sh
nano startxfce4_chrootubuntu.sh
```

Final content:

```bash
#!/bin/bash

pkill -9 -f com.termux.x11
killall -9 termux-x11 Xwayland pulseaudio virgl_test_server_android termux-wake-lock

am start --user 0 -n com.termux.x11/com.termux.x11.MainActivity

su -c "mkdir -p /data/local/chroot/ubuntu/tmp"
su -c "busybox mount -t tmpfs -o size=64M tmpfs /data/local/chroot/ubuntu/tmp"
su -c "chmod 1777 /data/local/chroot/ubuntu/tmp"

XDG_RUNTIME_DIR=${TMPDIR} termux-x11 :0 -ac &

sleep 3

su -c "mkdir -p /data/local/chroot/ubuntu/tmp/.X11-unix"
su -c "busybox mount --bind $TMPDIR/.X11-unix /data/local/chroot/ubuntu/tmp/.X11-unix"

pulseaudio --start \
  --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" \
  --exit-idle-time=-1
pacmd load-module module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1

su -c "sh /data/local/chroot/start_ubuntu_xfce.sh"
```

```bash
chmod +x startxfce4_chrootubuntu.sh
```

---

### 3.4 Termux Launcher Script (Terminal)

Location: `~/start_terminal.sh`

```bash
nano ~/start_terminal.sh
```

```bash
#!/bin/bash
su -c "sh /data/local/chroot/start_ubuntu_terminal.sh"
```

```bash
chmod +x ~/start_terminal.sh
```

Usage:

```bash
./start_terminal.sh
```

Inside the chroot:

```bash
cd /sdcard      # internal storage
cd /sdcard_ext  # external SD card
```

---

## 4. Ubuntu Chroot Initial Configuration

After first entering the chroot (initially as root):

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

echo 'export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin' >> /etc/profile
```

---

## 5. Create User

```bash
groupadd storage
groupadd wheel
useradd -m -g users -G wheel,audio,video,storage,aid_inet -s /bin/bash ochiuom
passwd ochiuom
```

Add to sudoers:

```bash
echo "ochiuom ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/ochiuom
chmod 440 /etc/sudoers.d/ochiuom
```

Switch to user and set locale:

```bash
su - ochiuom
sudo apt install locales
sudo locale-gen en_US.UTF-8
```

---

## 6. Install XFCE4 Desktop

```bash
sudo apt install xubuntu-desktop
```

Disable snapd (non-functional in chroot):

```bash
sudo apt-get autopurge snapd

cat <<EOF | sudo tee /etc/apt/preferences.d/nosnap.pref
Package: snapd
Pin: release a=*
Pin-Priority: -10
EOF
```

---

## 7. External SD Card Access

Add the user to `media_rw` group from Termux:

```bash
su -c "busybox chroot /data/local/chroot/ubuntu /bin/bash -c \
  'groupadd -g 1023 media_rw && usermod -aG media_rw ochiuom'"

su -c "chmod 777 /data/local/chroot/ubuntu/sdcard_ext"
```

---

## 8. Media Packages

Inside the chroot:

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

## 9. Shell Theming (Zsh + Powerlevel10k)

Applies to both Termux and the Ubuntu chroot.

### Install packages

**Termux:**
```bash
pkg install zsh git curl wget fzf fd bat eza zoxide fish
```

**Ubuntu chroot:**
```bash
sudo apt install zsh git curl wget fzf zoxide
```

### Oh My Zsh + Plugins

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

git clone https://github.com/zsh-users/zsh-autosuggestions \
  ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

git clone https://github.com/zsh-users/zsh-syntax-highlighting \
  ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

git clone https://github.com/zsh-users/zsh-history-substring-search \
  ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-history-substring-search

git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
  ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
```

Set as default shell:

```bash
chsh -s zsh
# or, inside chroot as root:
sudo chsh -s /bin/zsh ochiuom
```

### `.zshrc`

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

Run `p10k configure` after first launch to set up the prompt interactively.

---

## Notes

- The Termux-X11 APK must be installed and opened at least once before running the launcher script.
- After running the XFCE4 launcher, the desktop appears inside Termux-X11, not as a separate Android window.
- PulseAudio is bridged over TCP; audio works in both VLC and MPV inside the chroot.
- `eza` is not in Ubuntu 24.04's default repos — install via the [official binary](https://github.com/eza-community/eza/releases) or a PPA if using it inside the chroot.
