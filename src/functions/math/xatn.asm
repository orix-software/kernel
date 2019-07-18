.export    XATN_ROUTINE

.proc XATN_ROUTINE
  lda     ACC1S
  pha
  bpl     @L1
  jsr     XNA1_ROUTINE 
@L1:
  lda     ACC1E
  pha
  cmp     #$81
  bcc     @L2
  lda     #<const_atn_1
  ldy     #>const_atn_1 
  jsr     Lf287 
@L2:  
  lda     #<const_coef_atn 
  ldy     #>const_coef_atn 
  jsr     LF6E1
  pla
  cmp     #$81 
  bcc     @L3
  lda     #<CONST_SIN_AND_COS 
  ldy     #>CONST_SIN_AND_COS
  jsr     ACC2_ACC1
@L3:  
  pla
  bpl     @L4
  jsr     XNA1_ROUTINE
@L4:  
  jsr     test_if_degree_mode 
  beq     @L5
  jmp     XDEG_ROUTINE   
@L5:
  rts

const_coef_atn:
  .byt     $0b ; 11 coef
  .byt     $76,$b3,$83,$bd,$d3
  .byt     $79,$1e,$f4,$a6,$f5
  .byt     $7b,$83,$fc,$b0,$10
  .byt     $7c,$0c,$1f,$67,$ca
  .byt     $7c,$de,$53,$cb,$c1
  .byt     $7d,$14,$64,$70,$4c
  .byt     $7d,$b7,$ea,$51,$7a
  .byt     $7d,$63,$30,$88,$7e
  .byt     $7e,$92,$44,$99,$3a
  .byt     $7e,$4c,$cc,$91,$c7
  .byt     $7f,$aa,$aa,$aa,$13

.endproc