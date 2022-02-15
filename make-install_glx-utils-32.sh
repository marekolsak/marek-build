#!/bin/bash

gcc -O2      -g -fno-omit-frame-pointer demos/src/xdemos/glxinfo.c demos/src/xdemos/glinfo_common.c -o /usr/bin/glxinfo   -lX11 -lGL -lm && echo "glxinfo installed."
gcc -O2 -m32 -g -fno-omit-frame-pointer demos/src/xdemos/glxinfo.c demos/src/xdemos/glinfo_common.c -o /usr/bin/glxinfo32 -lX11 -lGL -lm && echo "glxinfo32 installed."
gcc -O2      -g -fno-omit-frame-pointer demos/src/xdemos/glxgears.c -o /usr/bin/glxgears   -lX11 -lGL -lm && echo "glxgears installed."
gcc -O2 -m32 -g -fno-omit-frame-pointer demos/src/xdemos/glxgears.c -o /usr/bin/glxgears32 -lX11 -lGL -lm && echo "glxgears32 installed."
