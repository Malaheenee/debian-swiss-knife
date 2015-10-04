#!/usr/bin/env bash

# This script installs all downloaded config files

# Common vars
OPTS="-f"
PWD=$(pwd)

echo "This script installs all all downloaded config files"
read -p "Create [s]imlinks or [c]opy config files?  (default \"copy\"): "
case ${REPLY} in
    S|s ) OPTS="-fs" ;;
    C|c|"" ) OPTS="-f" ;;
    [^SsCc]* ) echo "Wrong selection. Aborted."; exit 1 ;;
esac

check() {
    if [ -n "$(dpkg -s ${1} 2>&1 | grep Status)" ]; then
        return 1
    else
        return 0
    fi
}

# Skip message
skip() {
    echo "Seems that package \"${1}\" is not installed. Skipped."
}

# openbox
echo -n "openbox config... "
check openbox
if [ "${?}" -eq "1" ]; then
    cp ${OPTS} ${PWD}/openbox ${HOME}/.config/openbox
    echo "OK"
else
    skip openbox
fi

# tint2
echo -n "tint2 config... "
check tint2
if [ "${?}" -eq "1" ]; then
    mkdir ${HOME}/.config/tint2
    cp ${OPTS} ${PWD}/tint2rc ${HOME}/.config/tint2/tint2rc
    echo "OK"
else
    skip tint2
fi

# lilyterm
echo -n "lilyterm config... "
check lilyterm
if [ "${?}" -eq "1" ]; then
    mkdir ${HOME}/.config/lilyterm
    cp ${OPTS} ${PWD}/lilytermrc ${HOME}/.config/lilyterm/default.conf
    echo "OK"
else
    skip lilyterm
fi

# compton
echo -n "compton config... "
check compton
if [ "${?}" -eq "1" ]; then
    cp ${OPTS} ${PWD}/comptonrc ${HOME}/.config/compton.conf
    echo "OK"
else
    skip compton
fi

# mpv
echo -n "mpv config... "
check mpv
if [ "${?}" -eq "1" ]; then
    mkdir ${HOME}/.config/mpv
    cp ${OPTS} ${PWD}/mpvrc ${HOME}/.config/mpv/mpv.conf
    echo "OK"
else
    skip mpv
fi

# gxkb
echo -n "gxkb config... "
check gxkb
if [ "${?}" -eq "1" ]; then
    mkdir ${HOME}/.config/gxkb
    cp ${OPTS} ${PWD}/gxkb/gxkb.cfg ${HOME}/.config/gxkb/gxkb.cfg
    cp ${OPTS} ${PWD}/gxkb/flags ${HOME}/.local/share/gxkb/flags
    echo "OK"
else
    skip gxkb
fi

# GTK styles
echo -n "GTK configs... "
cp ${OPTS} ${PWD}/gtk/gtkrc-2 ${HOME}/.gtkrc-2.0
mkdir ${HOME}/.config/gtk-3.0
cp ${OPTS} ${PWD}/gtk/gtkrc-3 ${HOME}/.config/gtk-3.0/settings.ini
cp ${OPTS} ${PWD}/gtk/gtk3-css ${HOME}/.config/gtk-3.0/gtk.css
cp ${OPTS} ${PWD}/gtk/xresources ${HOME}/.Xresources
xrdb -merge ${HOME}/.Xresources
echo "OK"
