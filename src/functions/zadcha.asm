.proc ZADCHA_ROUTINE
   .out     .sprintf("|MODIFY:RESB:ZADCHA")

  ldx     #$13
  stx     RESB+1
  asl
  rol     RESB+1
  asl
  rol     RESB+1
  asl
  rol     RESB+1
  sta     RESB
  bit     FLGTEL
  bmi     @skip
  lda     RESB+1
  adc     #$1C
  sta     RESB+1

@skip:
  rts
.endproc
