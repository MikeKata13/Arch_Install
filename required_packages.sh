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
sudo pacman -S firefox alacritty lxappearance gnome-tweaks qtile zsh rofi neofetch 
paru -S brave-bin

#Create a Qtile config file
mkdir ~/.config/qtile
sudo cp usr/share/doc/qtile/default_config.py ~/.config/qtile/config.py
sudo chown mike:root ~/.config/qtile/config.py
