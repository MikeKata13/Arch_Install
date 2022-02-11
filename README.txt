#Create an .xprofile to put configuration calls
sudo vim ~/.xprofile
    setxkbmap -layout us,gr -option grp:alt_shift_toggle
    xset r rate 200 50
    nitrogen --restore
    picom -f &
#Set a directory for the nitrogen wallpaper

#Set opacity for alacritty (in a vm you may need to disable v-sync in picom.conf for it to work)
#In ~/.config/picom/picom.conf add:
opacity-rule = [ "80:class_g = 'Alacritty'" ] ,
