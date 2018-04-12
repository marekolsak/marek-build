#!/bin/bash

cmake . -G Ninja -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=RelWithDebInfo \
	-Dwaffle_has_gbm=ON -Dwaffle_has_glx=ON -Dwaffle_has_x11_egl=ON

echo
echo !!! Make sure this output contains: Supported platforms: ... gbm !!!
