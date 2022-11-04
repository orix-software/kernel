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
    jmp     print_routine_noparam
    ; $c003
    jmp     display_lsmem_state
    ; $c006

    jmp     print_msg_and_a
    ; $c009
    jmp     print_msg_and_ay
    ; $c00c
    jmp     print_msg_and_string_ay

table_low_ay:
    .byte <str_unknown
    .byte <str_xfree_enter
    .byte <str_xmalloc_enter
    .byte <str_xmalloc_return_address

table_high_ay:
    .byte >str_unknown
    .byte >str_xfree_enter   
    .byte >str_xmalloc_enter
    .byte >str_xmalloc_return_address


str_unknown: 
    .asciiz "Unknown"

table_low_noparam:        
    .byte <str_create_process
    .byte <str_xfree_enter
    .byte <str_xfree_garbage_collector_in
    .byte <str_xfree_garbage_collector_out
    .byte <str_found_chunk     
    .byte <str_fseek
    .byte <str_fclose
    .byte <str_unknown
    .byte <str_xopen_allocate_fp
    .byte <str_fclose_not_found    
    .byte <str_fclose_found
    .byte <str_max_xopen_file_not_found
    .byte <str_fork
    .byte <str_fork_starting
    .byte <str_unknown
    .byte <str_type
    .byte <str_mainargs
    .byte <str_process_struct
    .byte <str_type_fp

table_high_noparam:        
    .byte >str_create_process
    .byte >str_xfree_enter
    .byte >str_xfree_garbage_collector_in
    .byte >str_xfree_garbage_collector_out        
    .byte >str_found_chunk
    .byte >str_fseek        
    .byte >str_fclose
    .byte >str_unknown   
    .byte >str_xopen_allocate_fp
    .byte >str_fclose_not_found
    .byte >str_fclose_found
    .byte >str_max_xopen_file_not_found
    .byte >str_fork
    .byte >str_fork_starting
    .byte >str_unknown
    .byte >str_type
    .byte >str_mainargs    
    .byte >str_process_struct
    .byte >str_type_fp

table_low_ay_string:
    .byte <str_xexec_enter
    .byte <str_xopen_enter

table_high_ay_string:
    .byte >str_xexec_enter
    .byte >str_xopen_enter

table_str_low:        
    .byte <str_fd_id
    .byte <str_max_fd_reached
    .byte <str_fclose_enter
    .byte <str_kill_process

table_str_high:        
    .byte >str_fd_id
    .byte >str_max_fd_reached
    .byte >str_fclose_enter
    .byte >str_kill_process

str_xexec_enter:
    .byte $0D,"[XEXEC] command : ",0

str_xmalloc_enter:
    .byte $0D,"[XMALLOC] Query size :",0

str_xmalloc_return_address:
    .byte $0D,"[XMALLOC] Return address :",0    



str_max_fd_reached:
    .byte $0D,"[XOPEN] Free FP pointer, return $FFFF in AX, because KERNEL_MAX_FP reached :",0

str_max_xopen_file_not_found:
    .byte $0D,"[XOPEN] File not found",0


str_process_struct:
    .asciiz "PROCESS_STRUCT(Kernel)"

str_fd_id:
    .byte $0D,"[XOPEN] open the file : OK, return FD id : ",0
str_xopen_enter:
    .byte $0D,"[XOPEN] Enter ",0
str_xopen_allocate_fp:
    .byte $0D,"[XOPEN] Allocate FP : XMALLOC call, returns ptr FD in AX",0

str_kill_process:
    .byte $0D,"[XKILL] Enter kill process : ",0
str_type:
    .byte "Type:",0

str_found_chunk:
    .byte "Found Chunk",0

str_fclose_enter:
    .byte $0D
    .byte "[XCLOSE] Enter with FD id : ",0   

str_fclose_not_found:
    .byte $0D
    .byte "[XCLOSE] FD id not found [ERROR] ",0           

