#!/bin/bash

prefix=${PREFIX:-/usr/local}

if test x$1 = x32; then
    # 32-bit build
    rm -rf build32

    set -e

    mkdir build32
    cd build32
    cmake ../llvm -G Ninja \
        -DCMAKE_INSTALL_PREFIX=$prefix/llvm-i386 -DLLVM_TARGETS_TO_BUILD="X86;AMDGPU" -DLLVM_ENABLE_ASSERTIONS=ON \
        -DCMAKE_BUILD_TYPE=Release -DLLVM_BUILD_LLVM_DYLIB=ON -DLLVM_LINK_LLVM_DYLIB=ON -DLLVM_APPEND_VC_REV=OFF \
        -DLLVM_BUILD_32_BITS=ON -DLLVM_ENABLE_RTTI=ON -DLLVM_CCACHE_BUILD=ON -DLLVM_ENABLE_LIBXML2=OFF \
        -DCMAKE_C_FLAGS_RELEASE="-O2 -g1 -fno-omit-frame-pointer" \
        -DCMAKE_CXX_FLAGS_RELEASE="-O2 -g1 -fno-omit-frame-pointer" \
        -DTerminfo_LIBRARIES="/usr/lib/i386-linux-gnu/libtinfo.so" \
        -DZLIB_LIBRARY_RELEASE="/usr/lib/i386-linux-gnu/libz.so" \
        -Dzstd_LIBRARY="/usr/lib/i386-linux-gnu/libzstd.so"
    cd ..
else
    # 64-bit build
    rm -rf build

    set -e

    mkdir build
    cd build

    cmake ../llvm -G Ninja \
        -DCMAKE_INSTALL_PREFIX=$prefix/llvm -DLLVM_TARGETS_TO_BUILD="X86;AMDGPU" -DLLVM_ENABLE_ASSERTIONS=ON \
        -DCMAKE_BUILD_TYPE=Release -DLLVM_BUILD_LLVM_DYLIB=ON -DLLVM_LINK_LLVM_DYLIB=ON -DLLVM_APPEND_VC_REV=OFF \
        -DLLVM_CCACHE_BUILD=ON -DLLVM_ENABLE_RTTI=ON \
        -DCMAKE_C_FLAGS_RELEASE="-O2 -g1 -fno-omit-frame-pointer" \
        -DCMAKE_CXX_FLAGS_RELEASE="-O2 -g1 -fno-omit-frame-pointer"
    cd ..
fi

cd ..
