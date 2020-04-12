.proc _XEXEC

; DOC_PRIMITIVE_NAME=XEXEC
; DOC_REGISTERS_MODIFIED=A,X,Y
; DOC_PARAMETERS_REGISTERS_IN_0=A,Y
; DOC_PARAMETERS_REGISTERS_COMMENTS_0=A and Y contains the pointer of the string to execute
; DOC_MEMORY_WRITE_0=
; DOC_MEMORY_WRITE_1=

;PARSE_VECTOR
    ; A & Y contains the string command to execute
    sta     TR0        ; Save string pointer
    sty     TR1        ;

@S1:
    ; ok then execute
    ; now it's the current process
    ; RACE CONDITION FIXME BUG
    ; If there is a multitasking switch during this step, the process is not started, but kernel will try to execute it
    lda     BNKOLD
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
    ldx     KERNEL_TMP_XEXEC
    dex 
    cpx     #$04
    ;dec     KERNEL_TMP_XEXEC
    
    bne     next_bank



    lda     TR0
    ldy     TR1
    jsr     kernel_try_to_find_command_in_bin_path

    cmp     #EOK
    beq     out1


; Exit

    ldx     KERNEL_KERNEL_XEXEC_BNKOLD
    stx     BNKOLD

    rts

out1:

    ; Now kill the current process
    lda     kernel_process+kernel_process_struct::kernel_current_process
    jsr     kernel_kill_process
    ; Back to calling bank
exit:  
    lda     KERNEL_KERNEL_XEXEC_BNKOLD
    sta     BNKOLD
    ;sta     BNK_TO_SWITCH    
    lda     #EOK
    rts
.endproc
