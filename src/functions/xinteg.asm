
.export  XINTEG_ROUTINE

.proc XINTEG_ROUTINE
  jsr     XA1A2_ROUTINE
  lda     ACC2E
  beq     @S1
  bpl     @S3
  sec
  lda     #$A1
  sbc     ACC2E
  bcc     @S3
  tax
@L1:
  dex
  beq     @S2
  lsr     ACC2M
  ror     $6A
  ror     $6B
  ror     $6C
  bcc     @L1
  bcs     @S3
@S1:
  ldx     #$03
  sta     ACC2M,x
  dex
  bpl     @L1
@S2:
  lda     #$01
  rts

@S3:
  lda     #$00
  rts
.endproc
