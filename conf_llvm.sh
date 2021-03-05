#!/bin/bash

rm -rf build
mkdir build
cd build

cmake ../llvm -G Ninja \
    -DCMAKE_INSTALL_PREFIX=/usr/llvm/x86_64-linux-gnu -DLLVM_TARGETS_TO_BUILD="X86;AMDGPU" -DLLVM_ENABLE_ASSERTIONS=ON \
    -DCMAKE_BUILD_TYPE=Release -DLLVM_BUILD_LLVM_DYLIB=ON -DLLVM_LINK_LLVM_DYLIB=ON -DLLVM_APPEND_VC_REV=OFF \
    -DLLVM_CCACHE_BUILD=ON -DLLVM_ENABLE_RTTI=ON \
    -DCMAKE_C_FLAGS_RELEASE="-O2 -g1 -fno-omit-frame-pointer" \
    -DCMAKE_CXX_FLAGS_RELEASE="-O2 -g1 -fno-omit-frame-pointer" \
    -DCMAKE_EXE_LINKER_FLAGS_RELEASE="-fuse-ld=gold" \
    -DCMAKE_SHARED_LINKER_FLAGS_RELEASE="-fuse-ld=gold"

cd ..

rm -rf build32
mkdir build32
cd build32
cmake ../llvm -G Ninja \
    -DCMAKE_INSTALL_PREFIX=/usr/llvm/i386-linux-gnu -DLLVM_TARGETS_TO_BUILD="X86;AMDGPU" -DLLVM_ENABLE_ASSERTIONS=ON \
    -DCMAKE_BUILD_TYPE=Release -DLLVM_BUILD_LLVM_DYLIB=ON -DLLVM_LINK_LLVM_DYLIB=ON -DLLVM_APPEND_VC_REV=OFF \
    -DLLVM_BUILD_32_BITS=ON -DLLVM_ENABLE_RTTI=ON -DLLVM_CCACHE_BUILD=ON \
    -DCMAKE_C_FLAGS_RELEASE="-O2 -g1 -fno-omit-frame-pointer" \
    -DCMAKE_CXX_FLAGS_RELEASE="-O2 -g1 -fno-omit-frame-pointer" \
    -DCMAKE_EXE_LINKER_FLAGS_RELEASE="-fuse-ld=gold" \
    -DCMAKE_SHARED_LINKER_FLAGS_RELEASE="-fuse-ld=gold"
