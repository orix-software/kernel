.export BUFROU
.export KERNEL_CONF_BEGIN
.export TELEMON_KEYBOARD_BUFFER_END
.export TELEMON_KEYBOARD_BUFFER_BEGIN

.export KERNEL_BANK_MANAGEMENT

; Network
.export KERNEL_NETWORK_FLAG

.export KERNEL_NETWORK_SOCKET_LIST
.export KERNEL_NETWORK_SOCKET_DOMAIN
.export KERNEL_NETWORK_SOURCE_PORT

.include   "telestrat.inc"

.include   "include/kernel.inc"
.include   "include/process.inc"

.include   "include/memory.inc"
.include   "include/files.inc"
.include   "include/ori2.inc"
.include   "versions/versions.inc"

ORIX_NUMBER_OF_BANK = 64


.org $c080
.bss
BUFBUF_ORIX:

.org $C500
BUFROU:

.org $C5C4
TELEMON_KEYBOARD_BUFFER_BEGIN:

.org $C680
TELEMON_KEYBOARD_BUFFER_END:

.org $C680
    TELEMON_ACIA_BUFFER_INPUT_BEGIN:

.org $C800
    TELEMON_ACIA_BUFFER_INPUT_END:

.org $C800
    TELEMON_ACIA_BUFFER_OUTPUT_BEGIN:

.org $CA00
    TELEMON_ACIA_BUFFER_OUTPUT_END:

.org $CA00
    TELEMON_PRINTER_BUFFER_BEGIN:

.org $D200
    TELEMON_PRINTER_BUFFER_END:

.org $D201
KERNEL_CONF_BEGIN:

.org $D210
KERNEL_CONF_END:

.org $D300
; Store the state of each bank
KERNEL_BANK_MANAGEMENT:
    .tag kernel_bank_management_struct
KERNEL_NETWORK_FLAG:
    .byt 0 ; Set for flag,  it contains the state of the network
KERNEL_NETWORK_SOCKET_LIST:
    .res 8
KERNEL_NETWORK_SOCKET_DOMAIN:
    .res 8
KERNEL_NETWORK_SOURCE_PORT:
    .res 2