.export XSCHAR_ROUTINE
.export XCHAR_ROUTINE

.proc XSCHAR_ROUTINE
  sta     HRS3
  sty     HRS3+1
  stx     HRS2
  lda     #$40
  sta     HRSFB
  ldy     #$00
@L1:
  sty     HRS2+1
  cpy     HRS2
  bcs     Lea92 
  lda     (HRS3),y
  jsr     LEAB5 
  ldy     HRS2+1
  iny
  bne     @L1
.endproc  

XCHAR_ROUTINE
  lda     HRS1
  asl
  lsr     HRS2
  ror
LEAB5:
  pha
  lda     HRSX
  cmp     #$EA
  bcc     @S3
  ldx     HRSX6
  lda     HRSY
  adc     #$07
  tay
  sbc     #$BF
  bcc     @S2
  beq     @S2
  cmp     #$08
  bne     @S1
  lda     #$00
@S1:
  tay
@S2:
  jsr     hires_put_coordinate
@S3:
  pla
  jsr     ZADCHA_ROUTINE 
  ldy     #$00
Lead9:
  sty     RES
  lda     HRSX40
  pha
  lda     HRSX6
  pha
  lda     (RESB),Y
  asl
Leae4:
  asl
  beq     Leaf3 
  pha
  bpl     Leaed 
  jsr     LE79C 
Leaed:
  jsr     XHRSCD_ROUTINE 
  pla
  bne     Leae4 
Leaf3:
  jsr     XHRSCB_ROUTINE
  pla
  sta     HRSX6
  pla
  sta     HRSX40
  ldy     RES
  iny
  cpy     #$08
  bne     Lead9
  lda     HRSX
  adc     #$05
  tax
  ldy     HRSY
  jmp     hires_put_coordinate 
  