str_fclose_found:
    .byte $0D
    .byte "[XCLOSE] FD found [OK] ",0       

str_fclose:
    .byte $0D
    .byte "[XCLOSE]  ",0   

str_fseek:
    .byte $0D
    .byte "[FSEEK] ",0   

str_fork:
    .byte $0D
    .byte "[XFORK] Trying to find binary on device ...",0           

str_fork_starting:
    .byte $0D
    .byte "[XFORK] Starting process",0       

str_create_process:
    .byte $0D,"[CREATE PROCESS] Create process struct ...",0

str_xfree_enter:
    .byte $0D
    .byte "[XFREE] AY enter : ",0

str_xfree_garbage_collector_in:        
    .byte $0D,"[GARBAGE COLLECTOR IN]",0
str_xfree_garbage_collector_out:        
    .byte $0D,"[GARBAGE COLLECTOR OUT]",0

str_mainargs:
    .byte "MAINARGS(Kernel)",0
str_type_fp:
    .byte "FP(Kernel)",0


.proc print_routine_noparam
    ; X contains id of the string
    rts
    lda     table_low_noparam,x
    sta     ACC2M
    lda     table_high_noparam,x
    sta     ACC2M+1
    jsr     xdebug_send_string_to_printer
    jsr     display_pid
    rts
.endproc


.proc print_msg_and_string_ay

    ; X contains id of the string
    pha
    tya
    pha

    lda     table_low_ay_string,x
    sta     ACC2M
    lda     table_high_ay_string,x
    sta     ACC2M+1

    jsr     xdebug_send_string_to_printer

    pla
    tay
    pla
    sta     ACC2M
    sty     ACC2M+1
    jsr     xdebug_send_string_to_printer
    jsr     display_pid

    rts
.endproc

.proc print_msg_and_ay

    ; X contains id of the string
    pha
    lda     table_low_ay,x
    sta     ACC2M
    lda     table_high_ay,x
    sta     ACC2M+1
    tya
    pha
    jsr     xdebug_send_string_to_printer
    pla
    tay
    pla
    jsr     xdebug_send_ay_to_printer
    jsr     display_pid

    rts
.endproc

.proc print_msg_and_a  
    
    ; X contains id of the string
    pha
    
    lda     table_str_low,x
    sta     ACC2M
    lda     table_str_high,x
    sta     ACC2M+1
    tya
    pha
    jsr     xdebug_send_string_to_printer
    pla
    tay
    pla
    jsr     xdebug_send_a_to_printer
    jsr     display_pid

    rts
.endproc

.proc display_pid
    lda     #<pid
    sta     ACC2M
    lda     #>pid
    sta     ACC2M+1

    jsr     xdebug_send_string_to_printer
    lda     kernel_process+kernel_process_struct::kernel_current_process
    cmp     #$FF
    beq     @init
    clc
    adc     #'0'
    jsr     xdebug_send_printer 
@end:    
    lda     #')'
    jsr     xdebug_send_printer 
    rts
@init:
    lda     #'0'
    jsr     xdebug_send_printer 
    jmp     @end
pid:
    .asciiz "(pid:"
.endproc    

.proc display_lsmem_state
    tya
    pha


    lda     #<str_lsmem
    sta     ACC2M
    lda     #>str_lsmem
    sta     ACC2M+1

    jsr     xdebug_send_string_to_printer
    
    ldx     #$00
