# Useful scripts for Debian #
All scripts are used in Debian 8.0 ("Jessie") and above

## Scripts: ##
* *deb-configure-apt.sh* -- Configure "sources.list" and useful "apt" options;
* *deb-install-base-system.sh* -- Install all basic and GUI packages (XFCE, GNOME, KDE) without annoying dependencies;
* *deb-install-drivers.sh* -- Install needed drivers and firmwares (in progress);
* *deb-install-apps.sh* -- Install applications, depending on GTK or QT (in progress);
* *deb-collect-garbage.sh* -- Remove all unneeded packages (in progress);

## Configs: ##
* *deb-install-configs.sh* -- Install all downloaded config files (in progress);
* *openbox* folder -- window manager;
* *gxkb* folder -- keyboard indicator;
* *gtk* folder -- gtk-apps settings;
* *tint2rc* -- panel;
* *mpvrc* -- media player;
* *comptonrc* -- compositing manager;
* *lilytermrc* -- advanced terminal emulator;

## FAQ ##
* *What about tasksel & metapackages?*
  - Yes, you can use it. But main goal of this scripts - pure system without any garbage.
* *Some packages missed!*
  - Look previous question.
* *Difficult configuration of openbox/liyterm/etc!*
  - You can change it freely.

## Tips & tricks ##
1. [Shadows in gtk3-apps (patch added)](http://bbs.archbang.org/viewtopic.php?id=4908)
