.export kernel_restore_banking_states
.export kernel_restore_banking_states_register

.import KERNEL_SAVE_XEXEC_CURRENT_SET
.import KERNEL_SAVE_XEXEC_CURRENT_ROM_RAM

.import switch_to_kernel_extended


.segment "BANK7"

.proc  kernel_restore_banking_states
    pla
    jsr     switch_to_kernel_extended
    ; restore
    jmp     kernel_restore_banking_states_register
.endproc


.proc kernel_restore_banking_states_register
    pha
    lda     KERNEL_SAVE_XEXEC_CURRENT_SET
    sta     $343
    lda     KERNEL_SAVE_XEXEC_CURRENT_ROM_RAM
    sta     $342
    pla
    cli
    rts
.endproc
