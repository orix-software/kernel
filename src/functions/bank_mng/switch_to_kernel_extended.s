.include "telestrat.inc"

.export switch_to_kernel_extended
.export switch_to_kernel_extended_fill_register


.import KERNEL_SAVE_XEXEC_CURRENT_SET
.import KERNEL_SAVE_XEXEC_CURRENT_ROM_RAM

.segment "BANK7"

.proc switch_to_kernel_extended
    jsr     switch_to_kernel_extended_fill_register
    jmp     $40C
.endproc

.proc switch_to_kernel_extended_fill_register

    pha

    lda     $343
    sta     KERNEL_SAVE_XEXEC_CURRENT_SET

    lda     #$04
    sta     BNKCIB

    lda     $342
    sta     KERNEL_SAVE_XEXEC_CURRENT_ROM_RAM
    and     #%11011111
    sei

    sta     $342

    lda     #$04
    sta     $343
    pla
    rts
.endproc