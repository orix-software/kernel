XSLOAD_ROUTINE 
  ror     INDRS
  lsr     INDRS
  lda     #$40
  sta     VIA::IER
  jsr     LECC1
  jsr     read_a_file_rs232_minitel 
  lda     #$C0
  sta     VIA::IER
  jmp     Lecbf 
  