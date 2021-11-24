#!/bin/bash

if test x$1 = x; then
    dir=mesa
else
    dir=$1
fi


create_links()
{
    mesalibs=$1
    libdir=$2

    ln -sf $mesalibs/src/glx/libGLX_mesa.so             $libdir/libGLX_mesa.so.0.0.0
    ln -sf $mesalibs/src/egl/libEGL_mesa.so             $libdir/libEGL_mesa.so.0.0.0
    ln -sf $mesalibs/src/mapi/shared-glapi/libglapi.so  $libdir/libglapi.so.0.0.0
    ln -sf $mesalibs/src/gbm/libgbm.so                  $libdir/libgbm.so.1.0.0

    ln -sf $mesalibs/src/gallium/targets/dri/libgallium_dri.so    $libdir/dri/radeonsi_dri.so
    ln -sf $mesalibs/src/gallium/targets/dri/libgallium_dri.so    $libdir/dri/swrast_dri.so
    ln -sf $mesalibs/src/gallium/targets/dri/libgallium_dri.so    $libdir/dri/zink_dri.so

    if $3; then
        ln -sf $mesalibs/src/gallium/targets/va/libgallium_drv_video.so $libdir/dri/radeonsi_drv_video.so

        mkdir -p $libdir/vdpau
        ln -sf $mesalibs/src/gallium/targets/vdpau/libvdpau_gallium.so  $libdir/vdpau/libvdpau_radeonsi.so.1.0.0

        ln -sf $mesalibs/src/amd/vulkan/libvulkan_radeon.so $libdir/libvulkan_radeon.so
        ln -sf $mesalibs/src/gallium/targets/lavapipe/libvulkan_lvp.so $libdir/libvulkan_lvp.so
    fi
}

prefix=`dirname $0`
prefix=`realpath $prefix`

create_links $prefix/${dir}/build   /usr/lib/x86_64-linux-gnu true
create_links $prefix/${dir}/build32 /usr/lib/i386-linux-gnu false

ln -sf $prefix/${dir}/src/util/00-mesa-defaults.conf /usr/share/drirc.d/00-mesa-defaults.conf
