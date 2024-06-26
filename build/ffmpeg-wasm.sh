#!/bin/bash
# `-o <OUTPUT_FILE_NAME>` must be provided when using this build script.
# ex:
#     bash ffmpeg-wasm.sh -o ffmpeg.js

set -euo pipefail

EXPORT_NAME="createFFmpegCore"

CONF_FLAGS=(
  -I. 
  -I./src/fftools 
  -I$INSTALL_DIR/include 
  -L$INSTALL_DIR/lib 
  -Llibavcodec 
  -Llibavdevice 
  -Llibavfilter 
  -Llibavformat 
  -Llibavutil 
  -Llibpostproc 
  -Llibswresample 
  -Llibswscale 
  -lavcodec 
  -lavdevice 
  -lavfilter 
  -lavformat 
  -lavutil 
  -lpostproc 
  -lswresample 
  -lswscale 
  -Wno-deprecated-declarations 
  $LDFLAGS 
  -sWASM_BIGINT                            # enable big int support
  -sUSE_SDL=2                              # use emscripten SDL2 lib port
  -sMODULARIZE                             # modularized to use as a library
  -sINITIAL_MEMORY=1024MB                  # ALLOW_MEMORY_GROWTH is not recommended when using threads, thus we use a large initial memory
  -sPTHREAD_POOL_SIZE=32                   # use 32 threads
  -sPTHREAD_POOL_SIZE_STRICT=2             # abort on thread pool exhaustion
  -sEXPORT_NAME="$EXPORT_NAME"             # required in browser env, so that user can access this module from window object
  -sEXPORTED_FUNCTIONS=$(node src/bind/ffmpeg/export.js) # exported functions
  -sEXPORTED_RUNTIME_METHODS=$(node src/bind/ffmpeg/export-runtime.js) # exported built-in functions
  -lworkerfs.js
  --pre-js src/bind/ffmpeg/bind.js        # extra bindings, contains most of the ffmpeg.wasm javascript code
  # ffmpeg source code
  src/fftools/cmdutils.c 
  src/fftools/ffmpeg.c 
  src/fftools/ffmpeg_filter.c 
  src/fftools/ffmpeg_hw.c 
  src/fftools/ffmpeg_enc.c 
  src/fftools/ffmpeg_dec.c 
  src/fftools/ffmpeg_demux.c 
  src/fftools/ffmpeg_mux.c 
  src/fftools/ffmpeg_mux_init.c
  src/fftools/ffmpeg_opt.c 
  src/fftools/ffmpeg_sched.c
  src/fftools/opt_common.c
  src/fftools/sync_queue.c
  src/fftools/thread_queue.c
  src/fftools/objpool.c
)

emcc "${CONF_FLAGS[@]}" $@
