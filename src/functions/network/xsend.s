; .include   "../../kernel8/orixlibs/ch395/usr/include/asm/ch395.inc"
; .include   "../../kernel8/orixlibs/ksocket/usr/include/asm/socket.inc"

; .include   "../../include/kernel.inc"
; .include   "../../include/process.inc"
; .include   "../../include/memory.inc"

.include "telestrat.inc"

.export XSEND_ROUTINE

.import ksend


;.import socket_state
;.export socket_sour_port


.proc XSEND_ROUTINE

    ;;@brief Send data into socket
    ;;@inputTR0 Socket id
    ;;@inputY Low length
    ;;@inputX High length
    ;;@inputMEM_RES ptr
    ;;@modifyMEM_TR1 ptr
    ;;@returnsA Error type, 0 : success
  ;  jmp

    rts
.endproc
