.include   "../../kernel8/orixlibs/ch395/usr/include/asm/ch395.inc"
.include   "../../kernel8/orixlibs/ksocket/usr/include/asm/socket.inc"

.include   "../../include/kernel.inc"
.include   "../../include/process.inc"
.include   "../../include/memory.inc"

.include "telestrat.inc"

.export xconnect

.import kconnect

.import KERNEL_NETWORK_SOURCE_PORT
.import KERNEL_NETWORK_SOCKET_LIST

.proc xconnect
    socket  := TR0
    ip      := DECFIN
    srcport := DECDEB ; Don't change it, DECDEB is used in kconnect
    type    := TR3

    sty     ip
    stx     ip + 1
	lda     #<KERNEL_NETWORK_SOURCE_PORT
    sta     ADDRESS_READ_BETWEEN_BANK_DOUBLON

	lda     #>KERNEL_NETWORK_SOURCE_PORT
    sta     ADDRESS_READ_BETWEEN_BANK_DOUBLON+1

    ldx     #$00
    ldy     #$00
    MEMORY_GET_VALUE_FROM_BANK ; A default source port

    sta     srcport ; src port
    ldx     #$00
    stx     srcport + 1

    ; inc dst port for the future
    tax
    inx
    txa
    ldy     #$00
    ldx     #$00  ; BANK

    MEMORY_PUT_VALUE_TO_BANK KERNEL_NETWORK_SOURCE_PORT  ; ADDRESS_READ_BETWEEN_BANK_DOUBLON is already set previously : FIXME

	lda     #<KERNEL_NETWORK_SOCKET_LIST
	ldy     #>KERNEL_NETWORK_SOCKET_LIST

    sta     ADDRESS_READ_BETWEEN_BANK_DOUBLON
    sty     ADDRESS_READ_BETWEEN_BANK_DOUBLON + 1

    ldx     #$00
    ldy     socket
    MEMORY_GET_VALUE_FROM_BANK ; get Type
    sta     type


    ;;@` lda     #00  ; Port 80
    ;;@` sta     RESB
    ;;@` lda     #80  ; Port
    ;;@` sta     RESB+1
    ;;@` lda     #$00 ; Socket id
    ;;@` lda     mysocketid
    ;;@` sta     TR0
    ;;@ TR3 :

    ;;@` jsr     kconnect

    ldy     ip
    ldx     ip+1

    jmp     kconnect
.endproc
