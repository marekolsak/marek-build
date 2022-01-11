Marek's approach to building AMD GPU drivers for driver development
===================================================================

You are going to need meson, autoconf, automake, libtool, cmake, ninja, gcc, g++, gcc-multilib, g++-multilib and many lib development packages required by all the components.

IMPORTANT: Install "spirv-tools". It's required by some piglit tests, but piglit doesn't check for that dependency.

Copy the files from this repository into the directory where you are going to clone all git repositories, so that the files are above the repository directories.

Use git to clone these:
- firmware: https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git/ (open the page)
- kernel: the amd-staging-drm-next branch is recommended. Use the internal AMD repository or the public mirror of the branch at https://gitlab.freedesktop.org/agd5f/linux/.
- libdrm: https://gitlab.freedesktop.org/mesa/drm (open the page)
- llvm-project: https://github.com/llvm/llvm-project.git (clone directly) <!-- - meson: https://github.com/mesonbuild/meson.git (clone directly) -->
- mesa: https://gitlab.freedesktop.org/mesa/mesa (open the page)
- xf86-video-amdgpu: https://gitlab.freedesktop.org/xorg/driver/xf86-video-amdgpu (open the page)
- waffle: https://gitlab.freedesktop.org/mesa/waffle (open the page)
- piglit: https://gitlab.freedesktop.org/mesa/piglit (open the page)
- deqp: https://android.googlesource.com/platform/external/deqp/ (clone directly)
- glcts: https://github.com/KhronosGroup/VK-GL-CTS.git glcts (clone directly into the glcts directory) - **Check out commit 26b37d8c2 because nothing compiles after that.**

You can skip firmware if you already have firmware for your GPU.

You can usually skip xf86-video-amdgpu. All distributions should ship a version that's a good enough.

You can skip kernel and llvm if you don't intend to work on those. If you skip them, you will need llvm development packages.

Configure and build everything in the listed order, because there are dependencies:
- kernel depends on firmware
- libdrm and llvm don't depend on anything
- mesa depends on libdrm and llvm
- xf86-video-amdgpu depends on libdrm and mesa
- waffle depends on mesa
- piglit depends on mesa and waffle
- deqp depends on mesa
- glcts depends on mesa


Building the driver
-------------------

Getting the firmware is not necessary if your distribution already contains firmware for your GPU. You can find your current firmware in `/lib/firmware/amdgpu`. The firmware is installed by copying files from the firmware repository into that directory and re-installing the kernel (which packs the firmware into /boot/initrd*). The kernel only loads firmware from initrd.

**Most components require installation of additional development library packages. Follow error messages to resolve them.**

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
LLVM is installed in `/usr/local/llvm`. You need to copy the contents of the `etc` directory from this repository into `/etc`. Then, type this to notify ld about it:
```
sudo ldconfig
```
Now ld will be able to find LLVM.


**Mesa:** If you want to use LLVM installed in the standard directory paths, remove `--native-file` from `conf_mesa.sh`. Otherwise, it will get the LLVM installation path from the llvm_config_* files.

<!-- Before configuring Mesa, you need to install meson from the repository linked at the beginning. -->

Go to the mesa directory and type:
```
../conf_mesa.sh
ninja -Cbuild
sudo ninja -Cbuild install
```
Mesa contains libGL, libEGL, libgbm, and libglapi, and drivers.


**xf86-video-amdgpu**: Go to the xf86-video-amdgpu directory and type:
```
./autogen --prefix=/usr
make -j`nproc`
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

There is no installation step for the test suites. They are run from the build directory directly.

**Piglit:** Go to the piglit directory and type:
```
../conf_piglit.sh
ninja
```

**DEQP:** Go to the deqp directory and type:
```
../conf_deqp.sh
ninja
```

**GLCTS:** You need to have a Khronos account and you need to upload your ssh public key into your Khronos Gitlab account. Then the conf_glcts.sh script will fetch confidential Khronos source code that you need for building the desktop OpenGL Conformance Test Suite.

Go to the glcts directory and type:
```
../conf_glcts.sh
ninja
```


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

LLVM is already configured for the 32-bit build in its build32 directory.

Then the build steps for libdrm, llvm, and mesa use build32 instead of build:

```
ninja -Cbuild32
sudo ninja -Cbuild32 install
```


Mesa development without `ninja install`
---------------------------------------

You have to do `ninja install` for Mesa for the first time, so that waffle and piglit can find the latest Mesa headers, but you don't have to do that for any subsequent rebuilds of Mesa if you want to use the following method.

Run `make-mesa-symlinks.sh`. It will create symlinks pointing from the Mesa installation locations (`/usr/lib/....`) into your `mesa/build` and `mesa/build32` directories. Now, rebuilding Mesa is all you need for updating it.


Piglit regression testing
-------------------------

Install Rust's package manager Cargo: https://www.rust-lang.org/tools/install

Then install `deqp-runner`:
```
cargo install deqp-runner
```
(adding `$HOME/.cargo/bin` to `PATH` will make it easier to run `deqp-runner`)


Then you can use the `radeonsi-run-tests.py` script to run all the tests suites.
The script is located in `mesa/src/gallium/drivers/radeonsi/ci/radeonsi-run-tests.py` (again, adding this path to `$PATH` avoids typing the whole path each time).

`radeonsi-run-tests.py` needs to know where it can find piglit, glcts and deqp. If you followed the above installation steps, you can either:
- run it like this: `./mesa/src/gallium/drivers/radeonsi/ci/radeonsi-run-tests.py --parent-path $PWD`
- or define `MAREKO_BUILD_PATH=$PWD` and then run it directly: `./mesa/src/gallium/drivers/radeonsi/ci/radeonsi-run-tests.py` (or `radeonsi-run-tests.py` if your `$PATH` variable contains `mesa/src/gallium/drivers/radeonsi/ci`)

The alternative is to pass the path of each test suite (see `--piglit-path`, `--glcts-path` and `--deqp-path` options).

By default the script will write the results in `/tmp`, eg: `/tmp/2022-01-07-16-59-39`.

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
