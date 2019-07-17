.export  XLIGNE_ROUTINE

.proc XLIGNE_ROUTINE
  ; REMOVEME minitel
; minitel ; get the line
  jsr     LECD9 
  jsr     Lec49 
  jmp     LECD7
.endproc
