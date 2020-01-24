.proc XWRCLK_ROUTINE
  php
  sei
  sta     ADCLK
  sty     ADCLK+1
  sec
  ror     FLGCLK
  plp
  rts
.endproc  
