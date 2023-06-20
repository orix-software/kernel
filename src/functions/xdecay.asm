;                        CONVERSION ASCII -> BINAIRE

;Principe:On lit un à un les chiffres de la chaine stockée en AY jusqu'à ce
;qu'on ait plus de chiffres. On multiplie au fur et à mesure le resultat
;par 10 avant d'ajouter le chiffre trouvé. Le principe est aisee à
; assimiler et la routine compacte. Un bon exemple d'optimisation.
;En sortie, AY et RESB contient le nombre, AY l'adresse de la chaine,
; et X le nombre de caract?res d?cod?s.

.proc XDECAY_ROUTINE

  sta     RES      ;   on sauve l'adresse du nombre
  sty     RES+1    ;    dans RES
  ldy     #$00     ;    et on met RESB ? 0
  sty     RESB
  sty     RESB+1
loop:
  lda     (RES),Y  ;   on lit le code <------------------------------
  cmp     #$30     ;   inférieur à 0 ?                              I
  bcc     @S2      ;   oui -----------------------------------------+----
  cmp     #$3A     ;   supérieur à 9 ?                              I   I
  bcs     @S2      ;   oui -----------------------------------------+---O
  and     #$0F     ;   on isole le chiffre                          I   I
  pha              ;    dans la pile                                I   I
  asl     RESB     ;    RESB*2                                      I   I
  rol     RESB+1   ;                                                I   I
  lda     RESB     ;    AX=RESB*2                                   I   I
  ldx     RESB+1   ;                                                I   I
  asl     RESB     ;   *4                                           I   I
  rol     RESB+1   ;                                                I   I
  asl     RESB     ;   *8                                           I   I
  rol     RESB+1   ;                                                I   I
  adc     RESB     ;   +RESB*2                                      I   I
  sta     RESB     ;                                                I   I
  txa              ;                                                I   I
  adc     RESB+1   ;                                                I   I
  sta     RESB+1   ;   = RESB*10                                    I   I
  pla              ;   plus chiffre lu                              I   I
  adc     RESB     ;                                                I   I
  sta     RESB     ;                                                I   I
  bcc     @S1      ;                                                I   I
  inc     RESB+1   ;                                                I   I
@S1:
  iny              ;   on ajoute un chiffre lu                      I   I
  bne     loop     ;     et on recommence  ----------------------------   I
@S2:
  tya              ;     nombre de chiffres lus <--------------------------
  tax              ;     dans X
  lda     RESB     ;     nombre dans AY et RESB
  ldy     RESB+1   ;
  rts
.endproc