@loop:
    lda     kernel_malloc+kernel_malloc_struct::kernel_malloc_free_chunk_begin_high,x
    beq     @next_chunk
    lda     #<str_free
    sta     ACC2M
    lda     #>str_free
    sta     ACC2M+1

    jsr     xdebug_send_string_to_printer

    lda     #'#'
    jsr     xdebug_send_printer

    lda     kernel_malloc+kernel_malloc_struct::kernel_malloc_free_chunk_begin_high,x
    jsr     xdebug_binhex
    lda     kernel_malloc+kernel_malloc_struct::kernel_malloc_free_chunk_begin_low,x
    jsr     xdebug_binhex

    lda     #':'
    jsr     xdebug_send_printer    
    lda     kernel_malloc+kernel_malloc_struct::kernel_malloc_free_chunk_end_high,x
    jsr     xdebug_binhex
    lda     kernel_malloc+kernel_malloc_struct::kernel_malloc_free_chunk_end_low,x
    jsr     xdebug_binhex
    lda     #' '
    jsr     xdebug_send_printer
    lda     #'#'
    jsr     xdebug_send_printer
    lda     kernel_malloc+kernel_malloc_struct::kernel_malloc_free_chunk_size_high,x
    jsr     xdebug_binhex
    lda     kernel_malloc+kernel_malloc_struct::kernel_malloc_free_chunk_size_low,x
    jsr     xdebug_binhex
    lda     #$0D
    jsr     xdebug_send_printer
@next_chunk:
    inx
    cpx     #(KERNEL_MALLOC_FREE_CHUNK_MAX)
    bne     @loop


    ldx     #$00
@loop2:
    lda     kernel_malloc+kernel_malloc_struct::kernel_malloc_busy_chunk_begin_high,x
    beq     @next_chunk2
    lda     #<str_busy
    sta     ACC2M
    lda     #>str_busy
    sta     ACC2M+1
    jsr     xdebug_send_string_to_printer

    lda     #'#'
    jsr     xdebug_send_printer
    
    lda     kernel_malloc+kernel_malloc_struct::kernel_malloc_busy_chunk_begin_high,x
    jsr     xdebug_binhex
    lda     kernel_malloc+kernel_malloc_struct::kernel_malloc_busy_chunk_begin_low,x
    jsr     xdebug_binhex

    lda     #':'
    jsr     xdebug_send_printer    
    lda     kernel_malloc+kernel_malloc_struct::kernel_malloc_busy_chunk_end_high,x
    jsr     xdebug_binhex
    lda     kernel_malloc+kernel_malloc_struct::kernel_malloc_busy_chunk_end_low,x
    jsr     xdebug_binhex    
    lda     #' '
    jsr     xdebug_send_printer
    lda     #'#'
    jsr     xdebug_send_printer       
    lda     kernel_malloc+kernel_malloc_struct::kernel_malloc_busy_chunk_size_high,x
    jsr     xdebug_binhex
    lda     kernel_malloc+kernel_malloc_struct::kernel_malloc_busy_chunk_size_low,x
    jsr     xdebug_binhex
    ; lda     kernel_malloc+kernel_malloc_struct::kernel_malloc_busy_pid_list,x   
    lda     #$0D
    jsr     xdebug_send_printer
@next_chunk2:
    inx
    cpx     #(KERNEL_MAX_NUMBER_OF_MALLOC)
    bne     @loop2

    ;jsr        xdebug_load
    pla
    tay
    rts
str_lsmem:
    .byte   $0D,"[lsmem state]",$0D,$00   
str_free:
    .byte   "Free:",$00
str_busy:
    .byte   "Busy:",$00
.endproc


.proc xdebug_send_a_to_printer
    pha
    lda     #'#'
    jsr     xdebug_send_printer
    pla
  
    jsr     xdebug_binhex
    lda     #' '
    jsr     xdebug_send_printer
    rts  
.endproc


.proc xdebug_send_ay_to_printer
    pha
    lda     #'#'
    jsr     xdebug_send_printer
    tya
    jsr     xdebug_binhex
    pla
  
    jsr     xdebug_binhex
    lda     #' '
    jsr     xdebug_send_printer
    rts  
.endproc



.proc xdebug_load

    lda    kernel_debug+kernel_debug_struct::RES
    sta    RES

    lda    kernel_debug+kernel_debug_struct::RES+1
    sta    RES+1

    lda    kernel_debug+kernel_debug_struct::RESB
    sta    RESB

    lda    kernel_debug+kernel_debug_struct::RESB+1
    sta    RESB+1




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
