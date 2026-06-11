#!/bin/bash

set -ouex pipefail

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/43/x86_64/repoview/index.html&protocol=https&redirect=1

# this installs a package from fedora repos
dnf5 install -y \
    freeipmi \
    glmark2 \
    intel-gpu-tools \
    ipmitool \
    vkmark \
    tmux 

# Use a COPR Example:
#
# dnf5 -y copr enable ublue-os/staging
# dnf5 -y install package
# Disable COPRs so they don't end up enabled on the final image:
# dnf5 -y copr disable ublue-os/staging

### Add Flathub and install Flatpaks
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

flatpak install -y --noninteractive --system flathub \
    io.github.ilya_zlobintsev.LACT \
    io.missioncenter.MissionCenter

#### Example for enabling a System Unit File

systemctl enable podman.socket

### Copy custom system files
cp -a /ctx/system_files/. /

### Fix NetworkManager connection permissions
if [ -d /etc/NetworkManager/system-connections ]; then
    chmod 700 /etc/NetworkManager/system-connections
    chmod 600 /etc/NetworkManager/system-connections/*.nmconnection
    chown root:root /etc/NetworkManager/system-connections/*.nmconnection
fi

chmod +x /usr/libexec/lvs/lvs-firstboot-setup
systemctl enable lvs-firstboot-setup.service

### Disable KDE first-login setup wizard
systemctl disable plasma-setup.service || true
rm -f /etc/systemd/system/multi-user.target.wants/plasma-setup.service || true

### Disable Steam autostart
rm -f /etc/xdg/autostart/steam.desktop
rm -f /etc/skel/.config/autostart/steam.desktop

### Autorun update script at login
chmod +x /usr/libexec/lvs/lvs-login-preflight
