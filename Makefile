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


PATH_PACKAGE_ROM=build/usr/share/$(PROGRAM_NAME)-$(ORIX_VERSION)/
RELEASE_PATH=release/
init:
	@mkdir -p $(PATH_PACKAGE_ROM)/6502/
	@mkdir -p $(PATH_PACKAGE_ROM)/65c02/	
	@mkdir -p $(RELEASE_PATH)/6502/twilighte/v0.3
	@mkdir -p $(RELEASE_PATH)/6502/telestrat
	@mkdir -p build/usr/share/ipkg/
	@mkdir -p build/usr/share/man/  
	@mkdir -p build/usr/share/doc/$(PROGRAM_NAME)/
	@mkdir -p build/usr/include/orix/
	@mkdir -p build/usr/src/orix-source-1.0/src/
	@mkdir -p build/usr/src/kernel/
  
kernel: $(SOURCE)
	@echo Create lib
	#@ca65 -ttelestrat src/functions/files/xgetcwd.asm -o src/functions/files/xgetcwd.o
	#@ar65 r lib/kernel.lib src/functions/files/xgetcwd.o
	@echo Rom are built in $(PATH_PACKAGE_ROM)
	@date +'.define __DATE__ "%F %R"' > src/build.inc
	@echo Build kernelsd.rom for Telestrat
	@$(AS) --verbose -s -tnone --debug-info -o kernel-telestrat.ld65 $(SOURCE) $(ASFLAGS) 
	@ld65 -tnone kernel-telestrat.ld65 -m kernel.map -o kernel-telestrat.ld65.rom -DWITH_ACIA=2 -DWITH_SDCARD_FOR_ROOT=1 -Ln kernel-telestrat.ca.sym
	@cp kernel-telestrat.ld65.rom $(RELEASE_PATH)/6502/telestrat
	@cp kernel-telestrat.ca.sym  $(RELEASE_PATH)/6502/telestrat

	@echo Build kernelsd.rom for Twilighte board
	@$(AS) --verbose -s -tnone --debug-info -o kernel-twil-sd.ld65 $(SOURCE) $(ASFLAGS) 
	@ld65 -tnone kernel-twil-sd.ld65 -m kernel-twil-sd.map -o kernel-twil-sd.rom -DWITH_SDCARD_FOR_ROOT=1 -DWITH_TWILIGHTE_BOARD=1 -Ln kernel-twil-sd.ca.sym
	@cp kernel-twil-sd.rom $(RELEASE_PATH)/6502/twilighte/v0.3
	@cp kernel-twil-sd.ca.sym  $(RELEASE_PATH)/6502/twilighte/v0.3
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
	php buildTestAndRelease/publish/publish2repo.php $(PROGRAM_NAME).pkg ${hash} 6502 pkg alpha
	php buildTestAndRelease/publish/publish2repo.php $(PROGRAM_NAME).tgz ${hash} 6502 tgz alpha
	php buildTestAndRelease/publish/publish2repo.php $(PROGRAM_NAME).pkg ${hash} 65c02 pkg alpha
	php buildTestAndRelease/publish/publish2repo.php $(PROGRAM_NAME).tgz ${hash} 65c02 tgz alpha
  
  
