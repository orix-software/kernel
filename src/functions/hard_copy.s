
hard_copy_hires:

LE25E:
  dex
  bne     LE25E
  stx     TR0
LE269:
  ldx     #$06
LE26B:

LE276:
  lda     #$05
  sta     TR2
LE27A:
  lda     TR0
  asl
  asl
  asl
  jsr     XMUL40_ROUTINE
  sta     TR5
  tya
  clc
  adc     #$A0
  sta     TR6
  lda     #$08
  sta     TR4
  ldy     TR1
LE290:
  lda     (TR5),Y
  tax
  and     #$40
  bne     LE29B
  txa
  and     #$80
  tax
LE29B:
  txa
  bpl     LE2A0
  eor     #$3F
LE2A0:
  ldx     TR2
LE2A2:
  lsr
  dex
  bpl     LE2A2
  rol     TR3
  tya
  clc
  adc     #$28
  tay
  bcc     LE2B1
  inc     TR6
LE2B1:

LE2D0!

  rts
