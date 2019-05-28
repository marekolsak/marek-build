#!/bin/bash

mesa_cflags="-fno-omit-frame-pointer"
mesa_ldflags="$mesa_cflags -fuse-ld=gold"

if test x$1 = x32; then
    is64bit=false
    archdir=i386-linux-gnu
    gallium_drivers=radeonsi
    vulkandrv=
    omx=disabled

    export CC="gcc -m32"
    export CXX="g++ -m32"
else
    is64bit=true
    archdir=x86_64-linux-gnu
    gallium_drivers=radeonsi,swrast
    vulkandrv=amd
    omx=bellagio
fi

rm -r build$1

meson build$1 --prefix /usr --libdir /usr/lib/$archdir --buildtype debugoptimized \
	--native-file `dirname $0`/llvm_config_$archdir.cfg \
	-Dc_args="$mesa_cflags" -Dcpp_args="$mesa_cflags" \
	-Dc_link_args="$mesa_ldflags" -Dcpp_link_args="$mesa_ldflags" \
	-Dpkg_config_path=/usr/lib/$archdir/pkgconfig \
	-Dgallium-vdpau=$is64bit -Dgallium-va=$is64bit -Dgallium-omx=$omx -Dgallium-xvmc=false \
	-Dplatforms=x11,drm,surfaceless -Dgallium-drivers=$gallium_drivers \
	-Ddri-drivers= -Dvulkan-drivers=$vulkandrv \
	-Dlibunwind=$is64bit
