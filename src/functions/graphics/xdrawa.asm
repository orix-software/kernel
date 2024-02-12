
;                         TRACE DE TRAIT EN ABSOLU

; Action:on calcule dX et dY les deplacements dans HRS1 et HRS2 et on trace en
; relatif. En entr?e, comme ADRAW dans HRSx.

.proc XDRAWA_ROUTINE
  ldx     HRS1                   ;   X=colonne
  ldy     HRS2                   ;   Y=ligne du curseur
  jsr     hires_put_coordinate   ;   on place le curseur en X,Y
  ldx     #$FF                   ;   on met -1 dans X pour un changement de signe
  sec                            ;   éventuel dans les paramètres
  lda     HRS3                   ;   on prend X2
  sbc     HRS1                   ;   -X1
  sta     HRS1                   ;   dans HRS1 (DX)
  bcs     @S1                    ;   si DX<0, on inverse le signe de HRS1
  stx     HRS1+1                 ;   dec $4E aurait été mieux...
  sec

@S1:
  lda     HRS4                   ;  on prend Y2
  sbc     HRS2                   ;  -Y1
  sta     HRS2                   ;  dans HRS2 (DY)
  bcs     XDRAWR_ROUTINE         ;  et si DY négatif, on met signe -1
  stx     HRS2+1                 ;   ou dec $50
.endproc
