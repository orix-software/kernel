; This routine check if IRQ vector is set to $fffe, if yes we continue or else, we proceed to next bank
; Also if $FFF7 contains 0, it means that there is no command, then we skip

; At the beginning of this routine, we already swapped into the a bank to check
; Bank and twilighte_banking_register are managed in the kernel and call this routines located in the main ram
kernel_memory_driver_to_copy:
    lda     VIA2::PRA
    and     KERNEL_TMP_XEXEC               ; But select a bank in BNK_TO_SWITCH
    sta     VIA2::PRA

    lda     $FFFE
    cmp     #$FA                           ; Is it an Orix rom ?
    bne     exit_to_kernel

    lda     $FFF7                          ; The bank contains no any command in the current rom ($fff7=0) then skip
    beq     exit_to_kernel

test_debug:
    lda     $FFF5  ; List command
    sta     RESB
    lda     $FFF6  ; List command
    cmp     #$C0
    bcc     exit_to_kernel
    sta     RESB+1
; d15E
    ldx     #$00
read_command_from_bank_driver_mloop:
    ldy     #$00
read_command_from_bank_driver_next_char:
    lda     (RES),y          ; RES contains the ptr of the string typed by the user when XEXEC is launched
    cmp     (RESB),y         ; Same character? RESB contains the ptr of the command in the rom
    beq     read_command_from_bank_driver_no_space
    cmp     #' '             ; Space?
    bne     command_not_found_no_inc
    lda     (RESB),y         ; Last character of the command name?

read_command_from_bank_driver_no_space:
    cmp     #$00            ; Test end of command name or EOL
    beq     read_command_from_bank_driver_command_found
    iny
    cpy     #$08
    bne     read_command_from_bank_driver_next_char

command_not_found:
    ; read_until_we_reached $00
    ; this code is to detect the end of the string of the command tested
    ; For example, if the command launch in RES is "bank" and RESB a ptr to is "ls" string in the current bank, we "iny"
    ; the value in order to reach EOL of "ls". in that case, we add the length of "ls"+0 to the RESB ptr in order to read the next command
    iny

    ; Theses following lines are here to exit this routine, if we reach y=12, because it's impossible to have a command longer than 12 bytes.
    cpy     #12
    beq     exit_to_kernel

command_not_found_no_inc:
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
    cpx     $FFF7 ; loop until we reach number of command of the rom
    bne     read_command_from_bank_driver_mloop
    ; at this step we did not found the command in the rom
exit_to_kernel:
    lda     VIA2::PRA
    ora     #%00000111                     ; Return to telemon
    sta     VIA2::PRA

    ldy     #ENOENT  ; error

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
    sta     VEXBNK+1           ; Will store in read_command_from_bank_driver_to_patch
    iny
    lda     (RES),y
read_command_from_bank_driver_patch2:
    sta     VEXBNK+2           ; Will store in read_command_from_bank_driver_to_patch

    lda     #$07              ; Return to telemon
    jsr     $46A


    jsr     _XFORK

    ; we reached max process to launch ?
    lda     KERNEL_ERRNO
    cmp     #KERNEL_ERRNO_MAX_PROCESS_REACHED
    beq     exit_to_kernel                    ; Yes we reached max process we exit

    lda     KERNEL_TMP_XEXEC
    jsr     $46A



    lda     TR0
    ldy     TR1                               ; Send command line in A & Y

read_command_from_bank_driver_to_patch:
    jsr     VEXBNK
    pha

    lda     #$07              ; Return to telemon
    jsr     $46A


    pla
    ldy     #EOK

    rts
