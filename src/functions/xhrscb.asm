.proc     XHRSCB_ROUTINE

;                    DEPLACEMENT RELATIF DU CURSEUR HIRES                    
                                                                                
;Action:Ces quatres routines permettent un d?placement extr?mement rapide du     
;       curseur HIRES d'apr?s l'adresse de la ligne ou il se trouve (ADHRS),     
;       la colonne dans laquelle il se trouve (HRSX40) et sa position dans       
;       l'octet point? (HRSX6).                                                  
;       Attention:Les coordonn?es HRSX et HRSY ne sont pas modifi?es ni v?rifi?es
;                 avant le d?placement, ? vous de g?rer cela.                    
                                                                                
;                    DEPLACE LE CURSEUR HIRES VERS LE BAS                      

  clc           ;     on ajoute 40                                      
  lda     ADHRS     ;    à ADHRS
  adc     #$28                                                         
  sta     ADHRS                                                          
  bcc     skip
  inc     ADHRS+1                                                          
skip:  
  rts
.endproc  
