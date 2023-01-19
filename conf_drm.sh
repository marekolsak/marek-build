#!/bin/bash

prefix=${PREFIX:-/usr}

if test x$1 = x32; then
    is64bit=disabled
    archdir=i386-linux-gnu
    export CC="gcc -m32"
    export PKG_CONFIG_PATH=/usr/lib/$archdir/pkgconfig
else
    is64bit=enabled
    archdir=x86_64-linux-gnu
fi

rm -r build$1

cflags="-fno-omit-frame-pointer"

meson build$1 --prefix $prefix --libdir $prefix/lib/$archdir --buildtype debugoptimized \
	-Dc_args=$cflags -Dc_link_args=$cflags -Dpkg_config_path=$prefix/lib/$archdir/pkgconfig \
	-Detnaviv=enabled -Dexynos=enabled -Dfreedreno=enabled -Domap=enabled -Dtegra=enabled -Dvc4=enabled \
	-Dcairo-tests=$is64bit
