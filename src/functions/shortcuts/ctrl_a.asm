;                              CODE 01 - CTRL A

;Action:Place le curseur sur une tabulation, colonne multiple de 8.

CTRL_A_START:
  lda     SCRX,X        ; ->on lit ala colonne
  and     #$F8          ;  I on la met à 0
  adc     #$07          ;  I on place sur une tabulation 8 (C=1)
  cmp     SCRFX,X       ;  I est-on en fin de ligne ?
  beq     @S1           ;  I non
  bcc     @S1           ;  I --------------------------------------------------

  jsr     CTRL_M_START  ;  I oui, on ramène le curseur en début de ligne      I

  jsr     CTRL_J_START  ;  I et on passe une ligne                            I
  ldx     SCRNB         ;  I                                                  I

  lda     SCRX,X        ;  I on prend la colonne                              I
  and     #$07          ;  I est-on sur une tabulation                        I
  bne     CTRL_A_START  ;  --non, on tabule...                                I
  rts                   ;                                                     I
@S1:
  sta     SCRX,X        ;   on sauve la colonne <-----------------------------
  rts                   ;   et on sort codes A                               I
