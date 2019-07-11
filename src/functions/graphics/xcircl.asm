;                              TRACE UN CERCLE                               

;Principe:Pour tracer une ellipsoide en g?n?ral, on utilise la formule :         
                                                                                
;         (X*X)/(A*A)+(Y*Y)/(B*B)=1, A et B étant respectivement la largeur      
;         et la hauteur de l'ellipse. Pour un cercle, A=B donc on ?crit :        
                                                                                
;         X*X+Y*Y=R*R soit encore X=SQR(R*R-Y*Y).                                
                                                                                
;         Pour tracer le cercle, il suffit de faire varier Y de 0 à R. On        
;         obtient des valeurs positives de X et de Y donc la quart inférieur     
;         droit du cercle. On trace les 3 autres quarts par symétries. Le        
;         problème d'un tel algorithme c'est qu'il nécessite le calcul d'une     
;         exponentiation (SQR(A)=A^0.5) et une soustraction décimale.
;         Son atout est de n'avoir à calculer qu'un quart des valeurs.           
                                                                                
;         Les concepteurs de l'ATMOS (et à fortiori F. BROCHE) ayant jugé que cet
;         algorithme était par trop complexe et laborieux, on préféré le calcul  
;         par suites croisées dont la formule est :                              
                                                                                
;         X0=0 et Xn=X(n-1)+Yn/R   (n et n-1 sont les indices des termes X et Y) 
;         Y0=R et Yn=Y(n-1)-Xn/R                                                 
                                                                                
;         Etant donnée la priorité de calcul, on calcule en fait les termes :    
                                                                                
;         Xn = Xn-1 + Yn-1 / R                                                   
;         Yn = Yn-1 - Xn   / R ce qui fait déja une petite erreur de calcul.     
                                                                                
;         De plus, diviser à chaque fois par R serait long. Les programmeurs,    
;         et c'est là leur génie, ont donc pensé à deux choses fort astucieuses: 
                                                                                
;         a) on divisera non pas par R, mais par la puissance de deux            
;            immédiatement supérieure ? R afin de se ramener à des décalages.    
;            on devient ainsi trop précis, ce qui rattrape l'erreur passée.      
                                                                                
;         b) on va coder Xn et Yn sur deux octets qui seront se et sf,           
;            respectivement les parties entiéres et décimale de Xn et Yn.        
;            on calcule Xn=AB par Xn=A+B/256. Ce qui revient en fait à considérer
;            les 8 bits de B (b7b6b5b4b3b2b1b0) comme des bits de puissance      
;            n?gatives décroissantes (b-1b-2b-3b-4b-5b-6b-7b-8). La précision    
;            est donc inférieure a 2^-9, soit à 0,002. Ce qui est très suffisant.
                                                                                
;         Une fois ces deux conventions posées, on peut tracer le cercle très    
;         facilement. Son aspect sera de symétrie diagonales et non verticale/   
;         horizontale du fait de la quadrature exercée sur les valeurs mais bon. 
;         Pour tracer, on calcule un par un les termes des suites et si la valeur
;         entiére d'un des termes au moins change, on affiche le point. Et on    
;         continue jusqu'à ce que Xn et Yn soit revenus à leur position initiale.
                                                                                
;Remarque:La routine est buggée, en effet si le rayon est 0, la boucle de calcul 
;         de la puissance de 2 > au rayon est infinie, idem si le rayon est 128. 
;         Il aurait suffit d'incrémenter le rayon avant le calcul...             

.proc XCIRCL_ROUTINE
                                                                            
  lda      HRSX       ; on sauve HRSX                                     
  pha                                                              
  lda      HRSY                    ;  et HRSY                                           
  pha                                                              
  lda      HRSPAT                  ;  et on met le pattern dans $56
  sta      HRS5+1                  ;  car le tracé du cercle en tient compte
  lda      HRSY                    ;  on prend HRSY
  sec
  sbc      HRS1                    ;  -rayon
  TAY                              ;  dans Y
  ldx      HRSX                    ;  on prend HRSX
  jsr      hires_put_coordinate    ;  et on place le premier point du cercle (X,Y-R)
  ldx      #$08                    ;  X=7+1 pour calculer N tel que Rayon<2^N.
  lda      HRS1                    ;  on prend le rayon
