;                      DEPLACE LE CURSEUR VERS LA DROITE (hires)
.proc     XHRSCD_ROUTINE
   .out     .sprintf("|MODIFY:HRSX40:XHRSCD")
   .out     .sprintf("|MODIFY:HRSX6:XHRSCD")

  ldx     HRSX6      ;   on déplace d'un pixel
  inx
  cpx     #$06       ;   si on est à la fin
  bne     @skip
  ldx     #$00       ;   on revient au début
  inc     HRSX40     ;   et ajoute une colonne

@skip:
  stx     HRSX6
  rts
.endproc
