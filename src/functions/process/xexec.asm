.proc _XEXEC

;PARSE_VECTOR
    ; A & Y contains the string command to execute
    sta     TR0        ; Save string pointer
    sty     TR1        ;
    ; Copy in BUFEDT
    ldy     #$00
@L7:    
    lda     (TR0),y
    beq     @S6
    sta     BUFEDT,y
    iny
    cpy     #110
    bne     @L7

@S6:
    lda     #$00
    sta     BUFEDT,y

@S1:
    ; ok then execute
    ; now it's the current process
    ; RACE CONDITION FIXME BUG
    ; If there is a multitasking switch during this step, the process is not started, but kernel will try to execute it
    lda     BNKOLD
    cmp     #$07
    bne     @do_not_correct
    lda     #$05 ; Shell by default
@do_not_correct:    
    sta     KERNEL_KERNEL_XEXEC_BNKOLD


    ldx     #$05       ; start at bank 05
    stx     KERNEL_TMP_XEXEC

next_bank:
    ; We says that we return to Bank 7 
   ; BRK_KERNEL XRDW0
    ldx     KERNEL_TMP_XEXEC

    lda     TR0
    ldy     TR1
    sta     RES
    sty     RES+1

    jsr     KERNEL_DRIVER_MEMORY

    cmp     #EOK
    beq     out1

next:
    ; Here continue
    dec     KERNEL_TMP_XEXEC
    
    bne     next_bank

read_on_sdcard:

    lda     TR0
    ldy     TR1
    jsr     kernel_try_to_find_command_in_bin_path

    cmp     #EOK
    beq     out_from_bin


    rts

out_from_bin:
    lda     KERNEL_KERNEL_XEXEC_BNKOLD
    sta     BNK_TO_SWITCH    

out1:

    lda     kernel_process+kernel_process_struct::kernel_current_process

    jsr     kernel_kill_process
exit:   

    lda     #EOK

    rts
.endproc
