#!/bin/bash

prefix=${PREFIX:-/usr}
# for general development (optimized with assertions)
buildtype=${BUILD_TYPE:-debugoptimized}
draw_use_llvm=false
link_args="-fuse-ld=mold"

if test x$1 = x32; then
    export CC="gcc -m32"
    export CXX="g++ -m32"
    arch=i386-linux-gnu
    others="-Dgallium-va=disabled -Damd-use-llvm=false -Dllvm=disabled -Dspirv-tools=disabled"

    buildtype=release

    gallium_drivers=radeonsi,softpipe
    vulkandrv=amd
else
    arch=x86_64-linux-gnu
    mm="-Dgallium-va=enabled -Dvideo-codecs=av1dec,av1enc,vp9dec,vc1dec,h264dec,h264enc,h265dec,h265enc"

    # comment or uncomment the following settings

    # for benchmarking (fastest, optimized without assertions)
    #buildtype=release

    # for profiling (second fastest)
    #buildtype=release; profile="-fno-omit-frame-pointer" # -fno-optimize-sibling-calls"

    # for best debugging (no optimizations)
    #buildtype=debug

    gallium_drivers=radeonsi,softpipe
    vulkandrv=amd

    #gallium_drivers=all; vulkandrv=all; draw_use_llvm=true others="-Dbuild-tests=true"
fi

rm -r build$1

set -e

meson setup build$1 --prefix $prefix --libdir $prefix/lib/$arch --buildtype $buildtype \
        --native-file `dirname $0`/llvm_config_$arch.cfg \
        -Dc_args="-g $profile" -Dcpp_args="-g $profile" -Dc_link_args=$link_args -Dcpp_link_args=$link_args \
        -Ddisplay-info=disabled -Dlegacy-wayland=bind-wayland-display \
        -Dglvnd=enabled -Ddraw-use-llvm=$draw_use_llvm \
        -Dgallium-drivers=$gallium_drivers -Dvulkan-drivers=$vulkandrv $mm $others $repl
ninja -Cbuild$1 -k100
