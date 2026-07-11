; Code to test XMAINARGS

.include "telestrat.inc"
.include   "../../../src/kernel8/orixlibs/ch395/usr/include/asm/ch395.inc"
.include   "../../../src/kernel8/orixlibs/ksocket/usr/include/asm/socket.inc"

.include "../../../dependencies/orix-sdk/macros/SDK_mainargs.mac"
.include "../../../dependencies/orix-sdk/macros/SDK_print.mac"
.include "../../../dependencies/orix-sdk/macros/SDK_conio.mac"
.include "../../../dependencies/orix-sdk/macros/SDK_memory.mac"

.include "errno.inc"

.segment "STARTUP"
.segment "INIT"
.segment "ONCE"

.segment "CODE"

.define KERNEL_START_NETWORK             $04

_main:

.define KERNEL_NETWORK_STATE_NOT_INITIALIZED  $00
.define KERNEL_NETWORK_STATE_CHIP_INITIALIZED $01
.define KERNEL_NETWORK_CABLE_DISCONNECTED     $02
.define KERNEL_NETWORK_CABLE_CONNECTED        $03
.define KERNEL_NETWORK_FULLY_STARTED          $04
.define KERNEL_NETWORK_STARTING_DHCP          $05

.define KERNEL_SOCKET_NETWORK            $05
.define KERNEL_BIND_NETWORK              $06
.define KERNEL_CONNECT_NETWORK           $07
.define KERNEL_RECV_NETWORK              $08
.define KERNEL_SEND_NETWORK              $09
.define KERNEL_SOCKET_CLOSE_NETWORK      $0A

.define KERNEL_NETWORK_STATE_CHIP_NOT_FOUND   $FF


; Exemple
; SOCKET sock = SOCKET AF_INET, SOCK_STREAM, 0

.macro SOCKET domain, type, protocol
    lda     #$00
    ldx     #domain
    ldy     #type

    lda     #KERNEL_SOCKET_NETWORK
    BRK_TELEMON $01
.endmacro



userzp := $80

tmp1     := userzp
tmp2     := userzp + 1
tmp3     := userzp + 2
retry    := userzp + 3
socket   := userzp + 4
ptr_recv := userzp + 5


start_adress:
    malloc #4096
    cmp     #$00
    beq     @not_oom
    cpy     #$00
    bne     @not_oom
    print str_oom
    crlf
    rts

@not_oom:
    sta     ptr_recv
    sty     ptr_recv+1

    lda     #$FF
    sta     retry


    ; argv            := userzp     ; 2 bytes
    ; argc            := userzp + 2 ; 1 byte
@start:
    dec     retry
    beq     @end
    nop
    ; print str_bank_id_given
    lda     #KERNEL_START_NETWORK    ; Mode
    BRK_TELEMON $01 ; Get network state
    cmp     #KERNEL_NETWORK_CABLE_DISCONNECTED
    beq     @disconnected
    cmp     #KERNEL_NETWORK_CABLE_CONNECTED
    beq     @connected
    cmp     #KERNEL_NETWORK_FULLY_STARTED
    beq     @fully_started
    cmp     #KERNEL_NETWORK_STARTING_DHCP
    beq     @dhcp_starting
    cmp     #KERNEL_NETWORK_FULLY_STARTED
    beq     @dhcp_started
    cmp     #KERNEL_NETWORK_STATE_CHIP_NOT_FOUND
    beq     @network_chip_not_found

@end:
    pha
    print   str_not_known_network_status
    pla

    ldy     #00 ; 0 because the number is 12 (from A)
    print_int  ,2, 2 ; an arg is skipped because the number is from register
    crlf
    rts

nop

@fully_started:
    crlf
    print str_fully_started
    crlf
    rts

@disconnected:
    print str_cable_disconnected
    crlf
    rts

@connected:
    print str_cable_connected
    crlf
    print str_starting_dhcp
    jmp     @start

@dhcp_starting:
    print #'.'
    jmp     @start

@dhcp_started:
    print str_started_dhcp
    crlf
    rts

@waiting:
    print str_waiting
    crlf
    jmp     @start

@network_chip_not_found:
    print str_network_chip_not_found
    rts

@socket:

