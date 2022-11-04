Q ?= @
CC = arm-none-eabi-gcc
AR = arm-none-eabi-ar
RANLIB = arm-none-eabi-ranlib
NWLINK = npx --yes -- nwlink@0.0.15
LINK_GC = 1
LTO = 1

LIBS_PATH=$(shell pwd)/output/libs

CFLAGS += $(shell $(NWLINK) eadk-cflags)
CFLAGS += -Os
CPPFLAGS += -I$(LIBS_PATH)/include
CFLAGS += -fno-exceptions -fno-unwind-tables

LDFLAGS += --specs=nosys.specs
LDFLAGS += -L$(LIBS_PATH)/lib

ifeq ($(LINK_GC),1)
CFLAGS += -fdata-sections -ffunction-sections
LDFLAGS += -Wl,-e,main -Wl,-u,eadk_app_name -Wl,-u,eadk_app_icon -Wl,-u,eadk_api_level
LDFLAGS += -Wl,--gc-sections
endif

ifeq ($(LTO),1)
AR = arm-none-eabi-gcc-ar
RANLIB = arm-none-eabi-gcc-ranlib
CFLAGS += -flto -fno-fat-lto-objects
CFLAGS += -fwhole-program
CFLAGS += -fvisibility=internal
LDFLAGS += -flinker-output=nolto-rel
endif

.PHONY: build
build: output/pngviewer.nwa

output/libs/lib/libz.a:
	@mkdir -p output/libs && mkdir -p output/autoconf/zlib
	@echo "AUTOCNF $@"
	$(Q) cd output/autoconf/zlib && CC=$(CC) AR=$(AR) RANLIB=$(RANLIB) CFLAGS="$(CFLAGS)" ../../../src/zlib/configure --const --prefix=$(LIBS_PATH) --static > autoconf.log 2>&1
	@echo "MAKE    $@"
	$(Q) cd output/autoconf/zlib && make install > make.log 2>&1

output/libs/lib/libpng.a: output/libs/lib/libz.a
	@mkdir -p output/libs && mkdir -p output/autoconf/libpng
	@echo "AUTOCNF $@"
	$(Q) cd output/autoconf/libpng && AR=$(AR) RANLIB=$(RANLIB) ../../../src/libpng/configure --host=arm-none-eabi --disable-shared --prefix=$(LIBS_PATH) CPPFLAGS="$(CPPFLAGS)" CFLAGS="$(CFLAGS)" LDFLAGS="$(LDFLAGS)" > autoconf.log 2>&1
	@echo "MAKE    $@"
	$(Q) cd output/autoconf/libpng && make install > make.log 2>&1

.PHONY: check
check: output/pngviewer.bin

.PHONY: run
run: output/pngviewer.nwa src/hello.png
	@echo "INSTALL $<"
	$(Q) $(NWLINK) install-nwa --external-data src/hello.png $<

output/%.bin: output/%.nwa src/hello.png
	@echo "BIN     $@"
	$(Q) $(NWLINK) nwa-bin --external-data src/hello.png $< $@

output/%.elf: output/%.nwa src/hello.png
	@echo "ELF     $@"
	$(Q) $(NWLINK) nwa-elf --external-data src/hello.png $< $@

output/pngviewer.nwa: output/main.o output/icon.o
	@echo "LD      $@"
	$(Q) $(CC) $(CPPFLAGS) $(CFLAGS) -Wl,--relocatable -nostartfiles $(LDFLAGS) $^ -lpng -lz -lm -o $@

output/main.o: output/libs/lib/libz.a output/libs/lib/libpng.a

$(addprefix output/,%.o): src/%.c
	@mkdir -p $(@D)
	@echo "CC      $@"
	$(Q) $(CC) $(CPPFLAGS) $(CFLAGS) -c $< -o $@

output/icon.o: src/icon.png
	@echo "ICON    $<"
	$(Q) $(NWLINK) png-icon-o $< $@

.PHONY: clean
clean:
	@echo "CLEAN"
	$(Q) rm -rf output
