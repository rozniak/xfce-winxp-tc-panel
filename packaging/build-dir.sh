#!/bin/bash

L_SCRIPTDIR=`dirname "$0"`

CURDIR=`realpath -s "./"`
PKG_DIR=`realpath -s "./tmp-pkg"`
SCRIPTDIR=`realpath -s "${L_SCRIPTDIR}"`

REPO_ROOT=`realpath -s "${SCRIPTDIR}/.."`

#
# COMPILE
#
cd "${REPO_ROOT}"

./autogen.sh
make -j6 datarootdir=/usr/share datadir=/usr/share libdir=/usr/lib/x86_64-linux-gnu HELPER_PATH_PREFIX=/usr/lib/x86_64-linux-gnu

#
# BUILD DIR STRUCTURE
#
mkdir "${PKG_DIR}"

# XDG stuff
#
PKG_XDG_DIR="${PKG_DIR}/etc/xdg/xfce4/panel"

mkdir -p "${PKG_XDG_DIR}"
cp "${REPO_ROOT}/migrate/default.xml" "${PKG_XDG_DIR}"

# Binaries
#
PKG_BIN_DIR="${PKG_DIR}/usr/bin"

mkdir -p "${PKG_BIN_DIR}"
cp "${REPO_ROOT}/panel/.libs/xfce4-panel" "${PKG_BIN_DIR}"
cp "${REPO_ROOT}/plugins/applicationsmenu/xfce4-popup-applicationsmenu" "${PKG_BIN_DIR}"
cp "${REPO_ROOT}/plugins/directorymenu/xfce4-popup-directorymenu" "${PKG_BIN_DIR}"
cp "${REPO_ROOT}/plugins/windowmenu/xfce4-popup-windowmenu" "${PKG_BIN_DIR}"

# /usr/lib stuff (mostly panel plugins)
#
PKG_LIB_DIR="${PKG_DIR}/usr/lib/x86_64-linux-gnu/xfce4/panel"
PKG_LIB_PLUGINS_DIR="${PKG_LIB_DIR}/plugins"

mkdir -p "${PKG_LIB_PLUGINS_DIR}"
cp "${REPO_ROOT}/migrate/migrate" "${PKG_LIB_DIR}"
find "${REPO_ROOT}" -type f -iname "*.so" -exec cp '{}' "${PKG_LIB_PLUGINS_DIR}" \;

# XDG panel desktop entries
#
PKG_XDG_ENTRIES="${PKG_DIR}/usr/share/applications"

mkdir -p "${PKG_XDG_ENTRIES}"
cp "${REPO_ROOT}/panel-preferences.desktop" "${PKG_XDG_ENTRIES}"
cp "${REPO_ROOT}/panel-desktop-handler.desktop" "${PKG_XDG_ENTRIES}"

# XDG icons
#
PKG_XDG_ICONS="${PKG_DIR}/usr/share/icons/hicolor"

mkdir -p "${PKG_XDG_ICONS}"
cp -r "${REPO_ROOT}/icons"/* "${PKG_XDG_ICONS}"
find "${PKG_XDG_ICONS}" -type f -iname "Makefile*" -exec rm -f '{}' \;

# Locales
#
PKG_LOCALES_ROOT="${PKG_DIR}/usr/share/locale"

mkdir -p "${PKG_LOCALES_ROOT}"

for locale_file in "${REPO_ROOT}/po"/*.gmo;
do
    if [[ $locale_file =~ ([A-Za-z_]+)\.gmo ]]
    then
        lang_code="${BASH_REMATCH[1]}"
        lang_dir="${PKG_LOCALES_ROOT}/${lang_code}/LC_MESSAGES"

        mkdir -p "${lang_dir}"
        cp "${locale_file}" "${lang_dir}/xfce4-panel.mo"
    fi
done

# Plugin desktop entries
#
PKG_PLUGIN_ENTRIES="${PKG_DIR}/usr/share/xfce4/panel/plugins"

mkdir -p "${PKG_PLUGIN_ENTRIES}"
find "${REPO_ROOT}/plugins" -type f -iname "*.desktop" -exec cp '{}' "${PKG_PLUGIN_ENTRIES}" \;

# DEBIAN metadata
#
PKG_DEBIAN_DIR="${PKG_DIR}/DEBIAN"

mkdir -p "${PKG_DEBIAN_DIR}"
cp "${SCRIPTDIR}/control" "${PKG_DEBIAN_DIR}"

#
# PACKAGE NOW
#
cd "${CURDIR}"

fakeroot dpkg-deb -v --build "${PKG_DIR}"
mv "${PKG_DIR}.deb" "xfce4-panel.deb"

rm -rf "${PKG_DIR}"
