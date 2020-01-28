.export  XDEG_ROUTINE

.proc XDEG_ROUTINE
  ; convert ACC1 in defree
  lda     #<const_180_divided_by_pi
  ldy     #>const_180_divided_by_pi 
  jmp     LF184 
const_180_divided_by_pi:
  .byt    $86,$65,$2E,$E0,$D8
.endproc
