#!/bin/bash

create_links()
{
    build=$1
    libdir=$2
    is_64bit=$3

    if test ! -f $build/src/glx/libGLX_mesa.so; then
        echo $build/src/glx/libGLX_mesa.so: not found
        exit 1
    fi

    cd $build/src/gallium/targets/dri
    libgallium_so=`echo libgallium-*.so`
    cd - >/dev/null

    if test ! -f "$build/src/gallium/targets/dri/$libgallium_so"; then
        echo Expected $build/src/gallium/targets/libgallium-*.so. Found: "$libgallium_so" '(or the file is missing)'
        exit 1
    fi

    mkdir -p $libdir/gbm

    ln -sf $build/src/egl/libEGL_mesa.so             $libdir/libEGL_mesa.so.0.0.0
    ln -sf $build/src/glx/libGLX_mesa.so             $libdir/libGLX_mesa.so.0.0.0
    ln -sf $build/src/gbm/libgbm.so                  $libdir/libgbm.so
    ln -sf $build/src/gbm/libgbm.so                  $libdir/libgbm.so.1
    ln -sf $build/src/gbm/libgbm.so                  $libdir/libgbm.so.1.0.0
    ln -sf $build/src/gbm/backends/dri/dri_gbm.so    $libdir/gbm/dri_gbm.so
    ln -sf $build/src/mapi/shared-glapi/libglapi.so  $libdir/libglapi.so.0.0.0

    ln -sf $build/src/gallium/targets/dri/$libgallium_so     $libdir/$libgallium_so

    ln -sf $build/src/gallium/targets/dril/libdril_dri.so    $libdir/dri/libdril_dri.so
    ln -sf $build/src/gallium/targets/dril/libdril_dri.so    $libdir/dri/radeonsi_dri.so
    ln -sf $build/src/gallium/targets/dril/libdril_dri.so    $libdir/dri/swrast_dri.so
    ln -sf $build/src/gallium/targets/dril/libdril_dri.so    $libdir/dri/zink_dri.so

    ln -sf $build/src/amd/vulkan/libvulkan_radeon.so $libdir/libvulkan_radeon.so

    if $is_64bit; then
        ln -sf $build/src/gallium/targets/dri/$libgallium_so $libdir/dri/radeonsi_drv_video.so
        ln -sf $build/src/gallium/targets/lavapipe/libvulkan_lvp.so $libdir/libvulkan_lvp.so
    fi
}

prefix=`pwd`
prefix=`realpath $prefix`

create_links /opt/mesa   /usr/lib/x86_64-linux-gnu true
create_links /opt/mesa32 /usr/lib/i386-linux-gnu   false

ln -sf $prefix/${dir}/src/util/00-mesa-defaults.conf /usr/share/drirc.d/00-mesa-defaults.conf
ln -sf $prefix/${dir}/src/util/00-radv-defaults.conf /usr/share/drirc.d/00-radv-defaults.conf

ldconfig
