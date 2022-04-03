#!/bin/bash

L_SCRIPTDIR=`dirname "$0"`

CORE_COUNT=`nproc`
CURDIR=`realpath -s "./"`
PKG_DIR=`realpath -s "./tmp-pkg"`
SCRIPTDIR=`realpath -s "${L_SCRIPTDIR}"`

REPO_ROOT=`realpath -s "${SCRIPTDIR}/.."`


source /dev/stdin <<<"$(dpkg-architecture)"

#
# COMPILE
#
cd "${REPO_ROOT}"

./autogen.sh

if [[ $? -gt 0 ]]
then
    echo "Failed autogen.sh"
    exit 1
fi

make -j${CORE_COUNT} datarootdir=/usr/share datadir=/usr/share libdir=/usr/lib/${DEB_HOST_MULTIARCH} HELPER_PATH_PREFIX=/usr/lib/${DEB_HOST_MULTIARCH}

if [[ $? -gt 0 ]]
then
    echo "Failed build"
    exit 1
fi

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
PKG_LIB_DIR="${PKG_DIR}/usr/lib/${DEB_HOST_MULTIARCH}"
PKG_LIB_PANEL_DIR="${PKG_LIB_DIR}/xfce4/panel"

mkdir -p "${PKG_LIB_PANEL_DIR}"

cp "${REPO_ROOT}/libxfce4panel/.libs/libxfce4panel-2.0.so.4.0.0" "${PKG_LIB_DIR}"
ln -s "/usr/lib/${DEB_HOST_MULTIARCH}/libxfce4panel-2.0.so.4.0.0" "${PKG_LIB_DIR}/libxfce4panel-2.0.so.4"
cp "${REPO_ROOT}/wrapper/.libs/wrapper-2.0" "${PKG_LIB_PANEL_DIR}"

#
# DEBIAN metadata
#
PKG_DEBIAN_DIR="${PKG_DIR}/DEBIAN"
PKG_UPSTREAM_VERSION=`apt-cache show libxfce4panel-2.0-4 | grep Version | head -n 1 | cut -d " " -f 2`

mkdir -p "${PKG_DEBIAN_DIR}"
cp "${SCRIPTDIR}/control-libxfce4panel-2.0" "${PKG_DEBIAN_DIR}/control"

sed -i "s/@@UPSTREAM_VERSION@@/${PKG_UPSTREAM_VERSION}/" "${PKG_DEBIAN_DIR}/control"
sed -i "s/@@SYS_ARCH@@/${DEB_HOST_ARCH}/" "${PKG_DEBIAN_DIR}/control"

#
# PACKAGE NOW
#
cd "${CURDIR}"

fakeroot dpkg-deb -v --build "${PKG_DIR}"
mv "${PKG_DIR}.deb" "libxfce4panel-2.0-4.deb"

rm -rf "${PKG_DIR}"
