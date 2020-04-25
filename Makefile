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


ifdef TRAVIS_BRANCH
ifneq ($(TRAVIS_BRANCH), master)
RELEASE=alpha
endif
else
REALEASE:=$(shell cat VERSION)
endif


PATH_PACKAGE_ROM=build/usr/share/$(PROGRAM_NAME)/
RELEASE_PATH=release/
init:
	@mkdir -p $(PATH_PACKAGE_ROM)/
	@mkdir -p $(PATH_PACKAGE_ROM)/	
	@mkdir -p build/usr/share/ipkg/
	@mkdir -p build/usr/share/man/  
	@mkdir -p build/usr/share/doc/$(PROGRAM_NAME)/
	@mkdir -p build/usr/include/orix/
	@mkdir -p build/usr/src/kernel/
  
kernel: $(SOURCE)
	@echo Create lib
	#@ca65 -ttelestrat src/functions/files/xgetcwd.asm -o src/functions/files/xgetcwd.o
	#@ar65 r lib/kernel.lib src/functions/files/xgetcwd.o
	@echo Rom are built in $(PATH_PACKAGE_ROM)
	@date +'.define __DATE__ "%F %R"' > src/build.inc
	@echo Build kernelsd.rom for Telestrat
	@$(AS) --verbose -s -tnone --debug-info -o kernel-telestrat.ld65 -DWITH_SDCARD_FOR_ROOT=1  $(SOURCE) $(ASFLAGS) 
	@ld65 -tnone kernel-telestrat.ld65 -m kernel.map -o kernel-telestrat.ld65.rom -DWITH_ACIA=2 -DWITH_SDCARD_FOR_ROOT=1 -Ln kernel-telestrat.ca.sym
#	@cp kernel-telestrat.ld65.rom $(RELEASE_PATH)/6502/telestrat
#	@cp kernel-telestrat.ca.sym  $(RELEASE_PATH)/6502/telestrat

	@echo Build kernelsd.rom for Twilighte board
	@$(AS) --verbose -s -tnone --debug-info -o kernelsd.ld65 -DWITH_SDCARD_FOR_ROOT=1  $(SOURCE) $(ASFLAGS) 
	@ld65 -tnone kernelsd.ld65 -m kernelsd.map -o kernelsd.rom -DWITH_SDCARD_FOR_ROOT=1 -DWITH_TWILIGHTE_BOARD=1  -Ln kernelsd.sym
	@cp kernelsd.rom $(PATH_PACKAGE_ROM)/
	@cp kernelsd.sym  $(PATH_PACKAGE_ROM)/
	@cp kernelsd.map $(PATH_PACKAGE_ROM)/
	
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
	php buildTestAndRelease/publish/publish2repo.php $(PROGRAM_NAME).tgz ${hash} 6502 tgz $(RELEASE)
	
  
  
