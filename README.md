Marek's approach to building AMD GPU drivers for driver development
===================================================================

These instructions have been verified on Ubuntu 26.04. Older versions of Ubuntu may need small adjustments.

The following packages are needed:

```bash
sudo apt install git make gcc flex bison libncurses-dev libssl-dev libelf-dev libzstd-dev zstd python3-setuptools libpciaccess-dev ninja-build libcairo2-dev gcc-multilib cmake-curses-gui g++ g++-multilib ccache libudev-dev libglvnd-dev libxml2-dev graphviz doxygen xsltproc xmlto xorg-dev libxcb-glx0-dev libx11-xcb-dev libxcb-dri2-0-dev libxcb-dri3-dev libxcb-present-dev libxshmfence-dev libxkbcommon-dev libvulkan-dev spirv-tools glslang-tools python3-numpy libcaca-dev python3-lxml autoconf libtool automake xutils-dev libva-dev wayland-protocols libwayland-egl-backend-dev python3-mako libsensors-dev libunwind-dev valgrind libxcb-keysyms1-dev curl libwaffle-dev python3-pip mold mesa-utils vulkan-tools libdw-dev gawk llvm-dev
```

Also 32-bit packages (only Ubuntu 26.04 requires the dpkg command):

```bash
sudo dpkg --add-architecture i386
sudo apt install libelf-dev:i386 libzstd-dev:i386 libpciaccess-dev:i386 libcairo2-dev:i386 libudev-dev:i386 libglvnd-dev:i386 libxml2-dev:i386 libxcb-glx0-dev:i386 libx11-xcb-dev:i386 libxcb-dri2-0-dev:i386 libxcb-dri3-dev:i386 libxcb-present-dev:i386 libxshmfence-dev:i386 libxfixes-dev:i386 libxxf86vm-dev:i386 libxrandr-dev:i386 libwayland-dev:i386 libwayland-egl-backend-dev:i386 libsensors-dev:i386 libunwind-dev:i386 libxcb-keysyms1-dev:i386
```

Put `/usr/lib/ccache:` at the beginning of PATH in `/etc/environment`. Optionally change the ccache max size:

```bash
ccache --max-size=50G
```

Ubuntu 26.04 may have recent enough meson that apt may be sufficient. If not, use pip. Choose one of these:
```bash
sudo apt install meson
sudo pip install meson --break-system-packages
```

Cloning repos
-------------

