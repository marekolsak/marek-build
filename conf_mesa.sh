#!/bin/bash

if test x$1 = x32; then
    arch=i386-linux-gnu
    buildtype=release
    profile="-g"

    gallium_drivers=radeonsi
    others="-Dplatforms=x11 -Dgallium-vdpau=false -Dgallium-va=false -Dpkg_config_path=/usr/lib/$arch/pkgconfig" # -Dbuild-tests=true"

    export CC="gcc -m32"
    export CXX="g++ -m32"
else
    arch=x86_64-linux-gnu

    # comment or uncomment the following settings

    # for general development (optimized with assertions)
    buildtype=debugoptimized

    # for benchmarking (fastest, optimized without assertions)
    #buildtype=release; profile="-g"

    # for profiling (second fastest)
    #buildtype=release; profile="-g -fno-omit-frame-pointer"

    # for best debugging (no optimizations)
    #buildtype=debug

    gallium_drivers=radeonsi,swrast # ,r300,r600,crocus,zink,virgl,nouveau,d3d12,svga,etnaviv,freedreno,iris,kmsro,lima,panfrost,tegra,v3d,vc4,asahi,i915 #,swr

    #vulkandrv=amd #,swrast
    #dri_drivers=r100,r200,nouveau,i915,i965

    #others="-Dgallium-xa=true -Dgallium-nine=true -Dgallium-omx=bellagio -Dbuild-tests=true -Dtools=glsl,nir"
    #others="-Dbuild-tests=true -Dtools=glsl,nir"
fi


rm -r build$1

meson build$1 --prefix /usr --libdir /usr/lib/$arch --buildtype $buildtype -Dlibunwind=false -Dglvnd=true \
	-Dc_link_args=-fuse-ld=gold -Dcpp_link_args=-fuse-ld=gold --native-file `dirname $0`/llvm_config_$arch.cfg \
	-Dgallium-drivers=$gallium_drivers -Ddri-drivers=$dri_drivers -Dvulkan-drivers=$vulkandrv \
	-Dc_args="$profile" -Dcpp_args="$profile" $repl $others
