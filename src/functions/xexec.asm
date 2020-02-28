.proc _XEXEC
;PARSE_VECTOR
    ; A & Y contains the string command to execute
    sta     TR0        ; Save string pointer
    sty     TR1        ;
  

    ;jsr     kernel_create_process
    ;cmp     #NULL
    ;bne     @S1
    ;cpy     #NULL
    ;bne     @S1
    ; Error impossible to fork
   ; lda     #EUNKNOWN
;    sta     KERNEL_ERRNO
    ;rts
@S1:
    ; ok then execute
    ; now it's the current process
 ;   sta     KERNEL_XEXEC_SAVE_TMP
    
    ; RACE CONDITION FIXME BUG
    ; If there is a multitasking switch during this step, the process is not started, but kernel will try to execute it
    lda     BNKOLD
    pha

    lda     #$05       ; start at bank 05
    sta     KERNEL_TMP_XEXEC


next_bank:
    ; We says that we return to Bank 7 
    lda     KERNEL_TMP_XEXEC
    sta     BNK_TO_SWITCH ; for $4AF call


    lda     TR0
    ldy     TR1
    sta     RES
    sty     RES+1

    jsr     KERNEL_DRIVER_MEMORY


    cmp     #$00
    beq     out1

next:
    ; Here continue
    ldx     KERNEL_TMP_XEXEC
    dex
    stx     KERNEL_TMP_XEXEC
    ;cpx     #$01        ; Read only bank 5 to 4 for instance FIXME BUG
    bne     next_bank
    lda     #ENOENT         ; Error
    rts

out1:
    ; Now kill the current process
    lda     kernel_process+kernel_process_struct::kernel_current_process
    jsr     kernel_kill_process
    ; Back to calling bank
    
    pla
    sta     BNK_TO_SWITCH
    lda     #EOK
    rts
.endproc
