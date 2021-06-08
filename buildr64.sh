make
cp ../../shell/develop/shellus.rom k2021-3.r64
cat basicus1.rom >> k2021-3.r64
cat kernelus.rom >> k2021-3.r64
cat ../../empty-rom/empty-rom.rom  >> k2021-3.r64

cp k2021-3.r64 /s/devus.r64

cat ../../empty-rom/empty-rom.rom  > initrom.all
cat ../../empty-rom/empty-rom.rom  >> initrom.all
cat ../../empty-rom/empty-rom.rom  >> initrom.all
cat ../../empty-rom/empty-rom.rom  >> initrom.all

cat ../../shell/develop/shellus.rom >>initrom.all
cat basicus2.rom >> initrom.all
cat kernelus.rom >> initrom.all
cat ../../empty-rom/empty-rom.rom  >> initrom.all