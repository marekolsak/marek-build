#!/bin/bash

prefix=${PREFIX:-/usr}
arch=x86_64-linux-gnu

buildtype=${BUILD_TYPE:-debugoptimized}
buildtype=debug
profile="-g"

rm -r build$1

meson build$1 --prefix $prefix --libdir $prefix/lib/$arch --buildtype $buildtype \
        -Dc_args="$profile" -Dcpp_args="$profile"
