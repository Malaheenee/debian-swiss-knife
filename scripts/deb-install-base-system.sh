#!/bin/bash

# This script installs Install all basic and GUI packages (XFCE, GNOME, KDE)
# without annoying dependencies;

# Common vars
ROOT_UID=0
E_NOTROOT=101

# APT vars
APT_PROGRAM="apt-get"
APT_COMMAND="install"
APT_OPTIONS="-qqy"
APT_PACKAGES=""
APT_SOURCES_FILE="/etc/apt/sources.list"
PKG_SELECT=""

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
    local APT_OPTIONS="-qq"

    if [ -e ${APT_SOURCES_FILE} ]; then
        if [ -n "$(grep -oE "^deb\W*(h|f)tt?p.*main\W*contrib\W*non-free$" ${APT_SOURCES_FILE})" ]; then
            echo -n "Updating packages list... "
            eval ${APT_PROGRAM} ${APT_COMMAND} ${APT_OPTIONS}
            echo "Done."
            return 0
        else
            echo "You need to configure apt first."
            exit 1
        fi
    else
        echo "File ${APT_SOURCES_FILE} missing: installaton aborted."
        exit 1
    fi
}

# Select packages for installation
user_selection() {
    read -p "What you want to install first: [b]ase system, [k]de, [x]fce, [m]ixed (default \"mixed\"): " response
    case ${response} in
        B|b ) PKG_SELECT+="base" ;;
        K|k ) PKG_SELECT+="base kde" ;;
        M|m|"" ) PKG_SELECT+="base mixed" ;;
        X|x ) PKG_SELECT+="base xfce" ;;
        [^BbKkMmXx]* ) echo "Wrong selection. Aborted."; exit 1 ;;
    esac

    if [[ ${PKG_SELECT} =~ "kde" ]]; then
        read -p "What display manager you want to use: [l]ightdm or [k]dm, (default \"lightdm\"): " response
        case ${response} in
            K|k* ) PKG_SELECT+=" kdm" ;;
            L|l*|"" ) PKG_SELECT+=" lightdm" ;;
            [^KkLl]* ) echo "Wrong selection. Aborted."; exit 1 ;;
        esac
    elif [[ ${PKG_SELECT} =~ xfce|mixed ]]; then
        PKG_SELECT+=" lightdm"
    fi
    set_pkgs_list ${PKG_SELECT}
}

# Set list of needed packages
set_pkgs_list() {
    if [ ${1} == "base" ]; then
        APT_PACKAGES+=" bash-completion alsa-utils dbus ntfs-3g \
        dosfstools mtools mlocate intel-microcode bzip2 zip unzip p7zip-full \
        xz-utils libiso9660-8 unrar policykit-1 acpi-support"
    fi
    
    if [ -n "${2}" ]; then
        APT_PACKAGES+=" xfonts-base xfonts-scalable xserver-common xinit \
        xserver-xorg-video-fbdev xserver-xorg-video-vesa \
        xserver-xorg-input-evdev libnotify-bin xdg-utils xdg-user-dirs \
        cups-bsd lsb-release tango-icon-theme dmz-cursor-theme"

        case ${2} in
            xfce ) 
                APT_PACKAGES+=" xfce4-panel xfwm4 xfce4-settings xfce4-session \
                xfdesktop4 xfconf xfce4-notifyd ristretto tumbler xarchiver \
                mousepad xfce4-mixer xfce4-volumed thunar thunar-volman \
                thunar-archive-plugin xfce4-xkb-plugin xfce4-screenshooter \
                xfce4-power-manager gtk2-engines-xfce gtk3-engines-xfce \
                xfce4-terminal xfwm4-themes orage xfce4-appfinder xfce4-places-plugin \
                xfce4-weather-plugin libxfce4ui-utils galculator"
            ;;
            kde ) 
                APT_PACKAGES+=" dolphin kde-l10n-ru kde-window-manager \
                kde-baseapps-bin kde-workspace-bin polkit-kde-1 oxygencursors \
                oxygen-icon-theme plasma-widgets-workspace plasma-containments-addons \
                libkdesu5 kdesudo kde-runtime gwenview systemsettings konsole \
                kate kmix ark kwalletmanager kfind phonon-backend-gstreamer \
                ksysguard ksnapshot akonadi-backend-sqlite sqlite3 kcalc"
            ;;
            mixed ) 
                APT_PACKAGES+=" openbox hsetroot gmrun gsimplecal arandr \
                notification-daemon tint2 gxkb volumeicon-alsa compton spacefm \
                udevil lilyterm viewnior xarchiver galculator geany scrot"
            ;;
        esac

        case ${3} in
            lightdm )
                APT_PACKAGES+=" lightdm"
                if [ ${2} == "kde" ]; then
                    APT_PACKAGES+=" lightdm-kde-greeter"
                else
                    APT_PACKAGES+=" lightdm-gtk-greeter"
                fi
            ;;
            kdm ) APT_PACKAGES+=" kdm" ;;
        esac
    fi
}

# Install packages
proceed_to_install() {
    read -p "You proceed to install \"${PKG_SELECT}\". Do you want to continue? [Y]es, [N]o (default \"yes\"): " response
    case ${response} in
        [Yy]*|"" ) 
            is_apt_configured
            echo -n "Installation of packages... "
            eval ${APT_PROGRAM} ${APT_COMMAND} ${APT_OPTIONS} ${APT_PACKAGES}
            echo "Done."
            exit 0
        ;;
        [Nn]* )
            echo "Installaton aborted by user."
            exit 1
        ;;
    esac
}

# Run this script
runs_as_root
user_selection
proceed_to_install
