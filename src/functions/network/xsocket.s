.include   "../../kernel8/orixlibs/ch395/usr/include/asm/ch395.inc"
.include   "../../kernel8/orixlibs/ksocket/usr/include/asm/socket.inc"

.include   "../../include/kernel.inc"
.include   "../../include/process.inc"
.include   "../../include/memory.inc"
.include   "../../include/network.inc"

.include "telestrat.inc"

.import KERNEL_NETWORK_SOCKET_LIST
.import KERNEL_NETWORK_SOCKET_DOMAIN

.import init_network

.export XSOCKET_ROUTINE

.import ch395_set_ipraw_pro_sn
.import ch395_set_proto_type_sn
.import ch395_get_socket_status_sn
.import ch395_close_socket_sn
.import kernel_process
.import KERNEL_NETWORK_SOCKET_PID
;.import socket_state
;.export socket_sour_port


.proc XSOCKET_ROUTINE
    ;;@brief Open a socket
    ;;@inputA protocol
    ;;@inputX domain ex : AF_INET
    ;;@inputY type ex : SOCK_STREAM
    ;;@modifyMEM_RES
    ;;@modifyMEM_TR6
    ;;@modifyMEM_TR5
    ;;@returnsX The socket id
    ;;@returnsA if != -1 then it returns socket id. -1 is return if all socket are used, or network is not started or unavailable

    ; sock = socket(AF_INET, SOCK_STREAM, 0);
    ;;@```ca65
    ;;@` ; or use Macro (socket.mac) SOCKET domain, type, protocol
    ;;@` SOCKET AF_INET, SOCK_STREAM, 0
    ;;@`
    ;;@```

    ;;@```ca65
    ;;@` lda     #$00 ;
    ;;@` ldx     #AF_INET ; domain
    ;;@` ldy     #SOCK_STREAM ; type
    ;;@` brk     XSOCKET
    ;;@```

    ; socket_state contains 0 if socket is not used, or contains type if used


    socket := RES + 1
    type   := TR6
    domain := TR5

    stx     domain ; domain
    sty     type ; Save type


    ; Checking if network is started
    jsr     init_network
    cmp     #KERNEL_NETWORK_FULLY_STARTED
    beq     @continue
;   Error, return INVALID
    lda     #INVALID_SOCKET
    rts

@continue:
    ; Looking for available socket
    lda     #$00
    sta     socket

@search_free_socket:
    ldx     #$00

	lda     #<KERNEL_NETWORK_SOCKET_LIST
	ldy     #>KERNEL_NETWORK_SOCKET_LIST

    sta     ADDRESS_READ_BETWEEN_BANK_DOUBLON
    sty     ADDRESS_READ_BETWEEN_BANK_DOUBLON + 1
    ldy     socket
    MEMORY_GET_VALUE_FROM_BANK ; A contains the value
    cmp     #$00
    beq     @socketfound

    inc     socket
    lda     socket
    cmp     #NETWORK_MAX_SOCKET
    bne     @search_free_socket

;   Error, return INVALID
    lda     #INVALID_SOCKET

    rts

@socketfound:
;    A contains the id of the socket


    ; save TYPE (SOCK_STREAM etc)
    ldy     socket ; Get socket id (index)
    lda     type   ; Type sock_stream
    ldx     #$00   ; BANK
    MEMORY_PUT_VALUE_TO_BANK KERNEL_NETWORK_SOCKET_LIST  ; ADDRESS_READ_BETWEEN_BANK_DOUBLON is already set previously : FIXME

    ; Store domain
    ldy     socket ; Get socket id (index)
    lda     domain ; Domain
    ldx     #$00  ; BANK
    MEMORY_PUT_VALUE_TO_BANK KERNEL_NETWORK_SOCKET_DOMAIN  ; ADDRESS_READ_BETWEEN_BANK_DOUBLON is already set previously : FIXME

    ; Store pid
    ldy     socket ; Get socket id (index)
    lda     kernel_process + kernel_process_struct::kernel_current_process
    ldx     #$00  ; BANK

    MEMORY_PUT_VALUE_TO_BANK KERNEL_NETWORK_SOCKET_PID  ; ADDRESS_READ_BETWEEN_BANK_DOUBLON is already set previously : FIXME

    ; Setting CH395
    lda     type
    cmp     #SOCK_RAW
    beq     @is_ip_raw


    ; SOCK_STEAM or SOCK_DGRAM
    lda     socket ; socket
    ldx     type

    jsr     ch395_set_proto_type_sn
    jmp     @exit_socket

@is_ip_raw:
    lda     socket ; Get socket id
    ldx     #CH395_PROTO_TYPE_IP_RAW
    jsr     ch395_set_ipraw_pro_sn

@exit_socket:
    lda     socket ; return the id of the socket
    rts

.endproc




