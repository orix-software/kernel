.include "telestrat.inc"

.export close_sockets_by_pid

.import KERNEL_NETWORK_FLAG
.import KERNEL_NETWORK_SOCKET_LIST
.import KERNEL_NETWORK_SOURCE_PORT
.import KERNEL_NETWORK_SOCKET_PID
.import KERNEL_NETWORK_SOCKET_DOMAIN

.import kernel_process

.include   "../../kernel8/orixlibs/ch395/usr/include/asm/ch395.inc"
.include   "../../include/kernel.inc"
.include   "../../include/process.inc"
.include   "../../include/network.inc"
.include   "../../include/memory.inc"

.import ch395_close_socket_sn

.proc close_sockets_by_pid
    ;;@brief Close all sockets for current pid
    ;;@modifyMEM_TR1

    lda     #$00 ; First socket
    sta     TR1

@restart:
	lda     #<KERNEL_NETWORK_SOCKET_PID
	ldy     #>KERNEL_NETWORK_SOCKET_PID

    sta     ADDRESS_READ_BETWEEN_BANK_DOUBLON
    sty     ADDRESS_READ_BETWEEN_BANK_DOUBLON+1

    ldx     TR1
    ldy     #$00
    MEMORY_GET_VALUE_FROM_BANK ; A contains the value

    cmp     kernel_process + kernel_process_struct::kernel_current_process
    beq     @close_socket

@compute:
    inc     TR1
    lda     TR1
    cmp     #$08
    beq     @exit
    bne     @restart


@close_socket:
    lda     TR1 ; Socket ID
    jsr     ch395_close_socket_sn

    ; Set to 0
    ldy     TR1 ; Get socket id (index)
    lda     #$00  ; clear
    ldx     #$00   ; BANK
    MEMORY_PUT_VALUE_TO_BANK KERNEL_NETWORK_SOCKET_LIST  ; ADDRESS_READ_BETWEEN_BANK_DOUBLON is already set previously : FIXME

    ; Set to 0n
    ldy     TR1 ; Get socket id (index)
    lda     #$00 ; Domain
    ldx     #$00  ; BANK
    MEMORY_PUT_VALUE_TO_BANK KERNEL_NETWORK_SOCKET_DOMAIN  ; ADDRESS_READ_BETWEEN_BANK_DOUBLON is already set previously : FIXME

    ; Clear PID
    ldy     TR1 ; Get socket id (index)
    lda     #$00
    ldx     #$00  ; BANK
    MEMORY_PUT_VALUE_TO_BANK KERNEL_NETWORK_SOCKET_PID  ; ADDRESS_READ_BETWEEN_BANK_DOUBLON is already set previously : FIXME
    jmp     @compute
@exit:
    rts
.endproc