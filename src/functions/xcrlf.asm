.proc     XCRLF_ROUTINE
; Attention, parfois, il y a des tests bne/beq dans le shell (voir commande cat) pour faire des branchements et eviter le jmp.
; modifier en consequence cette routine
  lda     #$0A
  jsr     XWR0_ROUTINE 
  lda     #$0D
  jmp     XWR0_ROUTINE
.endproc  
