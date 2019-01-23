;                        CONVERSION ASCII -> BINAIRE                         

;Principe:On lit un ? un les chiffres de la chaine stock?e en AY jusqu'? ce      
;qu'on ait plus de chiffres. On multiplie au fur et ? mesure le resultat
;par 10 avant d'ajouter le chiffre trouv?. Le principe est ais? ?       
; assimiler et la routine compacte. Un bon exemple d'optimisation.       
;En sortie, AY et RESB contient le nombre, AY l'adresse de la chaine,   
; et X le nombre de caract?res d?cod?s.

.proc XDECAY_ROUTINE
                                                                                
  STA     RES      ;   on sauve l'adresse du nombre                      
  STY RES+1    ;    dans RES                                          
  LDY #$00     ;    et on met RESB ? 0                                
  STY RESB
  STY RESB+1                                                          
loop:
  LDA (RES),Y  ;   on lit le code <------------------------------    
  CMP #$30     ;   inférieur ? 0 ?                              I    
  BCC LE785    ;   oui -----------------------------------------+---- 
  CMP #$3A     ;   supérieur ? 9 ?                              I   I
  BCS LE785    ;   oui -----------------------------------------+---O 
  AND #$0F     ;   on isole le chiffre                          I   I
  PHA          ;    dans la pile                                I   I
  ASL RESB     ;    RESB*2                                      I   I
  ROL RESB+1   ;                                                I   I
  LDA RESB     ;    AX=RESB*2                                   I   I
  LDX RESB+1   ;                                                I   I
  ASL RESB     ;   *4                                           I   I
  ROL RESB+1   ;                                                I   I
  ASL RESB     ;   *8                                           I   I
  ROL RESB+1   ;                                                I   I
  ADC RESB     ;   +RESB*2                                      I   I
  STA RESB     ;                                                I   I
  TXA          ;                                                I   I
  ADC RESB+1   ;                                                I   I
  STA RESB+1   ;   = RESB*10                                    I   I
  PLA          ;   plus chiffre lu                              I   I
  ADC RESB     ;                                                I   I
  STA RESB     ;                                                I   I
  BCC LE782    ;                                                I   I
  INC RESB+1   ;                                                I   I
LE782
  INY          ;   on ajoute un chiffre lu                      I   I
  BNE loop    ;     et on recommence  ----------------------------   I
LE785
  TYA       ;     nombre de chiffres lus <--------------------------
  TAX       ;     dans X                                            
  LDA RESB   ;     nombre dans AY et RESB                            
  LDY RESB+1    ;                                                      
  RTS
.endproc   