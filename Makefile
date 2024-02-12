AS=ca65
CC=cl65
CFLAGS=-ttelestrat
ASFLAGS=-ttelestrat
LDFILES=

all : init kernel memmap
.PHONY : all

SOURCE=src/kernel.asm

PROGRAM_NAME=kernel

ifeq ($(CC65_HOME),)
        CC = cl65
        AS = ca65
        LD = ld65
        AR = ar65
else
        CC = $(CC65_HOME)/bin/cl65
        AS = $(CC65_HOME)/bin/ca65
        LD = $(CC65_HOME)/bin/ld65
        AR = $(CC65_HOME)/bin/ar65
endif

PATH_PACKAGE_ROM=build/usr/share/$(PROGRAM_NAME)/

init:
	@mkdir -p $(PATH_PACKAGE_ROM)/
	@mkdir -p $(PATH_PACKAGE_ROM)/
	@mkdir -p build/usr/share/ipkg/
	@mkdir -p build/usr/share/man/
	@mkdir -p build/usr/share/doc/$(PROGRAM_NAME)/
	@mkdir -p build/usr/include/kernel/
	@mkdir -p build/usr/src/kernel/

kernel: $(SOURCE)
	@echo Rom are built in $(PATH_PACKAGE_ROM)
	@echo Build kernelsd.rom for Twilighte board
	@$(AS) --verbose -s -tnone --debug-info -o kernelsd.ld65 -DWITH_SDCARD_FOR_ROOT=1  $(SOURCE) $(ASFLAGS) > output.log
	@$(LD) -C src/kernel.cfg kernelsd.ld65 -m kernelsd.map -DWITH_SDCARD_FOR_ROOT=1 -DWITH_TWILIGHTE_BOARD=1  -Ln kernelsd.sym > output.log
	@cp kernel.rom kernelsd.rom
	@sed -re 's/al 00(.{4}) \.(.+)$$/\1 \2/' kernelsd.sym| sort > kernelsd2.sym > output.log
	@cp kernelsd.rom $(PATH_PACKAGE_ROM)/
	@cp kernelsd.sym  $(PATH_PACKAGE_ROM)/
	@cp kernelsd.map $(PATH_PACKAGE_ROM)/

	@echo Build kernelus.rom for Twilighte board
	@echo "WITH_TWILIGHTE_BOARD">$(PATH_PACKAGE_ROM)/kernelus.lst
	@$(AS) --verbose -s -tnone --debug-info -o kernelus.ld65  $(SOURCE) $(ASFLAGS) > output.log
	@$(LD) -C src/kernel.cfg kernelus.ld65 -m kernelus.map  -DWITH_TWILIGHTE_BOARD=1  -Ln kernelus.sym > output.log
	@cp kernel.rom kernelus.rom

unittest:
	$(CC) $(CFLAGS) tests/mkdir.c -o tmkdir
	$(CC) $(CFLAGS) tests/fwrite.c -o tfwrite

memmap:
	@$(AS) --verbose -s -tnone --debug-info -o kernel-telestrat.ld65 -DWITH_SDCARD_FOR_ROOT=1 $(SOURCE) $(ASFLAGS) > memmap.md
	@$(LD) -C src/kernel.cfg kernel-telestrat.ld65 -m kernel.map -o kernel-telestrat.ld65.rom -DWITH_ACIA=2 -DWITH_SDCARD_FOR_ROOT=1 -Ln kernel-telestrat.ca.sym
	sh generate_memmap.sh

test:
	cp Makefile build/usr/src/kernel/
	cp README.md build/usr/src/kernel/
	cp src/* build/usr/src/kernel/ -adpR
	cp README.md build/usr/share/doc/$(PROGRAM_NAME)/
	ls -l $(HOMEDIR)
	export ORIX_PATH=`pwd`
	sh tools/builddocs.sh
	cd build && tar -c * > ../$(PROGRAM_NAME).tar &&	cd ..
	filepack  $(PROGRAM_NAME).tar $(PROGRAM_NAME).pkg
	gzip $(PROGRAM_NAME).tar
	mv $(PROGRAM_NAME).tar.gz $(PROGRAM_NAME).tgz

