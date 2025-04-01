#!/bin/bash

set -e
python3 external/fetch_sources.py

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
