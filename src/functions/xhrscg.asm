
;                     DEPLACE LE CURSEUR VERS LA GAUCHE (hires)

.proc XHRSCG_ROUTINE
   .out     .sprintf("|MODIFY:HRSX40:XHRSCG")
   .out     .sprintf("|MODIFY:HRSX6:XHRSCG")
  ldx     HRSX6
  dex             ;   on déplace à gauche
  bpl     @skip   ;   si on sort
  ldx     #$05    ;   on se place à droite
  dec     HRSX40  ;   et on enlève une colonne

@skip:
  stx     HRSX6
  rts
.endproc
