
;                       TRACE UN RECTANGLE EN RELATIF

;Principe:On calcule les coordonnées absolues des 4 coins et on trace en absolu.
;         Pas très optimisé en temps tout cela, il aurait été plus simple de
;         de tracer directement en relatif !!!
;         Le rectangle est tracé comme ABOX avec les paramètres dans HRSx.
.proc XBOX_ROUTINE
  clc              ;   C=0
  lda     HRSX     ;   on place les coordonées actuelles
  sta     DECFIN   ;   du curseur dans $06-07
  adc     HRS1     ;   et les coordonnées (X+dX,Y+dY)
  sta     DECCIB
  lda     HRSY
  sta     DECFIN+1
  adc     HRS2
  sta     DECCIB+1 ;   dans DECCIB-09
  bcc     LE83A    ;   inconditionnel
.endproc
