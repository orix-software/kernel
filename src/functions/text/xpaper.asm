
.proc XPAPER_ROUTINE
  clc
  .byt     $24
.endproc
; don't insert rts or any routine here, xink follows XPAPER_ROUTINE
.include "functions/text/xink.asm"
