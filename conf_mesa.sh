#!/bin/bash

if test x$1 = x32; then
    arch=i386-linux-gnu
    buildtype=release

    gallium_drivers=radeonsi
    vulkandrv=
    dri_drivers=
    others="-Dplatforms=x11 -Dgallium-vdpau=false -Dgallium-va=false -Dpkg_config_path=/usr/lib/$arch/pkgconfig"

    export CC="gcc -m32"
    export CXX="g++ -m32"
else
    arch=x86_64-linux-gnu
    buildtype=debugoptimized

    #buildtype=release
    #profile="-g -fno-omit-frame-pointer"

    #buildtype=debug

    gallium_drivers=radeonsi,swrast #,zink,r300,r600,d3d12,svga,etnaviv,freedreno,iris,kmsro,lima,nouveau,panfrost,svga,swr,tegra,v3d,vc4,virgl,i915
    vulkandrv=amd #,swrast
    dri_drivers= #r100,r200,nouveau,i915,i965

    #others="-Dgallium-xa=true -Dgallium-nine=true -Dgallium-omx=bellagio -Dbuild-tests=true"
    #others="-Dbuild-tests=true"
fi


rm -r build$1

meson build$1 --prefix /usr --libdir /usr/lib/$arch --buildtype $buildtype -Dlibunwind=false \
	-Dc_link_args=-fuse-ld=gold -Dcpp_link_args=-fuse-ld=gold --native-file `dirname $0`/llvm_config_$arch.cfg \
	-Dgallium-drivers=$gallium_drivers -Ddri-drivers=$dri_drivers -Dvulkan-drivers=$vulkandrv \
	-Dc_args="$profile" -Dcpp_args="$profile" $others
