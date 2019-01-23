@echo off

SET ORICUTRON="..\..\..\oricutron-iss\"

SET RELEASE="30"
SET UNITTEST="NO"

SET ORIGIN_PATH=%CD%

SET ROM=kernel

%CC65%\ca65.exe  -DWITH_ACIA --verbose -s -ttelestrat --include-dir %CC65%\asminc\ src/%ROM%.asm -o %ROM%.ld65 --debug-info
%CC65%\ld65.exe -tnone  %ROM%.ld65 -o %ROM%.rom -Ln kernel.sym

IF "%1"=="NORUN" GOTO End

copy %ROM%.rom %ORICUTRON%\roms\ > NUL

cd %ORICUTRON%

oricutron -b -mt  

:End
cd %ORIGIN_PATH%
rem %OSDK%\bin\MemMap "%ORIGIN_PATH%\xa_labels_orix.txt" memmap.html O docs/telemon.css

