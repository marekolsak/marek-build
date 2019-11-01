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
    ln -sf $mesalibs/src/mapi/es1api/libGLESv1_CM.so    $libdir/libGLESv1_CM.so.1.1.0
    ln -sf $mesalibs/src/mapi/es2api/libGLESv2.so       $libdir/libGLESv2.so
    ln -sf $mesalibs/src/mapi/es2api/libGLESv2.so       $libdir/libGLESv2.so.2.0.0
    ln -sf $mesalibs/src/mapi/shared-glapi/libglapi.so  $libdir/libglapi.so.0.0.0
    ln -sf $mesalibs/src/gbm/libgbm.so                  $libdir/libgbm.so.1
    ln -sf $mesalibs/src/gbm/libgbm.so                  $libdir/libgbm.so.1.0.0

    ln -sf $mesalibs/src/gallium/targets/dri/libgallium_dri.so    $libdir/dri/radeonsi_dri.so
    ln -sf $mesalibs/src/gallium/targets/dri/libgallium_dri.so    $libdir/dri/swrast_dri.so

    mkdir -p $libdir/vdpau
    ln -sf $mesalibs/src/gallium/targets/vdpau/libvdpau_gallium.so  $libdir/vdpau/libvdpau_radeonsi.so.1.0.0

    ln -sf $mesalibs/src/gallium/targets/va/libgallium_drv_video.so $libdir/dri/radeonsi_drv_video.so

    mkdir -p $libdir/d3d
    #ln -sf $mesalibs/../src/gallium/targets/d3dadapter9/.libs/d3dadapter9.so  $libdir/d3d/d3dadapter9.so.1
}

prefix=`dirname $0`
prefix=`realpath $prefix`

create_links $prefix/${dir}/build   /usr/lib/x86_64-linux-gnu
create_links $prefix/${dir}/build32 /usr/lib/i386-linux-gnu
