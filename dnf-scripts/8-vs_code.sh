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
        --width 40 \
        --margin "1" \
        --padding "1" \
'
 _   __        _____        __   
| | / /__     / ___/__  ___/ /__ 
| |/ (_-<_   / /__/ _ \/ _  / -_)
|___/___(_)  \___/\___/\_,_/\__/ 
                                 
'
}

clear && display_text
printf " \n \n"

###------ Startup ------###

# install script dir
dir="$(dirname "$(realpath "$0")")"
source "$dir/1-global_script.sh"

# present dir
parent_dir="$(dirname "$dir")"
source "$parent_dir/interaction_fn.sh"

# skip installed cache
cache_dir="$parent_dir/.cache"
installed_cache="$cache_dir/installed_packages"

# log dir
log_dir="$parent_dir/Logs"
log="$log_dir/vs_code-$(date +%d-%m-%y).log"

if [[ -f "$log" ]]; then
    errors=$(grep "ERROR" "$log")
    if [[ -z "$errors" ]]; then
        msg skp "Skipping this script. No need to run it again..."
        sleep 1
        exit 0
    fi
else
    mkdir -p "$log_dir"
    touch "$log"
fi

# checking if vs code is installed
if rpm -q code &> /dev/null; then
    msg skp "Skipping installing Visual Studio Code. It's already installed."
# insalling vs code
else
    msg act "Installing Visual Studio Code..."

    # adding vs code repo
    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc 2>&1 | tee -a "$log" &>> /dev/null
    sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo' 2>&1 | tee -a "$log" &>> /dev/null
    sudo dnf install code -y 2>&1 | tee -a "$log"

    if rpm -q code &> /dev/null; then
        msg dn "Visual Studio Code was installed successfully..." 2>&1 | tee -a >(sed 's/\x1B\[[0-9;]*[JKmsu]//g' >> "$log")

        common_scripts="$parent_dir/common"
        "$common_scripts/vs_code_theme.sh"
    else
        msg err "Could not installed Visual Studio Code.." 2>&1 | tee -a >(sed 's/\x1B\[[0-9;]*[JKmsu]//g' >> "$log")
    fi
fi

sleep 1 && clear
