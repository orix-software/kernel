.proc XSOUT_ROUTINE
; RS232 
  pha 
  jsr     LECC9
  pla
  jsr     write_caracter_in_output_serial_buffer
  jmp     LECC7    ; FIXME 65C02
.endproc  
  