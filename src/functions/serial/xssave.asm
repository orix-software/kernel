.export XSSAVE_ROUTINE

.proc XSSAVE_ROUTINE
  ror     INDRS  
  lsr     INDRS  
  jsr     LECC9
  jsr     save_file_rs232_minitel 
  jmp     LECC7 
.endproc  
