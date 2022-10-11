.proc     XHRSCB_ROUTINE

;                    DEPLACEMENT RELATIF DU CURSEUR HIRES

; Action:Ces quatres routines permettent un deplacement extremement rapide du
;       curseur HIRES d'apres l'adresse de la ligne ou il se trouve (ADHRS),
;       la colonne dans laquelle il se trouve (HRSX40) et sa position dans
;       l'octet point? (HRSX6).
;       Attention:Les coordonnees HRSX et HRSY ne sont pas modifiees ni verifiees
;                 avant le deplacement, de vous de gerer cela.

;                    DEPLACE LE CURSEUR HIRES VERS LE BAS

  clc               ;    on ajoute 40
  lda     ADHRS     ;    à ADHRS
  adc     #$28
  sta     ADHRS
  bcc     skip
  inc     ADHRS+1
skip:
  rts
.endproc
