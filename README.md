Marek's approach to building AMD GPU drivers for driver development
===================================================================

These instructions have been tested on Ubuntu 22.04.

You are going to need the following packages:

```bash
sudo apt install git make gcc flex bison libncurses-dev libelf-dev libzstd-dev libzstd-dev:i386 zstd python3-setuptools libpciaccess-dev ninja-build libcairo2-dev libva-dev gcc-multilib cmake-curses-gui g++ g++-multilib ccache libudev-dev libudev-dev:i386 libglvnd-dev libxml2-dev graphviz doxygen xsltproc xmlto xorg-dev wayland-protocols libwayland-egl-backend-dev libxcb-glx0-dev libxcb-glx0-dev:i386 libx11-xcb-dev libx11-xcb-dev:i386 libxcb-dri2-0-dev libxcb-dri2-0-dev:i386 libxcb-dri3-dev libxcb-dri3-dev:i386 libxcb-present-dev libxcb-present-dev:i386 libxshmfence-dev libxshmfence-dev:i386 libxfixes-dev libxfixes-dev:i386 libxxf86vm-dev libxxf86vm-dev:i386 libxrandr-dev libxkbcommon-dev libvulkan-dev spirv-tools glslang-tools python3-numpy libcaca-dev python3-lxml autoconf libtool automake xutils-dev vim meson build-essential
```

Put `/usr/lib/ccache:` at the beginning of PATH in `/etc/environment`.

```bash
ccache --max-size=50G
```

Cloning repos
-------------

### Guidelines:
- linux-firmware: Not necessary if your distribution already contains firmware for your GPU. You can find your current firmware in `/lib/firmware/amdgpu`. The firmware is installed by copying files from the firmware repository into that directory and re-installing the kernel (which packs the firmware into /boot/initrd*). The kernel only loads firmware from initrd.
- meson, libva, wayland-protocols (and the wayland dependency) are not needed if Mesa doesn't fail to configure. On Ubuntu 22.04, these dependencies should be met if the above mentioned list of packages are installed. Otherwise, build and install them from source.
- libdrm can be skipped if Mesa doesn't fail to configure, but that's rare.
- xf86-video-amdgpu is almost always not needed unless somebody explicitly told you that you need it.
- The 32-bit driver is not needed if Steam isn't going to be used because only Steam and some Steam games use it.

The optional sources can be skipped depending on your circumstances. Use your discretion to pick and choose from the optional sources, if necessary.
Clone with ssh for the repositories where you will want to push. The below commands only give you read-only access.

### Optional sources to install

```bash
# Frequently installed dependencies
git clone git://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git # Ideally use the AMD internal repository instead
git clone https://gitlab.freedesktop.org/agd5f/linux.git -b amd-staging-drm-next # Ideally use the AMD internal repository instead
git clone https://gitlab.freedesktop.org/xorg/driver/xf86-video-amdgpu.git
git clone https://gitlab.freedesktop.org/mesa/demos.git # just for glxinfo and glxgears

# Other dependencies
git clone https://github.com/mesonbuild/meson.git build-meson
git clone https://github.com/intel/libva.git
git clone https://gitlab.freedesktop.org/wayland/wayland.git
git clone https://gitlab.freedesktop.org/wayland/wayland-protocols.git
git clone https://gitlab.freedesktop.org/glvnd/libglvnd.git
```

### Essential sources to install

```bash
# For the driver:
git clone https://gitlab.freedesktop.org/mesa/drm.git
git clone https://github.com/llvm/llvm-project.git
git clone https://gitlab.freedesktop.org/mesa/mesa.git

# For test suites:
git clone https://gitlab.freedesktop.org/mesa/waffle.git
git clone https://gitlab.freedesktop.org/mesa/piglit.git
git clone https://android.googlesource.com/platform/external/deqp/
git clone https://github.com/KhronosGroup/VK-GL-CTS.git glcts -b opengl-cts-4.6.2
```

**Build order for the driver:**
- firmware (just copy the firmware files to /lib/firmware/amdgpu/)
- kernel (depends on firmware)
- libdrm
- llvm
- mesa (depends on libdrm and llvm)
- xf86-video-amdgpu (depends on libdrm and mesa)

**Build order for test suites:**
- waffle (depends on mesa) - install
- piglit (depends on mesa and waffle) - don't install
- deqp (depends on mesa) - don't install
- glcts (depends on mesa) - don't install


Building the driver
-------------------

