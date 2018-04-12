#!/bin/bash

export CFLAGS="-g -O2 -fno-omit-frame-pointer"

if test x$1 = x-32; then
    dir=i386-linux-gnu
    build=i686-linux-gnu
    export CC="gcc -m32"
    export PKG_CONFIG_PATH="/usr/lib/$dir/pkgconfig"
else
    dir=x86_64-linux-gnu
    build=$dir
fi

./autogen.sh --prefix=/usr --build=$build --host=$build --libdir=/usr/lib/$dir --disable-cairo-tests --enable-freedreno --enable-vc4 --enable-etnaviv-experimental-api
