#! /bin/bash
#ORICUTRON_PATH="/mnt/c/Users/plifp/OneDrive/oric/oricutron_wsl/oricutron"

#ORICUTRON_PATH="/mnt/c/Users/plifp/OneDrive/oric/oricutron_plugins/"
ORICUTRON_PATH="/mnt/c/Users/plifp/OneDrive/oric/projets/jedeoric/oricutron_assinie_plugins"
CA65_INC=/usr/share/cc65/asminc/
# -DWITH_DEBUG=1


build_file() {
    local file="$1"
    local path="$2"
    #echo Build $file
    ca65 --cpu 6502 -tnone $path/$file.s -o tmp/$file.o
    RET=$?
    if [ $RET != 0 ]
    then
        echo Error
        exit
    fi
}

ca65 --cpu 6502 -tnone src/functions/strings/xminma.asm -o tmp/xminma.o
ca65 --cpu 6502 -tnone src/functions/bank_mng/switch_to_kernel_extended.s -o tmp/switch_to_kernel_extended.o
ca65 --cpu 6502 -tnone src/functions/bank_mng/kernel_restore_banking_states.s -o tmp/kernel_restore_banking_states.o
ca65 --cpu 6502 -tnone src/functions/lib_mng/XBANK_ROUTINE.s -o tmp/xbank_routine.o
ca65 --cpu 6502 -tnone src/functions/network/init_network.s -o tmp/init_network.o
ca65 --cpu 6502 -tnone src/functions/network/xsocket.s -o tmp/xsocket.o
build_file "close_sockets_by_pid" "src/functions/network"
build_file "xconnect" "src/functions/network"
build_file "xsend" "src/functions/network"

ca65 --cpu 6502 -tnone src/functions/network/xclose_socket.s -o tmp/xclose_socket.o

RET=$?
if [ $RET != 0 ]
then
echo Error
exit
fi

# Bank 8
ca65 --cpu 6502 -tnone src/functions/bank_mng/search_free_bank.s -o tmp/search_free_bank.o
ca65 --cpu 6502 -tnone src/functions/bank_mng/kernel_free_bank.s -o tmp/kernel_free_bank.o
ca65 --cpu 6502 -tnone src/functions/bank_mng/kernel_free_bank_by_pid.s -o tmp/kernel_free_bank_by_pid.o

ar65 r tmp/kernel.lib tmp/xminma.o
ar65 r tmp/kernel.lib tmp/switch_to_kernel_extended.o
ar65 r tmp/kernel.lib tmp/kernel_restore_banking_states.o
ar65 r tmp/kernel.lib tmp/xbank_routine.o


ar65 r tmp/kernel_bank8.lib tmp/init_network.o
ar65 r tmp/kernel_bank8.lib tmp/search_free_bank.o
ar65 r tmp/kernel_bank8.lib tmp/kernel_free_bank.o
ar65 r tmp/kernel_bank8.lib tmp/kernel_free_bank_by_pid.o
ar65 r tmp/kernel_bank8.lib tmp/xsocket.o
ar65 r tmp/kernel_bank8.lib tmp/xconnect.o
ar65 r tmp/kernel_bank8.lib tmp/xsend.o
ar65 r tmp/kernel_bank8.lib tmp/close_sockets_by_pid.o



ca65 --cpu 6502 -DWITH_SDCARD_FOR_ROOT=1 --verbose -s -ttelestrat src/kernel_main_memory.s -o tmp/kernel_main_memory.ld65
ca65 --cpu 6502 -DWITH_SDCARD_FOR_ROOT=1 --verbose -s -ttelestrat src/kernel.asm -o tmp/kernelsd.ld65 --debug-info > memmap.md

RET=$?
if [ $RET != 0 ]
then
    echo Error
    exit
fi

ca65 --cpu 6502 -DWITH_SDCARD_FOR_ROOT=1 --verbose -s -ttelestrat src/kernel_bank0.s -o tmp/kernel_bank0.ld65 --debug-info > memmap.md
ca65 --cpu 6502 -tnone src/kernel8/src/kernel8.s -o tmp/kernel_bank8.ld65  > memmap.md
RET=$?
if [ $RET != 0 ]
then
    echo Error
    exit
