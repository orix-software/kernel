.proc xdebug_print_with_a
    rts
    pha
    lda  #<$c006
    sta  VEXBNK+1
    lda  #>$c006
    sta  VEXBNK+2
    lda  #$01
    sta  BNKCIB
    pla
    rts
    jmp  $40C    
    
.endproc

.proc xdebug_print_with_ay
    rts
    pha
    

    lda  #<$c009
    sta  VEXBNK+1
    lda  #>$c009
    sta  VEXBNK+2
    lda  #$01
    sta  BNKCIB
    pla

    jmp  $40C    
    
    
.endproc

.proc xdebug_print_with_ay_string
    rts
    pha
    

    lda  #<$c00C
    sta  VEXBNK+1
    lda  #>$c00C
    sta  VEXBNK+2
    lda  #$01
    sta  BNKCIB
    pla

    jmp  $40C    
    
    
.endproc

.proc kdebug_restore

    ldx  kernel_debug+kernel_debug_struct::NEXT_STACK_BANK
    stx  NEXT_STACK_BANK

    lda  kernel_debug+kernel_debug_struct::VALUE_NEXT_STACK_BANK
    sta  STACK_BANK,x

    lda  kernel_debug+kernel_debug_struct::BNKCIB
    sta  BNKCIB
    lda  kernel_debug+kernel_debug_struct::VEXBNK
    sta  VEXBNK+1
    lda  kernel_debug+kernel_debug_struct::VEXBNK+1
    sta  VEXBNK+2
    lda  kernel_debug+kernel_debug_struct::BNKOLD
    sta  BNKOLD
    lda  kernel_debug+kernel_debug_struct::FIXME_DUNNO
    sta  FIXME_DUNNO
    lda  kernel_debug+kernel_debug_struct::RA
    ldx  kernel_debug+kernel_debug_struct::RX
    ldy  kernel_debug+kernel_debug_struct::RY


    rts
.endproc

.proc kdebug_save

    sta  kernel_debug+kernel_debug_struct::RA
    stx  kernel_debug+kernel_debug_struct::RX
    sty  kernel_debug+kernel_debug_struct::RY
    lda  BNKCIB
    sta  kernel_debug+kernel_debug_struct::BNKCIB
    lda  VEXBNK+1
    sta  kernel_debug+kernel_debug_struct::VEXBNK
    lda  VEXBNK+2
    sta  kernel_debug+kernel_debug_struct::VEXBNK+1
    lda  BNKOLD
    sta  kernel_debug+kernel_debug_struct::BNKOLD
    lda  FIXME_DUNNO
    sta  kernel_debug+kernel_debug_struct::FIXME_DUNNO

    ldx  NEXT_STACK_BANK
    stx  kernel_debug+kernel_debug_struct::NEXT_STACK_BANK

    lda  STACK_BANK,x
    sta  kernel_debug+kernel_debug_struct::VALUE_NEXT_STACK_BANK

    ldx  kernel_debug+kernel_debug_struct::RX
    lda  kernel_debug+kernel_debug_struct::RA



    rts
.endproc

.proc xdebug_lsmem
 
    lda  #<$c003
    sta  VEXBNK+1
    lda  #>$c003
    sta  VEXBNK+2
    lda  #$01
    sta  BNKCIB


    jmp  $40C
.endproc

.proc xdebug_print
    rts
    lda   #<$c000
    sta   VEXBNK+1
    lda   #>$c000
    sta   VEXBNK+2
    lda   #$01
    sta   BNKCIB

    jmp   $40C
.endproc


.proc xdebug_enter_XMALLOC_fp
    jsr    xdebug_save
    lda    #<str_enter_malloc
    ldy    #>str_enter_malloc
    sta    RES 
    sty    RES+1
    jmp    xdebug_enter
str_enter_malloc:
    .byte "FP(Kernel)",0
.endproc

.proc xdebug_enter_merge_free_table
    jsr    xdebug_save
    lda    #<str_enter_malloc
    ldy    #>str_enter_malloc
    sta    RES 
    sty    RES+1
    jmp    xdebug_enter
str_enter_malloc:
    .byte $0D,"[XFREE] Merge Free table",0
.endproc

.proc xdebug_enter_not_found
    jsr    xdebug_save
    lda    #<str_enter_malloc
    ldy    #>str_enter_malloc
    sta    RES 
    sty    RES+1
    jmp    xdebug_enter
str_enter_malloc:
    .byte $0D,"[XFREE] not found",0
.endproc

.proc xdebug_enter_XMALLOC_return_adress
    jsr    xdebug_save
    lda    #<str_enter_found
    ldy    #>str_enter_found
    sta    RES 
    sty    RES+1
    jmp    xdebug_enter
str_enter_found:
    .byte " return address :  "
    .byte 0
.endproc

.proc xdebug_binhex

         pha                   ;save byte
         ;and #%11110000        ;extract LSN
         lsr                   ;extract...
         lsr                   ;MSN
         lsr
         lsr
         tax     
         jsr r0000010
                 ;save ASCII
         pla                   ;recover byte
         and #%00001111 
         tax  
r0000010:
 
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
    lda        #' '
    jsr        xdebug_send_printer
    jsr        xdebug_load
    rts  
.endproc

.proc xdebug_enter_XFREE_new_freechunk
    jsr    xdebug_save
    lda    #<str_enter_free
    ldy    #>str_enter_free
    sta    RES 
    sty    RES+1
    jmp    xdebug_enter

str_enter_free:
    .byte $0D,"[XFREE] new free chunk",0
.endproc

.proc xdebug_end
    jsr    xdebug_save
    lda    #$0D
    jsr    xdebug_send_printer 
    jsr    xdebug_load
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

.endproc