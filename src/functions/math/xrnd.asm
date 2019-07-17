.export  XRND_ROUTINE

.proc XRND_ROUTINE
  jsr     LF3BD
  tax
  bmi     LF753 
  lda     #$EF
  ldy     #$02
  jsr     Lf323
  txa
  beq     LF72A 
  lda     #<const_11879546_for_rnd
  ldy     #>const_11879546_for_rnd
  jsr     LF184
  lda     #<const_3_dot_92_for_rnd_etc
  ldy     #>const_3_dot_92_for_rnd_etc
  jsr     AY_add_acc1 
LF753  
  ldx     $64
  lda     ACC1M
  sta     $64
  stx     ACC1M
  lda     #$00    ; FIXME 65C02
  sta     ACC1S
  lda     ACC1E
  sta     ACC1EX
  lda     #$80
  sta     ACC1E
  jsr     Lf022 
  ldx     #$EF ; FIXME
  ldy     #$02 ; FIXME
  jmp     XA1XY_ROUTINE

  const_11879546_for_rnd:
  .byt $98,$35,$44,$7A,$6B ; 11879546,42
const_3_dot_92_for_rnd_etc:
  .byt $68,$28,$B1,$46,$20 ;3.927678 E-08
.endproc