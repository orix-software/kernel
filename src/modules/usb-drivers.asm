.define VERSION "2021.1"

.include   "telestrat.inc"
.include   "fcntl.inc"
.include   "build.inc"

userzp := $80 ; FIXME

.org $c000

.code
rom_start:
        rts

rom_signature:
	.byte   "Usb Drivers/Cache Exec Kernel Module v"
    .ASCIIZ VERSION

_command1:
        rts

command1_str:
        .ASCIIZ "command1"

commands_text:
        .addr command1_str
commands_address:
        .addr _command1
commands_version:
        .ASCIIZ "0.0.1"


	
; ----------------------------------------------------------------------------
; Copyrights address

        .res $FFF1-*
        .org $FFF1
; $fff1
parse_vector:
        .byt $00,$00
; fff3
adress_commands:
        .addr commands_address   
; fff5        
list_commands:
        .addr command1_str
; $fff7
number_of_commands:
        .byt 0
signature_address:
        .word   rom_signature

; ----------------------------------------------------------------------------
; Version + ROM Type
ROMDEF: 
        .addr rom_start

; ----------------------------------------------------------------------------
; RESET
rom_reset:
        .addr   rom_start
; ----------------------------------------------------------------------------
; IRQ Vector
empty_rom_irq_vector:
        .addr   IRQVECTOR ; from telestrat.inc (cc65)
end:
