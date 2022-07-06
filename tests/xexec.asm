.include "telestrat.inc"

; ca65 -ttelestrat xexec.asm
; ld65.exe -ttelestrat xexec.o -o xexec
XEXEC_ROUTINE:=$63
.segment "CODE"
__MAIN_START__:
    lda #<str
    ldy #<str
    BRK_TELEMON(XEXEC_ROUTINE)
    rts

str:
    .asciiz "lsmem"    
__MAIN_LAST__:
 