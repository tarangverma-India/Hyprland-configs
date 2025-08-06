#!/bin/bash

#WavesOS

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
   ___  __         __            __  __ 
  / _ )/ /_ _____ / /____  ___  / /_/ / 
 / _  / / // / -_) __/ _ \/ _ \/ __/ _ \
/____/_/\_,_/\__/\__/\___/\___/\__/_//_/
                                          
'
}

clear && display_text
printf " \n \n"

###------ Startup ------###

# install script dir
dir="$(dirname "$(realpath "$0")")"
parent_dir="$(dirname "$dir")"
source "$parent_dir/interaction_fn.sh"

cache_dir="$parent_dir/.cache"
pkgman_cache="$cache_dir/pkgman"
source "$pkgman_cache"

# install script dir
source "$parent_dir/${pkgman}-scripts/1-global_script.sh"

# log dir
log_dir="$parent_dir/Logs"
log="$log_dir/bluetooth-$(date +%d-%m-%y).log"
mkdir -p "$log_dir"
touch "$log"

if [[ "$pkgman" == "pacman" ]]; then
  bluetooth=(
    bluez
    bluez-utils
    blueman
  )
elif [[ "$pkgman" == "dnf" ]]; then
  bluetooth=(
    bluez
    bluez-tools
    blueman
    python3-cairo
  )
elif [[ "$pkgman" == "zypper" ]]; then
  bluetooth=(
    bluez
    blueman
  )

# Bluetooth

msg act "Installing Bluetooth Packages..."
 for bluetooth_pkgs in "${bluetooth[@]}"; do
   install_package "$bluetooth_pkgs"
  done

msg act "Activating Bluetooth Services..."
sudo systemctl enable --now bluetooth.service 2>&1 | tee -a "$log"

clear
