.export  XCOS_ROUTINE
.proc     XCOS_ROUTINE
  jsr     LF8B1 
  lda     #<CONST_PI_DIVIDED_BY_TWO
  ldy     #>CONST_PI_DIVIDED_BY_TWO
  jsr     AY_add_acc1
  jmp     LF791
.endproc