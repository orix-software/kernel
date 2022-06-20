
;                          TRACE DE TRAIT EN RELATIF

;Principe:Le principe du tracé des droites est en fait assez complexe. On aurait
;         aimé que F. BROCHE nous ponde une routine hyper-optimisée dont il a le
;         secret. Ce n'est malheureusement pas le cas puisque cette routine
;         l'algorithme des ROM V1.0 et 1.1. Sans doute parce qu'il est très
;         efficace...
;         Pour tracer un trait le plus rapidement possible, on cherche lequel des
;         deux axes est le plus grand et on trace selon cet axe. Pour tracer,    
;         on avance sur l'axe de t points (t est la valeur de la tangente) et on 
;         avance d'un point sur l'autre axe, et ainsi de suite jusqu'à ce qu'on  
;         ait parcouru tout l'axe.
;         Ainsi DRAW 10,2,1 donnera en fait 2 paliers de 5 pixels de large.      
;         Le cas dX=dY (déplacements égaux) est traité avec t=-1, de plus les    
;         poids fort des déplacements gardent le signe car on prend la valeur    
;         absolue de dX et dY pour les calculs.


; NOERROR


.proc XDRAWR_ROUTINE
  lda     HRSPAT         ;   sauve le pattern
  sta     HRS5+1         ;   FIXME Jede : Erreur entre le commentaire et la valeur (avant $56) dans HRS1+1
  jsr     check_relative_parameters          ;   vérifie la validité de dX et dY
  stx     HRSX           ;   X et Y contiennent HRSX+dX et HRSY+dY
  sty     HRSY           ;   dans HRSX et HRSY
  bit     HRS1+1         ;   dX négatif ?
  bpl     @S1            ;   non ----------------------------------------------
  lda     HRS1           ;   oui, on complèmente                              I
  eor     #$FF           ;   dX                                               I
  sta     HRS1           ;                                                    I
  inc     HRS1           ;   à 2                                              I
@S1:
  bit     HRS2+1         ;   dY négatif ? <------------------------------------
  bpl     @S2            ;   non ---------------------------------------------- 
  lda     HRS2           ;   oui on complèmente                               I
  eor     #$FF           ;   dY                                               I
  sta     HRS2           ;                                                    I
  inc     HRS2           ;   à 2                                              I
@S2:
  lda     HRS1           ;   on teste dX et dY <-------------------------------
  cmp     HRS2
  bcc     LE8ED          ;   dX<dY -------------------------------------------- 
  php                    ;   dX>=dY , on trace selon dX                       I
  lda     HRS1           ;   on prends dX                                     I
  beq     LE8EB          ;   dX=0, on sort -------------------------------    I 
  ldx     HRS2           ;   X=dY                                        I    I
  jsr     Le921          ;   on calcule dY/dX                            I    I 
  plp                    ;                                               I    I
  bne     LE8C0          ;   dX<>dY -----------------------------------  I    I 
  lda     #$FF           ;   dX=dY, la tangente est 1                 I  I    I
  sta     RES            ;   en fait, -1, mais c'est la même chose    I  I    I
LE8C0:
  bit     HRS1+1         ; I
  bpl     @S2            ; I dX>0 -------------------------------------  I    I
  jsr     XHRSCG_ROUTINE ; I dX<0, on d?place le curseur à gauche     I  I    I 
  jmp     @S3            ; I---                                       I  I    I  
@S2:
  jsr     XHRSCD_ROUTINE ; II  on on déplace le curseur à droite <-------  I    I 
@S3:
  clc                    ; I-->a-t-on parcouru une valeur de la tangente   I    I
  lda     RES            ; I                                               I    I
  adc     RESB           ; I   on stocke le résultat dans RESB              I    I
  sta     RESB           ; I                                               I    I
  bcc     @S5          ;I   non, on continue -------------------------  I    I 
  bit     $50            ; I   oui, dY<0 ?                              I  I    I FIXME
  bmi     @S4          ; I   oui -------------------------------      I  I    I
  jsr     XHRSCB_ROUTINE ; I   non, on déplace le curseur        I      I  I    I 
  jmp     @S5          ;I---vers le bas                       I      I  I    I 
@S4:
  jsr     XHRSCH_ROUTINE ; II  on déplace vers le haut <----------      I  I    I
@S5:
  jsr     XHRSSE_ROUTINE    ;I-->on affiche le point <---------------------  I    I 
  dec     HRS1   ; I   on d?cremente dX,                           I    I
  bne     LE8C0 ; ----on n'a pas parcouru tout l'axe              I    I 
LE8EA:
  rts       ;  -->sinon, on sort                              I    I
LE8EB:
  plp      ;   I  <--------------------------------------------    I
  rts       ;  I                                                   I
LE8ED:
  lda     HRS2   ;  I  on trace la droite selon dY <---------------------
  beq     LE8EA  ; ---dY=0, on sort
  ldx     HRS1   ;     X=dX
  jsr     Le921 ;     on calcule dX/dY dans RES
LE8F6:
  bit     HRS2+1
  bpl     LE900  ;    dY>0 --------------------------------------------- 
  jsr     XHRSCH_ROUTINE ;    dY<0, on déplace vers le haut                    I 
  jmp     LE903  ; ---et on saute                                      I 
LE900:
  jsr     XHRSCB_ROUTINE  ; I  on déplace vers le bas <-------------------------- 
LE903:
  clc       ;  -->a-t-on parcouru la tangente ?
  lda     RES
  adc     RESB
  sta     RESB             ;   (dans RESB)
  bcc     LE919            ;   non ---------------------------------------------- 
  bit     HRS1+1           ;                                                    I
  bpl     LE916   ;   dX>0 ------------------------------------        I
  jsr     XHRSCG_ROUTINE   ;   dX<0, on déplace vers                   I        I 
  jmp     LE919  ; ---la gauche                               I        I 
LE916:
  jsr     XHRSCD_ROUTINE  ; I  on déplace vers la droite <--------------        I 
LE919  
  jsr     XHRSSE_ROUTINE   ; -->on affiche le point <----------------------------- 
  dec     HRS2    ;    et on décrit dY       FIXME
  bne     LE8F6                                                       ;
  rts         ;   avant de sortir de longueur des lignes
.endproc 
