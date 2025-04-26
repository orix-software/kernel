.include "telestrat.inc"

.export XBANK_ROUTINE

.export XNETWORK_START_ROUTINE

.import switch_to_kernel_extended
.import kernel_restore_banking_states

.import KERNEL_SAVE_XEXEC_CURRENT_ROM_RAM
.import KERNEL_SAVE_XEXEC_CURRENT_SET

XNETWORK_START_ROUTINE := XBANK_ROUTINE

.segment "BANK7"

.proc XBANK_ROUTINE

    .out     .sprintf("|MODIFY:VEXBNK:XBANK_ROUTINE")

    ;;@brief XBANK_ROUTINE is a wrapper to switch to Kernel bank 8 (extended mode) and call the function in bank 8.
    ;;@modifyMEM_VEXBNK

    pha
    lda     #<$C000
    sta     VEXBNK + 1

    lda     #>$C000
    sta     VEXBNK + 2
    ; !!!! pla is done in kernel_restore_banking_states
    jmp     kernel_restore_banking_states

.endproc
