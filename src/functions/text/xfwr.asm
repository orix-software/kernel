.proc _XFWR_routine

    ldy     ADSCRL
    sty     ADSCR     
    ldy     ADSCRH
    sty     ADSCR+1  
    ldy     SCRX
    sta     (ADSCR),y   ; FIXME 65c02


    inc     SCRX

    rts
.endproc
