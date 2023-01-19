#!/bin/bash

set -e

prefix=${PREFIX:-/usr}
buildtype=${BUILD_TYPE:-debugoptimized}

rm -r build
mkdir build
meson build --prefix $prefix --libdir $prefix/lib/$arch --datadir $prefix/share --buildtype $buildtype

echo
echo !!! Make sure this output contains: Supported platforms: ... gbm !!!
