.proc     _xreclk
  lda     #$00
  ldx     #$04
@loop:
  sta     TIMED,x
  dex
  bpl     @loop
  lda     #$01
  sta     FLGCLK_FLAG
  rts
.endproc
