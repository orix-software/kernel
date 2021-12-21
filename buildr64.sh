make
cp ../../shell/develop/shellus.rom k2021-4.r64
cat basicus1.rom >> k2021-4.r64
cat kernelus.rom >> k2021-4.r64
cat ../../empty-rom/empty-rom.rom  >> k2021-4.r64

cp k2021-4.r64 /s/devus.r64

cat ../../empty-rom/empty-rom.rom  > initromD.all
cat ../../empty-rom/empty-rom.rom  >> initromD.all
cat ../../empty-rom/empty-rom.rom  >> initromD.all
cat ../../empty-rom/empty-rom.rom  >> initromD.all

cat ../../shell/develop/shellus.rom >>initromD.all
cat basicus2.rom >> initromD.all
cat kernelud.rom >> initromD.all
cat ../../empty-rom/empty-rom.rom  >> initromD.all


