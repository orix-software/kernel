
;                         TRACE UN RECTANGLE ABSOLU


;Principe:Par un procédé très astucieux, on va tracer les 4 traits (en absolu)
;         joignant les 4 points. Voila bien la seule astuce inutile ! Il aurait
;         été 100 (pourquoi pas 1000 !?) fois plus simple, puisque le rectangle
;         n'est fait que de verticales et d'horizontales, de tracer le rectangle
;         immédiatement en relatif plutot que de passer par des calculs de
;         tangentes lourds et donnant un résultat connu (0 et infini) !!!
;         Cette piètre routine nécessite les paramètres comme ABOX dans HRSx.
;         Notez également l'utilisation de l'absolu,X plutot que du page 0,X en
;         $E850... tss tss !



XABOX_ROUTINE:
  ldy     #$06    ; On place les 4 paramètres (poids faible seulement)
  ldx     #$03
LE830
  lda     HRS1,y      ;  de HRSx
  sta     DECFIN,x    ;  dans $06-7-8-9
  dey
  dey
  dex
  bpl     LE830
LE83A:
  ldx     #$03          ;  on va tracer 4 traits
LE83C:
  stx     DECDEB+1      ;  dans $05 <----------------------------------------
  lda     table_for_rect,x   ; on lit le code coordonn?es                       I
  sta     DECDEB      ;  dans $04                                         I
  ldx #$06            ;  on va extraire 8 bits                            I
LE845:
  lda #$00            ;  A=0 <----------------------------------------    I
  sta HRS1+1,c        ;  poids fort HRSx ? 0 et positif              I    I
  lsr DECDEB          ;   on sort 2 bits                              I    I
  rol                 ;   dans A                                      I    I
  lsr DECDEB          ;                                               I    I
  rol                 ;                                               I    I
  tay                 ;   et Y                                        I    I
  lda $0006,y         ;  on lit la coordonnée correspondante         I    I
  sta HRS1,x          ;  et on stocke dans HRSx                      I    I
  dex                 ;                                               I    I
  dex                 ;                                              I    I
  bpl LE845           ;   on fait les 4 coordonnées ADRAW -------------    I
  jsr XDRAWA_ROUTINE  ;   on trace le trait en absolu                      I
  ldx DECDEB+1        ;                                                     I
  dex                 ;                                                     I
  bpl LE83C           ;   et on fait 4 traits ------------------------------
  rts
table_for_rect:
  .byt $26,$67,$73,$32
