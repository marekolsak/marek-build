#!/bin/bash
cd `dirname $0`/piglit

# run-piglit.sh [-isol] [BASELINE|--] [piglit params]

ISOLATION=0
if test "x$1" = "x-isol"; then
    ISOLATION=1
    shift 1
fi

# quick:
DISABLE="-x max-texture-size -x tex3d-maxsize -x fbo-maxsize -x texture_buffer_object.max-size -x image_load_store.max-size -x texture_buffer_max_size"
DISABLE="$DISABLE -x khr_create_context.pre-gl3.2 -x khr_create_context.3.2"

PROFILE="quick"

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
