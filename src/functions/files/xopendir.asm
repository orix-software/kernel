CH376_DIR_INFO_READ = $37

.proc XOPENDIR_READDIR_CLOSEDIR
   cpx     #$00 ; XOPENDIR
   beq     xopendir
   cpx     #$01
   beq     _readdirAll
   cpx     #$02
   beq     _closedir
   rts
.endproc

.proc _closedir
   jsr     XCLOSE_ROUTINE
   rts
.endproc

.proc      xopendir
   ; A&Y ptr of str
   ; Do do : check if it's a DIR
   sta     RES
   sty     RES+1

   ; Add /* at the end
   ldy     #$00
@L1:
   lda     (RES),y
   beq     @end
   iny
   bne     @L1
@end:
   lda     #'/'
   sta     (RES),y
   iny
   lda     #'*'
   sta     (RES),y
   iny
   lda     #$00
   sta     (RES),y


   ldy     #O_RDONLY
   lda     RES
   ldx     RES+1

   jsr     XOPEN_ROUTINE
   rts
.endproc

; Entrée du catalogue:
;   Offset              Description
;   00-07               Filename
;   08-0A               Extension
;   0B                  File attributes
;                           0x01: Read only
;                           0x02: Hidden
;                           0x04: System
;                           0x08: Volume label
;                           0x10: Subdirectory
;                           0x20: Archive
;                           0x40: Device (internal use only)
;                           0x80: Unused
;   0C                  Reserved
;   0D                  Create time: fine resolution (10ms) 0 -> 199
;   0E-0F               Create time: Hour, minute, second
;                            bits
;                           15-11: Hour  (0-23)
;                           10- 5: Minutes (0-59)
;                            4- 0: Seconds/2 (0-29)
;   10-11               Create time:Year, month, day
;                            bits
;                           15- 9: Year (0->1980, 127->2107)
;                            8- 5: Month (1->Jan, 12->Dec)
;                            4- 0: Day (1-31)
;   12-13               Last access date
;   14-15               EA index
;   16-17               Last modified time
;   18-19               Last modified date
;   1A-1B               First cluster
;   1C-1F               File size

;.define READDIR_SIZE_BUFFER 2000

.define READDIR_MAX_LINE 100

    .out     .sprintf("|MODIFY:RES:XOPENDIR")
    .out     .sprintf("|MODIFY:RESB:XOPENDIR")
    .out     .sprintf("|MODIFY:RESC:XOPENDIR")
    .out     .sprintf("|MODIFY:TR0:XOPENDIR")
    .out     .sprintf("|MODIFY:TR7:XOPENDIR")

.proc _readdirAll
    ; save FD
    sta     RES
    sty     RES+1
    ; FD
    lda     #<(.sizeof(_READDIR_STRUCT)*READDIR_MAX_LINE)
    ldy     #>(.sizeof(_READDIR_STRUCT)*READDIR_MAX_LINE)
    jsr     XMALLOC_ROUTINE
    cmp     #$00
    bne     @continue
    cpy     #$00
    bne     @continue

    lda     #ENOMEM
    sta     KERNEL_ERRNO
@error:
    lda     #$00
    tax
    rts
@continue:
    ; Save PTR
    sta     RESB
    sta     RESC
    sty     RESB+1
    sty     RESC+1

    jmp     @start

    jsr     _ch376_verify_SetUsbPort_Mount

    lda     #$00
    sta     TR7         ; Used to compute number of entries

    lda     #CH376_SET_FILE_NAME        ;$2F
    sta     CH376_COMMAND
    lda     #'/'
    sta     CH376_DATA

    lda     #$00
    sta     CH376_DATA

    jsr     _ch376_file_open

    lda     #CH376_SET_FILE_NAME        ;$2F
    sta     CH376_COMMAND

    lda     #'*'
    sta     CH376_DATA

    lda     #$00
    sta     CH376_DATA

    jsr     _ch376_file_open


    cmp     #CH376_ERR_MISS_FILE
    beq     @error

    cmp     #CH376_USB_INT_SUCCESS
@start:
;display_one_file_catalog:
    lda     #CH376_DIR_INFO_READ
    sta     CH376_COMMAND
    lda     #$ff
    sta     CH376_DATA
    jsr     _ch376_wait_response
    cmp     #CH376_USB_INT_SUCCESS
  ;  cmp     #CH376_USB_INT_SUCCESS

  ;  bne     @error

go:
@next_entry:
    lda     #CH376_RD_USB_DATA0
    sta     CH376_COMMAND
    lda     CH376_DATA

@read_entry:
    lda     #$00
    sta     TR0 ; Use to set "."
    jsr     display_catalog

    ldx     TR7
    cpx     #READDIR_MAX_LINE
    beq     @exit

    cmp     #CH376_USB_INT_DISK_READ
    beq     @next_entry

@exit:
    ; Store 00 at the last entry
    lda     #$00
    tay
    sta     (RESC),y

    lda     RESB
    ldx     RESB+1
    rts

display_catalog:

    STZ_ABS TR0


    ldy     #$00
@loop2:
    lda     CH376_DATA
    cmp     #' '   ; Space ?
    bne     @not_space

  ;  bne     @skip
    pha
    lda     TR0
    bne     @dot_already_stored
    sty     TR0   ; Save pos of the dot
  ;  lda     #'.'
    ;bne     @skip

@dot_already_stored:
    pla
@not_space:
    cmp     #'Z'+1 ;
    bcs     @skip
    cmp     #'A'
    bcc     @skip

    adc     #$1F

@skip:

@do_not_remove_dot:
    sta     (RESC),y
@inc_y:
    iny
    cpy     #8+3
    bne     @loop2

    lda     #$00
    sta     (RESC),y ; Store EOS
    iny

    lda     CH376_DATA  ; Attribute

    sta     (RESC),y


@continue:
    iny

@loop3:
    lda     CH376_DATA
    sta     (RESC),y
    iny
    cpy     #.sizeof(_READDIR_STRUCT)
    bne     @loop3

    ldy     #11+1
    lda     (RESC),y
    cmp     #$10
    beq     @skip_point

    ldy     TR0
    lda     #'.'        ; Store . if we have reached a space
    sta     (RESC),y
@skip_point:
    ; Checking if we have an extension. If yes, we store \0 at the position of the dot
    ldy     TR0
    beq     @no_dot

    ldy     #8+1   ; Position of the extension
    lda     (RESC),y
    cmp     #' ' ; is it space
    bne     @copy_ext ; No continue
    ; else remove dot
    ldy     TR0
    lda     #$00
    sta     (RESC),y
    jmp     @no_dot
@copy_ext:
    lda     TR0    ; Check where dot is
    cmp     #'8'   ; 8 position ? Do not move ext
    beq     @no_dot

    ldy     #8
    lda     (RESC),y
    ldy     TR0
    iny
    sta     (RESC),y

    ldy     #9
    lda     (RESC),y
    ldy     TR0
    iny
    iny
    sta     (RESC),y

    ldy     #10
    lda     (RESC),y
    ldy     TR0
    iny
    iny
    iny
    sta     (RESC),y
    iny
    lda     #$00
    sta     (RESC),y

@no_dot:
    ; Compute
    lda     RESC
    clc
    adc     #.sizeof(_READDIR_STRUCT)
    bcc     @do_not_inc
    inc     RESC+1
@do_not_inc:
    sta     RESC

    inc     TR7


    lda     #CH376_FILE_ENUM_GO
    sta     CH376_COMMAND
    jmp     _ch376_wait_response


.endproc
