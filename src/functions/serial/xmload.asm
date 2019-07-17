.export XMLOAD_ROUTINE

.proc XMLOAD_ROUTINE
  ror     INDRS
  sec
  ror     INDRS
  jsr     LECD1 
  jsr     read_a_file_rs232_minitel 
  jmp     LECCF 
.endproc   
  
