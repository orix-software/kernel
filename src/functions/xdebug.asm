
.proc xdebug_enter_XMALLOC
    jsr    xdebug_save
    lda    #<str_enter_malloc
    ldy    #>str_enter_malloc
    sta    RES 
    sty    RES+1
    jmp    xdebug_enter
str_enter_malloc:
    .byte "XMALLOC",$0D,"=======================",$0D
    .byte "SIZE  PID",$0D,0
.endproc

.proc xdebug_binhex

         pha                   ;save byte
         and #%00001111        ;extract LSN
         jsr r0000010
         tax                   ;save ASCII
         pla                   ;recover byte
         lsr                   ;extract...
         lsr                   ;MSN
         lsr
         lsr         
         
r0000010
    ; cmp #15               ; 0 to 9 ?
         ;bcc r0000020          ; b: yes - must set bits 4 and 5
;
         ;adc #103-1            ; 10 to 15 -> 113 to 118
;
; $71 to $76
; %01110001 to %01110110
; - must clear bits 4 and 5
;         
;r0000020 ;eor #%00110000        ;set or clear bits 4 and 5
         tax
         lda    hex_table,x
         
         jsr    xdebug_send_printer
         rts                   ;done
hex_table:
.byte "0123456789ABCDEF"                  
.endproc     

.proc xdebug_send_ay_to_printer
    jsr        xdebug_save
    lda        #'#'
    jsr        xdebug_send_printer
    lda        kernel_debug+kernel_debug_struct::RY
    jsr        xdebug_binhex
    lda        kernel_debug+kernel_debug_struct::RA
    jsr        xdebug_binhex
    jsr        xdebug_load
    rts  
.endproc

.proc xdebug_enter_XFREE
    jsr    xdebug_save
    lda    #<str_enter_free
    ldy    #>str_enter_free
    sta    RES 
    sty    RES+1
    jmp    xdebug_enter
str_enter_free:
    .byte "XFREE",$0D,"=======================",$0D
    .byte "",$0D,0
.endproc

.proc xdebug_end
    lda    #$0D
    jsr    xdebug_send_printer 
    rts
.endproc

.proc xdebug_enter
    jsr    xdebug_send_string_to_printer
    jsr    xdebug_load
    rts
.endproc

.proc xdebug_send_string_to_printer
    ldy    #$00
@L1:    
    lda    (RES),y
    beq    @out
    jsr    xdebug_send_printer
    iny
    jmp    @L1
@out:
    rts
.endproc

.proc xdebug_send_printer
  
    sta     VIA::PRA
    ;lda     #%00000000

    lda     VIA::PRB
    and     #$EF
    sta     VIA::PRB
    ora     #$10
    sta     VIA::PRB
    rts
.endproc

.proc xdebug_save
    sta    kernel_debug+kernel_debug_struct::RA 
    sty    kernel_debug+kernel_debug_struct::RY
    stx    kernel_debug+kernel_debug_struct::RX

    lda    RES
    sta    kernel_debug+kernel_debug_struct::RES
    lda    RES+1
    sta    kernel_debug+kernel_debug_struct::RES+1
    
    lda    RESB
    sta    kernel_debug+kernel_debug_struct::RESB

    lda    RESB+1
    sta    kernel_debug+kernel_debug_struct::RESB+1

    lda    TR0
    sta    kernel_debug+kernel_debug_struct::TR0

    lda    TR1
    sta    kernel_debug+kernel_debug_struct::TR1

    lda    TR2
    sta    kernel_debug+kernel_debug_struct::TR2
    
    lda    TR3
    sta    kernel_debug+kernel_debug_struct::TR3

    lda    TR4
    sta    kernel_debug+kernel_debug_struct::TR4

    lda    TR5
    sta    kernel_debug+kernel_debug_struct::TR5

    lda    TR6
    sta    kernel_debug+kernel_debug_struct::TR6

    lda    TR7
    sta    kernel_debug+kernel_debug_struct::TR7

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

.endproc