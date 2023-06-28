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
	@date +'.define __DATE__ "%F %R"' > src/build.inc
	@echo Build kernelsd.rom for Telestrat

	@$(AS) --verbose -s -tnone --debug-info -o kernel-telestrat.ld65 -DWITH_SDCARD_FOR_ROOT=1 $(SOURCE) $(ASFLAGS) > output.log
	@$(LD) -tnone kernel-telestrat.ld65 -m kernel.map -o kernel-telestrat.ld65.rom -DWITH_ACIA=2 -DWITH_SDCARD_FOR_ROOT=1 -Ln kernel-telestrat.ca.sym > output.log
	@echo Build kernelsd.rom for Twilighte board

	@$(AS) --verbose -s -tnone --debug-info -o kernelsd.ld65 -DWITH_SDCARD_FOR_ROOT=1  $(SOURCE) $(ASFLAGS) > output.log
	@$(LD) -tnone kernelsd.ld65 -m kernelsd.map -o kernelsd.rom -DWITH_SDCARD_FOR_ROOT=1 -DWITH_TWILIGHTE_BOARD=1  -Ln kernelsd.sym > output.log
	@sed -re 's/al 00(.{4}) \.(.+)$$/\1 \2/' kernelsd.sym| sort > kernelsd2.sym > output.log
	@cp kernelsd.rom $(PATH_PACKAGE_ROM)/
	@cp kernelsd.sym  $(PATH_PACKAGE_ROM)/
	@cp kernelsd.map $(PATH_PACKAGE_ROM)/


	@echo Build kernelus.rom for Twilighte board
	@echo "WITH_TWILIGHTE_BOARD">$(PATH_PACKAGE_ROM)/kernelus.lst
	@$(AS) --verbose -s -tnone --debug-info -o kernelus.ld65  $(SOURCE) $(ASFLAGS) > output.log
	@$(LD) -tnone kernelus.ld65 -m kernelus.map -o kernelus.rom -DWITH_TWILIGHTE_BOARD=1  -Ln kernelus.sym > output.log

	@echo Build kernelud.rom for Twilighte board
	@$(AS) --verbose -s -tnone --debug-info -o kernelud.ld65 -DWITH_DEBUG_BOARD=1  $(SOURCE) $(ASFLAGS) > output.log
	@$(LD) -tnone kernelud.ld65 -m kernelud.map -o kernelud.rom -DWITH_DEBUG_BOARD=1 -DWITH_TWILIGHTE_BOARD=1  -Ln kernelud.sym > output.log


	@sed -re 's/al 00(.{4}) \.(.+)$$/\1 \2/' kernelus.sym| sort > kernelus2.sym
	@cp kernelus.rom $(PATH_PACKAGE_ROM)/
	@cp kernelus.sym  $(PATH_PACKAGE_ROM)/
	@cp kernelus.map $(PATH_PACKAGE_ROM)/

	@echo Build kernelu0.rom for Twilighte board -ACIA
	@echo "WITH_TWILIGHTE_BOARD">$(PATH_PACKAGE_ROM)/kernelu0.lst
	@echo "WITH_ACIA=">>$(PATH_PACKAGE_ROM)/kernelu0.lst
	@$(AS) --verbose -s -tnone --debug-info -o kernelu0.ld65 -DWITH_ACIA=1  $(SOURCE) $(ASFLAGS) > output.log
	@$(LD) -tnone kernelu0.ld65 -m kernelu0.map -o kernelu0.rom -DWITH_TWILIGHTE_BOARD=1 -DWITH_ACIA=1 -Ln kernelu0.sym > output.log
	@sed -re 's/al 00(.{4}) \.(.+)$$/\1 \2/' kernelu0.sym| sort > kernelu02.sym
	@cp kernelu0.rom $(PATH_PACKAGE_ROM)/
	@cp kernelu0.sym  $(PATH_PACKAGE_ROM)/
	@cp kernelu0.map $(PATH_PACKAGE_ROM)/

	@echo Build kernlus.c02 : Kernel for 65C02
	@$(AS) --cpu 65C02 --verbose -s -tnone --debug-info -o kernelusc02.ld65  $(SOURCE) $(ASFLAGS) > output.log
	@$(LD) -tnone kernelusc02.ld65 -m kernelus.map -o kernelus.c02 -DWITH_TWILIGHTE_BOARD=1  -Ln kernelus.sym > output.log

	@echo Build kernlus.c02 : Kernel for 65C816
	@$(AS) --cpu 65816 --verbose -s -tnone --debug-info -o kernelus816.ld65  $(SOURCE) $(ASFLAGS) > output.log
	@$(LD) -tnone kernelus816.ld65 -m kernelus.map -o kernelus.816 -DWITH_TWILIGHTE_BOARD=1 -Ln kernelus.sym > output.log

unittest:
	$(CC) $(CFLAGS) tests/mkdir.c -o tmkdir
	$(CC) $(CFLAGS) tests/fwrite.c -o tfwrite

memmap:
	@$(AS) --verbose -s -tnone --debug-info -o kernel-telestrat.ld65 -DWITH_SDCARD_FOR_ROOT=1 $(SOURCE) $(ASFLAGS) > memmap.md
	@$(LD) -tnone kernel-telestrat.ld65 -m kernel.map -o kernel-telestrat.ld65.rom -DWITH_ACIA=2 -DWITH_SDCARD_FOR_ROOT=1 -Ln kernel-telestrat.ca.sym
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

