;                      DEPLACE LE CURSEUR VERS LA DROITE (hires)
.proc     XHRSCD_ROUTINE
  LDX     HRSX6      ;      on déplace d'un pixel                             
  inx                                                              
  CPX     #$06       ;     si on est à la fin
  BNE     @skip
  LDX     #$00       ;    on revient au début
  INC     HRSX40     ;   et ajoute une colonne 
@skip:
  STX     HRSX6                                                          
  RTS    
.endproc