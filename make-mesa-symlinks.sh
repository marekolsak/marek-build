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

    ln -sf $mesalibs/src/glx/libGL.so                   $libdir/libGL.so.1.2.0
    ln -sf $mesalibs/src/glx/libGL.so                   $libdir/libGL.so.1
    ln -sf $mesalibs/src/glx/libGL.so                   $libdir/libGL.so
    ln -sf $mesalibs/src/egl/libEGL.so                  $libdir/libEGL.so.1.0.0
    ln -sf $mesalibs/src/egl/libEGL.so                  $libdir/libEGL.so.1
    ln -sf $mesalibs/src/egl/libEGL.so                  $libdir/libEGL.so
    ln -sf $mesalibs/src/mapi/es1api/libGLESv1_CM.so    $libdir/libGLESv1_CM.so
    ln -sf $mesalibs/src/mapi/es1api/libGLESv1_CM.so    $libdir/libGLESv1_CM.so.1
    ln -sf $mesalibs/src/mapi/es1api/libGLESv1_CM.so    $libdir/libGLESv1_CM.so.1.1.0
    ln -sf $mesalibs/src/mapi/es2api/libGLESv2.so       $libdir/libGLESv2.so
    ln -sf $mesalibs/src/mapi/es2api/libGLESv2.so       $libdir/libGLESv2.so.2
    ln -sf $mesalibs/src/mapi/es2api/libGLESv2.so       $libdir/libGLESv2.so.2.0.0
    ln -sf $mesalibs/src/mapi/shared-glapi/libglapi.so  $libdir/libglapi.so
    ln -sf $mesalibs/src/mapi/shared-glapi/libglapi.so  $libdir/libglapi.so.0
    ln -sf $mesalibs/src/mapi/shared-glapi/libglapi.so  $libdir/libglapi.so.0.0.0
    ln -sf $mesalibs/src/gbm/libgbm.so                  $libdir/libgbm.so
    ln -sf $mesalibs/src/gbm/libgbm.so                  $libdir/libgbm.so.1
    ln -sf $mesalibs/src/gbm/libgbm.so                  $libdir/libgbm.so.1.0.0
    ln -sf $mesalibs/src/amd/vulkan/libvulkan_radeon.so $libdir/libvulkan_radeon.so

    ln -sf $mesalibs/src/gallium/targets/dri/libgallium_dri.so    $libdir/dri/radeonsi_dri.so
    ln -sf $mesalibs/src/gallium/targets/dri/libgallium_dri.so    $libdir/dri/swrast_dri.so
    ln -sf $mesalibs/src/gallium/targets/dri/libgallium_dri.so    $libdir/dri/zink_dri.so

    mkdir -p $libdir/vdpau
    ln -sf $mesalibs/src/gallium/targets/vdpau/libvdpau_gallium.so  $libdir/vdpau/libvdpau_radeonsi.so.1.0.0

    ln -sf $mesalibs/src/gallium/targets/va/libgallium_drv_video.so $libdir/dri/radeonsi_drv_video.so
}

prefix=`dirname $0`
prefix=`realpath $prefix`

create_links $prefix/${dir}/build   /usr/lib/x86_64-linux-gnu
create_links $prefix/${dir}/build32 /usr/lib/i386-linux-gnu

ln -sf $prefix/${dir}/src/util/00-mesa-defaults.conf /usr/share/drirc.d/00-mesa-defaults.conf
