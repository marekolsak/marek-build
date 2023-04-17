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
    others="-Dplatforms=x11 -Dgallium-vdpau=disabled -Dpkg_config_path=${prefix}/lib/$arch/pkgconfig" # -Dbuild-tests=true"

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

    gallium_drivers=radeonsi,swrast # ,r300,r600,crocus,zink,virgl,nouveau,d3d12,svga,etnaviv,freedreno,iris,kmsro,lima,panfrost,tegra,v3d,vc4,asahi,i915

    #vulkandrv=amd #,swrast

    #others="-Dgallium-xa=true -Dgallium-nine=true -Dgallium-omx=bellagio -Dbuild-tests=true -Dtools=glsl,nir"
    #others="-Dbuild-tests=true -Dtools=glsl,nir"
    videocodecs=h264dec,h264enc,h265dec,h265enc
fi


rm -r build$1

meson build$1 --prefix $prefix --libdir $prefix/lib/$arch --buildtype $buildtype -Dlibunwind=disabled -Dglvnd=true \
	--native-file `dirname $0`/llvm_config_$arch.cfg \
	-Dgallium-drivers=$gallium_drivers -Dvulkan-drivers=$vulkandrv \
	-Dc_args="$profile" -Dcpp_args="$profile" $repl $others -Dgallium-va=$va -Dvideo-codecs=$videocodecs
