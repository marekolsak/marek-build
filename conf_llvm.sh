#!/bin/bash

mkdir -p build
cd build

cmake .. -G Ninja -DCMAKE_INSTALL_PREFIX=/usr/llvm/x86_64-linux-gnu -DLLVM_TARGETS_TO_BUILD="X86;AMDGPU" -DLLVM_ENABLE_ASSERTIONS=ON \
                  -DCMAKE_BUILD_TYPE=RelWithDebInfo -DLLVM_BUILD_LLVM_DYLIB=ON -DLLVM_LINK_LLVM_DYLIB=ON \
                  -DLLVM_APPEND_VC_REV=OFF -DCMAKE_SHARED_LINKER_FLAGS_RELWITHDEBINFO="-fuse-ld=gold" \
                  -DCMAKE_C_FLAGS_RELWITHDEBINFO="-O2 -g -fno-omit-frame-pointer" \
                  -DCMAKE_CXX_FLAGS_RELWITHDEBINFO="-O2 -g -fno-omit-frame-pointer" \
                  -DLLVM_CCACHE_BUILD=ON
cd ..

mkdir -p build32
cd build32
cmake .. -G Ninja -DCMAKE_INSTALL_PREFIX=/usr/llvm/i386-linux-gnu -DLLVM_TARGETS_TO_BUILD="X86;AMDGPU" -DLLVM_ENABLE_ASSERTIONS=ON \
                  -DCMAKE_BUILD_TYPE=RelWithDebInfo -DLLVM_BUILD_LLVM_DYLIB=ON -DLLVM_LINK_LLVM_DYLIB=ON \
                  -DLLVM_APPEND_VC_REV=OFF -DCMAKE_SHARED_LINKER_FLAGS_RELWITHDEBINFO="-fuse-ld=gold" \
                  -DCMAKE_C_FLAGS_RELWITHDEBINFO="-O2 -g -fno-omit-frame-pointer" \
                  -DCMAKE_CXX_FLAGS_RELWITHDEBINFO="-O2 -g -fno-omit-frame-pointer" \
                  -DLLVM_BUILD_32_BITS=ON -DLLVM_CCACHE_BUILD=ON
