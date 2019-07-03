#!/bin/bash
cd `dirname $0`/piglit

# run-piglit.sh [-isol] [-gpu] [-prime] [-cts] [BASELINE|--] [piglit params]

ISOLATION=0
if test "x$1" = "x-isol"; then
    ISOLATION=1
    shift 1
fi

DISABLE="-x maxsize -x max[_-].*size -x maxuniformblocksize -x robustness.*infinite_loop -x deqp-gles31.functional.ssbo.layout.random.all_shared_buffer.48"

PROFILE="quick"

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

./piglit run --process-isolation $ISOLATION $DISABLE -p gbm $@ $PROFILE "$RESULTS/${NAME}" || exit 1

if test "x$BASELINE" != "x" && test "x$BASELINE" != "x--"; then
    ./piglit summary html -o "$SUMMARY/compare_${NAME}" "$RESULTS/${BASELINE}" "$RESULTS/${NAME}"
else
    ./piglit summary html -o "$SUMMARY/single_${NAME}" "$RESULTS/${NAME}"
fi
