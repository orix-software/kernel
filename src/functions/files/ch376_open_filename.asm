.proc ch376_open_filename

; Returns A=0 end of string
; else A<>0 : there is others strings

@loop_next_byte:
    lda     (KERNEL_XOPEN_PTR1),y
    beq     @send_end_out
    cmp     #'/'
    beq     @send
    jsr     XMINMA_ROUTINE
    sta     CH376_DATA
    iny
    bne     @loop_next_byte

@send:

@send_end_out:

    rts
.endproc
