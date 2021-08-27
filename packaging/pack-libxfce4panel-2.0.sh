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
if [[ -d "${PKG_DIR}" ]]
then
    rm -rf "${PKG_DIR}"
fi

mkdir "${PKG_DIR}"

# Binaries
#
PKG_LIB_DIR="${PKG_DIR}/usr/lib/x86_64-linux-gnu"
PKG_LIB_PANEL_DIR="${PKG_LIB_DIR}/xfce4/panel"

mkdir -p "${PKG_LIB_PANEL_DIR}"

cp "${REPO_ROOT}/libxfce4panel/.libs/libxfce4panel-2.0.so.4.0.0" "${PKG_LIB_DIR}"
ln -s "/usr/lib/x86_64-linux-gnu/libxfce4panel-2.0.so.4.0.0" "${PKG_LIB_DIR}/libxfce4panel-2.0.so.4"
cp "${REPO_ROOT}/wrapper/.libs/wrapper-2.0" "${PKG_LIB_PANEL_DIR}"

#
# DEBIAN metadata
#
PKG_DEBIAN_DIR="${PKG_DIR}/DEBIAN"

mkdir -p "${PKG_DEBIAN_DIR}"
cp "${SCRIPTDIR}/control-libxfce4panel-2.0" "${PKG_DEBIAN_DIR}/control"

#
# PACKAGE NOW
#
cd "${CURDIR}"

fakeroot dpkg-deb -v --build "${PKG_DIR}"
mv "${PKG_DIR}.deb" "libxfce4panel-2.0-4.deb"

rm -rf "${PKG_DIR}"
