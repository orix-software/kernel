@echo off

rem SET ORICUTRON="..\..\..\oricutron-iss\"

SET ORICUTRON="D:\Onedrive\oric\oricutron-iss2-debug\"

SET RELEASE="30"
SET UNITTEST="NO"

SET ORIGIN_PATH=%CD%

For /f "tokens=1-4 delims=/ " %%a in ('date /t') do (set mydate=%%c-%%b-%%a)
For /f "tokens=1-2 delims=/:" %%a in ('time /t') do (set mytime=%%a:%%b)

REM OPTION for compiling : -DWITH_PRINTER  -DWITH_ACIA -DWITH_RAMOVERLAY  -WITH_FDC -DWITH_MV -DWITH_CP -DWITH_DF -DWITH_LSOF -DWITH_SEDSD -DWITH_MEMINFO

SET SOURCE_BANK7=kernel.asm

SET MYDATE=%mydate% %mytime%

rem echo %MYDATE%

%OSDK%\bin\xa.exe -C -W  -e error.txt -D__DATEBUILT__="%MYDATE%"  -l xa_labels_bank7.txt  src\%SOURCE_BANK7% -o  kernel.rom
rem %OSDK%\bin\xa.exe -C -W  -e error.txt -D__DATEBUILT__="%MYDATE%"  -l xa_labels.txt  src\%SOURCE_BANK7% -o  orixbank7_noacia.rom
rem %OSDK%\bin\xa.exe -C -W  -e error.txt -DWITH_ACIA -DWITH_TWILIGHTE_BOARD -D__DATEBUILT__="%MYDATE%"  -l xa_labels.txt  src\%SOURCE_BANK7% -o  orixbank7_acia.rom

rem -DWITH_KILL  -DWITH_LSCPU -DWITH_VI
 rem -DWITH_HISTORY -DWITH_CA65 -DWITH_MONITOR -DWITH_DEBUG -DWITH_IOPORT -DWITH_MV -DWITH_CP -DWITH_DF -DWITH_LSOF -DWITH_SEDSD -DWITH_OCONFIG   -DWITH_MOUNT -DWITH_VI -DWITH_MULTITASKING -DWITH_XORIX -DWITH_SH -DWITH_DF -DWITH_LSOF -DWITH_SEDSD -DWITH_OCONFIG

%OSDK%\bin\xa.exe -W  -e error.txt -DWITH_BANKS -DWITH_CP -DWITH_DEBUG -DWITH_IOPORT -DWITH_MONITOR -DWITH_TELEFORTH    -l xa_labels_orix.txt src/orixbank5.asm -D__DATEBUILT__="%MYDATE%" -o orixbank5.rom
%OSDK%\bin\xa.exe -W  -e error.txt -DWITH_BANKS -DWITH_CP -DWITH_DEBUG -DWITH_IOPORT -DWITH_MONITOR -DWITH_TELEFORTH  -DWITH_BANKS   -l xa_labels_orix.txt src/orixbank5.asm -D__DATEBUILT__="%MYDATE%" -o orixbank5_debug.rom

rem  -DWITH_LSOF  
%OSDK%\bin\xa.exe tests\xmkdir.asm -o xmkdir
%OSDK%\bin\xa.exe tests\xrm.asm -o xrm
%OSDK%\bin\xa.exe tests\xfillm.asm -o xfillm

cl65.exe -ttelestrat tests/mkdir.c -o tmkdir
cl65.exe -ttelestrat tests/fwrite.c -o tfwrite

rem copy orixbank4.rom /b + orixbank5_debug.rom + roms\ROMCH376_noram.rom /b + orixbank7.rom /b cardridge_6502.rom > NUL
rem copy orixbank1.rom /b + orixbank2.rom /b + orixbank3.rom /b + orixbank4.rom /b + orixbank5_debug.rom /b + roms\ROMCH376_noram.rom /b + orixbank7.rom /b cardridge_6502_twilighte_card_noacia.rom > NUL
rem copy roms\empty_bank.rom /b + roms\empty_bank.rom /b + roms\empty_bank.rom /b + roms\empty_bank.rom /b + orixbank5_debug.rom /b + roms\ROMCH376.rom  /b + orixbank7_noacia.rom /b cardridge_6502_twilighte_card_noacia.rom

IF "%1"=="NORUN" GOTO End

copy kernel.rom %ORICUTRON%\roms\
copy roms\ROMCH376_noram.rom %ORICUTRON%\roms\orixbank6.rom  > NUL
rem copy orixbank5_debug.rom %ORICUTRON%\roms\orixbank5.rom > NUL
rem copy src\man\*.hlp %ORICUTRON%\usbdrive\usr\share\man > NUL


mkdir %ORICUTRON%\usbdrive\tests
copy tests\xmkdir %ORICUTRON%\usbdrive\tests\  > NUL
copy tests\xrm %ORICUTRON%\usbdrive\tests\  > NUL
copy tmkdir %ORICUTRON%\usbdrive\bin
copy tfwrite %ORICUTRON%\usbdrive\bin

cd %ORICUTRON%
oricutron -mt  --symbols "%ORIGIN_PATH%\xa_labels_orix.txt"

:End
cd %ORIGIN_PATH%
%OSDK%\bin\MemMap "%ORIGIN_PATH%\xa_labels_orix.txt" memmap.html O docs/telemon.css

