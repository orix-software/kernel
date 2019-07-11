.proc wait_0_3_seconds ; Wait 0,3333 seconds 
  ldy     #$1F
  ldx     #$00
@loop:
  dex
  bne     @loop
  dey
  bne     @loop
  rts
.endproc
