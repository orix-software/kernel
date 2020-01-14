@echo off

SET ORICUTRON="..\..\..\oricutron-iss\"

SET RELEASE="30"
SET UNITTEST="NO"

SET ORIGIN_PATH=%CD%

SET ROM=kernel
rem -DWITH_SDCARD_FOR_ROOT=1
%CC65%\ca65.exe --cpu 6502 -DWITH_SDCARD_FOR_ROOT=1 --verbose -s -ttelestrat --include-dir %CC65%\asminc\ src/%ROM%.asm -o %ROM%.ld65 --debug-info
%CC65%\ld65.exe -tnone -DWITH_SDCARD_FOR_ROOT=1  %ROM%.ld65 -o %ROM%.rom -Ln kernel.sym

IF "%1"=="NORUN" GOTO End

copy %ROM%.rom %ORICUTRON%\roms\ > NUL

cd %ORICUTRON%

oricutron -mt  
rem  -r :bp.txt

:End
cd %ORIGIN_PATH%
rem %OSDK%\bin\MemMap "%ORIGIN_PATH%\xa_labels_orix.txt" memmap.html O docs/telemon.css

