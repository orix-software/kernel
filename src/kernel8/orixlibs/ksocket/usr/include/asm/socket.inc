
SOCK_STREAM = CH395_PROTO_TYPE_TCP    ; stream (connection) socket
SOCK_DGRAM  = CH395_PROTO_TYPE_UDP    ; datagram (conn.less) socket
SOCK_RAW    = CH395_PROTO_TYPE_IP_RAW

INVALID_SOCKET = 255
SOCKET_ERROR   = 255

; https://www.cisco.com/c/en/us/td/docs/ios/sw_upgrades/interlink/r2_0/unpremsg/mucsock.html

NETWORK_MAX_SOCKET = 4
AF_UNIX            = 1 ; /* Unix domain sockets*/
AF_INET            = 2 ;

EPROTOTYPE      = 41 ; Protocol wrong type
ESOCKTNOSUPPORT = 44 ; Socket type not supported
EPFNOSUPPORT    = 46 ; Protocol family not supported
EAFNOSUPPORT    = 47 ; Address family not supported
EADDRINUSE      = 48 ; Address already in use
ENETDOWN        = 50 ; Network is down
ENETUNREACH     = 51 ; Network is unreachable
ECONNRESET      = 54 ; Connection reset by peer
EISCONN         = 56 ; Socket is already connected
ENOTCONN        = 57 ; Socket is not connected
ETIMEDOUT       = 60 ; Connection timed out
ECONNREFUSED    = 61 ; Connection refused
EHOSTUNREACH    = 65 ; No route to host

;ENOPROTOOPT=  42 ; Protocol not available
;EPROTONOSUPPORT =43 ;Protocol not supported
;EOPNOTSUPP 45 Operation not supported
;EADDRNOTAVAIL 49 Can't assign requested address
;ENETRESET  52 Network dropped connection
;ECONNABORTED 53 Software caused connection
;ENOBUFS 55  No buffer space available
;ESHUTDOWN 58 Can't send after shutdown
;ETOOMANYREFS  59 Too many references

.struct sockaddr_in
   sin_family .byte ; e.g. AF_INET
   sin_port   .word   ; e.g. htons(3490)
   sin_addr   .res 4  ;long sin_addr
.endstruct
