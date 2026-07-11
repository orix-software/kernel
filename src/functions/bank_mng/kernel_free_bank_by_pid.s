.export kernel_free_bank_by_pid

.include "telestrat.inc"

.include   "../../include/kernel.inc"
.include   "../../include/process.inc"
.include   "../../include/memory.inc"
.include   "../../include/files.inc"

;.segment "BANK8"

.import KERNEL_BANK_MANAGEMENT
.import kernel_process
.import kernel_free_bank



.proc kernel_free_bank_by_pid
    ;;@brief Free all bank with PID
    ;;@inputA the pid
    ;;@modifyA
    ;;@modifyX
    ;;@modifyY
    ;;@modifyMEM_RES Tmp value
    ;;@modifyMEM_RESB Tmp value
    ;;@returnsA
    ;;@returnsX
    ;;@returnsY
    sta     TR0 ; Save pid to compare

    ldx     #$00 ; ???

    ldy     #$00  ; First bank
    sty     TR1

	lda     #<KERNEL_BANK_MANAGEMENT
	ldy     #>KERNEL_BANK_MANAGEMENT

    sta     ADDRESS_READ_BETWEEN_BANK_DOUBLON
    sty     ADDRESS_READ_BETWEEN_BANK_DOUBLON + 1

@check_next_bank:
    ldy     TR1

    cpy     #KERNEL_LAST_RAM_BANK
    beq     @oob ; Out Of Bank

    MEMORY_GET_VALUE_FROM_BANK ; A contains the value

    cmp     TR0
    beq     @found
@inc_next_bank:
    inc     TR1
    jmp     @check_next_bank

@found:
    jsr     kernel_free_bank
    jmp	    @inc_next_bank

    rts
@oob:
    lda     #$00 ; Not found
    rts
.endproc
