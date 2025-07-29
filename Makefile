AS=ca65
CC=cl65
CFLAGS=-ttelestrat
ASFLAGS=-ttelestrat
LDFILES=

all : init kernel memmap
.PHONY : prepare_tmp all

prepare_tmp:
	@mkdir -p tmp/

KCH395_LIB_VERSION=2025.1
SOURCE=src/kernel.asm
PROGRAM_NAME=kernel

ifeq ($(strip $(GITHUB_WORKSPACE)),)
    WORKSPACE = $(ORICUTRON_PATH)
else
    WORKSPACE = $(GITHUB_WORKSPACE)/oricutron/
endif

ifeq ($(CC65_HOME),)
    CL = cl65
    CC = cc65
    AS = ca65
    LD = ld65
    AR = ar65
else
    CL = $(CC65_HOME)/bin/cl65
    CC = $(CC65_HOME)/bin/cc65
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
	@mkdir -p tmp/
	@cd src/kernel8 && bpm update && cd ..
	@echo Rom are built in $(PATH_PACKAGE_ROM)
	@echo "########################################################"
	@echo "#  Build kernelsd.rom for Twilighte board              #"
	@echo "########################################################"
	@$(AS) --cpu 6502 -tnone src/functions/strings/xminma.asm -o tmp/xminma.o
	@$(AS) --cpu 6502 -tnone src/functions/bank_mng/switch_to_kernel_extended.s -o tmp/switch_to_kernel_extended.o
	@$(AS) --cpu 6502 -tnone src/functions/bank_mng/kernel_restore_banking_states.s -o tmp/kernel_restore_banking_states.o
	@$(AS) --cpu 6502 -tnone src/functions/lib_mng/XBANK_ROUTINE.s -o tmp/xbank_routine.o
	@$(AS) --cpu 6502 -tnone src/functions/network/init_network.s -o tmp/init_network.o
	@$(AS) --cpu 6502 -tnone src/functions/bank_mng/search_free_bank.s -o tmp/search_free_bank.o
	@$(AS) --cpu 6502 -tnone src/functions/bank_mng/kernel_free_bank.s -o tmp/kernel_free_bank.o
	@$(AS) --cpu 6502 -tnone src/functions/bank_mng/kernel_free_bank_by_pid.s -o tmp/kernel_free_bank_by_pid.o
	@$(AS) --cpu 6502 -tnone src/functions/network/close_sockets_by_pid.s -o tmp/close_sockets_by_pid.o
	@$(AS) --cpu 6502 -tnone src/functions/network/xsocket.s -o tmp/xsocket.o
	@$(AS) --cpu 6502 -tnone src/functions/network/xconnect.s -o tmp/xconnect.o
	@$(AS) --cpu 6502 -tnone src/functions/network/xsend.s -o tmp/xsend.o
	@$(AS) --cpu 6502 -tnone src/functions/network/xclose_socket.s -o tmp/xclose_socket.o

	@$(AR) r tmp/kernel.lib tmp/xminma.o
	@$(AR) r tmp/kernel.lib tmp/switch_to_kernel_extended.o
	@$(AR) r tmp/kernel.lib tmp/kernel_restore_banking_states.o
	@$(AR) r tmp/kernel.lib tmp/xbank_routine.o
	@$(AR) r tmp/kernel_bank8.lib tmp/init_network.o
	@$(AR) r tmp/kernel_bank8.lib tmp/search_free_bank.o
	@$(AR) r tmp/kernel_bank8.lib tmp/kernel_free_bank.o
	@$(AR) r tmp/kernel_bank8.lib tmp/kernel_free_bank_by_pid.o
	@$(AR) r tmp/kernel_bank8.lib tmp/xsocket.o
	@$(AR) r tmp/kernel_bank8.lib tmp/xconnect.o
	@$(AR) r tmp/kernel_bank8.lib tmp/xsend.o
	@$(AR) r tmp/kernel_bank8.lib tmp/xclose_socket.o
	@$(AR) r tmp/kernel_bank8.lib tmp/close_sockets_by_pid.o


	@$(AS) --cpu 6502 -DWITH_SDCARD_FOR_ROOT=1 --verbose -s -ttelestrat src/kernel_main_memory.s -o tmp/kernel_main_memory.ld65

	echo ici
	@$(AS) --verbose -s --debug-info --cpu 6502 src/kernel8/src/kernel8.s -o tmp/kernel_bank8.ld65 $(ASFLAGS) > output.log
	echo ici2
	@$(AS) --verbose -s --debug-info -o tmp/kernel_bank0.ld65 -DWITH_SDCARD_FOR_ROOT=1 src/kernel_bank0.s $(ASFLAGS) > output.log
	@$(AS) --verbose -s --debug-info -o tmp/kernelsd.ld65 -DWITH_SDCARD_FOR_ROOT=1 $(SOURCE) $(ASFLAGS) > output.log

	echo ici3
	@$(LD) -C cfg/kernel.cfg -DWITH_SDCARD_FOR_ROOT=1 tmp/kernelsd.ld65 tmp/kernel_bank0.ld65 tmp/kernel_main_memory.ld65 tmp/kernel.lib -Ln tmp/kernelsd.sym -m tmp/memmap.txt -vm
	@cp kernel.rom kernelsd.rom

	@$(AS) --cpu 6502 -DWITH_SDCARD_FOR_ROOT=1 --verbose -s -ttelestrat src/kernel_bank0.s -o tmp/kernel_bank0.ld65 --debug-info > memmap.md
	@$(LD) -C cfg/rom.cfg tmp/kernel_bank8.ld65 tmp/kernel_bank0.ld65 tmp/kernel_main_memory.ld65 tmp/kernel_bank8.lib src/kernel8/orixlibs/ksocket/usr/share/ksocket/2025.1/ksocket.lib  src/kernel8/orixlibs/kch395/usr/share/kch395/$(KCH395_LIB_VERSION)/kch395.lib src/kernel8/orixlibs/ch395/usr/share/ch395/2024.4/ch395.lib -o kernel8.rom -Ln tmp/kernel8sd.sym -m tmp/memmap8.txt -vm


	@#@sed -re 's/al 00(.{4}) \.(.+)$$/\1 \2/' kernelsd.sym| sort > kernelsd2.sym > output.log
	@cp kernelsd.rom $(PATH_PACKAGE_ROM)/
	@#@cp kernelsd.sym $(PATH_PACKAGE_ROM)/
	@#@cp kernelsd.map $(PATH_PACKAGE_ROM)/

	@echo "########################################################"
	@echo "#       Build kernelus.rom for Twilighte board         #"
	@echo "########################################################"
	@$(AS) --verbose -s --debug-info -o kernel_bank0.ld65 -DWITH_TWILIGHTE_BOARD=1 src/kernel_bank0.s $(ASFLAGS) > output.log
	@echo "WITH_TWILIGHTE_BOARD">$(PATH_PACKAGE_ROM)/kernelus.lst
	@$(AS) --verbose -s --debug-info -o kernelus.ld65 $(SOURCE) $(ASFLAGS) > output.log



