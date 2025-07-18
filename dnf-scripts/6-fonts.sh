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
   ____          __    
  / __/__  ___  / /____
 / _// _ \/ _ \/ __(_-<
/_/  \___/_//_/\__/___/
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
log="$log_dir/fonts-$(date +%d-%m-%y).log"

if [[ -f "$log" ]]; then
    errors=$(grep "ERROR" "$log")
    last_installed=$(grep "jetbrains-mono-fonts" "$log" | awk {'print $2'})
    if [[ -z "$errors" && "$last_installed" == "DONE" ]]; then
        msg skp "Skipping this script. No need to run it again..."
        sleep 1
        exit 0
    fi
else
    mkdir -p "$log_dir"
    touch "$log"
fi

# installable fonts will be here
fonts=(
    fontawesome-fonts-all
    google-noto-sans-cjk-fonts
    google-noto-color-emoji-fonts
    google-noto-emoji-fonts
    jetbrains-mono-fonts
)

# checking already installed packages 
for skipable in "${fonts[@]}"; do
    skip_installed "$skipable"
done

to_install=($(printf "%s\n" "${fonts[@]}" | grep -vxFf "$installed_cache"))

printf "\n\n"

for font in "${to_install[@]}"; do
  install_package "$font"

    if rpm -q "$font" &> /dev/null; then
        echo " [ DONE ] - $font was installed successfully!" 2>&1 | tee -a "$log" &> /dev/null
    else
        echo "[ ERROR ] - Sorry, could not install $font" 2>&1 | tee -a "$log" &> /dev/null
    fi
done

if [ ! -d ~/.local/share/fonts/JetBrainsMonoNerd ]; then
    DOWNLOAD_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz"
    # Maximum number of download attempts
    MAX_ATTEMPTS=2
    for ((ATTEMPT = 1; ATTEMPT <= MAX_ATTEMPTS; ATTEMPT++)); do
        curl -OL "$DOWNLOAD_URL" && break
        msg att "Download attempt $ATTEMPT failed. Retrying in 2 seconds..."
        sleep 2
    done
    mkdir -p ~/.local/share/fonts/JetBrainsMonoNerd
    # Extract the new files into the JetBrainsMono folder and log the output
    tar -xJkf JetBrainsMono.tar.xz -C ~/.local/share/fonts/JetBrainsMonoNerd
else 
    msg skp "Skipping installing JetBrainsMonoNerd, font was already there..."
fi


# Update font cache and log the output
sudo fc-cache -fv &> /dev/null

# clean up 
if [ -d "JetBrainsMono.tar.xz" ]; then
	rm -rf JetBrainsMono.tar.xz
fi

sleep 1 && clear
