#!/usr/bin/env bash

# Fedora Post-Install Setup Script
# For Fedora KDE VM or Bare Metal
# Last Updated: 2025-07-22

set -e

echo "Starting Fedora post-install setup..."

### --- Core System Update ---
echo "Updating system packages..."
sudo dnf update -y

### --- Basic Utilities ---
echo "Installing basic utilities..."
sudo dnf install -y neofetch fastfetch tree curl wget git htop gnome-disk-utility kate

### --- Set System Info ---
echo "Setting hostname and timezone..."
sudo hostnamectl set-hostname fedora-vm
sudo timedatectl set-timezone America/Chicago

### --- RPM Fusion (Free + Non-Free) ---
echo "Adding RPM Fusion repositories..."
sudo dnf install -y \
  https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
  https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

### --- Gaming Setup (Optional) ---
echo "Installing Steam..."
sudo dnf install -y steam

### --- ExpressVPN Setup (Manual Step) ---
echo "NOTE: Download ExpressVPN RPM from:"
echo "  https://www.expressvpn.com/latest2#linux"
echo "Then run: sudo dnf install ./expressvpn-*.rpm && expressvpn activate"

### --- Security: Firewall & Firejail ---
echo "Enabling firewall..."
sudo systemctl enable --now firewalld
sudo firewall-cmd --permanent --add-service=ssh
sudo firewall-cmd --reload

echo "Installing Firejail sandboxing..."
sudo dnf install -y firejail

### --- Snapper + Btrfs Setup ---
echo "Installing Snapper..."
sudo dnf install -y snapper snapper-zypp-plugin grubby

echo "Creating root snapper config..."
sudo snapper -c root create-config /

echo "Enabling timeline and cleanup timers..."
sudo systemctl enable --now snapper-timeline.timer
sudo systemctl enable --now snapper-cleanup.timer

echo "Updating GRUB kernel args for snapshot booting..."
sudo grubby --update-kernel=ALL --args="rd.snapshot"

### --- Helper Tools ---
echo "Installing power user CLI tools..."
sudo dnf install -y \
  ncdu \
  bat \
  fzf \
  ripgrep \
  lsd \
  btop \
  ranger

### --- Dev Tools ---
echo "Installing development tools..."
sudo dnf groupinstall -y "Development Tools"
sudo dnf install -y gcc g++ make cmake python3 python3-pip

### --- GUI Helper Tools ---
echo "Installing GUI utilities for KDE..."
sudo dnf install -y \
  gparted \
  ksystemlog \
  filelight

### --- Flatpak Support ---
echo "Enabling Flatpak + Flathub..."
sudo dnf install -y flatpak
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

### --- Fonts ---
echo "Installing developer-friendly fonts..."
sudo dnf install -y google-roboto-fonts fira-code-fonts

### --- Bash Customization (Optional) ---
echo "Customizing .bashrc aliases..."
cat << 'EOF' >> ~/.bashrc

# Custom Aliases
alias ll='ls -alF'
alias ff='fastfetch'
alias cls='clear'
alias please='sudo'
alias grep='rg'
alias ls='lsd'
alias top='btop'
alias find='fzf'
alias usage='ncdu'
alias edit='kate'
EOF

echo "Setup complete. You may want to reboot now."
