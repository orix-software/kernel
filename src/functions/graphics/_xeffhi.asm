.proc _xeffhi
  lda     #<$A000
  ldy     #>$A000
  sta     RES
  sty     RES+1
  ldy     #<$BF68
  ldx     #>$BF68
  lda     #$40
  jmp XFILLM_ROUTINE
.endproc  
