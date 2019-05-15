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

#--verbose -s -ttelestrat --include-dir %CC65%\asminc\ src/%ROM%.asm -o %ROM%.ld65 --debug-info
init:
	@mkdir -p $(PATH_PACKAGE_ROM)/6502/
	@mkdir -p $(PATH_PACKAGE_ROM)/65c02/	
	@mkdir -p build/usr/share/ipkg/
	@mkdir -p build/usr/share/man/  
	@mkdir -p build/usr/share/doc/$(PROGRAM_NAME)/
	@mkdir -p build/usr/include/orix/
	@mkdir -p build/usr/src/orix-source-1.0/src/
  
kernel: $(SOURCE)
	@date +'.define __DATE__ "%F %R"' > src/build.inc
	@$(AS) --verbose -s -tnone --debug-info -o $(PROGRAM_NAME).ld65 $(SOURCE) $(ASFLAGS) 
	@ld65 -tnone $(PROGRAM_NAME).ld65 -o $(PROGRAM_NAME)rom -Ln $(PROGRAM_NAME).ca.sym
	@echo Generating Kernel sd
	@ld65 -tnone $(PROGRAM_NAME).ld65 -DWITH_SDCARD_FOR_ROOT=1 -o kernelsd.rom -Ln kernelsd.ca.sym
	@sed -re 's/al 00(.{4}) \.(.+)$$/\1 \2/' $(PROGRAM_NAME).ca.sym | sort >  $(PROGRAM_NAME).sym	
	@rm $(PROGRAM_NAME).ca.sym
	@echo Generating Kernel for 32 banks ROM name kernela

test:
	#xa tests/xrm.asm -o xrm
	#xa tests/xmkdir.asm -o xmkdir
	#cp src/include/orix.h build/usr/include/orix/
	cp Makefile build/usr/src/orix-source-1.0/
	cp README.md build/usr/src/orix-source-1.0/
	cp src/* build/usr/src/orix-source-1.0/src/ -adpR
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
  
  
