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
   __ __              __             __
  / // /_ _____  ____/ /__ ____  ___/ /
 / _  / // / _ \/ __/ / _ `/ _ \/ _  / 
/_//_/\_, / .__/_/ /_/\_,_/_//_/\_,_/  
     /___/_/                           
'
}

clear && display_text
printf " \n \n"

###------ Startup ------###

# install script dir
dir="$(dirname "$(realpath "$0")")"
source "$dir/1-global_script.sh"

parent_dir="$(dirname "$dir")"
source "$parent_dir/interaction_fn.sh"

# skip installed cache
cache_dir="$parent_dir/.cache"
installed_cache="$cache_dir/installed_packages"

# log directory
log_dir="$parent_dir/Logs"
log="$log_dir/hyprland-$(date +%d-%m-%y).log"

if [[ -f "$log" ]]; then
    errors=$(grep "ERROR" "$log")
    last_installed=$(grep "hyprsunset" "$log" | awk {'print $2'})
    if [[ -z "$errors" && "$last_installed" == "DONE" ]]; then
        msg skp "Skipping this script. No need to run it again..."
        sleep 1
        exit 0
    fi
else
    mkdir -p "$log_dir"
    touch "$log"
fi

_hypr=(
    hyprland
    hyprlock
    hypridle
    hyprcursor
    hyprsunset
    hyprpolkitagent
    pyprland
)

# checking already installed packages 
for skipable in "${_hypr[@]}"; do
    skip_installed "$skipable"
done

to_install=($(printf "%s\n" "${_hypr[@]}" | grep -vxFf "$installed_cache"))

printf "\n\n"

# Installation of Hyprland basics
for hypr_pkgs in "${to_install[@]}"; do
    install_package "$hypr_pkgs"

    if rpm -q "$hypr_pkgs" &> /dev/null; then
        echo "[ DONE ] - '$hypr_pkgs' was installed successfully!" 2>&1 | tee -a "$log" &> /dev/null
    else
        echo "[ ERROR ] - Sorry, could not install '$hypr_pkgs'" 2>&1 | tee -a "$log" &> /dev/null
    fi
done

sleep 1 && clear
