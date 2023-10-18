#!/bin/bash

set -e

python3 external/fetch_sources.py

mkdir build
cmake -B build -G Ninja -DCMAKE_BUILD_TYPE=RelWithDebInfo

echo
echo !!! DEQP is not supposed to be installed !!!
echo Type \"ninja -Cbuild\" to build.