#! /bin/bash
ORICUTRON_PATH="/mnt/c/Users/plifp/OneDrive/oric/oricutron_wsl/oricutron"
CA65_INC=/usr/share/cc65/asminc/
# -DWITH_DEBUG=1

ca65 --cpu 6502 -DWITH_SDCARD_FOR_ROOT=1  --verbose -s -ttelestrat  src/kernel.asm -o tmp/kernelsd.ld65 --debug-info > memmap.md
RET=$?
if [ $RET != 0 ]
then
echo Error
exit
fi

ld65 -tnone -DWITH_SDCARD_FOR_ROOT=1  tmp/kernelsd.ld65 -o kernel.rom -Ln tmp/kernelsd.sym -m tmp/memmap.txt -vm
#cl65 -ttelestrat -C  tests/orix-sdk/cfg/telestrat_900.cfg  tests/multiples_files_opened.c tests/multiples_files_fopen.s tests/exec.s -o multi
#cl65 -ttelestrat -C  tests/orix-sdk/cfg/telestrat_900.cfg  tests/readdir.c tests/kernel_calls/readdir_extern.s  -o b

ca65 --cpu 6502 -DWITH_SDCARD_FOR_ROOT=1 -DWITH_DEBUG=1  --verbose -s -ttelestrat  src/kdebug.asm -o kdebugsd.ld65 --debug-info
ld65 -tnone -DWITH_SDCARD_FOR_ROOT=1 -DWITH_DEBUG=1  kdebugsd.ld65 -o kdebug.rom -Ln kdebugsd.sym -m memmap.txt -vm

cp kernel.rom $ORICUTRON_PATH/roms
cp kdebug.rom $ORICUTRON_PATH/roms
cp tests/test_kernel $ORICUTRON_PATH/sdcard/bin/test

cp tests/kopened $ORICUTRON_PATH/sdcard/bin/

cd $ORICUTRON_PATH
./oricutron
#-r :bp.txt
cd -

