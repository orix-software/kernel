
.proc XSCROH_ROUTINE
;                     SCROLLE UNE FENETRE VERS LE BAS
;Action:scrolle vers le bas de la ligne X à la ligne Y la fenêtre courante.

  lda     #$00     ;  on prend $0028, soit 40
  sta     DECFIN+1
  lda     #$28
  bne     scroll_XSCROB_ROUTINE    ;  inconditionnel
.endproc

;                      SCROLLE UNE FENETRE VERS LE HAUT
;Action:scrolle vers le haut de la ligne X à la ligne Y la fenêtre courante.

XSCROB_ROUTINE:
  lda     #$FF       ;    on prend $FFD8, soit -40 en complément à 2
  sta     DECFIN+1
  lda     #$D8
scroll_XSCROB_ROUTINE:
  sta     DECFIN     ;   $06-07 contiennent le déplacement
  stx     RES        ;    on met la ligne de départ en RES
  tya
  sec
  sbc     RES        ;   on calcule le nombre de lignes
  pha                ;    on sauve le nombre de lignes
  txa                ;    ligne de début dans A
  bit     DECFIN
  bpl     @skip      ;    déplacement négatif ?
  tya                ;    oui, ligne de fin dans A
@skip:
  ldx     SCRNB
  jsr     LDE12      ;   on calcule l'adresse de la ligne
  clc
  adc     SCRDX    ;   l'adresse exacte de la ligne dans la fenêtre
  bcc     @skip2
  iny
@skip2:
  sta     DECCIB     ;  est dans $08-09
  sty     DECCIB+1
  clc                ; on ajoute le déplacement
  adc     DECFIN
  sta     DECDEB
  tya
  adc     DECFIN+1
  sta     DECDEB+1   ;   dans $04-05
  pla                ;   on sort le nombre de lignes
  sta     RES        ;   dans RES
  beq     LDEC4      ;   si nul on fait n'importe quoi ! on devrait sortir!
  bmi     LDECD      ;  si négatif, on sort ------------------------------
  sec                ;  on calcule                                       I
  ldx     SCRNB      ;                                                   I
  lda     SCRFX    ; la largeur de la fenêtre                          I
  sbc     SCRDX    ;                                                   I
  sta     RES+1      ;  dans RES+1                                       I
LDE9D:
  ldy     RES+1
@L2:                 ;                                                   I
  lda     (DECDEB),y ;   on transfère une ligne                          I
  sta     (DECCIB),y ;                                                   I
  dey                ;                                                   I
  bpl     @L2        ;                                                   I
  clc                ;                                                   I
  lda     DECDEB     ;   on ajoute le déplacement                        I
  adc     DECFIN     ;   à l'adresse de base                             I
  sta     DECDEB     ;                                                   I
  lda     DECDEB+1   ;                                                   I
  adc     DECFIN+1   ;                                                   I
  sta     DECDEB+1   ;                                                   I
  clc                ;                                                   I
  lda     DECCIB     ;   et à l'adresse d'arrivée                        I
  adc     DECFIN     ;                                                   I
  sta     DECCIB     ;                                                   I
  lda     DECCIB+1   ;                                                   I
  adc     DECFIN+1   ;                                                   I
  sta     DECCIB+1   ;                                                   I
  dec     RES        ;  on décompte une ligne de faite                   I
  bne     LDE9D      ;  et on fait toutes les lignes                     I
LDEC4:
  ldy     RES+1      ;  on remplit la dernière ligne                     I
  lda     #$20       ;                                                   I
@L1:
  sta     (DECCIB),y ;  avec de espaces                                  I
  dey                ;                                                   I
  bpl     @L1        ;                                                   I
LDECD:
  rts                ;  <-------------------------------------------------
