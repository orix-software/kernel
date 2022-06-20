.export  XCOS_ROUTINE
.proc     XCOS_ROUTINE
  jsr     LF8B1 
  lda     #<CONST_PI_DIVIDED_BY_TWO
  ldy     #>CONST_PI_DIVIDED_BY_TWO
  jsr     AY_add_acc1
  jmp     LF791
.endproc
LF8B1
  jsr     test_if_degree_mode  
  beq     LF8CC  
CONST_SIN_AND_COS:
CONST_PI_DIVIDED_BY_TWO:
  .byt    $81,$49,$0F,$DA,$A2
const_pi_mult_by_two:
  .byt    $83,$49,$0F,$DA,$A2 ; 6.283185307
const_0_dot_twenty_five: ; 0.25
  .byt    $7F,$00,$00,$00,$00
coef_polynome_sin:
  .byt    $05 ; 6 coef
  .byt    $84,$E6,$1A,$2D,$1B
  .byt    $86,$28,$07,$FB,$F8
  .byt    $87,$99,$68,$89,$01
  .byt    $87,$23,$35,$DF,$E1
  .byt    $86,$A5,$5D,$E7,$28
  .byt    $83,$49,$0F,$DA,$A2