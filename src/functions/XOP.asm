; A contains channel
.proc XOP0_ROUTINE
   .out     .sprintf("|MODIFY:IOTAB:XOP0")
   .out     .sprintf("|MODIFY:work_channel:XOP0")

    ldx     #$00 ; Channel 0
    pha


@L1:
    pla
    cmp     IOTAB,x    ; Already open with the same IO ?
    beq     @S1     ; Yes exit
    ldy     IOTAB,x
    bpl     @skip129
    inx
    pha
    txa
    and     #$03
    bne     @L1
    pla

@S1:
    rts

@skip129:
    ldy     #(KERNEL_SIZE_IOTAB - 1)

@loop:
    cmp     IOTAB,y
    beq     @skip2
    dey

    bpl     @loop
    stx     work_channel
    pha

    ldy     #$80
    tax

    jsr     send_command_A ; Why it sends something in the open channel ?

    ldx     work_channel
    pla

@skip2:
    sta     IOTAB,x
    clc
    rts
.endproc
