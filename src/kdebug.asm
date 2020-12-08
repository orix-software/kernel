.include   "telestrat.inc"
.include   "fcntl.inc"
.include   "build.inc"
.include   "include/kernel.inc"
.include   "include/process.inc"
.include   "include/process_bss.inc"
.include   "include/memory.inc"
.include   "include/files.inc"
.include   "include/debug.inc"
.include   "kernel.inc"


.org $c000

.code
rom_start:
        
        ; $c000
        jmp     print_routine
        jmp     display_lsmem_state

print_routine:      
        ; X contains id of the string
        lda     table_low,x
        sta     ACC2M
        lda     table_high,x
        sta     ACC2M+1
        jsr     xdebug_send_string_to_printer
        ;jsr     display_lsmem_state

        rts

.proc display_lsmem_state

    lda     #<str_lsmem
    sta     ACC2M
    lda     #>str_lsmem
    sta     ACC2M+1
    jsr     xdebug_send_string_to_printer

    ldx     #$00
@loop:
    lda        kernel_malloc+kernel_malloc_struct::kernel_malloc_free_chunk_begin_high,x
    beq        @next_chunk
    lda     #<str_free
    sta     ACC2M
    lda     #>str_free
    sta     ACC2M+1
    jsr     xdebug_send_string_to_printer

    lda        #'#'
    jsr        xdebug_send_printer
    
    lda        kernel_malloc+kernel_malloc_struct::kernel_malloc_free_chunk_begin_high,x
    jsr        xdebug_binhex
    lda        kernel_malloc+kernel_malloc_struct::kernel_malloc_free_chunk_begin_low,x
    jsr        xdebug_binhex

    lda        #':'
    jsr        xdebug_send_printer    
    lda        kernel_malloc+kernel_malloc_struct::kernel_malloc_free_chunk_end_high,x
    jsr        xdebug_binhex
    lda        kernel_malloc+kernel_malloc_struct::kernel_malloc_free_chunk_end_low,x
    jsr        xdebug_binhex    
    lda        #' '
    jsr        xdebug_send_printer
    lda        #'#'
    jsr        xdebug_send_printer       
    lda        kernel_malloc+kernel_malloc_struct::kernel_malloc_free_chunk_size_high,x
    jsr        xdebug_binhex
    lda        kernel_malloc+kernel_malloc_struct::kernel_malloc_free_chunk_size_low,x
    jsr        xdebug_binhex   
    lda        #$0D
    jsr        xdebug_send_printer
@next_chunk:         
    inx
    cpx     #(KERNEL_MALLOC_FREE_FRAGMENT_MAX)
    bne     @loop


    ldx     #$00
@loop2:
    lda        kernel_malloc+kernel_malloc_struct::kernel_malloc_busy_chunk_begin_high,x
    beq        @next_chunk2
    lda     #<str_busy
    sta     ACC2M
    lda     #>str_busy
    sta     ACC2M+1
    jsr     xdebug_send_string_to_printer

    lda        #'#'
    jsr        xdebug_send_printer
    
    lda        kernel_malloc+kernel_malloc_struct::kernel_malloc_busy_chunk_begin_high,x
    jsr        xdebug_binhex
    lda        kernel_malloc+kernel_malloc_struct::kernel_malloc_busy_chunk_begin_low,x
    jsr        xdebug_binhex

    lda        #':'
    jsr        xdebug_send_printer    
    lda        kernel_malloc+kernel_malloc_struct::kernel_malloc_busy_chunk_end_high,x
    jsr        xdebug_binhex
    lda        kernel_malloc+kernel_malloc_struct::kernel_malloc_busy_chunk_end_low,x
    jsr        xdebug_binhex    
    lda        #' '
    jsr        xdebug_send_printer
    lda        #'#'
    jsr        xdebug_send_printer       
    lda        kernel_malloc+kernel_malloc_struct::kernel_malloc_busy_chunk_size_high,x
    jsr        xdebug_binhex
    lda        kernel_malloc+kernel_malloc_struct::kernel_malloc_busy_chunk_size_low,x
    jsr        xdebug_binhex   
    lda        #$0D
    jsr        xdebug_send_printer
@next_chunk2:         
    inx
    cpx     #(KERNEL_MAX_NUMBER_OF_MALLOC)
    bne     @loop2

    jsr    xdebug_load
    rts
str_lsmem:
.byte  "[lsmem state]",$0D,$00   
str_free:
.byte  "Free:",$00
str_busy:
.byte  "Busy:",$00
.endproc


