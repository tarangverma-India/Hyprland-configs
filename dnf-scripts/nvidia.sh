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
        --width 40 \
        --margin "1" \
        --padding "1" \
'
   _  __     _    ___     
  / |/ /  __(_)__/ (_)__ _
 /    / |/ / / _  / / _ `/
/_/|_/|___/_/\_,_/_/\_,_/   

'
}

clear && display_text
printf " \n \n"

###------ Startup ------###

# install script dir
dir="$(dirname "$(realpath "$0")")"
source "$dir/1-global_script.sh"

# log directory
parent_dir="$(dirname "$dir")"
source "$parent_dir/interaction_fn.sh"

# skip installed cache
cache_dir="$parent_dir/.cache"
installed_cache="$cache_dir/installed_packages"

# log dir
log_dir="$parent_dir/Logs"
log="$log_dir/nvidia-$(date +%d-%m-%y).log"

mkdir -p "$log_dir"
touch "$log"

nvidia_pkg=(
  akmod-nvidia
  xorg-x11-drv-nvidia-cuda
  libva
  libva-nvidia-driver
)


# checking already installed packages 
for skipable in "${nvidia_pkg[@]}"; do
    skip_installed "$skipable"
done

to_install=($(printf "%s\n" "${nvidia_pkg[@]}" | grep -vxFf "$installed_cache"))

printf "\n\n"

# installing nvidia packages
for __nvidia in "${to_install[@]}"; do
    install_package "$__nvidia"
    if rpm -q "$__nvidia" &>/dev/null; then
        echo "[ DONE ] - $__nvidia was installed successfully!\n" 2>&1 | tee -a "$log" &>/dev/null
    else
        echo "[ ERROR ] - Sorry, could not install $__nvidia!\n" 2>&1 | tee -a "$log" &>/dev/null
    fi
done

# Additional options to add to GRUB_CMDLINE_LINUX
additional_options="rd.driver.blacklist=nouveau modprobe.blacklist=nouveau nvidia-drm.modeset=1"

# Check if additional options are already present in GRUB_CMDLINE_LINUX
if grep -q "GRUB_CMDLINE_LINUX.*$additional_options" /etc/default/grub; then
	msg skp "GRUB_CMDLINE_LINUX already contains the additional options" 2>&1 | tee -a "$log"
else
	# Append the additional options to GRUB_CMDLINE_LINUX
	sudo sed -i "s/GRUB_CMDLINE_LINUX=\"/GRUB_CMDLINE_LINUX=\"$additional_options /" /etc/default/grub
    msg dn "Added the additional options to GRUB_CMDLINE_LINUX" 2>&1 | tee -a "$log"
fi

# Update GRUB configuration
sudo grub2-mkconfig -o /boot/grub2/grub.cfg

msg dn "Nvidia DRM modeset and additional options have been added to /etc/default/grub. Please reboot for changes to take effect." 2>&1 | tee -a "$log"

clear
