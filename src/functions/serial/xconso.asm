
.export XCONSO_ROUTINE

.proc XCONSO_ROUTINE
  jsr     LECC1
  jsr     LECC9
@S2:
  jsr     READ_A_SERIAL_BUFFER_CODE_INPUT 
  bcs     @S1
  jsr     Ldbb5
@S1:   
  jsr     XRD0_ROUTINE;
  bcs     @S2
  cmp     #$03
  beq     LED94
  jsr     write_caracter_in_output_serial_buffer
  jmp     @S2
LED94  
  jsr     Lecbf 
  jmp     LECC7 
.endproc
  
