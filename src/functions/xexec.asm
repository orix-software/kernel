.proc _XEXEC
;PARSE_VECTOR
    sta     TR6        ; Save string pointer
    sty     TR7

    sei
    lda     #<PARSE_VECTOR
    sta     ptr1
    lda     #>PARSE_VECTOR
    sta     ptr1+1
    ldy     #$00
    jsr     READ_BYTE_FROM_OVERLAY_RAM ; get low
    sta     VEXBNK+1
    ;sta     VAPLIC+1
    iny 
    jsr     READ_BYTE_FROM_OVERLAY_RAM ; get high
    sta     VEXBNK+2
    ;sta     VAPLIC+2
    lda     #$07  ; kernel
    sta     VAPLIC
    lda     #$06 ; Shell bank
    sta     BNKCIB
    lda     #<next
    sta     VAPLIC+1
    lda     #>next
    sta     VAPLIC+2
    JMP     EXBNK
next:  
    cli
    rts
   
	;lda     #<$c000
	;ldy     #>$c000
    ;sta     VAPLIC+1
	;sty     VAPLIC+2
	STA     VEXBNK+1 ; BNK_ADDRESS_TO_JUMP_LOW
	STY     VEXBNK+2 ; BNK_ADDRESS_TO_JUMP_HIGH
	STX     BNKCIB
	JMP     EXBNK

;    lda     RES
    ;sta     ptr1
    ;lda     RES+1
    ;sta     ptr1+1


	rts
.endproc