compile_cc65:
	@echo "########################################################"
	@echo "#       Compile C file with cc65                        #"
	@echo "########################################################"
	@echo "FILE_TO_COMPILE: $(FILE_TO_COMPILE) FINAL_BIN: $(FINAL_BIN) "
	@$(CC) $(CFLAGS) $(FILE_TO_COMPILE) -o tmp/$(FINAL_BIN)_1000.s
	@$(CC) $(CFLAGS) $(FILE_TO_COMPILE) -o tmp/$(FINAL_BIN)_2304.s

	@$(AS) $(CFLAGS) tmp/$(FINAL_BIN)_1000.s -o tmp/$(FINAL_BIN)_1000.o
	@$(AS) $(CFLAGS) tmp/$(FINAL_BIN)_2304.s -o tmp/$(FINAL_BIN)_2304.o

	@$(LD) $(CFLAGS) tmp/$(FINAL_BIN)_1000.o -o tmp/$(FINAL_BIN)_1000 --start-addr 2048 telestrat.lib
	@$(LD) $(CFLAGS) tmp/$(FINAL_BIN)_2304.o -o tmp/$(FINAL_BIN)_2304 --start-addr 2304 telestrat.lib
	@dependencies/orix-sdk/bin/relocbin.py3 -o tmp/$(FINAL_BIN) -2 tmp/$(FINAL_BIN)_1000 tmp/$(FINAL_BIN)_2304

