# pngviewer

[![Build](https://github.com/nwagyu/pngviewer/actions/workflows/build.yml/badge.svg)](https://github.com/nwagyu/pngviewer/actions/workflows/build.yml)

This apps lets you display a PNG image on your [NumWorks calculator](https://www.numworks.com).

## Install the app

Installing is rather easy:
1. Download the latest `pngviewer.nwa` file from the [Releases](https://github.com/nwagyu/pngviewer/releases) page
2. Head to [my.numworks.com/apps](https://my.numworks.com/apps) to send the `nwa` file on your calculator. On this page you will be able to add the PNG file you want to display.

## How to use the app

Well, it's pretty dull: just launch the app and look at your image!

## FAQ

This app uses the simplified libpng API. As such, it will decode the entire PNG image in memory. Unfortunately, as a result, images that are too large just won't work.

## Dependencies

This programs uses two libraries:

|Library|Version|
|-|-|
|[zlib](https://zlib.net/)|1.2.12|
|[libpng](http://www.libpng.org/pub/png/libpng.html)|1.6.38|

## Build the app

To build this sample app, you will need to install the [embedded ARM toolchain](https://developer.arm.com/Tools%20and%20Software/GNU%20Toolchain) and [nwlink](https://www.npmjs.com/package/nwlink).

```shell
brew install numworks/tap/arm-none-eabi-gcc node # Or equivalent on your OS
npm install -g nwlink
make clean && make build
```
