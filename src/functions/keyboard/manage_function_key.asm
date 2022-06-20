.proc manage_function_key
  lda     (ADKBD),y
  cmp     #$2D
  beq     @S1
  cmp     #$3D
  beq     @S2
  pla
  ora     #$40
  pha
  lda     FLGKBD
  lsr
  bcs     @S3
  lda     (ADKBD),y
  and     #$1F
  ora     #$80
  .byt    $2C
@S1:
  lda     #$60
  .byt    $2C
@S2:
  lda     #$7E
  jmp     Ld882
@S3:
  jmp     (KBDFCT) ; Jump into function key vector
.endproc