@loop_socket:
    ;lda     ip ; 12
    ;ldy     #00 ; 0 because the number is 12 (from A)
    ;print_int  ,2, 2 ; an arg is skipped because the number is from register
   ; lda     #' '
;    BRK_TELEMON XWR0
    nop
    print str_socket


; .macro SOCKET domain, type, protocol
;     lda     #$00
;     ldx     #domain
;     ldy     #type

;     lda     #KERNEL_SOCKET_NETWORK
;     BRK_TELEMON $01
; .endmacro

    SOCKET AF_INET, SOCK_STREAM, 0
    cmp     #INVALID_SOCKET
    beq     @INVALID_SOCKET_STR
    sta     socket
    clc
    adc     #'0'
    BRK_TELEMON XWR0
    crlf

    lda     #00  ; Port 80
    sta     RESB
    lda     #80  ; Port
    sta     RESB+1
    lda     #$00 ; Socket id
    lda     socket
    sta     TR0
    ldy     #<ip
    ldx     #>ip
    lda     #KERNEL_CONNECT_NETWORK ; Connect
    BRK_TELEMON $01
    cmp     #SOCKET_ERROR
    beq     @socket_error

    ;;@brief Send data into socket
    ;;@inputTR0 Socket id
    ;;@inputY Low length
    ;;@inputX High length
    ;;@inputMEM_RES ptr
    ;;@modifyMEM_TR1 ptr
    ;;@returnsA Error type, 0 : success
    lda     socket
    sta     TR0
    ; Set length
    lda     #<str_http
    sta     RES
    lda     #>str_http
    sta     RES + 1
    ldy     #18
    ldx     #$00
    nop
    lda     #KERNEL_SEND_NETWORK ; Connect
    BRK_TELEMON $01
    cmp     #$00
    beq     @send_success
    print str_send_error
    crlf

    ;socket_connect 202, (curl_dest_port), (curl_ip_dest)
    jmp     @loop_socket

@send_success:
    print   str_send_success


    ; Recv

    ;;@inputTR0 Socket id
    ;;@inputY Low ptr to store the buffer
    ;;@inputX High ptr to store the buffer
    lda     socket
    sta     TR0


    ldy     ptr_recv
    ldx     ptr_recv+1
    lda     #KERNEL_RECV_NETWORK
    BRK_TELEMON $01
    cmp     #EOK
    bne     @not_received
    beq     @received

    crlf
    jmp     @loop_socket

@socket_error:
    print       str_socket_error
    crlf
    jmp         @loop_socket

@INVALID_SOCKET_STR:
    print   str_invalid_socket
    rts

@not_received:
    print       str_not_received
    crlf
    jmp         @loop_socket

@received:
    print       str_received
    crlf
    jmp         @loop_socket

str_network_chip_not_found:
    .byte $81,"Network chip not found",0

str_not_known_network_status:
    .byte $81,"Unknown network status !",0

str_cannot_open_socket:
    .byte 1,"Cannot open socket !",0

str_not_received:
    .byte $81,"Received Error!",0

str_received:
    .byte $81,"Received!",0

str_oom:
    .byte $81,"OOM!",0

str_send_success:
    .byte 2,"Send success !",0

str_send_error:
    .byte $81,"Send Error!",0

str_http:
    .byte "GET /index.htm", $0D, $0A, $0D, $0A

str_socket_error:
    .byte $81, "Socket open error",0

ip:
    ;.byte 213,186,33,19
    .byte 192,168,1,77

str_invalid_socket:
    .byte $81,"Invalid socket",0

str_socket:
    .asciiz "Socket : "

str_waiting:
    .asciiz "Waiting ..."

str_started_dhcp:
    .asciiz "Dhcp Started !"

str_starting_dhcp:
    .asciiz "Starting dhcp"

str_fully_started:
    .asciiz "Fully Started"

str_cable_disconnected:
    .asciiz "Cable disconnected"

str_cable_connected:
    .asciiz "Cable connected"
