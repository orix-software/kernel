
.proc XINK_ROUTINE
  sec

;                    FIXE LA COULEUR DE FOND OU DU TEXTE

;Principe:A contient la couleur, X la fenêtre ou 128 si mode HIRES et C=1 si la
;couleur est pour l'encre, 0 pour le fond.
;         Changer la couleur consiste à remplir la colonne couleur correspondante
;         avec le code de couleur. Auncun test de validite n'étant fait, on peut
;         utiliser ce moyen pour remplir les colonnes 0 et 1 de n'importe quel
;         attribut.

  pha               ; on sauve la couleur
  php               ; et C
  stx     RES       ; fenêtre dans RES
  bit     RES       ; HIRES ?
  bmi     @S4       ; oui ----------------------------------------------
  stx     SCRNB     ; TEXT, on met le numero de fenetre dans $28       I
  bcc     @S2       ; si C=0, c'est PAPER                              I
  sta     SCRCT,x   ; on stocke la couleur d'encre                     I
  bcs     @S1       ; si C=1 c'est INK                                 I
@S2:
  sta     SCRCF,x   ; ou la couleur de fond
@S1:
  lda     FLGSCR,x  ; est on en 38 colonnes ?                          I
  and     #$10      ;                                                   I
  bne     @S3       ; mode 38 colonnes ------------------------------  I
  lda     #$0C      ;  mode 40 colonnes, on efface l'ecran           I  I
  jsr     Ldbb5     ;  (on envoie CHR$(12))                          I  I
  lda     #$1D      ;  et on passe en 38 colonnes                    I  I
  jsr     Ldbb5     ;  (on envoie CHR$(29))                          I  I
  ldx     SCRNB     ;  on prend X=numéro de fen?tre                  I  I
@S3:
  lda     SCRDY,x           ;  on prend la ligne 0 de la fenêtre <------------  I
  jsr     XMUL40_ROUTINE    ;  *40 dans RES                                     I
  lda     SCRBAL,x          ;  AY=adresse de base de la fenêtre                 I
  ldy     SCRBAH,x          ;                                                   I
  jsr     XADRES_ROUTINE    ;  on ajoute l'adresse à RES (ligne 0 *40) dans RES I
  ldy     SCRDX,x           ;  on prend la première colonne de la fenêtre       I
  dey                       ;  on enlève deux colonnes                          I
  dey                       ;                                                   I
  sec                       ;                                                   I
  lda     SCRFY,x           ;   on calcule le nombre de lignes                   I
  sbc     SCRDY,x           ;   de la fenêtre                                    I
  tax                       ;   dans X                                           I
  inx                       ;                                                    I
  tya                       ;   colonne 0 dans Y                                 I
  bcs     @S5               ;   inconditionnel --------------------------------- I
@S4:
  lda     #$00              ;  <----------------------------------------------+-- FIXME 65C02
  ldx     #$A0              ;                                                 I
  sta     RES               ;  RES=$A000 , adresse HIRES                      I
  stx     RES+1             ;                                                  I
  ldx     #$C8              ;   X=200 pour 200 lignes                          I
  lda     #$00              ;   A=0 pour colonne de début = colonne 0          I
@S5:
  plp                       ;   on sort C <-------------------------------------
  adc     #$00              ;   A=A+C
  tay                       ;    dans Y
  pla                       ;    on sort le code                                   *
@S7:
  sta     (RES),Y; -->on le place dans la colonne correspondante
  pha        ; I  on le sauve
  clc        ; I
  lda     RES    ; I  on passe 28 colonnes
  adc     #$28    ;I  (donc une ligne)
  sta     RES     ;I
  bcc     @S6  ; I
  inc     RES+1    ; I
@S6:
  pla        ; I  on sort le code
  dex        ; I  on compte X lignes
  bne     @S7   ;---
  rts         ;   et on sort----------------------------------------
.endproc
