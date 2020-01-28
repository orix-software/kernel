.proc _xdrawr
  lda     HRSPAT   ;    sauve le pattern                                  
  sta     HRS5+1   ;   FIXME Jede : Erreur entre le commentaire et la valeur (avant $56) dans HRS1+1     
  jsr     Le942    ;    vérifie la validité de dX et dY
  stx     HRSX     ;    X et Y contiennent HRSX+dX et HRSY+dY             
  sty     HRSY     ;   dans HRSX et HRSY
  bit     HRS1+1   ;    dX négatif ?
  BPL     LE89D    ;    non ----------------------------------------------
  LDA     HRS1     ;    oui, on compl?mente                              I
  EOR     #$FF     ;   dX                                               I
  STA     HRS1     ;                                                     I
  INC     HRS1     ;    à 2                                              I
LE89D
  BIT     HRS2+1   ;    dY négatif ? <------------------------------------
  BPL     LE8A9    ;    non ---------------------------------------------- 
  LDA     HRS2     ;    oui on complémente                               I
  EOR     #$FF     ;    dY                                               I
  STA     HRS2     ;                                                     I
  INC     HRS2     ;    à 2                                              I
LE8A9
  LDA     HRS1     ;    on teste dX et dY <-------------------------------
  CMP     HRS2                                                          
  BCC     LE8ED    ;   dX<dY -------------------------------------------- 
  PHP              ;   dX>=dY , on trace selon dX                       I
  LDA     HRS1     ;   on prends dX                                     I
  BEQ     LE8EB    ;    dX=0, on sort -------------------------------    I 
  LDX     HRS2     ;    X=dY                                        I    I
  JSR     Le921    ;    on calcule dY/dX                            I    I 
  plp        ;                                                I    I
  bne     LE8C0  ;    dX<>dY -----------------------------------  I    I 
  lda     #$FF   ;    dX=dY, la tangente est 1                 I  I    I
  sta     RES   ;     en fait, -1, mais c'est la m?me chose    I  I    I
LE8C0  
  BIT     HRS1+1 ; I
  BPL     LE8CA          ; I   dX>0 -------------------------------------  I    I
  JSR XHRSCG_ROUTINE ; I   dX<0, on déplace le curseur à gauche     I  I    I 
  JMP LE8CD          ; I---                                         I  I    I  
LE8CA
  JSR XHRSCD_ROUTINE ; II  on on déplace le curseur à droite <-------  I    I 
LE8CD
  CLC       ; I-->a-t-on parcouru une valeur de la tangente   I    I
  LDA     RES   ; I                                               I    I
  ADC RESB   ; I   on stocke le résultat dans RESB              I    I
  STA RESB   ; I                                               I    I
  BCC LE8E3  ;I   non, on continue -------------------------  I    I 
  BIT $50   ; I   oui, dY<0 ?                              I  I    I
  BMI LE8E0 ; I   oui -------------------------------      I  I    I
  JSR XHRSCB_ROUTINE ; I   non, on déplace le curseur        I      I  I    I 
  JMP LE8E3  ;I---vers le bas                       I      I  I    I 
LE8E0
  JSR XHRSCH_ROUTINE ; II  on déplace vers le haut <----------      I  I    I
LE8E3
  JSR XHRSSE_ROUTINE    ;I-->on affiche le point <---------------------  I    I 
  DEC HRS1   ; I   on décremente dX,                           I    I
  BNE LE8C0 ; ----on n'a pas parcouru tout l'axe              I    I 
LE8EA
  RTS       ;  -->sinon, on sort                              I    I
LE8EB
  PLP      ;   I  <--------------------------------------------    I
  RTS       ;  I                                                   I
LE8ED
  LDA     HRS2   ;  I  on trace la droite selon dY <---------------------
  BEQ LE8EA  ; ---dY=0, on sort                                      
  LDX HRS1   ;     X=dX                                              
  JSR Le921 ;     on calcule dX/dY dans RES                          
LE8F6
  BIT     HRS2+1                                                          
  BPL LE900  ;    dY>0 --------------------------------------------- 
  JSR XHRSCH_ROUTINE ;    dY<0, on d?place vers le haut                    I 
  JMP LE903  ; ---et on saute                                      I 
LE900
  JSR XHRSCB_ROUTINE  ; I  on déplace vers le bas <-------------------------- 
LE903  
  CLC       ;  -->a-t-on parcouru la tangente ?                     
  LDA RES                                                          
  ADC RESB                                                          
  STA RESB     ;   (dans RESB)                                        
  BCC LE919   ;   non ---------------------------------------------- 
  BIT HRS1+1     ;                                                    I
  BPL LE916   ;   dX>0 ------------------------------------        I
  JSR XHRSCG_ROUTINE   ;   dX<0, on déplace vers                   I        I 
  JMP LE919  ; ---la gauche                               I        I 
LE916  
  JSR XHRSCD_ROUTINE  ; I  on d?place vers la droite <--------------        I 
LE919  
  JSR XHRSSE_ROUTINE   ; -->on affiche le point <----------------------------- 
  DEC HRS2    ;    et on d?crit dY       FIXME                             
  BNE LE8F6                                                       ;
  rts         ;   avant de sortir de longueur des lignes            
.endproc 
