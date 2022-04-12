# export DISPLAY=172.17.160.1:0
ORICUTRON_PATH="/mnt/c/Users/plifp/OneDrive/oric/oricutron_wsl/oricutron"
CA65_INC=/usr/share/cc65/asminc/

ca65 --cpu 6502 -DWITH_SDCARD_FOR_ROOT=1 --verbose -s -ttelestrat  src/kernel.asm -o kernelsd.ld65 --debug-info
ld65 -tnone -DWITH_SDCARD_FOR_ROOT=1  kernelsd.ld65 -o kernel.rom -Ln kernelsd.sym -m memmap.txt -vm

cl65 -ttelestrat -C  tests/orix-sdk/cfg/telestrat_900.cfg  tests/multiples_files_opened.c tests/multiples_files_fopen.s tests/exec.s -o multi


cp kernel.rom $ORICUTRON_PATH/roms 
cp multi $ORICUTRON_PATH/sdcard/bin/a
cd $ORICUTRON_PATH
./oricutron
cd -

