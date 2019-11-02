Marek's approach to building AMD GPU drivers for driver development
===================================================================

You are going to need autoconf, automake, libtool, cmake, ninja, gcc, g++, and many lib development packages required by all the components.

Copy the files from this repository into the directory where you are going to clone all git repositories, so that the files are above the repository directories.

Use git to clone these:
- firmware: https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git/ (open the page)
- kernel: the amd-staging-drm-next branch is recommended. Use the internal AMD repository or the public mirror.
- libdrm: https://gitlab.freedesktop.org/mesa/drm (open the page)
- llvm-project: https://github.com/llvm/llvm-project.git (clone directly)
- meson: https://github.com/mesonbuild/meson.git (clone directly)
- mesa: https://gitlab.freedesktop.org/mesa/mesa (open the page)
- xf86-video-amdgpu: https://gitlab.freedesktop.org/xorg/driver/xf86-video-amdgpu (open the page)
- waffle: https://github.com/waffle-gl/waffle (open the page)
- piglit: git://people.freedesktop.org/~mareko/piglit (clone directly) - **Check out the `deqp` branch in piglit.**
- deqp: https://android.googlesource.com/platform/external/deqp/ (clone directly)
- glcts: https://github.com/KhronosGroup/VK-GL-CTS.git glcts (clone directly into the glcts directory)

You can skip firmware if you already have firmware for your GPU.

You can skip kernel and llvm if you don't intend to work on those. You are going to need llvm development packages if you are not going to build llvm manually.

Configure and build everything in the listed order, because there are dependencies:
- kernel depends on firmware
- libdrm and llvm don't depend on anything
- mesa uses meson for configuration of the build system
- mesa depends on libdrm and llvm
- xf86-video-amdgpu depends on libdrm and mesa
- waffle depends on mesa
- piglit depends on mesa and waffle
- deqp depends on mesa
- glcts depends on mesa


Building the driver
-------------------

Getting the firmware is not necessary if your distribution already contains firmware for your GPU. You can find your current firmware in `/lib/firmware/amdgpu`. Installing the firmware only consists of copying files from the firmware repository into that directory and re-installing the kernel (which packs the firmware into /boot/initrd*). The kernel only loads firmware from initrd.

**Most components may require installation of additional development library packages. Follow error messages to resolve them.**

**Kernel:** Go to the kernel directory and type:
```
make menuconfig # (to create the config; just exit if you don't want to change anything)
../build_kernel.sh
```
It will build and install the kernel.

**libdrm:** Go to the libdrm directory and type:
```
../conf_drm.sh
ninja -Cbuild
sudo ninja -Cbuild install
```

**LLVM:** Go to the llvm-project directory and type:
```
../conf_llvm.sh
ninja -Cbuild
sudo ninja -Cbuild install
```
`conf_llvm.sh` might fail for the build32 part of the script. Ignore that for now.

LLVM is installed outside of `/usr/lib`, so you need to copy the contents of the `etc` directory from this repository into `/etc`. Then, type this to notify ld about it:
```
sudo ldconfig
```
Now ld will be able to find LLVM.


**Mesa:** If you want to use LLVM installed in the standard directory paths, remove `--native-file` from `conf_mesa_meson.sh`. Otherwise, it will get the LLVM installation path from the llvm_config_* files.

Before configuring Mesa, you need to install meson from the repository linked at the beginning.

Go to the mesa directory and type:
```
../conf_mesa.sh
ninja -Cbuild
sudo ninja -Cbuild install
```
Mesa contains libGL, libEGL, libgbm, and libglapi, and drivers.

(Before or after installing Mesa on Ubuntu 16.04, the following hack has to be done: Remove all `libGL.*` and `libEGL.*` files that are not directly in `/usr/lib/x86_64-linux-gnu`, but are in subdirectories of that directory, and then run `sudo ldconfig`. You have to do it every time Ubuntu updates its Mesa packages.)


**xf86-video-amdgpu**: Go to the xf86-video-amdgpu directory and type:
```
./autogen --prefix=/usr
make -j16
sudo make install
```


Building OpenGL test suites
---------------------------

**Waffle:** Go to the waffle directory and type:
```
../conf_waffle.sh
ninja
sudo ninja install
```

**Piglit:** Go to the piglit directory and type:
```
../conf_piglit.sh
ninja
```
There is no installation step for piglit.

