#!/bin/bash

set -e

if test "x$1" == x; then
    echo "The first parameter must be gl or gles32."
    exit 1
fi

error() {
    echo
    echo You need to be a Khronos member and add your ssh public key into your Khronos Gitlab account.
    echo Only then can you use the desktop OpenGL test suite.
    exit 1
}

python3 external/fetch_sources.py
python3 external/fetch_kc_cts.py --protocol ssh || error

mkdir build
cmake -B build . -G Ninja -DCMAKE_BUILD_TYPE=RelWithDebInfo -DGLCTS_GTF_TARGET=$1 -DDEQP_TARGET=x11_egl

echo
echo !!! GLCTS is not supposed to be installed !!!
echo Type \"ninja -Cbuild\" to build GLCTS.
