.export search_free_bank


.include "telestrat.inc"

.include   "../../include/kernel.inc"
.include   "../../include/process.inc"
.include   "../../include/memory.inc"
.include   "../../include/files.inc"
;.include   "../../kernel.inc"

;.segment "BANK8"

.import KERNEL_BANK_MANAGEMENT
.import kernel_process


.proc search_free_bank

    ;;@brief Search free bank : Only manage RAM bank for instance
    ;;@inputA the type of the bank
    ;;@modifyA
    ;;@modifyX
    ;;@modifyY
    ;;@modifyMEM_RES Tmp value
    ;;@returnsA the id of the bank from 34 to 63 (Else A = 0 if out of bank)
    ;;@returnsX the set
    ;;@returnsY the id of the bank (from 1 to 4 depending of the set)

    ldx     #$00

    ldy     #KERNEL_FIRST_FREE_RAM_BANK  ; First bank
    sty     RES + 1

	lda     #<KERNEL_BANK_MANAGEMENT
	ldy     #>KERNEL_BANK_MANAGEMENT

    sta     ADDRESS_READ_BETWEEN_BANK_DOUBLON
    sty     ADDRESS_READ_BETWEEN_BANK_DOUBLON + 1

@not_found:

    ldy     RES + 1

    cpy     #(KERNEL_LAST_RAM_BANK + 1)
    beq     @oob ; Out Of Bank

    MEMORY_GET_VALUE_FROM_BANK ; A contains the value

    cmp     #$00
    beq     @found

    inc     RES + 1
    bne     @not_found


@found:
    ; Set busy flag
    lda     #$01 ; Type
    ldy     RES + 1 ; Offset
    ldx     #$00  ; BANK

    MEMORY_PUT_VALUE_TO_BANK KERNEL_BANK_MANAGEMENT

    lda     RES + 1 ; Offset
    clc
    adc     #kernel_bank_management_struct::KERNEL_BANK_PROCESS_ID
    tay
    ; At this step, Y contains the offset of kernel_bank_management_struct::KERNEL_BANK_PROCESS_ID to store process id
    lda     kernel_process+kernel_process_struct::kernel_current_process
    ldx     #$00  ; BANK 0 to store process into KERNEL_BANK_MANAGEMENT and kernel_bank_management_struct::KERNEL_BANK_PROCESS_ID offset

    MEMORY_PUT_VALUE_TO_BANK KERNEL_BANK_MANAGEMENT

    ; A contains the id of the bank

    lda     RES + 1 ; Load the id of the bank found
    beq     @bank0
    tay
    lda     set,y
    tax
    lda     bank,y
    tay
    lda     RES + 1

    rts

@bank0:
    ; Impossible to have bank 0
    tax
    rts

@oob:
    lda     #$00
    rts

.include "../xvars/set_bank_mapping_values.s"

.endproc
