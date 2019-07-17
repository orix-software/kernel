.export  XSQR_ROUTINE

.proc XSQR_ROUTINE
  jsr     XA1A2_ROUTINE 
  lda     #<const_zero_dot_half  
  ldy     #>const_zero_dot_half  
  jsr     XAYA1_ROUTINE
.endproc 