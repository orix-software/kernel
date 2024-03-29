.proc _XEXEC
.out     .sprintf("|MODIFY:RES:_XEXEC")
.out     .sprintf("|MODIFY:TR0:_XEXEC")
.out     .sprintf("|MODIFY:TR1:_XEXEC")
.out     .sprintf("|MODIFY:BUFEDT:_XEXEC")
.out     .sprintf("|MODIFY:BNKOLD:_XEXEC")
.out     .sprintf("|MODIFY:BNK_TO_SWITCH:_XEXEC")
.out     .sprintf("|MODIFY:KERNEL_TMP_XEXEC:_XEXEC")
.out     .sprintf("|MODIFY:KERNEL_KERNEL_XEXEC_BNKOLD:_XEXEC")
.out     .sprintf("|MODIFY:HRS2:_XEXEC")
.out     .sprintf("|MODIFY:HRS3:_XEXEC")

.out     .sprintf("|MODIFY:VEXBNK:_XEXEC") ; with KERNEL_DRIVER_MEMORY call
.out     .sprintf("|MODIFY:RESB:_XEXEC")  ; with KERNEL_DRIVER_MEMORY call


;PARSE_VECTOR
    ; A & Y contains the string command to execute
    sta     TR0        ; Save string pointer
    sty     TR1        ;
    stx     HRS3       ; Save X, if X=0 fork, if X=1 performs an standard EXEC like linux/unix

.ifdef WITH_DEBUG
    ldx    #XDEBUG_XEXEC_ENTER
    jsr    xdebug_print_with_ay_string
.endif

    ; Save current set
    lda     $343
    sta     KERNEL_SAVE_XEXEC_CURRENT_SET

    lda     $342
    sta     KERNEL_SAVE_XEXEC_CURRENT_ROM_RAM
    ; Force eeprom set
    and     #%11011111
    sta     $342

    STZ_ABS $343

    ; Copy in BUFEDT
    ldy     #$00
@L7:
    lda     (TR0),y
    beq     @S6
    sta     BUFEDT,y
    iny
    cpy     #110
    bne     @L7

@S6:
    lda     #$00
    sta     BUFEDT,y

@S1:
    ; Ok then execute
    ; Now it's the current process
    ; RACE CONDITION FIXME BUG
    ; If there is a multitasking switch during this step, the process is not started, but kernel will try to execute it
    lda     BNKOLD
    cmp     #$07
    bne     @do_not_correct
    lda     #$05 ; Shell by default

@do_not_correct:
    sta     KERNEL_KERNEL_XEXEC_BNKOLD

    ldx     #$05       ; start at bank 05
    stx     KERNEL_TMP_XEXEC

next_bank:
    ; We says that we return to Bank 7
    ldx     KERNEL_TMP_XEXEC

    lda     TR0
    ldy     TR1
    sta     RES
    sty     RES+1

    jsr     KERNEL_DRIVER_MEMORY

    cpy     #EINVAL
    beq     exit

    cpy     #EOK
    beq     out1

next:
    ; Here continue
    dec     KERNEL_TMP_XEXEC

    bne     next_bank

    ldx     $343
    inx
    cpx     #04
    beq     no_04

    cpx     #$08
    beq     check_memory_bank
    bne     store
no_04:

store:
    stx     $343

    ldx     #$04       ; start at bank 0
    stx     KERNEL_TMP_XEXEC

    jmp     next_bank

check_memory_bank:

    ; Is it already memory bank  ?
    lda     $342
    and     #%00100000
    cmp     #%00100000
    beq     read_on_sdcard

    STZ_ABS $343

    lda     $342
    ora     #%00100000
    sta     $342

    lda     #$04
    sta     KERNEL_TMP_XEXEC
    jmp     next_bank

read_on_sdcard:
    lda     TR0
    ldy     TR1
    jsr     kernel_try_to_find_command_in_bin_path

    cpy     #EOK
    beq     out2

    STZ_ABS      KERNEL_ERRNO

    rts

out2:
    ldy     KERNEL_KERNEL_XEXEC_BNKOLD  ; Use Y or else it override A (return code from binary)
    sty     BNK_TO_SWITCH

out1:
    ; At this step, the binary passed in XEXEC had been executed

    sta     HRS2   ; Save in HRS2 the value of A (return value of the previous process)
    stx     HRS2+1

skip_sta_hrs2:

    lda     kernel_process+kernel_process_struct::kernel_current_process
    cmp     #$01 ; Dans le cas d'exec, il y a 2 kill qui se font FIXME bug
    beq     @no_kill
    jsr     kernel_kill_process

@no_kill:
    ldy     #EOK

exit:
    ; Restore current set
    lda     KERNEL_KERNEL_XEXEC_BNKOLD
    sta     BNK_TO_SWITCH

    lda     KERNEL_SAVE_XEXEC_CURRENT_ROM_RAM
    sta     $342

    lda     KERNEL_SAVE_XEXEC_CURRENT_SET
    sta     $343

    lda     HRS2        ; Return code
    ldx     HRS2+1

    rts
.endproc
