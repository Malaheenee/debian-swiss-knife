#!/usr/bin/env bash

# This script installs all basic and GUI packages (XFCE, GNOME, KDE)
# without annoying dependencies.

# Common vars
ROOT_UID=0
E_NOTROOT=101

# APT vars
APT_PROGRAM=$(which apt-get)
APT_COMMAND="install"
APT_OPTIONS="-qy"
APT_PACKAGES=""
APT_SOURCES_FILE="/etc/apt/sources.list"
PKG_SELECT=""

# Different vars
USRNM=$(grep -oe "^.*x:1000" /etc/passwd)
USRHP=$(grep -oe ":1000.*\/.*:" /etc/passwd)
USR=${USRNM:0:$(expr index "${USRNM}" :)-1}
PROFILE_FILE=${USRHP:$(expr index "${USRHP}" /)-1:(-1)}/.profile
TTY1_FILE="/etc/systemd/system/getty@tty1.service.d"
AGETTY=$(which agetty)

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
            case ${?} in
                "0" ) echo ${?} "Done."; return 0;;
                "100" ) echo ${?} "Incorrect settings of apt!"; exit 1 ;;
            esac
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
    echo "This script installs all basic and GUI packages without annoying dependencies."
    read -p "What you want to install first: [b]ase system, [k]de, [x]fce, [m]ixed (default \"mixed\"): "
    case ${REPLY} in
        B|b ) PKG_SELECT+="base" ;;
        K|k ) PKG_SELECT+="base kde" ;;
        M|m|"" ) PKG_SELECT+="base mixed" ;;
        X|x ) PKG_SELECT+="base xfce" ;;
        [^BbKkMmXx]* ) echo "Wrong selection. Aborted."; exit 1 ;;
    esac

    if [[ ${PKG_SELECT} != "base" ]]; then
        read -p "What display manager you want to use: [l]ightdm, [k]dm or [w]ithout DM (default \"lightdm\"): "
        case ${REPLY} in
            K|k ) PKG_SELECT+=" kdm" ;;
            L|l|"" ) PKG_SELECT+=" lightdm" ;;
            W|w|"" ) PKG_SELECT+=" withoutdm" ;;
            [^KkLlWw]* ) echo "Wrong selection. Aborted."; exit 1 ;;
        esac
    fi

    if [[ ${PKG_SELECT} =~ "base" ]]; then
        APT_PACKAGES+=" bash-completion alsa-utils dbus ntfs-3g \
        dosfstools mtools mlocate intel-microcode bzip2 zip unzip p7zip-full \
        xz-utils libiso9660-8 unrar policykit-1 acpi-support"
    fi

    if [[ ${PKG_SELECT} =~ "xfce"|"kde"|"mixed" ]]; then
        APT_PACKAGES+=" xfonts-base xfonts-scalable xserver-common xinit \
        xserver-xorg xserver-xorg-video-fbdev xserver-xorg-video-vesa \
        xserver-xorg-input-evdev libnotify-bin xdg-utils xdg-user-dirs \
        cups-bsd faenza-icon-theme dmz-cursor-theme fonts-droid-fallback xclip"
    fi

    if [[ ${PKG_SELECT} =~ "xfce" ]]; then
        APT_PACKAGES+=" xfce4-panel xfwm4 xfce4-settings xfce4-session \
        xfdesktop4 xfconf xfce4-notifyd ristretto tumbler xarchiver \
        mousepad thunar thunar-volman thunar-archive-plugin \
        xfce4-xkb-plugin xfce4-screenshooter xfce4-power-manager \
        gtk2-engines-xfce gtk3-engines-xfce xfce4-terminal \
        xfwm4-themes orage xfce4-appfinder xfce4-places-plugin \
        xfce4-weather-plugin libxfce4ui-utils galculator gvfs"
    elif [[ ${PKG_SELECT} =~ "kde" ]]; then
        APT_PACKAGES+=" dolphin kde-l10n-ru kde-window-manager \
        kde-baseapps-bin kde-workspace-bin polkit-kde-1 oxygencursors \
        oxygen-icon-theme plasma-widgets-workspace plasma-containments-addons \
        libkdesu5 kdesudo kde-runtime gwenview systemsettings konsole \
        kate kmix ark kwalletmanager kfind phonon-backend-gstreamer \
        ksysguard ksnapshot akonadi-backend-sqlite sqlite3 kcalc"
    elif [[ ${PKG_SELECT} =~ "mixed" ]]; then
        APT_PACKAGES+=" openbox hsetroot gmrun gsimplecal arandr \
        notification-daemon tint2 gxkb volumeicon-alsa compton spacefm \
        udevil lilyterm viewnior xarchiver galculator geany scrot"
    fi

    if [[ ${PKG_SELECT} =~ "lightdm" ]]; then
        APT_PACKAGES+=" lightdm"
        if [[ ${PKG_SELECT} =~ "kde" ]]; then
            APT_PACKAGES+=" lightdm-kde-greeter"
        else
            APT_PACKAGES+=" lightdm-gtk-greeter"
        fi
    elif [[ ${PKG_SELECT} =~ "kdm" ]]; then
        APT_PACKAGES+=" kdm"
    fi
}

# Install packages
proceed_to_install() {
    read -p "You proceed to install \"${PKG_SELECT}\". Do you want to continue? [Y|n]: "
    case ${REPLY} in
        Y|y|"" )
            is_apt_configured
            echo -n "Installation of packages... "
            eval ${APT_PROGRAM} ${APT_COMMAND} ${APT_OPTIONS} ${APT_PACKAGES}
            if [[ ${PKG_SELECT} =~ "withoutdm" ]]; then
                mkdir -p ${TTY1_FILE}
                TTY1_FILE+="/override.conf"
                echo "[Service]" > ${TTY1_FILE}
                echo "ExecStart=" >> ${TTY1_FILE}
                echo "ExecStart=-${AGETTY} --autologin ${USR} --noclear %I 38400 linux" >> ${TTY1_FILE}
                echo '[[ -z $DISPLAY && $XDG_VTNR -eq 1 ]] && exec startx' >> ${PROFILE_FILE}
            fi
            echo "Done."
            exit 0
        ;;
        N|n )
            echo "Installaton aborted by user."
            exit 1
        ;;
        [^YyNn]* )
            echo "Wrong selection. Aborted."
            exit 1
        ;;
    esac
}

# Run this script
runs_as_root
user_selection
proceed_to_install
