#!/bin/bash

# Enable verbose mode for easier debugging
set -e

# Check if the script is running with root privileges
if [[ "$(id -u)" -ne 0 ]]; then
	echo "This script must be run as root. Exiting..."
	exit 1
fi

# Define the package files and dotfiles folder
PACKAGE_FILE="packages.txt"
FLATPAK_FILE="flatpak.txt"
DOTFILES_DIR="dotfiles"
WALLPAPER_DIR="Wallpapers"
THEMES_DIR=".themes"
ICONS_DIR=".icons"
ZSHRC_FILE=".zshrc"

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
pacman -Syu --noconfirm

# Check if yay is installed, and if not, install it
if ! command -v yay &>/dev/null; then
	echo "Installing yay..."
	pacman -S --noconfirm --needed base-devel git
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
	pacman -S --noconfirm flatpak
	echo "Setting up Flatpak..."
	flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
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

# Install Oh-My-Zsh before copying .zshrc
if ! command -v zsh &>/dev/null; then
	echo "Installing Zsh..."
	pacman -S --noconfirm zsh
fi

if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
	echo "Installing Oh-My-Zsh..."
	sh -c "$(wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"
fi

# Copy .zshrc to home directory, overwriting if necessary
if [[ -f "$DOTFILES_DIR/$ZSHRC_FILE" ]]; then
	echo "Copying $ZSHRC_FILE to home directory..."
	cp "$DOTFILES_DIR/$ZSHRC_FILE" "$HOME/"
fi

# Install Nerd Fonts
echo "Installing Nerd Fonts..."
mkdir -p "$HOME/.local/share/fonts"
git clone --depth 1 https://github.com/ryanoasis/nerd-fonts.git
cd nerd-fonts
./install.sh
rm -rf nerd-fonts

# Copy dotfiles to .config, overwriting any existing files
echo "Copying dotfiles to ~/.config (overwriting existing files)..."
rsync -a --delete "$DOTFILES_DIR/" ~/.config/

# Modify /etc/environment to add a new line
echo "Modifying /etc/environment to set PROTON_ENABLE_NVAPI=1..."
if ! grep -q "PROTON_ENABLE_NVAPI=1" /etc/environment; then
	echo "PROTON_ENABLE_NVAPI=1" >>/etc/environment
fi

echo "Dotfiles copied successfully!"
echo "All packages (including Flatpak) installed, directories created, Nerd Fonts installed, configurations applied, and /etc/environment updated!"