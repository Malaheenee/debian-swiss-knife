#!/usr/bin/env bash

# This script configure "sources.list" and some useful "apt" options

# Common vars
ROOT_UID=0
E_NOTROOT=101

# APT vars
APT_SOURCES_FILE="/etc/apt/sources.list"
APT_CONF_FILE="/etc/apt/apt.conf.d/20apt-local"

# Other vars
REPO_LIST="stable testing unstable experimental"
REPO_URL="http://ftp.debian.org"
DEFAULT_RELEASE="testing"

# Verify user uid
runs_as_root() {
    if [ ${UID} -ne ${ROOT_UID} ]; then
        echo -e '\n\E[37;41m'"\033[1mYou are not root\033[0m\n"
        tput sgr0
        sleep 1
        exit ${E_NOTROOT}
    fi
}

# Configure apt
configure_apt() {
    if [ -e ${APT_SOURCES_FILE} ]; then
        sed -i "s/^deb/# deb/g" ${APT_SOURCES_FILE}
    else
        touch ${APT_SOURCES_FILE}
    fi
    
    for repo in ${REPO_LIST}; do
        echo "deb ${REPO_URL}/debian/ $repo main contrib non-free" >> ${APT_SOURCES_FILE}
    done
    
    if [[ ${REPO_LIST} =~ "stable" ]]; then
        echo "deb ${REPO_URL}/debian/ stable-updates main contrib non-free" >> ${APT_SOURCES_FILE}
        echo "deb http://security.debian.org/ stable/updates main contrib non-free" >> ${APT_SOURCES_FILE}
    fi

    if [ ! -e ${APT_CONF_FILE} ]; then
        touch ${APT_CONF_FILE}
    fi

    echo "Apt::Default-Release \"${DEFAULT_RELEASE}\";" > ${APT_CONF_FILE}
    echo "Apt::Get::Show-Versions \"true\";" >> ${APT_CONF_FILE}
    echo "Apt::Install-Recommends \"false\";" >> ${APT_CONF_FILE}
    echo "Aptitude::CmdLine::Show-Versions \"true\";" >> ${APT_CONF_FILE}
    echo "Aptitude::CmdLine::Package-Display-Format \"%c%a%M %30p# - %20V# - %t - %55d\";" >> ${APT_CONF_FILE}
}

user_selection() {
    echo "This script configure your sources.list and some useful \"apt\" options."

    if [ -e ${APT_SOURCES_FILE} ]; then
        if [ -n "$(grep -oE "^deb\W*(h|f)tt?p.*main\W*contrib\W*non-free$" ${APT_SOURCES_FILE})" ]; then
            read -p "Seems that apt is already configured. Do you want to continue? [y|N] "
            case ${REPLY} in
                N|n|"" ) exit 0 ;;
                Y|y ) sed -i "s/^deb/# deb/g" ${APT_SOURCES_FILE} ;;
                [^YyNn]* ) echo "Wrong selection. Aborted."; exit 1 ;;
            esac
        fi
    fi

    read -p "Enter mirror's URL that you want to use (default \"${REPO_URL}\"): "
    case ${REPLY} in
        "" ) REPO_URL="http://ftp.debian.org" ;;
        [A-Za-z]* )
            if [[ ${REPLY:0:5} == "http:" ]] ||
               [[ ${REPLY:0:5} == "file:" ]] ||
               [[ ${REPLY:0:5} == "ftp:/" ]]; then
                REPO_URL=${REPLY}
            else
                echo "Wrong URL: ${REPLY}. Aborted."
                exit 1
            fi
        ;;
    esac

    read -p "Which release you want to use? [s]table, [t]esting, [u]nstable (default \"t\"): "
    case ${REPLY} in
        T|t|"" ) DEFAULT_RELEASE="testing" ;;
        S|s ) DEFAULT_RELEASE="stable" ;;
        U|u ) DEFAULT_RELEASE="unstable" ;;
        [^SsTtUu]* ) echo "Wrong selection. Aborted."; exit 1 ;;
    esac

    read -p "Do you want to include in sources.list all branches? [y|N]: "
    case ${REPLY} in
        N|n|"" ) REPO_LIST=${DEFAULT_RELEASE} ;;
        Y|y ) REPO_LIST="stable testing unstable experimental" ;;
        [^YyNn]* ) echo "Wrong selection. Aborted."; exit 1 ;;
    esac

    configure_apt
}

runs_as_root
user_selection
