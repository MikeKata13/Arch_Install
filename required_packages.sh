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
sudo pacman -S vim nano xorg-server pulseaudio xfce4 firefox alacritty lxappearance nitrogen picom qtile zsh rofi neofetch nemo libreoffice-fresh vlc code
sddm python-psutil papirus-icon-theme geany
paru -S brave-bin spotify nordic-theme flat-remix

#Enable Display Manager
sudo systemctl enable sddm

#Create a Qtile config file
mkdir ~/.config/qtile
#Here clone and copy your custom qtile configuration
sudo cp /usr/share/doc/qtile/default_config.py ~/.config/qtile/config.py
sudo chown mike:root ~/.config/qtile/config.py
git clone https://github.com/MikeKata13/Qtile.git
cd Qtile
cp config.py ~/.config/qtile/config.py


#Create a picom configurration file
sudo cp /etc/xdg/picom.conf ~/.config/

sudo vim ~/.xprofile


#Finish
echo "Script Completed Successfully"
