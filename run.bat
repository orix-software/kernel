@echo off

rem SET ORICUTRON="..\..\..\..\oricutron-iss2-debug\"
SET ORICUTRON="D:\users\plifp\Onedrive\oric\oricutron_twilighte"

rem set ORICUTRON="/d/Users/plifp/onedrive/oric/oricutron_twilighte"



SET ORIGIN_PATH=%CD%

SET ROM=kernel
rem -DWITH_SDCARD_FOR_ROOT=1
%CC65%\ca65.exe --cpu 6502 -DWITH_SDCARD_FOR_ROOT=1   --verbose -s -ttelestrat --include-dir %CC65%\asminc\ src/%ROM%.asm -o %ROM%sd.ld65 --debug-info
%CC65%\ld65.exe -tnone -DWITH_SDCARD_FOR_ROOT=1   %ROM%sd.ld65 -o %ROM%.rom -Ln kernelsd.sym -m memmap.txt -vm

%CC65%\ca65.exe --cpu 6502 -DWITH_SDCARD_FOR_ROOT=1 -DWITH_DEBUG=1  --verbose -s -ttelestrat --include-dir %CC65%\asminc\ src/kdebug.asm -o kdebugsd.ld65 --debug-info
%CC65%\ld65.exe -tnone -DWITH_SDCARD_FOR_ROOT=1 -DWITH_DEBUG=1  kdebugsd.ld65 -o kdebug.rom -Ln kdebugsd.sym -m memmap.txt -vm


IF "%1"=="NORUN" GOTO End

copy %ROM%.rom %ORICUTRON%\roms\ > NUL
rem copy kdebug.rom %ORICUTRON%\roms\ > NUL
 
cd %ORICUTRON%

oricutron


:End
cd %ORIGIN_PATH%
rem %OSDK%\bin\MemMap "%ORIGIN_PATH%\xa_labels_orix.txt" memmap.html O docs/telemon.css

