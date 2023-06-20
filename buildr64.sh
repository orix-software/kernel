#! /bin/bash
#make
NAME_TO_BUILD=k2023-2.r64

cp ../../shell/develop/shell.rom $NAME_TO_BUILD
cat basicus2.rom >> $NAME_TO_BUILD
cat kernelus.rom >> $NAME_TO_BUILD
cat ../../empty-rom/empty-rom.rom  >> $NAME_TO_BUILD

cp $NAME_TO_BUILD /mnt/s/devus.r64
# NAME_TO_BUILD2=k2023-1.r64

# cp ../../shell/develop/shell.rom $NAME_TO_BUILD2
# cat basic11b.rom >> $NAME_TO_BUILD2
# cat kernelus.rom >> $NAME_TO_BUILD2
# cat ../../empty-rom/empty-rom.rom  >> $NAME_TO_BUILD2

# cp $NAME_TO_BUILD2 /mnt/s/devus2.r64

#cat ../../empty-rom/empty-rom.rom  > initromD.all
#cat ../../empty-rom/empty-rom.rom  >> initromD.all
#cat ../../empty-rom/empty-rom.rom  >> initromD.all
#cat ../../empty-rom/empty-rom.rom  >> initromD.all

#cat ../../shell/develop/shellus.rom >>initromD.all
#cat basicus2.rom >> initromD.all
#cat kernelud.rom >> initromD.all
#cat ../../empty-rom/empty-rom.rom  >> initromD.all


