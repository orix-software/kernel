.include "telestrat.inc"

.export _malloc_kernel

.importzp ptr1

.import popax

.proc _malloc_kernel
    ;; void *realloc_kernel(void *ptr, int size);
    ; A & X size
    sta     ptr1
    stx     ptr1 + 1

    jsr     popax ; Get ptr
    sta     RES
    stx     RES + 1

    lda     ptr1 ; Size
    ldy     ptr1 + 1
    BRK_TELEMON XMALLOC
    sty     RES
    ldx     RES
    rts
.endproc

