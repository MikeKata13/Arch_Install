#!/bin/bash

# Enable verbose mode for easier debugging
set -e

# Define the package files and dotfiles folder
PACKAGE_FILE="packages.txt"
FLATPAK_FILE="flatpaks.txt"
DOTFILES_DIR="dotfiles"
WALLPAPER_DIR="Wallpapers"
THEMES_DIR=".themes"
ICONS_DIR=".icons"
ZSHENV_FILE=".zshenv"
XPROFILE_FILE=".xprofile"

# Define user directories
USER_DIRS=("Documents" "Pictures" "Music" "Downloads" "Videos")

# Check if the package file exists
if [[ ! -f "$PACKAGE_FILE" ]]; then
  echo "Error: $PACKAGE_FILE not found!"
  exit 1
fi

# Check if the flatpak file exists
if [[ ! -f "$FLATPAK_FILE" ]]; then
  echo "Error: $FLATPAK_FILE not found!"
  exit 1
fi

# Check if the dotfiles directory exists
if [[ ! -d "$DOTFILES_DIR" ]]; then
  echo "Error: $DOTFILES_DIR not found!"
  exit 1
fi

# Update the package database and upgrade the system
echo "Updating system..."
sudo pacman -Syu --noconfirm

# Check if yay is installed, and if not, install it
if ! command -v yay &>/dev/null; then
  echo "Installing yay..."
  sudo pacman -S --noconfirm --needed base-devel git
  git clone https://aur.archlinux.org/yay.git
  cd yay
  makepkg -si --noconfirm
  cd ..
  rm -rf yay
fi

# Install packages using yay (both AUR and official repos)
echo "Installing packages from $PACKAGE_FILE..."
yay -S --needed --noconfirm - <"$PACKAGE_FILE"

# Install Flatpak packages if flatpak is installed
if ! command -v flatpak &>/dev/null; then
  echo "Installing Flatpak..."
  sudo pacman -S --noconfirm flatpak
  echo "Setting up Flatpak..."
  sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
fi

echo "Installing Flatpak apps from $FLATPAK_FILE..."
while IFS= read -r app || [[ -n "$app" ]]; do
  if [[ ! -z "$app" && ! "$app" =~ ^# ]]; then
    echo "Installing Flatpak: $app"
    flatpak install flathub "$app" -y
  fi
done <"$FLATPAK_FILE"

# Create user directories if they don't exist
echo "Creating user directories..."
for dir in "${USER_DIRS[@]}"; do
  mkdir -p "$HOME/$dir"
  echo "Ensured directory $HOME/$dir exists"
done

# Copy Wallpapers folder to ~/Pictures
if [[ -d "$WALLPAPER_DIR" ]]; then
  echo "Copying Wallpapers folder to ~/Pictures..."
  cp -r "$WALLPAPER_DIR" "$HOME/Pictures/"
  echo "Wallpapers copied to ~/Pictures."
else
  echo "Warning: $WALLPAPER_DIR not found!"
fi

# Copy .themes and .icons to home directory, overwriting if necessary
if [[ -d "$THEMES_DIR" ]]; then
  echo "Copying $THEMES_DIR to home directory..."
  cp -r "$THEMES_DIR" "$HOME/"
fi

if [[ -d "$ICONS_DIR" ]]; then
  echo "Copying $ICONS_DIR to home directory..."
  cp -r "$ICONS_DIR" "$HOME/"
fi

# Copy dotfiles to ~/.config, overwriting existing files
echo "Copying dotfiles to ~/.config (overwriting existing files)..."
rsync -a --delete "$DOTFILES_DIR/" "$HOME/.config/"
echo "Dotfiles copied successfully!"

# Install Oh-My-Zsh before copying .zshrc
if ! command -v zsh &>/dev/null; then
  echo "Installing Zsh..."
  sudo pacman -S --noconfirm zsh
fi

#if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
#  echo "Installing Oh-My-Zsh..."
#  sh -c "$(wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"
#fi

# Copy .zshenv to home directory, overwriting if necessary (this points to custom zsh folder in dotfiles, where .zshrc is found)
if [[ -f "$ZSHENV_FILE" ]]; then
  echo "Copying $ZSHENV_FILE to home directory..."
  cp "$ZSHENV_FILE" "$HOME/"
fi

# Copy .xprofile to home directory, overwriting if necessary
if [[ -f "$XPROFILE_FILE" ]]; then
  echo "Copying $XPROFILE_FILE to home directory..."
  cp "$XPROFILE_FILE" "$HOME/"
fi

# Modify /etc/environment to add a new line
echo "Modifying /etc/environment to set PROTON_ENABLE_NVAPI=1..."
if ! grep -q "PROTON_ENABLE_NVAPI=1" /etc/environment; then
  echo "PROTON_ENABLE_NVAPI=1" | sudo tee -a /etc/environment
fi

# Enable gdm service
echo "Enabling gdm service..."
sudo systemctl enable gdm.service

# Install Nerd Fonts
echo "Installing Nerd Fonts..."
mkdir -p "$HOME/.local/share/fonts"
git clone --depth 1 https://github.com/ryanoasis/nerd-fonts.git
cd nerd-fonts
./install.sh
rm -rf nerd-fonts

echo "All packages (including Flatpak) installed, directories created, configurations applied, /etc/environment updated, and Nerd Fonts installed!"
