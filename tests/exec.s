.export _xexec_extern

XEXEC = $63

.proc _xexec_extern
    stx save_x

    ldx $321
    stx save_return
    ldy save_x

    ldx     #$00 ; FORK
    .byte $00,XEXEC ; BRK_KERNEL XEXEC

    ldx     save_return
    stx     $321

    rts
.endproc
save_return:
    .res 1
save_x:
    .res 1
