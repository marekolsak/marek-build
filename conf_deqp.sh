#!/bin/bash

python3 external/fetch_sources.py

cmake . -G Ninja -DCMAKE_BUILD_TYPE=RelWithDebInfo

echo
echo !!! DEQP is not supposed to be installed !!!
