.export XSDUMP_ROUTINE 


.proc XSDUMP_ROUTINE
  jsr     LECC1
@L1:
  asl     KBDCTC
  bcs     @S3
  jsr     READ_A_SERIAL_BUFFER_CODE_INPUT
  bcs     @L1
  tax
  bmi     @S1
  cmp     #$20
  bcs     @S2
@S1:
  pha
  lda     #$81
  jsr     Ldbb5 
  pla
  jsr     XHEXA_ROUTINE 
  jsr     Ldbb5 
  tya 
  jsr     Ldbb5 
  lda     #$87 
@S2:
  jsr     Ldbb5
  jmp     @L1
@S3:  
  jmp     Lecbf 
.endproc  
