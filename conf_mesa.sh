#!/bin/bash

export USER_CFLAGS="-fno-omit-frame-pointer"
export USER_CXXFLAGS=$USER_CLAGS
export LDFLAGS="-fuse-ld=gold"

if test x$1 = x-32; then
    dir=i386-linux-gnu
    build=i686-linux-gnu
    export LDFLAGS="$LDFLAGS -L/usr/lib/$dir"
    export CC="gcc -m32"
    export CXX="g++ -m32"
    export PKG_CONFIG_PATH="/usr/lib/$dir/pkgconfig"

    params="--disable-va --disable-vdpau --disable-libunwind"
    drivers=radeonsi
    cdrivers=
else
    dir=x86_64-linux-gnu
    build=$dir

    params=
    drivers=radeonsi,swrast
    cdrivers=

    # All drivers:
    #drivers=$drivers,r300,r600,etnaviv,freedreno,i915,imx,nouveau,svga,swr,vc4,virgl,pl111
    #cdrivers=i965,i915,nouveau,radeon,r200,swrast
fi

./autogen.sh \
 --build=$build --host=$build --prefix=/usr --libdir=/usr/lib/$dir --with-llvm-prefix=/usr/llvm/$dir \
 --with-sha1=libnettle --with-egl-platforms=x11,drm --disable-xvmc --enable-debug \
 --enable-glx-tls --enable-texture-float --enable-gles1 --enable-gles2 \
 --with-gallium-drivers=$drivers --with-dri-drivers=$cdrivers $params
