.include   "../../kernel8/orixlibs/ch395/usr/include/asm/ch395.inc"
.include   "../../kernel8/orixlibs/ksocket/usr/include/asm/socket.inc"

.include   "../../include/kernel.inc"
.include   "../../include/process.inc"
.include   "../../include/memory.inc"

.include "telestrat.inc"



.import KERNEL_NETWORK_SOCKET_LIST
.import KERNEL_NETWORK_SOCKET_DOMAIN
.import KERNEL_NETWORK_SOCKET_PID

.export XSOCKET_CLOSE_ROUTINE

.import ch395_close_socket_sn

.proc XSOCKET_CLOSE_ROUTINE
    ; X contains the id of the socket
    ; Remove socket id
    .out     .sprintf("|MODIFY:TR0:XSOCKET_CLOSE_ROUTINE")

    txa
    sta     TR0

    tay     ; Contains socket id
    lda     #$00  ; Type
    ldx     #$00  ; BANK
    MEMORY_PUT_VALUE_TO_BANK KERNEL_NETWORK_SOCKET_LIST  ; ADDRESS_READ_BETWEEN_BANK_DOUBLON is already set previously : FIXME


    ldy     TR0     ; Contains socket id
    lda     #$00  ; Type
    ldx     #$00  ; BANK
    MEMORY_PUT_VALUE_TO_BANK KERNEL_NETWORK_SOCKET_PID  ; ADDRESS_READ_BETWEEN_BANK_DOUBLON is already set previously : FIXME

    ; Flush buffers
    lda     TR0 ; Load socket id
    jmp     ch395_close_socket_sn


.endproc

