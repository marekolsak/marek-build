#!/bin/bash

# run-piglit.sh [-isol] [-gpu] [-prime] [-cts] [BASELINE|--] [piglit params]

prefix=`dirname $0`
prefix=`realpath $prefix`

cd `dirname $0`/piglit

export PIGLIT_SOURCE_DIR=$prefix/piglit

export PIGLIT_KHR_GL_BIN=$prefix/glcts/external/openglcts/modules/glcts
export PIGLIT_DEQP_EGL_BIN=$prefix/deqp/modules/egl/deqp-egl
export PIGLIT_DEQP_GLES2_BIN=$prefix/deqp/modules/gles2/deqp-gles2
export PIGLIT_DEQP_GLES3_BIN=$prefix/deqp/modules/gles3/deqp-gles3
export PIGLIT_DEQP_GLES31_BIN=$prefix/deqp/modules/gles31/deqp-gles31

export PIGLIT_KHRGL45_MUSTPASS=$prefix/glcts/external/openglcts/modules/gl_cts/data/mustpass/gl/khronos_mustpass/4.6.1.x/gl46-master.txt
export PIGLIT_DEQP_EGL_MUSTPASS=$prefix/deqp/android/cts/master/egl-master.txt
export PIGLIT_DEQP2_MUSTPASS=$prefix/deqp/android/cts/master/gles2-master.txt
export PIGLIT_DEQP3_MUSTPASS=$prefix/deqp/android/cts/master/gles3-master.txt
export PIGLIT_DEQP31_MUSTPASS=$prefix/deqp/android/cts/master/gles31-master.txt

export PIGLIT_KHR_GL_EXTRA_ARGS=--deqp-visibility=hidden
export PIGLIT_DEQP_EGL_EXTRA_ARGS=--deqp-visibility=hidden
export PIGLIT_DEQP_GLES2_EXTRA_ARGS=--deqp-visibility=hidden
export PIGLIT_DEQP_GLES3_EXTRA_ARGS=--deqp-visibility=hidden
export PIGLIT_DEQP_GLES31_EXTRA_ARGS=--deqp-visibility=hidden

ISOLATION=0
if test "x$1" = "x-isol"; then
    ISOLATION=1
    shift 1
fi

DISABLE="-x maxsize -x max[_-].*size -x maxuniformblocksize -x robustness.*infinite_loop -x deqp-gles31.functional.ssbo.layout.random.all_shared_buffer.48 -x ext_external_object"

PROFILE="khr_gl45 deqp_gles31 deqp_gles2 deqp_gles3 deqp_egl quick"

if test "x$1" = "x-gpu"; then
    PROFILE="gpu"
    shift 1
fi
if test "x$1" = "x-cts"; then
    PROFILE="khr_gl45"
    shift 1
fi

if test "x$1" = "x-deqp"; then
    PROFILE="deqp_gles2 deqp_gles3 deqp_gles31 deqp_egl"
    shift 1
fi
if test "x$1" = "x-deqp-egl"; then
    PROFILE="deqp_egl"
    shift 1
fi
if test "x$1" = "x-deqp2"; then
    PROFILE="deqp_gles2"
    shift 1
fi
if test "x$1" = "x-deqp3"; then
    PROFILE="deqp_gles3"
    shift 1
fi
if test "x$1" = "x-deqp31"; then
    PROFILE="deqp_gles31"
    shift 1
fi

if test "x$1" = "x-prime1"; then
    export DRI_PRIME=1
    export WAFFLE_GBM_DEVICE=/dev/dri/renderD128
    shift 1
fi

if test "x$1" = "x-prime2"; then
    export DRI_PRIME=1
    export WAFFLE_GBM_DEVICE=/dev/dri/renderD129
    shift 1
fi

BASELINE=$1
shift 1

SUMMARY="../piglit-summary"
RESULTS="../piglit-results"

NOW=`date "+%m-%d_%H:%M"`
RENDERER=`PIGLIT_PLATFORM=gbm bin/glinfo 2>&1| fgrep GL_RENDERER | cut -d" " -f3- | sed "s/AMD //; s/ ([^)]*)//g; s/\///g"`
PARAM_STR=`echo $@ | sed 's/^-c//; s/ -c//'`
NAME=`echo ${NOW}_${RENDERER}${PARAM_STR} | sed "s/ /_/g"`

echo "Name: $NAME"

export MESA_GLSL_CACHE_DISABLE=1
export MESA_DEBUG=silent
export PIGLIT_NO_FAST_SKIP=1
export NIR_VALIDATE=1
export GLSL_VALIDATE=1

./piglit run --deqp-mustpass-list --process-isolation $ISOLATION $DISABLE -c -p gbm $@ $PROFILE "$RESULTS/${NAME}" || exit 1

if test "x$BASELINE" != "x" && test "x$BASELINE" != "x--"; then
    ./piglit summary html -o "$SUMMARY/compare_${NAME}" "$RESULTS/${BASELINE}" "$RESULTS/${NAME}"
else
    ./piglit summary html -o "$SUMMARY/single_${NAME}" "$RESULTS/${NAME}"
fi
