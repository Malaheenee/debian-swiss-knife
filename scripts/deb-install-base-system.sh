#!/bin/bash

# This script installs all basic packages

# Common vars
ROOT_UID=0
E_NOTROOT=101

# APT vars
APT_PROGRAM="apt-get"
APT_COMMAND="install"
APT_OPTIONS="-qqys"
APT_PACKAGES=""
APT_SOURCES_FILE="/etc/apt/sources.list"

# Verify user uid
runs_as_root() {
    if [ ${UID} -ne ${ROOT_UID} ]; then
        echo -e '\n\E[37;41m'"\033[1mYou are not root\033[0m\n"
        tput sgr0
        sleep 1
        exit ${E_NOTROOT}
    fi
}

# Update packages list
is_apt_configured() {
    local APT_COMMAND="update"
    local APT_OPTIONS="-s"

    if [ -e ${APT_SOURCES_FILE} ]; then
        if [ -n "$(grep -oE "^deb\W*(h|f)tt?p.*main\W*contrib\W*non-free$" ${APT_SOURCES_FILE})" ]; then
            echo -n "Updating packages list... "
            eval ${APT_PROGRAM} ${APT_COMMAND} ${APT_OPTIONS}
            echo "Done."
            return 0  
        else
            return 1
        fi
    else
        echo "File ${APT_SOURCES_FILE} missing: installaton aborted"
        return 1
    fi
}

# Select packages for installation
user_selection() {
    local response

    read -p "What you want to install: [b]ase system, [f]onts, [a]all (default \"a\"): " $response
    case ${response} in
        [a]* ) return 0 ;;
        [b]* ) return 1 ;;
        [f]* ) return 2 ;;
        * ) return 0 ;;
    esac
}

# Set variables for basic system installation
install_base() {
    APT_PACKAGES+=" bash-completion alsa-utils dbus ntfs-3g \
dosfstools mtools mlocate intel-microcode bzip2 zip unzip p7zip-full \
xz-utils libiso9660-8 unrar policykit-1 acpi-support"
}

# Set variables for fonts installation
install_fonts() {
    APT_PACKAGES+=" fonts-dejavu-core fonts-dejavu-extra fonts-droid \
fonts-liberation fonts-freefont-ttf fonts-croscore fonts-linuxlibertine \
ttf-mscorefonts-installer"
}

# Install packages
proceed_to_install() {
    local response
    
    case ${1} in
        [0]* ) install_base; install_fonts ;;
        [1]* ) install_base ;;
        [2]* ) install_fonts ;;
        * ) echo "Something wrong: installaton aborted."; exit 1;;
    esac

    read -p "You proceed to install ... packages. Do you want to continue? [Y]es, [No] (default \"y\"): " $response
    case ${response} in
        [Yy]* ) ;;
        [Nn]* ) echo "Installaton aborted by user."; exit 1 ;;
    esac

    is_apt_configured
    case ${?} in
        [0]* ) echo -n "Installation of packages... ";
               eval ${APT_PROGRAM} ${APT_COMMAND} ${APT_OPTIONS} ${APT_PACKAGES};
               echo "Done." ;;
        [1]* ) echo "You need to configure apt first." ;;
    esac

    exit 0
}

# Run this script
runs_as_root
user_selection
proceed_to_install ${?}



    
