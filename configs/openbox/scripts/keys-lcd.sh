#!/bin/bash

# This script selects video output on-boot & on-demand (by pressing hotkey)
# XF86Display key; on ASUS laptops it is Fn+F8.

# Change you LVDS as in 'xrandr -q | grep LVDS'
LVDS="LVDS"

# Check connections
CONNECTED=$(/usr/bin/xrandr -q | grep -iE "\bconnected\b" | cut -d " " -f1)
DISCONNECTED=$(/usr/bin/xrandr -q | grep -iE "\bdisconnected\b" | cut -d " " -f1)

# Enable/disable outputs
work_out() {
  ACTION=${1}
  shift
  for OUT in "$@"; do
    /usr/bin/xrandr --output ${OUT} --${ACTION}
  done
}

# Select an output respectivetly
if [ "${CONNECTED}" != "${LVDS}" ]; then
  CONNECTED=$(echo ${CONNECTED} | sed s/${LVDS}//)
  DISCONNECTED+=" ${LVDS}"
fi
work_out auto ${CONNECTED}
work_out off ${DISCONNECTED}

# Re-set wallpapers (don't forget to change path)
hsetroot -cover ${HOME}/.config/openbox/debian-wall2.png

exit 0
