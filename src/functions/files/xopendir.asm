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
   sty     RES
   ldy     #O_RDONLY
   ldx     RES
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
    rts

@continue:
    ; Save PTR
    sta     RESB
    sty     RESB+1


;  ZZ1001:
 ;   cmp #CH376_USB_INT_SUCCESS
  ;  bne ZZ1002
   ; lda #COLOR_FOR_FILES
   ; bne display_one_file_catalog

  ;ZZ1002:
   ; cmp #CH376_ERR_OPEN_DIR
   ; bne ZZ0003
   ; lda #COLOR_FOR_DIRECTORY
   ; bne display_one_file_catalog

  ;ZZ0003:
   ; cmp #CH376_USB_INT_DISK_READ
    ;bne ZZ0004
    ;beq go

;display_one_file_catalog:
 ;   lda #CH376_DIR_INFO_READ
  ;  sta CH376_COMMAND
   ; lda #$ff
    ;sta CH376_DATA
    ;jsr _ch376_wait_response
    ;cmp #CH376_USB_INT_SUCCESS

    ;bne Error

;go:
 ;   lda #CH376_RD_USB_DATA0
  ;  sta CH376_COMMAND
   ; lda CH376_DATA
    ;cmp #$20
    ;beq ZZ0005

;    rts

 ; ZZ0005:
  ;  jsr display_catalog



  ; FD
    ldy     #$00
L1:
    lda     CH376_DATA
    sta     (RESB),y
    iny
    cpy     #$1F
    bne     L1
    rts
    ;lda     CH376_DATA
    ;sta     (RES),y          ; Sauvegarde l'attribut pour plus tard

;    ldx #$14

;@L2:
 ;   lda CH376_DATA
;    sta BUFEDT+1,y
    ;dex
    ;bpl @L2

  ;rts
.endproc 
