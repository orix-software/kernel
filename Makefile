AS=ca65
CC=cl65
CFLAGS=-ttelestrat
ASFLAGS=-ttelestrat
LDFILES=

all : init kernel 
.PHONY : all

HOMEDIR=/home/travis/bin/
ORIX_VERSION=1

SOURCE=src/kernel.asm

PROGRAM_NAME=kernel

MYDATE = $(shell date +"%Y-%m-%d %H:%m")

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

ifdef TRAVIS_BRANCH
ifeq ($(TRAVIS_BRANCH), master)
RELEASE:=$(shell cat VERSION)
else
RELEASE:=alpha
endif
endif


PATH_PACKAGE_ROM=build/usr/share/$(PROGRAM_NAME)/
RELEASE_PATH=release/
init:
	@mkdir -p $(PATH_PACKAGE_ROM)/
	@mkdir -p $(PATH_PACKAGE_ROM)/	
	@mkdir -p build/usr/share/ipkg/
	@mkdir -p build/usr/share/man/  
	@mkdir -p build/usr/share/doc/$(PROGRAM_NAME)/
	@mkdir -p build/usr/include/kernel/
	@mkdir -p build/usr/src/kernel/
  
kernel: $(SOURCE)
	#@ca65 -ttelestrat src/functions/files/xgetcwd.asm -o src/functions/files/xgetcwd.o
	#@ar65 r lib/kernel.lib src/functions/files/xgetcwd.o
	@echo Rom are built in $(PATH_PACKAGE_ROM)
	@date +'.define __DATE__ "%F %R"' > src/build.inc
	@echo Build kernelsd.rom for Telestrat
	
	
	@$(AS) --verbose -s -tnone --debug-info -o kernel-telestrat.ld65 -DWITH_SDCARD_FOR_ROOT=1 $(SOURCE) $(ASFLAGS)
	@$(LD) -tnone kernel-telestrat.ld65 -m kernel.map -o kernel-telestrat.ld65.rom -DWITH_ACIA=2 -DWITH_SDCARD_FOR_ROOT=1 -Ln kernel-telestrat.ca.sym
	@echo Build kernelsd.rom for Twilighte board


	@$(AS) --verbose -s -tnone --debug-info -o kernelsd.ld65 -DWITH_SDCARD_FOR_ROOT=1  $(SOURCE) $(ASFLAGS) 
	@$(LD) -tnone kernelsd.ld65 -m kernelsd.map -o kernelsd.rom -DWITH_SDCARD_FOR_ROOT=1 -DWITH_TWILIGHTE_BOARD=1  -Ln kernelsd.sym
	@sed -re 's/al 00(.{4}) \.(.+)$$/\1 \2/' kernelsd.sym| sort > kernelsd2.sym
	@cp kernelsd.rom $(PATH_PACKAGE_ROM)/
	@cp kernelsd.sym  $(PATH_PACKAGE_ROM)/
	@cp kernelsd.map $(PATH_PACKAGE_ROM)/

	
	@echo Build kernelus.rom for Twilighte board
	@echo "WITH_TWILIGHTE_BOARD">$(PATH_PACKAGE_ROM)/kernelus.lst
	@$(AS) --verbose -s -tnone --debug-info -o kernelus.ld65  $(SOURCE) $(ASFLAGS) 
	@$(LD) -tnone kernelus.ld65 -m kernelus.map -o kernelus.rom -DWITH_TWILIGHTE_BOARD=1  -Ln kernelus.sym

	@echo Build kernelud.rom for Twilighte board 
	@$(AS) --verbose -s -tnone --debug-info -o kernelud.ld65 -DWITH_DEBUG_BOARD=1  $(SOURCE) $(ASFLAGS) 
	@$(LD) -tnone kernelud.ld65 -m kernelud.map -o kernelud.rom -DWITH_DEBUG_BOARD=1 -DWITH_TWILIGHTE_BOARD=1  -Ln kernelud.sym


	@sed -re 's/al 00(.{4}) \.(.+)$$/\1 \2/' kernelus.sym| sort > kernelus2.sym
	@cp kernelus.rom $(PATH_PACKAGE_ROM)/
	@cp kernelus.sym  $(PATH_PACKAGE_ROM)/
	@cp kernelus.map $(PATH_PACKAGE_ROM)/

	@echo Build kernelu0.rom for Twilighte board -ACIA
	@echo "WITH_TWILIGHTE_BOARD">$(PATH_PACKAGE_ROM)/kernelu0.lst
	@echo "WITH_ACIA=">>$(PATH_PACKAGE_ROM)/kernelu0.lst
	@$(AS) --verbose -s -tnone --debug-info -o kernelu0.ld65 -DWITH_ACIA=1  $(SOURCE) $(ASFLAGS) 
	@$(LD) -tnone kernelu0.ld65 -m kernelu0.map -o kernelu0.rom -DWITH_TWILIGHTE_BOARD=1 -DWITH_ACIA=1 -Ln kernelu0.sym
	@sed -re 's/al 00(.{4}) \.(.+)$$/\1 \2/' kernelu0.sym| sort > kernelu02.sym
	@cp kernelu0.rom $(PATH_PACKAGE_ROM)/
	@cp kernelu0.sym  $(PATH_PACKAGE_ROM)/
	@cp kernelu0.map $(PATH_PACKAGE_ROM)/

	
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
	echo Release : $(RELEASE)
	#php buildTestAndRelease/publish/publish2repo.php $(PROGRAM_NAME).tgz ${hash} 6502 tgz $(RELEASE)

  
  
