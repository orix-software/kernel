.proc     XHRSCH_ROUTINE
   .out     .sprintf("|MODIFY:ADHRS:XHRSCH")

;                   DEPLACE LE CURSEUR HIRES VERS LE HAUT
  sec               ;     on soustrait 40
  lda     ADHRS     ;     à ADHRS
  sbc     #$28
  sta     ADHRS
  bcs     @skip
  dec     ADHRS+1

@skip:
  rts
.endproc
