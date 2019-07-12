XMSAVE_ROUTINE
  ror     INDRS
  sec
  ror     INDRS
  jsr     LECD9 
  jsr     save_file_rs232_minitel 
  jmp     LECD7 
