.proc _XFWR_routine
    ;pha
    ;ldx     #$00
    ;jsr     LDE07
    ;pla

    ldy     ADSCRL
    sty     ADSCR     
    ldy     ADSCRH
    sty     ADSCR+1  
    ldy     SCRX
    sta     (ADSCR),y   ; FIXME 65c02


    inc     SCRX

    rts
.endproc