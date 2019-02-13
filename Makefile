AS=ca65
CC=cl65
CFLAGS=-ttelestrat
ASFLAGS=-ttelestrat
LDFILES=

all : init kernel 
.PHONY : all

HOMEDIR=/home/travis/bin/
ORIX_VERSION=1

SOURCE_BANK7=src/kernel.asm
KERNEL_ROM=kernel

MYDATE = $(shell date +"%Y-%m-%d %H:%m")


PATH_PACKAGE_ROM=build/usr/share/$(KERNEL_ROM)-$(ORIX_VERSION)/

#--verbose -s -ttelestrat --include-dir %CC65%\asminc\ src/%ROM%.asm -o %ROM%.ld65 --debug-info
init:
	@mkdir -p $(PATH_PACKAGE_ROM)/6502/
	@mkdir -p $(PATH_PACKAGE_ROM)/65c02/	
	@mkdir -p build/usr/share/ipkg/
	@mkdir -p build/usr/share/man/  
	@mkdir -p build/usr/share/doc/$(KERNEL_ROM)/
	@mkdir -p build/usr/include/orix/
	@mkdir -p build/usr/src/orix-source-1.0/src/
  
kernel: $(SOURCE_BANK7)
	@date +'.define __DATE__ "%F %R"' > src/build.inc
	@$(AS) --verbose -s -tnone --debug-info -o kernel.ld65 $(SOURCE_BANK7) $(ASFLAGS) 
	@ld65 -tnone kernel.ld65 -o kernel.rom -Ln kernel.ca.sym
	@ld65 -tnone kernel.ld65 -DWITH_SDCARD_FOR_ROOT=1 -o kernelsd.rom -Ln kernelsd.ca.sym
	@sed -re 's/al 00(.{4}) \.(.+)$$/\1 \2/' kernel.ca.sym | sort >  kernel.sym	
	@rm kernel.ca.sym
	@echo Generating Kernel for 32 banks ROM name kernela

test:
	#xa tests/xrm.asm -o xrm
	#xa tests/xmkdir.asm -o xmkdir
	#cp src/include/orix.h build/usr/include/orix/
	cp Makefile build/usr/src/orix-source-1.0/
	cp README.md build/usr/src/orix-source-1.0/
	cp src/* build/usr/src/orix-source-1.0/src/ -adpR
	cp README.md build/usr/share/doc/$(KERNEL_ROM)/
	ls -l $(HOMEDIR)
	export ORIX_PATH=`pwd`
	sh tools/builddocs.sh
	cd build && tar -c * > ../$(KERNEL_ROM).tar &&	cd ..
	filepack  $(KERNEL_ROM).tar $(KERNEL_ROM).pkg
	gzip $(KERNEL_ROM).tar
	mv $(KERNEL_ROM).tar.gz $(KERNEL_ROM).tgz
	php buildTestAndRelease/publish/publish2repo.php $(KERNEL_ROM).pkg ${hash} 6502 pkg alpha
	php buildTestAndRelease/publish/publish2repo.php $(KERNEL_ROM).tgz ${hash} 6502 tgz alpha
	php buildTestAndRelease/publish/publish2repo.php $(KERNEL_ROM).pkg ${hash} 65c02 pkg alpha
	php buildTestAndRelease/publish/publish2repo.php $(KERNEL_ROM).tgz ${hash} 65c02 tgz alpha
  
  
