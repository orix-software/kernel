AS=ca65
CC=cl65
CFLAGS=-ttelestrat
ASFLAGS=-ttelestrat
LDFILES=
ASCA65=ca65

all : init kernel 
.PHONY : all

HOMEDIR=/home/travis/bin/
HOMEDIR_ORIX=/home/travis/build/oric-software/orix
ORIX_VERSION=1

SOURCE_BANK7=src/kernel.asm
SOURCE_BANK5=src/orixbank5.asm
SOURCE_BANK4=src/monitor_bank4.asm
SOURCE_BANK1=src/empty.asm

TELESTRAT_TARGET_RELEASE=release/telestrat

ORIX_ROM=orix

ATMOS_ROM=ROMCH376_noram.rom

MYDATE = $(shell date +"%Y-%m-%d %H:%m")

ASFLAGS= -W -e error.txt -l xa_labels.txt -D__DATEBUILT__="$(MYDATE)"

PATH_PACKAGE_ROM=build/usr/share/$(ORIX_ROM)-$(ORIX_VERSION)/

init:
	mkdir -p $(PATH_PACKAGE_ROM)/6502/
	mkdir -p $(PATH_PACKAGE_ROM)/65c02/	
	mkdir -p build/usr/share/ipkg/
	mkdir -p build/usr/share/man/  
	mkdir -p build/usr/share/doc/$(ORIX_ROM)/
	mkdir -p build/usr/include/orix/
	mkdir -p build/usr/src/orix-source-1.0/src/
  
kernel: $(SOURCE_BANK7)
	$(AS) -o $(PATH_PACKAGE_ROM)/6502/kernel.rom $(SOURCE_BANK7) $(ASFLAGS) -DWITH_ACIA -DWITH_DISPLAY_BANK_SIGNATURE
	echo Generating Kernel for 32 banks ROM name kernela

test:
	xa tests/xrm.asm -o xrm
	xa tests/xmkdir.asm -o xmkdir
	cp src/include/orix.h build/usr/include/orix/
	cp Makefile build/usr/src/orix-source-1.0/
	cp README.md build/usr/src/orix-source-1.0/
	cp src/* build/usr/src/orix-source-1.0/src/ -adpR
	cp roms/basic11b_noram_test.rom build/usr/share/$(ORIX_ROM)-$(ORIX_VERSION)/6502/basic11.x02
	cp roms/basic11b_noram_test.rom build/usr/share/$(ORIX_ROM)-$(ORIX_VERSION)/65c02/basic11.x02	
	cp README.md build/usr/share/doc/$(ORIX_ROM)/
	ls -l $(HOMEDIR)
	export ORIX_PATH=`pwd`
	sh tools/builddocs.sh
	cd build && tar -c * > ../$(ORIX_ROM).tar &&	cd ..
	filepack  $(ORIX_ROM).tar $(ORIX_ROM).pkg
	gzip $(ORIX_ROM).tar
	mv $(ORIX_ROM).tar.gz $(ORIX_ROM).tgz
	php buildTestAndRelease/publish/publish2repo.php $(ORIX_ROM).pkg ${hash} 6502 pkg alpha
	php buildTestAndRelease/publish/publish2repo.php $(ORIX_ROM).tgz ${hash} 6502 tgz alpha
	php buildTestAndRelease/publish/publish2repo.php $(ORIX_ROM).pkg ${hash} 65c02 pkg alpha
	php buildTestAndRelease/publish/publish2repo.php $(ORIX_ROM).tgz ${hash} 65c02 tgz alpha
  
  
