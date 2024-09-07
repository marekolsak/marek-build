#!/bin/bash

prefix=${PREFIX:-/usr}
# for general development (optimized with assertions)
buildtype=${BUILD_TYPE:-debugoptimized}

if test x$1 = x32; then
    arch=i386-linux-gnu
    va=disabled
    buildtype=release
    profile="-g"

    gallium_drivers=radeonsi
    vulkandrv=amd
    others="-Dplatforms=x11 -Dgallium-vdpau=disabled"

    export CC="gcc -m32"
    export CXX="g++ -m32"
else
    arch=x86_64-linux-gnu
    va=enabled

    # comment or uncomment the following settings

    # for benchmarking (fastest, optimized without assertions)
    #buildtype=release; profile="-g"

    # for profiling (second fastest)
    #buildtype=release; profile="-g -fno-omit-frame-pointer"

    # for best debugging (no optimizations)
    #buildtype=debug

    gallium_drivers=radeonsi,llvmpipe,softpipe #,r300,r600 #,zink,crocus,virgl,nouveau,d3d12,svga,etnaviv,freedreno,kmsro,lima,panfrost,tegra,v3d,vc4,i915 #,iris,asahi #needs libllvmspirv

    vulkandrv=amd #,swrast

    videocodecs=h264dec,h264enc,h265dec,h265enc
fi

rm -r build$1

set -e

meson setup build$1 --prefix $prefix --libdir $prefix/lib/$arch --buildtype $buildtype -Dlibunwind=disabled -Dglvnd=enabled \
	--native-file `dirname $0`/llvm_config_$arch.cfg \
	-Dgallium-drivers=$gallium_drivers -Dvulkan-drivers=$vulkandrv \
	-Dc_args="$profile" -Dcpp_args="$profile" $repl $st $tests $others -Dgallium-va=$va -Dvideo-codecs=$videocodecs
