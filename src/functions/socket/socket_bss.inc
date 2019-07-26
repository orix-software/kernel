.include "functions/socket/socket.inc"

.bss

kernel_socket_list_id:
; contains id of the socket
 .res KERNEL_SOCKET_MAX_NUMBER
kernel_socket_pid_id:
; contains the pid 
; if byte0 = 12 then the byte 0 of KERNEL_SOCKET_MAX_NUMBER contains the id of the socket of process 12
 .res KERNEL_SOCKET_MAX_NUMBER
kernel_socket_type:
 .res KERNEL_SOCKET_MAX_NUMBER