.proc xdebug_load
   
    ;lda    #<str_line
    ;ldy    #>str_line
    ;sta    RES
    ;sty    RES+1

    ;jsr     xdebug_send_string_to_printer

    lda    kernel_debug+kernel_debug_struct::RES
    sta    RES
    
    lda    kernel_debug+kernel_debug_struct::RES+1
    sta    RES+1
    
    lda    kernel_debug+kernel_debug_struct::RESB
    sta    RESB

    lda    kernel_debug+kernel_debug_struct::RESB+1
    sta    RESB+1

    lda    kernel_debug+kernel_debug_struct::TR0
    sta    TR0

    lda    kernel_debug+kernel_debug_struct::TR1
    sta    TR1

    lda    kernel_debug+kernel_debug_struct::TR2
    sta    TR2
    
    lda    kernel_debug+kernel_debug_struct::TR3
    sta    TR3

    lda    kernel_debug+kernel_debug_struct::TR4
    sta    TR4

    lda    kernel_debug+kernel_debug_struct::TR5
    sta    TR5

    lda    kernel_debug+kernel_debug_struct::TR6
    sta    TR6

    lda    kernel_debug+kernel_debug_struct::TR7
    sta    TR7




    lda    kernel_debug+kernel_debug_struct::RA 
    ldy    kernel_debug+kernel_debug_struct::RY
    ldx    kernel_debug+kernel_debug_struct::RX
    rts
str_line:
    .byte $0D,"=======================",$0D
    .byte 0
.endproc

.proc xdebug_binhex

         pha                   ;save byte
         lsr                   ;extract...
         lsr                   ;MSN
         lsr
         lsr
         tay     
         jsr r0000010
                 ;save ASCII
         pla                   ;recover byte
         and #%00001111 
         tay
r0000010:

         lda    hex_table,y
         
         jsr    xdebug_send_printer
         rts                   ;done
hex_table:
.byte "0123456789ABCDEF"                  
.endproc     


  lda     kernel_malloc+kernel_malloc_struct::kernel_malloc_busy_chunk_begin_low,x
  sta     kernel_malloc+kernel_malloc_struct::kernel_malloc_free_chunk_begin_low
	
  lda     kernel_malloc+kernel_malloc_struct::kernel_malloc_busy_chunk_begin_high,x
  sta     kernel_malloc+kernel_malloc_struct::kernel_malloc_free_chunk_begin_high
  
  ; update size
  
  lda     kernel_malloc+kernel_malloc_struct::kernel_malloc_busy_chunk_size_low,x
  clc
  adc     kernel_malloc+kernel_malloc_struct::kernel_malloc_free_chunk_size_low
  bcc     @do_not_inc
  inc     kernel_malloc+kernel_malloc_struct::kernel_malloc_free_chunk_size_high	
@do_not_inc:
  sta     kernel_malloc+kernel_malloc_struct::kernel_malloc_free_chunk_size_low


  lda     kernel_malloc+kernel_malloc_struct::kernel_malloc_busy_chunk_size_high,x
  clc
  adc     kernel_malloc+kernel_malloc_struct::kernel_malloc_free_chunk_size_high
  sta     kernel_malloc+kernel_malloc_struct::kernel_malloc_free_chunk_size_high



table_low:        
        .byte <str_create_process
        .byte <str_xfree_enter
        .byte <str_xfree_garbage_collector_in
        .byte <str_xfree_garbage_collector_out        
table_high:        
        .byte >str_create_process
        .byte >str_xfree_enter
        .byte >str_xfree_garbage_collector_in
        .byte >str_xfree_garbage_collector_out        

str_create_process:
        .byte "[CREATE PROCESS]",$0D,0
str_xfree_enter:
        .byte $0D,"[XFREE] AY enter : ",0
str_xfree_garbage_collector_in:        
        .byte $0D,"[GARBAGE COLLECTOR IN]",0
str_xfree_garbage_collector_out:        
        .byte $0D,"[GARBAGE COLLECTOR OUT]",0
.proc xdebug_send_string_to_printer
    ldy    #$00
@L1:    
    lda    (ACC2M),y
    beq    @out
    jsr    xdebug_send_printer
    iny
    jmp    @L1
@out:
    rts
.endproc





.proc xdebug_send_printer
    sta     VIA::PRA

    lda     VIA::PRB
    and     #$EF
    sta     VIA::PRB
    ora     #$10
    sta     VIA::PRB
    rts
.endproc

rom_signature:
	.ASCIIZ   "Kernel Debug rom v2021.1"

_command1:
        rts

command1_str:
        .ASCIIZ "kdebug"

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
