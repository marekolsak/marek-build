#!/bin/bash

set -e

error() {
    echo
    echo You need to be a Khronos member and add your ssh public key into your Khronos Gitlab account.
    echo Only then can you use the desktop OpenGL test suite.
    exit 1
}

python3 external/fetch_sources.py
python3 external/fetch_kc_cts.py --protocol ssh || error

rm -rf build
mkdir build
cmake -B build . -G Ninja -DCMAKE_BUILD_TYPE=RelWithDebInfo -DGLCTS_GTF_TARGET=gl -DDEQP_TARGET=x11_egl

rm -rf build_es
mkdir build_es
cmake -B build_es . -G Ninja -DCMAKE_BUILD_TYPE=RelWithDebInfo -DGLCTS_GTF_TARGET=gles32 -DDEQP_TARGET=x11_egl

echo
echo !!! GLCTS is not supposed to be installed !!!
echo Type:
echo '   ninja -Cbuild && ninja -Cbuild_es'
