.export  XCURSE_ROUTINE

;                    ROUTINE CURSET                               
.proc XCURSE_ROUTINE
  ldx      HRS1                     ;  X=HRSX      
  ldy      HRS2                     ;   Y=HRSY      
  jsr      hires_verify_position    ;  on vérifie les coordonnées
_DONT_VERIFY:
  jsr      hires_put_coordinate     ;  on place le curseur en X,Y                        

  jmp      LE79C                    ;  et on affiche sans gérer pattern      
.endproc  