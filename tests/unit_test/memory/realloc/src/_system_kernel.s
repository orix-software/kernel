.include "telestrat.inc"

.export _system_kernel

.importzp ptr1

.proc _system_kernel
    ;;@brief Execute a kernel function from the system space (0-16K). Return

    stx     ptr1
    ldy     ptr1
    ldx     #$00 ; Fork
    BRK_TELEMON XEXEC
    rts
.endproc

