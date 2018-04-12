#!/bin/bash

create_links()
{
    mesalibs=$1
    libdir=$2

    ln -sf $mesalibs/libGL.so                   $libdir/libGL.so.1.2.0
    ln -sf $mesalibs/libGL.so                   $libdir/libGL.so.1
    ln -sf $mesalibs/libGL.so                   $libdir/libGL.so
    ln -sf $mesalibs/libEGL.so                  $libdir/libEGL.so.1.0.0
    ln -sf $mesalibs/libEGL.so                  $libdir/libEGL.so.1
    ln -sf $mesalibs/libEGL.so                  $libdir/libEGL.so
    ln -sf $mesalibs/libGLESv1_CM.so            $libdir/libGLESv1_CM.so.1.1.0
    ln -sf $mesalibs/libGLESv2.so               $libdir/libGLESv2.so
    ln -sf $mesalibs/libGLESv2.so               $libdir/libGLESv2.so.2.0.0
    ln -sf $mesalibs/libglapi.so                $libdir/libglapi.so.0.0.0
    ln -sf $mesalibs/libgbm.so                  $libdir/libgbm.so.1
    ln -sf $mesalibs/libgbm.so                  $libdir/libgbm.so.1.0.0

    ln -sf $mesalibs/gallium/radeonsi_dri.so    $libdir/dri/radeonsi_dri.so
    ln -sf $mesalibs/gallium/swrast_dri.so      $libdir/dri/swrast_dri.so

    mkdir -p $libdir/vdpau
    ln -sf $mesalibs/gallium/libvdpau_radeonsi.so.1  $libdir/vdpau/libvdpau_radeonsi.so.1.0.0

    ln -sf $mesalibs/../src/gallium/targets/va/.libs/gallium_drv_video.so $libdir/dri/gallium_drv_video.so
}

cd `dirname $0`

if test x$1 = x; then
    dir=mesa
else
    dir=$1
fi

create_links `pwd`/${dir}/x86_64-linux-gnu /usr/lib/x86_64-linux-gnu
create_links `pwd`/${dir}32/i386-linux-gnu /usr/lib/i386-linux-gnu
