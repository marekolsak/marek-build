#!/bin/bash

prefix=${PREFIX:-/usr}

if test x$1 = x32; then
    is64bit=false
    archdir=i386-linux-gnu
    export CC="gcc -m32"
    export PKG_CONFIG_PATH=/usr/lib/$archdir/pkgconfig
else
    is64bit=true
    archdir=x86_64-linux-gnu
fi

rm -r build$1

set -e

cflags="-fno-omit-frame-pointer"

meson build$1 --prefix $prefix --buildtype debugoptimized \
	-Dc_args=$cflags -Dc_link_args=$cflags -Dpkg_config_path=$prefix/lib/$archdir/pkgconfig \
	-Detnaviv=disabled -Dexynos=disabled -Dfreedreno=disabled -Domap=disabled -Dtegra=disabled -Dvc4=disabled \
	-Dcairo-tests=disabled
