.export  XRAND_ROUTINE

.proc XRAND_ROUTINE
  jsr     LF348
  jsr     XRND_ROUTINE
  lda     #$73
  ldy     #$00
  jsr     LF184
  jmp     XINT_ROUTINE
.endproc