fi


#ld65  -tnone -DWITH_SDCARD_FOR_ROOT=1 tmp/kernelsd.ld65  tmp/kernel.lib -Ln tmp/kernelsd.sym -m tmp/memmap.txt -vm
echo "##########"
echo "# Bank 8 #"
echo "##########"
ld65 -C cfg/rom.cfg tmp/kernel_bank8.ld65 tmp/kernel_bank0.ld65 tmp/kernel_main_memory.ld65 tmp/kernel_bank8.lib src/kernel8/orixlibs/ksocket/usr/share/ksocket/2025.1/ksocket.lib  src/kernel8/orixlibs/ch395/usr/share/ch395/2024.4/ch395.lib -o kernel8.rom -Ln tmp/kernel8sd.sym -m tmp/memmap8.txt -vm

RET=$?
if [ $RET != 0 ]
then
echo Error
exit
fi

echo "##########"
echo "# Bank 7 #"
echo "##########"

ld65  -C cfg/kernel.cfg -DWITH_SDCARD_FOR_ROOT=1 tmp/kernelsd.ld65 tmp/kernel_bank0.ld65 tmp/kernel_main_memory.ld65 tmp/kernel.lib -Ln tmp/kernelsd.sym -m tmp/memmap.txt -vm

#cl65 -ttelestrat -C  tests/orix-sdk/cfg/telestrat_900.cfg  tests/multiples_files_opened.c tests/multiples_files_fopen.s tests/exec.s -o multi
#cl65 -ttelestrat -C  tests/orix-sdk/cfg/telestrat_900.cfg  tests/readdir.c tests/kernel_calls/readdir_extern.s  -o b

#ca65 --cpu 6502 -DWITH_SDCARD_FOR_ROOT=1 -DWITH_DEBUG=1  --verbose -s -ttelestrat  src/kdebug.asm -o kdebugsd.ld65 --debug-info
#ld65 -tnone -DWITH_SDCARD_FOR_ROOT=1 -DWITH_DEBUG=1  kdebugsd.ld65 -o kdebug.rom -Ln kdebugsd.sym -m memmap.txt -vm


# cl65 -ttelestrat tests/functions/bank_mng/search_free_bank.s -o tmp/1000 --start-addr 2048
# cl65 -ttelestrat tests/functions/bank_mng/search_free_bank.s -o tmp/1256 --start-addr 2304
# dependencies/orix-sdk/bin/relocbin.py3 -o tmp/sfbtest -2 tmp/1000 tmp/1256
# cp tmp/sfbtest $ORICUTRON_PATH/sdcard/bin/

cl65 -ttelestrat tests/functions/network/netchk.s -o tmp/1000 --start-addr 2048
cl65 -ttelestrat tests/functions/network/netchk.s -o tmp/1256 --start-addr 2304
dependencies/orix-sdk/bin/relocbin.py3 -o tmp/netchk -2 tmp/1000 tmp/1256
cp tmp/netchk $ORICUTRON_PATH/sdcard/bin/

cp kernel.rom $ORICUTRON_PATH/roms
cp kernel8.rom $ORICUTRON_PATH/roms

# # cp kdebug.rom $ORICUTRON_PATH/roms
# cp tests/test_kernel $ORICUTRON_PATH/sdcard/bin/test


#cp tests/kopened $ORICUTRON_PATH/sdcard/bin/

#cat  tests/unit_test/xopen.sub > $ORICUTRON_PATH/sdcard/etc/AUTOBOOT
cat  tests/unit_test/start.sub > $ORICUTRON_PATH/sdcard/etc/AUTOBOOT

# cp  tests/unit_test/mainarg.sub $ORICUTRON_PATH/sdcard/bin/mainarg.sub

# cl65 -ttelestrat tests/unit_test/mainarg.s -o 1000 --start-addr 2048
# cl65 -ttelestrat tests/unit_test/mainarg.s -o 1256 --start-addr 2304
# dependencies/orix-sdk/bin/relocbin.py3 -o mainarg -2 1000 1256


#cp mainarg $ORICUTRON_PATH/sdcard/bin/mainarg

cd $ORICUTRON_PATH
./oricutron
#-r :bp.txt
cd -

