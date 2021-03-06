#!/bin/sh
HOME=your home directory
# Notes:
# if get: shared:ERROR: Configure step failed with non-zero return code: 1.  Command line: ./configure --with-mictype=webaudio --prefix=/home/daddy/git/juliusjs/build at /home/daddy/git/juliusjs/src
# run 'autoconf' in that sub-directory

# make clean - cd src && make distclean && cd ..
#              cd include/zlib && make clean && cd ../..
echo "### compiling julius to emcscript bytecode ###"
cd src
emconfigure ./configure --disable-pthread  --with-mictype=webaudio --prefix=$HOME/git/juliusjs/build
#EMCC_DEBUG=1 EM_BUILD_VERBOSE=3  emmake make
emmake make

# install binaries to dist folder
emmake make install
cd ..

echo "### compiling zlib library ###"
# TODO need to 'emmake make' include/zlib
cd include/zlib
emconfigure ./configure
emmake make
cd ../..

# rename julius LLVM bytcode file to something emcc will recognize
# should be a config setting to fix this...
cp -f build/bin/julius.js.mem build/bin/julius.bc

echo "### linking julius and zlib to create recognizer.js ###"
# error: undefined symbol: popen; therefore use: '-s ERROR_ON_UNDEFINED_SYMBOLS=0'
# see: https://github.com/emscripten-core/emscripten/issues/7302
cd dist
# emcc -O3 ../build/bin/julius.bc -o recognizer.html  \
# EMCC_DEBUG=1 EM_BUILD_VERBOSE=3 emcc -O0 ../build/bin/julius.bc -o recognizer.js
# no optimization (i.e no compression of resulting js code)
emcc -O0 ../build/bin/julius.bc -o recognizer.js  \
-L../include/zlib -lz \
--preload-file voxforge \
-s ERROR_ON_UNDEFINED_SYMBOLS=0 \
-s BUILD_AS_WORKER=1 \
-s INVOKE_RUN=0 \
-s NO_EXIT_RUNTIME=1 \
-s ALLOW_MEMORY_GROWTH=1 \
-s EXPORTED_FUNCTIONS="['_main', '_main_event_recognition_stream_loop', \
'_end_event_recognition_stream_loop', '_event_recognize_stream', '_fill_buffer']" \
-s EXTRA_EXPORTED_RUNTIME_METHODS='["ccall", "cwrap"]'

