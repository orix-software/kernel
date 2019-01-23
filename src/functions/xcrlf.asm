.proc     XCRLF_ROUTINE
  lda     #$0A
  jsr     XWR0_ROUTINE 
  lda     #$0D
  jmp     XWR0_ROUTINE
.endproc  