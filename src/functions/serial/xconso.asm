
XCONSO_ROUTINE: 
  jsr     LECC1
  jsr     LECC9
LED7D  
  jsr     READ_A_SERIAL_BUFFER_CODE_INPUT 
  bcs     LED85
  jsr     Ldbb5
LED85  
  jsr     XRD0_ROUTINE;
  bcs     LED7D
  cmp     #$03
  beq     LED94
  jsr     write_caracter_in_output_serial_buffer
  jmp     LED7D  
LED94  
  jsr     Lecbf 
  jmp     LECC7 
  