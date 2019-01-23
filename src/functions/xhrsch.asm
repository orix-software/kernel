.proc     XHRSCH_ROUTINE

;                   DEPLACE LE CURSEUR HIRES VERS LE HAUT        
  SEC               ;     on soustrait 40                                   
  LDA     ADHRS     ;     à ADHRS                                           
  SBC     #$28                                                         
  STA     ADHRS                                                          
  BCS     @skip                                                     
  DEC     ADHRS+1
@skip:
  RTS
.endproc   
