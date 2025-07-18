#!/bin/bash

#### Advanced Hyprland Installation Script by ####
#### Shell Ninja ( https://github.com/shell-ninja ) ####

# color defination
red="\e[1;31m"
green="\e[1;32m"
yellow="\e[1;33m"
blue="\e[1;34m"
magenta="\e[1;1;35m"
cyan="\e[1;36m"
orange="\e[1;38;5;214m"
end="\e[1;0m"

display_text() {
    gum style \
        --border rounded \
        --align center \
        --width 60 \
        --margin "1" \
        --padding "1" \
'
   _______  ___  __  ___  ________                
  / __/ _ \/ _ \/  |/  / /_  __/ /  ___ __ _  ___ 
 _\ \/ // / // / /|_/ /   / / / _ \/ -_)  ; \/ -_)
/___/____/____/_/  /_/   /_/ /_//_/\__/_/_/_/\__/ 
                                                   
'
}

clear && display_text
printf " \n \n"

###------ Startup ------###

# finding the presend directory and log file
# install script dir
dir="$(dirname "$(realpath "$0")")"

# log directory
parent_dir="$(dirname "$dir")"
source "$parent_dir/interaction_fn.sh"

log_dir="$parent_dir/Logs"
log="$log_dir/sddm_theme-$(date +%d-%m-%y).log"
mkdir -p "$log_dir"
touch "$log"

# Install THEME
theme="$parent_dir/.cache/SilentSDDM"
theme_dir=/usr/share/sddm/themes

# creating sddm theme dir
[ ! -d "$theme_dir" ] && sudo mkdir -p "$theme_dir"

msg act "Clonning sddm theme..."
git clone --depth=1 https://github.com/shell-ninja/SilentSDDM.git "$parent_dir/.cache/SilentSDDM" &> /dev/null

# Set up SDDM
msg act "Setting up the Login Screen..."
sddm_conf_dir=/etc/sddm.conf.d
[ ! -d "$sddm_conf_dir" ] &&  sudo mkdir -p "$sddm_conf_dir"

sudo mv "$theme" "$theme_dir/"

mkdir -p ~/.local/share/fonts/sddm-fonts
sudo mv /usr/share/sddm/themes/SilentSDDM/fonts/* ~/.local/share/fonts/sddm-fonts/
echo -e "[Theme]\nCurrent=SilentSDDM" | sudo tee "$sddm_conf_dir/theme.conf.user" &> /dev/null
echo -e "[General]\nInputMethod=qtvirtualkeyboard" | sudo tee "$sddm_conf_dir/virtualkbd.conf" &> /dev/null

if [ -d "$theme_dir/SilentSDDM" ]; then
    msg dn "Sddm theme was installed successfully!"
fi

sleep 1 && clear
