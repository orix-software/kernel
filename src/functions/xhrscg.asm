
;                     DEPLACE LE CURSEUR VERS LA GAUCHE (hires)

.proc XHRSCG_ROUTINE
  LDX     HRSX6                                                          
  DEX         ;   on d?place ? gauche                               
  BPL     @skip   ;   si on sort                                        
  LDX     #$05    ;   on se place ? droite                              
  DEC     HRSX40     ;   et on enl?ve une colonne 
@skip:
  STX     HRSX6                                                          
  RTS 
.endproc       