Notes:
- linux-firmware: The latest firmware is in the [linux-firmware](https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git/) repository. It's recommended to only download the latest tagged archive, not the whole repository. Getting newer firmware is not necessary if the distribution already contains firmware for the GPU. Installed firmware can be found in `/lib/firmware/amdgpu`. The firmware is installed by copying files from the firmware repository into that directory and running `sudo update-initramfs -k all -u` to update initrd. The kernel only loads firmware from initrd.
- libdrm can be skipped if Mesa doesn't fail to configure, but that's rare.
- The 32-bit driver is not needed if Steam is not going to be used because only Steam and some Steam games need 32-bit drivers.
- xf86-video-amdgpu is not needed. The modesetting DDX is recommended instead, which is part of the X server and is required by zink (in case that's needed).
- LLVM isn't needed if the goal is to use only ACO (which is the AMD GPU shader compiler in Mesa) or alternatively LLVM can be obtained from the distribution. If LLVM is built from source, using the latest release branch of LLVM is recommended.
- mesa/demos is only needed for building 32-bit glxinfo and glxgears to verify whether 32-bit Mesa is installed correctly and functional. 64-bit glxinfo and glxgears is provided by the distribution.
- If the distro kernel is recent enough, it may be sufficient.

These are usually recommended to build from source:
- linux
- libdrm
- mesa
- piglit
- VK-GL-CTS

ssh addresses can be used instead if needed.

```bash

# For configure scripts
git clone https://github.com/marekolsak/marek-build.git

# For the kernel:
git clone git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git
cd linux
git remote add agd5f https://gitlab.freedesktop.org/agd5f/linux.git # AMD staff should use the internal repository instead
git fetch agd5f
git checkout amd-staging-drm-next

# For userspace:
git clone https://gitlab.freedesktop.org/mesa/libdrm.git
git clone https://github.com/llvm/llvm-project.git # only if needed
git clone https://gitlab.freedesktop.org/mesa/mesa.git
git clone https://gitlab.freedesktop.org/mesa/demos.git # just for 32-bit glxinfo and glxgears
git clone https://gitlab.freedesktop.org/mesa/piglit.git
git clone https://github.com/KhronosGroup/VK-GL-CTS.git cts
```

**Build order for the driver:**
- linux-firmware (just copy the firmware files to /lib/firmware/amdgpu/ if needed)
- linux (the kernel, it uses firmware)
- libdrm
- llvm (if needed)
- mesa (depends on libdrm and optionally llvm)


Building the driver
-------------------

```bash

# 64-bit and 32-bit glxgears and glxinfo (optional, this uses the demos repository)
sudo marek-build/make-install_glx-utils-32.sh

# Kernel
cd linux
make oldconfig # later study localmodconfig to reduce the build size
scripts/config --set-str SYSTEM_TRUSTED_KEYS "" # These are needed when building from a plain source tree
scripts/config --set-str SYSTEM_REVOCATION_KEYS ""
scripts/config --enable LOCALVERSION_AUTO # This appends additional version information like the git commit ID to the kernel version
make olddefconfig
../marek-build/build_kernel.sh
cd ..

# libdrm
cd libdrm
../marek-build/conf_drm.sh
../marek-build/conf_drm.sh 32
ninja -Cbuild
ninja -Cbuild32
sudo ninja -Cbuild install
sudo ninja -Cbuild32 install
cd ..

# LLVM (optional)
cd llvm-project
sudo cp ../marek-build/etc/ld.so.conf.d/marek_llvm.conf /etc/ld.so.conf.d/
../marek-build/conf_llvm.sh
ninja -Cbuild
sudo ninja -Cbuild install
sudo ldconfig

# LLVM 32-bit (optional) - this is usually skipped because conf_mesa.sh always uses ACO for 32-bit arch
../marek-build/conf_llvm.sh 32
ninja -Cbuild32
sudo ninja -Cbuild32 install
sudo ldconfig
cd ..

# Mesa
# The script expects LLVM 21 from the distribution, which is the version
# present in Ubuntu 26.04. If LLVM isn't found, edit llvm_config_x86_64-linux-gnu.cfg
# to point to the preferred installed llvm-config.
# Some people also edit conf_mesa.sh to adjust the build options.
cd mesa
../marek-build/conf_mesa.sh
../marek-build/conf_mesa.sh 32
ninja -Cbuild
ninja -Cbuild32

# Installing Mesa is optional and might not be ideal depending on your
# development setup. See the section about how to use Mesa without installing
# it below.
sudo ninja -Cbuild install
sudo ninja -Cbuild32 install
sudo ldconfig
cd ..
```

If Mesa and libdrm are installed according to the above instructions, distribution libraries and header files will be overwritten. If the Linux distribution updates them, re-running `ninja install` may be needed.


Building test suites
--------------------

These can be built independently of drivers.

```bash
# piglit
cd piglit
../mesa/src/gallium/drivers/radeonsi/ci/build/conf_piglit.sh
ninja
cd ..

# VK-GL-CTS
cd cts
../mesa/src/gallium/drivers/radeonsi/ci/build/conf_glcts.sh
ninja -Cbuild
cd ..
```

Do not install the test suites. They should be run from their build directories.


First test
----------

Verify that the driver works without Xorg. If this works, Xorg will work too.

```bash
PIGLIT_PLATFORM=gbm piglit/bin/glinfo
PIGLIT_PLATFORM=gbm piglit/bin/fbo-generatemipmap -auto
```


Using Mesa without installing it
--------------------------------

An alternative to installing Mesa is to replace Mesa binaries in `/usr/lib` with symlinks pointing to the binaries in the Mesa build directory. Then every time Mesa is built, apps will use it immediately without having to install it first.

A script is provided that creates the symlinks:

```bash
marek-build/make-mesa-symlinks.sh
```

If the Linux distribution updates packages and overwrites the symlinks, just re-run the script.


Test suites and regression testing
----------------------------------

`radeonsi-run-tests.py` expects the cts directory to be called glcts. Make a symlink glcts -> cts.

Initial setup:
- mesa, piglit, and cts directories must be next to each other.
- Add `PATH=$HOME/?/mesa/src/gallium/drivers/radeonsi/ci:$PATH` into `.bashrc`. Replace `?` with the proper path.
- Only Ubuntu 24.04: Install Rust, which will include its package manager Cargo: https://www.rust-lang.org/tools/install
  - The installer will add the Cargo environment into `.bashrc`, which will add cargo into `PATH`.
  - Restart bash to get the new `PATH`.
- Run: `cargo install deqp-runner`

Then just type `radeonsi-run-tests.py` to run all test suites. It will store the results in the `test-results` directory next to the cloned repositories and print regression information into the terminal.

If the machine has multiple GPUs, you may select the one to test using `--gpu N`.

Expected tests results for some GPU types are stored directly in Mesa, so running `radeonsi-run-tests.py` will compare the results again this baseline. If the tests results are identical, the output will look like this:
```
$ radeonsi-run-tests.py
Tested GPU: 'AMD Radeon RX 6800 XT' (sienna_cichlid)
Output folder: '/tmp/2022-01-07-13-07-48'
Running piglit tests [baseline .../sienna_cichlid-piglit-quick-fail.csv]  ... Completed in 397 seconds
Running  GLCTS tests [baseline .../sienna_cichlid-glcts-fail.csv]  ... Completed in 338 seconds
Running   dEQP tests [baseline .../sienna_cichlid-deqp-fail.csv]  ... Completed in 649 seconds
```

If no baseline is available, or if new errors were found, the output will be similar to:
```
Tested GPU: 'AMD Radeon RX 6800 XT' (sienna_cichlid)
Output folder: '/tmp/2022-01-07-13-07-48'
Running piglit tests [baseline .../sienna_cichlid-piglit-quick-fail.csv]  ... Completed in 397 seconds
New errors. Check /tmp/2022-01-07-13-07-48/new_baseline/sienna_cichlid-piglit-quick-fail.csv
Running  GLCTS tests [baseline .../sienna_cichlid-glcts-fail.csv]  ... Completed in 338 seconds
New errors. Check /tmp/2022-01-07-13-07-48/new_baseline/sienna_cichlid-glcts-fail.csv
Running   dEQP tests [baseline .../sienna_cichlid-deqp-fail.csv]  ... Completed in 649 seconds
New errors. Check /tmp/2022-01-07-13-07-48/new_baseline/sienna_cichlid-deqp-fail.csv
```

The `*-fail.csv` files contain the unexpected results. `radeonsi-run-tests.py` has a test filter feature, and these files can be used to easily re-run the failed tests.
Here's an example, which also uses the `-v` (verbose) option:

```
$ radeonsi-run-tests.py -v -t /tmp/2022-01-07-13-07-48/new_baseline/sienna_cichlid-piglit-quick-fail.csv
Tested GPU: 'AMD Radeon RX 6800 XT' (sienna_cichlid)
Output folder: '/tmp/2022-01-07-17-06-01'
Running piglit tests
[baseline .../sienna_cichlid-piglit-quick-fail.csv]
| Running 4 piglit tests on 16 threads
| Pass: 0, Duration: 0
| ERROR - Test spec@!opengl 1.1@windowoverlap: Fail: See "/tmp/2022-01-07-17-06-01/piglit/piglit.spec@!opengl 1.1@windowoverlap.log"
| ERROR - Test spec@!opengl 1.1@windowoverlap: Fail: See "/tmp/2022-01-07-17-06-01/piglit/piglit.spec@!opengl 1.1@windowoverlap.log"
| ERROR - Test spec@ext_texture_integer@fbo-integer: UnexpectedPass: See "/tmp/2022-01-07-17-06-01/piglit/piglit.spec@ext_texture_integer@fbo-integer.log"
| ERROR - Test spec@ext_texture_integer@fbo-integer: UnexpectedPass: See "/tmp/2022-01-07-17-06-01/piglit/piglit.spec@ext_texture_integer@fbo-integer.log"
| ERROR - Test spec@arb_direct_state_access@gettextureimage-formats: UnexpectedPass: See "/tmp/2022-01-07-17-06-01/piglit/piglit.spec@arb_direct_state_access@gettextureimage-formats.log"
| ERROR - Test spec@arb_direct_state_access@gettextureimage-formats: UnexpectedPass: See "/tmp/2022-01-07-17-06-01/piglit/piglit.spec@arb_direct_state_access@gettextureimage-formats.log"
| Pass: 1, Fail: 1, UnexpectedPass: 2, Duration: 0, Remaining: 0
|
| Slowest tests:
| spec@arb_direct_state_access@gettextureimage-formats (0.29s)
| spec@arb_direct_state_access@gettextureimage-formats init-by-rendering (0.26s)
| spec@ext_texture_integer@fbo-integer (0.08s)
| spec@!opengl 1.1@windowoverlap (0.00s)
|
| Some failures found:
| spec@!opengl 1.1@windowoverlap,Fail
| spec@arb_direct_state_access@gettextureimage-formats,UnexpectedPass
| spec@ext_texture_integer@fbo-integer,UnexpectedPass
|
└ Completed in 0 seconds
New errors. Check /tmp/2022-01-07-17-06-01/new_baseline/sienna_cichlid-piglit-quick-fail.csv
Running  GLCTS tests
[baseline .../sienna_cichlid-glcts-fail.csv]
| Running dEQP on 16 threads in 1-test groups
| Pass: 0, Duration: 0
| Pass: 0, Duration: 0
|
└ Completed in 0 seconds
Running   dEQP tests
[baseline .../sienna_cichlid-deqp-fail.csv]
| Running dEQP on 16 threads in 1-test groups
| Running dEQP on 16 threads in 1-test groups
| Running dEQP on 16 threads in 1-test groups
| Running dEQP on 16 threads in 1-test groups
| Pass: 0, Duration: 0
| Pass: 0, Duration: 0
|
└ Completed in 0 seconds
```

As `radeonsi-run-tests.py` uses multiple processes / threads, the `-j` option can be used to control how many are spawned.
Lastly, there are several `--no-xxx` option to disable running specific tests suites (eg: `--no-deqp-egl`). Use `-h` to see all options.


What to do if piglit hangs the GPU
----------------------------------

When it hangs, run `ps aux|grep home` over ssh to get command lines of currently running tests.  After reboot, run each line separately to find the hanging test.