Notes:
- If you get Mesa build failures due to LLVM, go back to llvm-project, check out the latest release/* branch in git, and repeat all step for LLVM. Then repeat all steps for Mesa.
- The instructions below are in the recommended build order. 

```bash
# Meson (optional)
cd build-meson
sudo python3 setup.py install

# libva (optional)
cd libva
meson build -Dprefix=/usr -Dlibdir=lib/x86_64-linux-gnu
ninja -Cbuild
sudo ninja -Cbuild install

# Wayland (for wayland-protocols) (optional)
cd wayland
meson build -Dprefix=/usr -Dlibdir=lib/x86_64-linux-gnu
ninja -Cbuild
sudo ninja -Cbuild install

# wayland-protocols (optional)
cd wayland-protocols
meson build -Dprefix=/usr -Dlibdir=lib/x86_64-linux-gnu
ninja -Cbuild
sudo ninja -Cbuild install

# Kernel (optional)
cd linux
sudo apt install linux-source; cp -r /usr/src/linux-source-*/debian . # to fix a compile failure on Ubuntu
../marek-build/build_kernel.sh

# libdrm (essential)
cd drm
../marek-build/conf_drm.sh
../marek-build/conf_drm.sh 32
ninja -Cbuild
ninja -Cbuild32
sudo ninja -Cbuild install
sudo ninja -Cbuild32 install

# LLVM (essential)
cd llvm-project
sudo cp ../marek-build/etc/ld.so.conf.d/marek_llvm.conf /etc/ld.so.conf.d/
../marek-build/conf_llvm.sh
ninja -Cbuild
ninja -Cbuild32
sudo ninja -Cbuild install
sudo ninja -Cbuild32 install
sudo ldconfig

# libglvnd (optional)
cd libglvnd
../marek-build/conf_glvnd.sh
ninja -Cbuild
sudo ninja -Cbuild install

# Mesa (essential)
cd mesa
../marek-build/conf_mesa.sh
../marek-build/conf_mesa.sh 32
ninja -Cbuild
ninja -Cbuild32
sudo ninja -Cbuild install
sudo ninja -Cbuild32 install
sudo ldconfig

# Install the latest 64-bit and 32-bit glxgears and glxinfo (this uses the demos repository) (optional)
sudo marek-build/make-install_glx-utils-32.sh

# xf86-video-amdgpu (usually not needed - optional)
cd xf86-video-amdgpu
./autogen.sh --prefix=/usr
make -j`nproc`
sudo make install
```

The above instructions overwrite distribution libraries and header files. If your Linux distribution updates them, you'll have to reinstall them from source.


Building OpenGL test suites
---------------------------

For GLCTS, you need a Khronos account and you need to upload your ssh public key into your Khronos Gitlab account. Then the conf_glcts.sh script will fetch additional Khronos source code that you need for building the desktop OpenGL Conformance Test Suite.

```bash
# Waffle (essential)
cd waffle
../marek-build/conf_waffle.sh
ninja -Cbuild
sudo ninja -Cbuild install

# piglit (essential)
cd piglit
../marek-build/conf_piglit.sh
ninja

# deqp (essential)
cd deqp
../marek-build/conf_deqp.sh
ninja

# glcts (essential)
cd glcts
../marek-build/conf_glcts.sh
ninja
```

First test
----------

Verify that the driver is working without Xorg. If this works, Xorg will work too.

```bash
PIGLIT_PLATFORM=gbm piglit/bin/glinfo
PIGLIT_PLATFORM=gbm piglit/bin/fbo-generatemipmap -auto
```

Xorg startup crashes can be debugged via gdb over ssh like this: `sudo gdb /usr/lib/xorg/Xorg`


Mesa development and testing without subsequent installation
------------------------------------------------------------

After you run `ninja install` for Mesa, you don't have to install it every time you rebuild it if you add symlinks from `/usr/lib` into your build directory. Then, you just build Mesa and the next started app will use it. There is a script that creates the symlinks:

```bash
marek-build/make-mesa-symlinks.sh
```

If your Linux distribution updates packages and overwrites your symlinks, just re-run the script.


Test suites and regression testing
----------------------------------

Initial setup:
- mesa, piglit, deqp, and glcts directories must be next to each other.
- Add `PATH=$HOME/?/mesa/src/gallium/drivers/radeonsi/ci:$PATH` into `.bashrc`. Replace `?` with the proper path.
- Install Rust, which will include its package manager Cargo: https://www.rust-lang.org/tools/install
  - The installer will add the Cargo environment into `.bashrc`, which will add cargo into `PATH`.
- Restart bash to get the new `PATH`.
- Run: `cargo install deqp-runner`

Then just type `radeonsi-run-tests.py` to run all test suites. It will store the results in the `test-results` directory next to the cloned repositories and print regression information into the terminal.

If your machine has multiple GPUs, you can select the one to test with `--gpu N`.

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

When it hangs, run `ps aux|grep home` over ssh to get command lines of currently running tests.  After reboot, you can run each line separately to find the hanging test.