**DEQP:** Go to the deqp directory and type:
```
../conf_deqp.sh
ninja
```
There is no installation step for DEQP.

**GLCTS:** Go to the glcts directory and type:

You need to have a Khronos account and you need to upload your ssh public key into your Khronos Gitlab account. Then the following will fetch confidential Khronos source code that you need to build the desktop OpenGL Conformance Test Suite:
```
../conf_glcts.sh
ninja
```
There is no installation step for GLCTS.


First test
----------

To verify that everything is installed properly, run `driver-load-sanity-test` and `driver-render-sanity-test` from this repository. They have to pass for X to be able to even start. Those two are also the first tests to run when debugging X startup issues, because they use the same APIs as X (that is GBM + EGL).

Now reboot your machine and everything should work.

X crashes can also be debugged via gdb over ssh: `sudo gdb /usr/lib/xorg/Xorg`


Building 32-bit drivers
-----------------------

This step is unnecessary if you don't expect to test certain Steam games. You only need 32-bit libdrm, llvm, and Mesa. You don't need anything else.

It's the same as above except that you add these parameters:
```
../conf_drm.sh 32
../conf_mesa.sh 32
```

LLVM is already configured for the 32-bit build in its build32 directory. (if it didn't fail when you configured it above)

Then the build steps for libdrm, llvm, and mesa use build32 instead of build:

```
ninja -Cbuild32
sudo ninja -Cbuild32 install
```



Mesa development without `make install`
---------------------------------------

You have to do `make install` for the first time, so that waffle and piglit can find the latest Mesa, but you don't have to do that for any subsequent rebuilds of Mesa if you want to use the following method.

Run `make-mesa-symlinks.sh`. It will create symlinks pointing from the Mesa installation locations in `/usr/lib/....` into your `mesa` and `mesa32` directories. Now, rebuilding Mesa is all you need to make it visible to applications.

The less invasive alternative is to set these environment variables for a specific application that you want to run:
- `LIBGL_DRIVERS_PATH` to your `mesa/x86_64-linux-gnu/gallium` directory
- `LD_LIBRARY_PATH` to your `mesa/x86_64-linux-gnu` directory

I recommend using `LD_LIBRARY_PATH` for LLVM development without `ninja install`.


Piglit regression testing
-------------------------

Use `run-piglit.sh` from this repository. It will run piglit and create an HTML report in the `piglit-summary` directory.

To run piglit for the first time, type:
```
./run-piglit.sh
```

It will print the name of the run, for example:
```
Name: 04-11_19:35_VEGA12
```
The name of the run will also be on the first row of the HTML report table.

If you want to run piglit and compare it against a baseline, specify the baseline name on the command line. It will create an HTML report comparing your current run with the baseline:
```
./run-piglit.sh 04-11_19:35_VEGA12
```
The piglit results are stored in the `piglit-results` directory, while the HTML reports are stored separately in the `piglit-summary` directory. You can always regenerate the reports from the results or generate comparisons between two or more sets of results using the `./piglit summary html` command in the piglit repository.

Other examples:
- `./run-piglit.sh 04-11_19:35_VEGA12`: force concurrency for all tests (recommended but most tests are already run concurrently)
- `./run-piglit.sh`: if you want to specify a parameter but not a baseline, use `--` instead
- `./run-piglit.sh 04-11_19:35_VEGA12 -x view`: exclude all tests containing `view` in their name
- `./run-piglit.sh 04-11_19:35_VEGA12 -t clear`: run only tests containing `clear` in their name
- `./run-piglit.sh 04-11_19:35_VEGA12 -t clear -x view`: run tests containing `clear` but not containing `view`
- `./run-piglit.sh 04-11_19:35_VEGA12 -j1`: disable concurrency (`-j1`)

Disabling concurrency can help if you have an unstable kernel driver.


What to do if piglit hangs the GPU
----------------------------------

Run piglit with the `-isol` parameter before the baseline name:
```
./run-piglit.sh -isol 04-11_19:35_VEGA12
```
`-isol` enables process isolation for tests, meaning that tests are run as separate processes instead of combined into one process. This will make full test executable command lines visible to `ps`.

When it hangs, run `ps aux|grep piglit` over ssh to get command lines of currently running tests.  After reboot, you can run each line separately to find the hanging test.
