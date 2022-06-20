.export _xexec_extern

XEXEC = $63

.proc _xexec_extern
    stx save_x
    ldy save_x

    .byte $00,XEXEC ; BRK_KERNEL XEXEC


    rts
.endproc
save_x:
    .res 1
    