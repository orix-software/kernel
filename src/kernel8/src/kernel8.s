
;.FEATURE labels_without_colons, pc_assignment, loose_char_term, c_comments, org_per_seg
.FEATURE org_per_seg

.include   "telestrat.inc"
.include   "../../rom_cmd.s"

.include   "../../include/kernel.inc"
.include   "../../include/process.inc"
.include   "../../include/network.inc"
.include   "../../include/memory.inc"
.include   "../../include/files.inc"
.include   "../../include/ori2.inc"
.include   "../../versions/versions.inc"


.import KERNEL_BANK_MANAGEMENT
.import search_free_bank
.import kernel_free_bank
.import kernel_free_bank_by_pid
.import init_network
.import XSOCKET_ROUTINE

.import kbind
.import krecv
.import ksend
.import ksocket_close
.import xconnect
.import XSOCKET_CLOSE_ROUTINE

   ; .segment "BANK8"
    .org $C000
start_rom:
    jmp     XBANK

XBANK:

    cmp     #KERNEL_ALLOCATE_BANK
    beq     @allocate_bank

    cmp     #KERNEL_FREE_BANK
    beq     @free_bank

    cmp     #KERNEL_FREE_BANK_BY_PID
    beq     @kernel_free_bank_by_pid

    cmp     #KERNEL_START_NETWORK
    beq     @kernel_init_network

    cmp     #KERNEL_SOCKET_NETWORK
    beq     @kernel_socket_network

    cmp     #KERNEL_BIND_NETWORK
    beq     @kernel_bind_network

    cmp     #KERNEL_CONNECT_NETWORK
    beq     @kernel_connect_network

    cmp     #KERNEL_RECV_NETWORK
    beq     @kernel_recv_network

    cmp     #KERNEL_SEND_NETWORK
    beq     @kernel_send_network

    cmp     #KERNEL_SOCKET_CLOSE_NETWORK
    beq     @kernel_socket_close_network

    rts

@allocate_bank:
    jmp     search_free_bank

@free_bank:
    jmp     kernel_free_bank

@kernel_free_bank_by_pid:
    jmp     kernel_free_bank_by_pid

@kernel_init_network:
    jmp     init_network

@kernel_socket_network:
    jmp     XSOCKET_ROUTINE

@kernel_bind_network:
    jmp     kbind

@kernel_connect_network:
    jmp     xconnect

@kernel_send_network:
    jmp     ksend

@kernel_recv_network:
    jmp     krecv

@kernel_socket_close_network:
    jmp     XSOCKET_CLOSE_ROUTINE

signature:
    .asciiz "Kernel Extended v2025.X"

.segment "ORIXVECT"
  .byt     $01 ; Kernel type

; This token is used to detect if Kernel Extended rom is here (used in bank 7)
kernel_extended_magic_token:
  .byt     'x'

  .res     6

  .byt     <signature
  .byt     >signature

; .segment "CPUVECT"

END_ROM:
; fffa
.segment "CPUVECT"
NMI:
  .byt     <start_rom,>start_rom
; fffc
RESET:
  .byt     <start_rom,>start_rom
; fffe
BRK_IRQ:
  .byt     <IRQVECTOR,>IRQVECTOR
; Displays map