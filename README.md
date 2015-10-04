# Useful scripts for Debian #
All scripts are used in Debian 8.0 ("Jessie") and above.

## Scripts: ##
* *deb-configure-apt.sh* -- Configure "sources.list" and useful "apt" options;
* *deb-install-base-system.sh* -- Install all basic and GUI packages (XFCE, GNOME, KDE) without annoying dependencies;
* *deb-install-drivers.sh* -- Install needed drivers and firmwares (in progress);
* *deb-install-apps.sh* -- Install applications, depending on GTK or QT (in progress);
* *deb-collect-garbage.sh* -- Remove all unneeded packages (in progress).

## Configs: ##
* *deb-install-configs.sh* -- Install all downloaded config files;
* *openbox* folder -- [window manager](http://openbox.org/wiki/Main_Page);
* *gxkb* folder -- [keyboard indicator](http://sourceforge.net/projects/gxkb);
* *gtk* folder -- [gtk-apps settings](http://www.gtk.org);
* *tint2rc* -- [panel](https://gitlab.com/o9000/tint2);
* *mpvrc* -- [media player](http://mpv.io);
* *comptonrc* -- [compositing manager](https://github.com/chjj/compton);
* *lilytermrc* -- [advanced terminal emulator](http://lilyterm.luna.com.tw).

## FAQ ##
* *What about tasksel & metapackages?*
  - Yes, you can use it. But main goal of this scripts - pure system without any garbage.
* *Some packages missed!*
  - Look previous question.
* *Difficult configuration of openbox/liyterm/etc!*
  - You can change it freely.

## Tips & tricks ##
1. [Shadows in gtk3-apps (patch added)](http://bbs.archbang.org/viewtopic.php?id=4908)
