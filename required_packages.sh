#!/bin/bash

#Get SuperUser rights
yes | sudo pacman -Syu

#Install paru
yes | sudo pacman -S git wget
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si
yes | paru -Syu

#Install needed packages
sudo pacman -S xorg-server pulseaudio xfce4 xfce4-goodies firefox alacritty lxappearance gnome-tweaks qtile zsh rofi neofetch nemo libreoffice-fresh vlc code

paru -S brave-bin spotify


#Create a Qtile config file
mkdir ~/.config/qtile
#Here clone and copy your custom qtile configuration
sudo cp usr/share/doc/qtile/default_config.py ~/.config/qtile/config.py
sudo chown mike:root ~/.config/qtile/config.py

#Finish
echo "Script Completed Successfully"