@L1:
  dex                              ;  on enlève une puissance
  asl                              ;  on décale le rayon à gauche
  bpl      @L1                     ;  jusqu'à ce qu'un bit se présente dans b7
  stx      TR0                     ;  exposant du rayon dans $0C
  lda      #$80                    ;  A=$80 soit 0,5 en décimal
  sta      TR2                     ;  dans sfX
  sta      TR4                     ;  et sfY
  asl                              ;  A=0
  sta      TR3                     ;  dans seX
  lda      HRS1                    ;  A=Rayon
  sta      TR5                     ;  dans seY
@L2:
  sec                                                              

  ror      TR1                     ;   on met b7 de TR1 à 1 (ne pas afficherle point)
  lda      TR4                     ;    AX=sY
  ldx      TR5                                                          
  jsr      Lea62                   ;   on calcule sY/R (en fait sY/2^N)
  clc                                                              
  lda      TR2                     ;   on calcule sX=sX+sY/R                             
  adc      TR6                                                          
  sta      TR2                                                          
  lda      TR3                                                          
  sta      TR6                                                          
  adc      TR7                                                          
  sta      TR3                     ;  la partie entière seX a bougé ?
  cmp      TR6                                                          
  beq      @S3                     ;  non ----------------------------------------------    
  bcs      @S1                     ;  elle a augmenté ----------------------------     I    
  jsr      XHRSCD_ROUTINE          ;  elle a baissé, on déplace le curseur       I     I  
  jmp      @S2                     ; -à droite                                   I     I  
@S1:
  jsr      XHRSCG_ROUTINE          ;  on déplace le curseur à gauche <------------     I  
@S2:  
  LSR      TR1                     ; -->on indique qu'il faut afficher le point        I
@S3:
  lda      TR2                     ;  AX=sX <-------------------------------------------
  ldx      TR3                                                          
  jsr      Lea62                   ;    on calcule sX/R (en fait sX/2^N)
  sec                                                              
  lda      TR4                     ;    et sY=sY-sX/R
  sbc      TR6                                                          
  sta      TR4                                                          
  lda      TR5                                                          
  sta      TR6                                                          
  sbc      TR7                                                          
  sta      TR5                     ;    seY ? changé (faut-il se déplacer verticalement)? 
  cmp      TR6                                                          
  beq      @S6                     ;    non ----------------------------------------------    
  bcs      @S4                     ;    on est monté --------------------------------    I  
  jsr      XHRSCB_ROUTINE          ;    on est descendu, on déplace le curseur      I    I   
  jmp      @S5                     ; ---vers le bas et on affiche                   I    I   
@S4:
  jsr      XHRSCH_ROUTINE          ; I  on déplace le curseur vers le haut <---------    I   
  jmp      @S5                     ; O--et on affiche                                    I 
@S6:
  bit      TR1                     ; I  faut-il afficher le point ? <---------------------
  bmi      @S7                     ;  I  non, on passe  -----------------------------------    
@S5:
  jsr      XHRSSE_ROUTINE          ; -->on affiche le point nouvellement calcul?         I  
@S7:
  lda      TR3                     ;     seX=0 ? <-----------------------------------------
  bne      @L2                     ;    non, on boucle
  lda      TR5                     ;    oui, seY=rayon?
  cmp      HRS1                                                          
  bne      @L2                     ;    non, on boucle
  pla                              ;    oui, on a fait le tour
  TAY                              ;    on reprend les coordonnées du curseur sauvées 
  pla                              ;    dans X et Y
  tax                                                              
  jmp hires_put_coordinate         ;  et on replace le curseur
.endproc  
