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

cmake . -G Ninja -DCMAKE_BUILD_TYPE=RelWithDebInfo -DGLCTS_GTF_TARGET=gl -DDEQP_TARGET=x11_egl

echo
echo !!! GLCTS is not supposed to be installed !!!
