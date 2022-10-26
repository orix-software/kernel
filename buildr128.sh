#! /bin/bash
#make
NAME_TO_BUILD=full.128

cat ../../empty-rom/empty-rom.rom  > $NAME_TO_BUILD
cat ../../empty-rom/empty-rom.rom  >> $NAME_TO_BUILD
cat ../../empty-rom/empty-rom.rom  >> $NAME_TO_BUILD
cat ../../empty-rom/empty-rom.rom  >> $NAME_TO_BUILD


cat ../../shell/develop/shellus.rom >> $NAME_TO_BUILD
cat basicus2.rom >> $NAME_TO_BUILD
cat kernelus.rom >> $NAME_TO_BUILD
cat ../../empty-rom/empty-rom.rom  >> $NAME_TO_BUILD

#cp $NAME_TO_BUILD /mnt/s/devus.r64


#cat ../../shell/develop/shellus.rom >>initromD.all
#cat basicus2.rom >> initromD.all
#cat kernelud.rom >> initromD.all
#cat ../../empty-rom/empty-rom.rom  >> initromD.all


