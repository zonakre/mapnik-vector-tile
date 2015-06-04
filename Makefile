MAPNIK_PLUGINDIR := $(shell mapnik-config --input-plugins)
BUILDTYPE ?= Release

all: libvtile

./deps/gyp:
	git clone https://chromium.googlesource.com/external/gyp.git ./deps/gyp && cd ./deps/gyp && git checkout 3464008

./deps/pbf:
	git clone https://github.com/mapbox/pbf.hpp.git ./deps/pbf && cd ./deps/pbf && git checkout 0d1c0061e4

build/Makefile: ./deps/pbf ./deps/gyp gyp/build.gyp test/*cpp

./deps/clipper:
	git clone https://github.com/mapnik/angus-clipper.git ./deps/clipper && cd ./deps/clipper && git checkout 972a403

build/Makefile: ./deps/gyp ./deps/clipper ./deps/pbf gyp/build.gyp test/*cpp
	deps/gyp/gyp gyp/build.gyp --depth=. -DMAPNIK_PLUGINDIR=\"$(MAPNIK_PLUGINDIR)\" -Goutput_dir=. --generator-output=./build -f make

libvtile: build/Makefile Makefile
	@$(MAKE) -C build/ BUILDTYPE=$(BUILDTYPE) V=$(V)

test: libvtile
	./build/$(BUILDTYPE)/tests

clean:
	rm -rf ./build

.PHONY: test


