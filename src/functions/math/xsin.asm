XSIN_ROUTINE:

  jsr     LF8B1
LF791:
  jsr     XA1A2_ROUTINE
  lda     #<const_pi_mult_by_two
  ldy     #>const_pi_mult_by_two
  ldx     ACC2S
  jsr     LF267 
  jsr     XA1A2_ROUTINE 
  jsr     XINT_ROUTINE
  lda     #$00
  sta     ACCPS
  jsr     XA2NA1_ROUTINE
  lda     #<const_0_dot_twenty_five
  ldy     #>const_0_dot_twenty_five 
  jsr     ACC2_ACC1 
  lda     ACC1S
  pha
  bpl     LF7C5
  jsr     add_0_5_A_ACC1
  lda     ACC1S
  bmi     LF7C8 
  lda     FLSGN
  eor     #$FF
  sta     FLSGN
  .byt    $24
LF7C4  
  pha
LF7C5  
  jsr     XNA1_ROUTINE 
LF7C8  
  lda     #<const_0_dot_twenty_five
  ldy     #>const_0_dot_twenty_five
  jsr     AY_add_acc1
  pla
  bpl     @S1
  jsr     XNA1_ROUTINE
@S1:
  lda     #<coef_polynome_sin
  ldy     #>coef_polynome_sin
  jmp     LF6E1
  