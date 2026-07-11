.include "telestrat.inc"

.export _realloc_kernel

.importzp ptr1

.import popax

.proc _realloc_kernel
    ;; void *realloc_kernel(void *ptr, int size);
    ; A & X size
    sta     ptr1
    stx     ptr1 + 1

    jsr     popax ; Get ptr


    sta     RES
    stx     RES + 1



    lda     ptr1 ; Size
    ldy     ptr1 + 1
    BRK_TELEMON $02
    sty     RES
    ldx     RES
    rts
.endproc

