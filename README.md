JuliusJS - updated build
====

# A speech recognition library for the web
JuliusJS is a port of the "Large Vocabulary Continuous Speech Recognition
Engine [julius](https://github.com/julius-speech/julius)"
to JavaScript

[original source code](https://github.com/zzmp/juliusjs/)

## Getting started

### run build script

$ ./build.sh

## testing

### go to dist folder and start python web server:

$ cd juliusjs/dist

$ python -m SimpleHTTPServer 8080

(Note: On Ubuntu, you may need to add an entry to your /etc/mime.types file:
    "application/wasm      wasm")

### from your browser, go to this URL:

> https://localhost:8080