prepare-unit-test:
	@cp build/usr/share/kernel/kernelsd.rom ${WORKSPACE}/roms/kernel.rom
	@cat tests/unit_test/xopen.sub > ${WORKSPACE}/sdcard/ETC/AUTOBOOT
	@cat tests/file_operations/file_operations.sub >> ${WORKSPACE}/sdcard/ETC/AUTOBOOT
	@cat tests/unit_test/xrm.sub >> ${WORKSPACE}/sdcard/ETC/AUTOBOOT
	@cat tests/unit_test/tail.sub >> ${WORKSPACE}/sdcard/ETC/AUTOBOOT
	@cp tmp/tfseek ${WORKSPACE}/sdcard/BIN
	cat ${WORKSPACE}/sdcard/ETC/AUTOBOOT

launch-unit-test: build-unit-test prepare-unit-test execute-oricutron
	@echo "########################################################"
	@echo "#       Launch unit test                              #"
	@echo "########################################################"

execute-oricutron:
	@cp kernelsd.rom ${WORKSPACE}/roms/kernel.rom
	@cp kernel8.rom ${WORKSPACE}/roms/
	@cd ${WORKSPACE} && ./oricutron

memmap:
	@cp kernel.rom kernelus.rom
	@cp kernelus.rom $(PATH_PACKAGE_ROM)/

build-unit-test:
	@$(MAKE) compile_cc65 FILE_TO_COMPILE="tests/file_operations/fseek_test.c" FINAL_BIN="tfseek"
	@#$(CL) $(CFLAGS) tests/file_operations/mkdir.c -o tmp/tmkdir
	@$(CL) $(CFLAGS) tests/file_operations/fwrite.c -o tmp/tfwrite
	@$(CL) $(CFLAGS) tests/unit_test/mainarg.s -I dependencies/orix-sdk/macros/ -o tmp/1000 --start-addr 2048
	@$(CL) $(CFLAGS) tests/unit_test/mainarg.s -I dependencies/orix-sdk/macros/ -o tmp/1256 --start-addr 2304

	@echo "########################################################"
	@echo "#       Build memmap.md                                #"
	@echo "########################################################"
	@$(AS) --cpu 6502 -DMEMMAP_GENERATE=1 --verbose -s -ttelestrat src/kernel_main_memory.s -o tmp/kernel_main_memory.ld65 > memmap.md
	@#@$(LD) -C cfg/kernel.cfg tmp/kernelsd.ld65 tmp/kernel_bank0.ld65 tmp/kernel_main_memory.ld65 tmp/kernel.lib -m kernelus.map -o kernel-telestrat.ld65.rom -DWITH_ACIA=2 -DWITH_SDCARD_FOR_ROOT=1 -Ln kernel-telestrat.ca.sym
	@sh generate_memmap.sh

test:
	@cp Makefile build/usr/src/kernel/
	@cp README.md build/usr/src/kernel/
	@cp src/* build/usr/src/kernel/ -adpR
	@cp README.md build/usr/share/doc/$(PROGRAM_NAME)/
	@ls -l $(HOMEDIR)
	@export ORIX_PATH=`pwd`
	@sh tools/builddocs.sh
	@cd build && tar -c * > ../$(PROGRAM_NAME).tar && cd ..
	@filepack  $(PROGRAM_NAME).tar $(PROGRAM_NAME).pkg
	@gzip $(PROGRAM_NAME).tar
	@mv $(PROGRAM_NAME).tar.gz $(PROGRAM_NAME).tgz

