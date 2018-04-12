#!/bin/bash

sudo echo && make -j`nproc` && sudo make modules_install && sudo make install
