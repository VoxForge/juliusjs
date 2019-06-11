#!/bin/bash

# (c) 2014 Zachary Pomerantz, @zzmp

###
# This script will emscript the Julius SRE
#
###

# Check dependencies
which git ||         { echo 'Missing git. Install git';
                       exit 1; }
which autoconf ||    { echo 'Missing autoconf. Install autoconf';
                       exit 1; }
which emconfigure || { echo 'Missing emconfigure';
                       echo 'Add emconfigure (from emscripten) to your path.';
                       exit 1; }
which emcc ||        { echo 'Missing emcc';
                       echo 'Add emcc (from emscripten) to your path.';
                       exit 1; }

mkdir -p build
mkdir -p src
mkdir -p bin
mkdir -p js

# Build julius.js
# - build intermediary targets
# -- add Web Audio adin_mic library

cp mods/libsent/configure.in src/libsent/.
# -- autoconf configure.in (can't get this to work, so just cp configure)
cp mods/libsent/configure src/libsent/.
cp mods/libsent/src/adin/adin_mic_webaudio.c src/libsent/src/adin/.

cp mods/libjulius/src/m_adin.c src/libjulius/src/.

# -- update app.h routines for (evented) multithreading
cp -f mods/julius/app.h src/julius/.
cp -f mods/julius/main.c src/julius/.
cp -f mods/julius/recogloop.c src/julius/.

# -- update libjulius for (evented) multithreading
cp -f mods/libjulius/src/recogmain.c src/libjulius/src/.
cp -f mods/libjulius/src/adin-cut.c src/libjulius/src/.


# -- remove implicit declarations per C99 errors
#pushd julius
#grep -Ev 'j_process_remove' module.c > tmp && mv tmp module.c
#grep -Ev 'j_process_lm_remove' module.c > tmp && mv tmp module.c
#popd

# -- emscript
emconfigure ./configure --with-mictype=webaudio
emmake make -j4
mv julius/julius julius/julius.bc

popd

# - build zlib intermediary targets
mkdir -p include
pushd include
# -- zlib
curl http://zlib.net/zlib-1.2.8.tar.gz | tar zx
mv zlib-1.2.8 zlib
pushd zlib
emconfigure ./configure
emmake make
popd
popd

popd

# - build javascript package
pushd js

# -- grab a recent voxforge LM
mkdir -p voxforge
pushd voxforge
curl http://www.repository.voxforge1.org/downloads/Main/Tags/Releases/0_1_1-build726/Julius_AcousticModels_16kHz-16bit_MFCC_O_D_\(0_1_1-build726\).tgz | tar zx
popd

emcc -O3 ../src/emscripted/julius/julius.bc -L../src/include/zlib -lz -o recognizer.js --preload-file voxforge -s INVOKE_RUN=0 -s NO_EXIT_RUNTIME=1 -s ALLOW_MEMORY_GROWTH=1 -s BUILD_AS_WORKER=1 -s EXPORTED_FUNCTIONS="['_main', '_main_event_recognition_stream_loop', '_end_event_recognition_stream_loop', '_event_recognize_stream', '_get_rate', '_fill_buffer']"

# -- copy the javascript wrappers
cp -fr ../dist/* . 

popd

# mark as built
touch .emscripted_flag
