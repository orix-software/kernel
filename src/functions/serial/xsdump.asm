  
XSDUMP_ROUTINE
  jsr     LECC1
LED9D  
  asl     KBDCTC
  bcs     LEDC7 
  jsr     READ_A_SERIAL_BUFFER_CODE_INPUT
  bcs     LED9D 
  tax
  bmi     LEDAE 
  cmp     #$20
  bcs     LEDC1
LEDAE:
  pha
  lda     #$81
  jsr     Ldbb5 
  pla
  jsr     XHEXA_ROUTINE 
  jsr     Ldbb5 
  tya 
  jsr     Ldbb5 
  lda     #$87 
LEDC1  
  jsr     Ldbb5
  jmp     LED9D
LEDC7  
  jmp     Lecbf 