nop

    ; sta     tmp1
    ; stx     tmp2
    ; sty     tmp3

    ; ldy     #00
    ; print_int  ,2, 2
    ; print str_set
    ; lda     tmp2 ; Load set
    ; ldy     #00
    ; print_int  ,2, 2
    ; print str_bank
    ; lda     tmp3 ; Load bank
    ; ldy     #00
    ; print_int  ,2, 2
    ; crlf

    ; ; Free
    ; print str_free_id
    ; lda     tmp1
    ; print_int  ,2, 2
    ; lda     #KERNEL_FREE_BANK   ; Mode
    ; ldx     tmp1 ; X the type of bank
    ; BRK_TELEMON $01 ; GET free bank
    ; crlf
    ; ;

    ; print str_bank_id_given
    ; lda     #KERNEL_ALLOCATE_BANK    ; Mode
    ; ldx     #KERNEL_RAM_BANK_APPLICATION_TYPE ; X the type of bank
    ; BRK_TELEMON $01 ; GET free bank
    ; sta     tmp1
    ; stx     tmp2 ; Set
    ; sty     tmp3

    ; ldy     #00
    ; print_int  ,2, 2
    ; print str_set
    ; lda     tmp2 ; Load set
    ; ldy     #00
    ; print_int  ,2, 2
    ; print str_bank
    ; lda     tmp3 ; Load bank
    ; ldy     #00
    ; print_int  ,2, 2
    ; crlf

    ; print str_bank_id_given
    ; lda     #KERNEL_ALLOCATE_BANK    ; Mode
    ; ldx     #KERNEL_RAM_BANK_APPLICATION_TYPE ; X the type of bank
    ; BRK_TELEMON $01 ; GET free bank
    ; sta     tmp1
    ; stx     tmp2
    ; sty     tmp3

    ; ldy     #00
    ; print_int  ,2, 2
    ; print str_set
    ; lda     tmp2 ; Load set
    ; ldy     #00
    ; print_int  ,2, 2
    ; print str_bank
    ; lda     tmp3 ; Load bank
    ; ldy     #00
    ; print_int  ,2, 2
    ; crlf

    ; print str_bank_id_given
    ; lda     #KERNEL_ALLOCATE_BANK    ; Mode
    ; ldx     #KERNEL_RAM_BANK_APPLICATION_TYPE ; X the type of bank
    ; BRK_TELEMON $01 ; GET free bank
    ; sta     tmp1
    ; stx     tmp2
    ; sty     tmp3

    ; ldy     #00
    ; print_int  ,2, 2
    ; print str_set
    ; lda     tmp2 ; Load set
    ; ldy     #00
    ; print_int  ,2, 2
    ; print str_bank
    ; lda     tmp3 ; Load bank
    ; ldy     #00
    ; print_int  ,2, 2
    ; crlf

    ;initmainargs argv, argc, 0
    rts

    ; appel de la lib curl

    ; brk XEXECLIB, #curl_exec, id_bank

    ; Macro :

    ; XEXECLIB #curl_exec, bank.
    ; Ce qui donnerait :
    ; pha
    ; lda bank
    ; sta bank_lib ; Offset
    ; lda func
    ; sta func_id ; Offset
    ; pla
    ; brk_kernel xexec lib
    
    ; Initialisation d'une banque pour charger une lib curl: 

    ; lda     #KERNEL_ALLOCATE_BANK    ; Mode
    ; ldx     #KERNEL_RAM_BANK_LIB_TYPE ; X the type of bank
    ; BRK_TELEMON $01 ; GET free bank

    ; lda     #KERNEL_LOAD_LIB
    ; ldx     #<libcurl_so
    ; ldy     #>libcurl_so
    ; BRK_TELEMON $01
    ; ; Relocation de la lib
    ; referencement de la lib

    ; rts
    ;libcurl_so:
    ; .asciiz "/lib/2024.1/libcurl.so"
    ; 



;     lda     argc
;     cmp     #$03
;     bne     @no_arg

;     getmainarg #1, (argv)
;     BRK_TELEMON XWSTR0
;     crlf

;     getmainarg #2, (argv)
;     BRK_TELEMON XWSTR0
;     crlf

;     rts

; @no_arg:
;     print str_there_not_two_arg
;     lda     #$01
;     ldy     #$00
;     rts

str_there_not_two_arg:
    .asciiz "There is not 2 arg"

str_bank_id_given:
    .asciiz "Allocate bank id : "

str_free_id:
    .asciiz "Free bank id : "

str_set:
    .asciiz " Set :"

str_bank:
    .asciiz " bank :"