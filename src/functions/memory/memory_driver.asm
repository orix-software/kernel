
kernel_memory_driver_to_copy:
 


    lda     VIA2::PRA
    and     BNK_TO_SWITCH                  ; but select a bank in BNK_TO_SWITCH
    sta     VIA2::PRA


    lda     $FFF5  ; List command
    sta     RESB
    lda     $FFF6  ; List command
    sta     RESB+1  

    ldx     #$00

read_command_from_bank_driver_mloop:
    ldy     #$00
read_command_from_bank_driver_next_char:
    lda     (RES),y
    cmp     (RESB),y        ; same character?
    beq     read_command_from_bank_driver_no_space
    cmp     #' '             ; space?
    bne     command_not_found_no_inc
    lda     (RESB),y        ; Last character of the command name?
read_command_from_bank_driver_no_space:                   ; FIXME
    cmp     #$00            ; Test end of command name or EOL
    beq     read_command_from_bank_driver_command_found
    iny
    bne     read_command_from_bank_driver_next_char
 
command_not_found:
    ; read_until_we_reached $00
    iny
command_not_found_no_inc    
    lda     (RESB),y        
    beq     @add
    bne     command_not_found
@add:
    iny
    tya
    clc
    adc     RESB
    bcc     read_command_from_bank_driver_do_not_inc
    inc     RESB+1
read_command_from_bank_driver_do_not_inc:
    sta     RESB    
    inx
    cpx     $FFF7 ; Number of command
    bne     read_command_from_bank_driver_mloop
    ; at this step we did not found the command in the rom
    lda     VIA2::PRA
    ora     #%00000111                     ; Return to telemon
    sta     VIA2::PRA

    lda     #ENOENT  ; error

    rts 
read_command_from_bank_driver_command_found:


    ; X contains the id of the command to start
    lda     $FFF3
    sta     RES
    lda     $FFF4
    sta     RES+1
    txa
    asl
    tay
    lda     (RES),y

read_command_from_bank_driver_patch1:    
    sta     $dead           ; Will store in read_command_from_bank_driver_to_patch
    iny
    lda     (RES),y
read_command_from_bank_driver_patch2:        
    sta     $dead           ; Will store in read_command_from_bank_driver_to_patch

    lda     VIA2::PRA
    ora     #%00000111                     ; Return to telemon
    sta     VIA2::PRA
    jsr     _XFORK

    lda     VIA2::PRA
    and     BNK_TO_SWITCH                  ; but select a bank in BNK_TO_SWITCH
    sta     VIA2::PRA

read_command_from_bank_driver_to_patch:

    jsr     $dead

    lda     VIA2::PRA
    ora     #%00000111                     ; Return to telemon
    sta     VIA2::PRA
    lda     #EOK

    rts




