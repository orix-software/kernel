.include "telestrat.inc"

; ca65 -ttelestrat xexec.asm
; ld65.exe -ttelestrat xexec.o -o xexec
XEXEC_ROUTINE:=$63
.segment "CODE"
__MAIN_START__:
    ;lda $321
   ; sta save_return
    lda #<str
    ldy #>str
    BRK_TELEMON(XEXEC_ROUTINE)

    ;lda save_return
   ; sta $321
    rts
;save_return:
 ;   .res 1
str:
    .asciiz "lsmem"    
__MAIN_LAST__:
 