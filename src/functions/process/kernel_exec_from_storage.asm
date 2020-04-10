
;    ptr_header   :=userzp+2
    ;fp_exec      :=userzp+4
    ;copy_str     :=userzp+8
    ;temp         :=userzp+10

RESC := DECDEB 
RESD := DECFIN
RESE := DECCIB



.proc kernel_try_to_find_command_in_bin_path

    ; A & Y contains the command
	; here we found no command, let's go trying to find it in /bin
    ; Malloc
    sta     RES
    sty     RES+1

    lda     #<(.strlen("/bin/")+8+1) ; 5 because /bin/ & 8 because length can't be greater than 8 for the command
    ldy     #>(.strlen("/bin/")+8+1)
    jsr     XMALLOC_ROUTINE
    cmp     #NULL
    bne     @malloc_ok
    cpy     #NULL
    bne     @malloc_ok

    
    rts
    ; FIX ME test OOM
@malloc_ok:

    sta     RESB
    sty     RESB+1

    sta     RESC
    sty     RESC+1

    lda     #'A'
    sta     $bb81

    

    ; copy /bin
    ; do a strcat
    ldy     #$00
@L1:
    lda     str_root_bin,y

    beq     @end
    sta     (RESC),y
    iny
    cpy     #.strlen("/bin/")
    bne     @L1


@end:
    tya
    clc
    adc     RESC
    bcc     @S20
    inc     RESC+1    
@S20:
    sta     RESC

    ldy     #$00
; strcat of the command
@L2:
    lda     (RES),y
    beq     @end2
    cmp     #' '
    beq     @end2
    sta     (RESC),y
    iny
    cpy     #$08
    bne     @L2
    ; now copy argv[0]
@end2:
    lda     #$00
    sta     (RESC),y

    lda     #'B'
    sta     $bb80

    ; at this step RES (only) can be used again     

    ; at this step RESB contains the beginning of the string

    lda     RESB
    sta     RESC
    lda     RESB+1
    sta     RESC+1



@out:
    ldy     #$00
@L5:    
    lda     (RESB),y
    beq     @S1
    sta     $bb89,y
    iny
    bne     @L5


@S1:
    ldy     #O_RDONLY
    lda     RESB
    ldx     RESB+1
    jsr     XOPEN_ROUTINE
    
    cmp     #NULL
    bne     @not_null

    cpy     #NULL
    bne     @not_null

 

    lda     #'C'
    sta     $bb82

    ; free string used for the strcat
    lda     RESC
    ldy     RESC+1
    jsr     XFREE_ROUTINE

    ; error not found
    lda     #ENOENT 

    rts
@not_null:
    ; save fp
    pha
    tya
    pha
    ; free tmp string
    lda     RESC
    ldy     RESC+1
    jsr     XFREE_ROUTINE


    pla
    sta     RESC+1   ; save fp
    pla
    sta     RESC     ; save fp


    lda     #'D'
    sta     $bb83

    ; Found let's fork
    jsr     _XFORK
    ; RESC contains file pointer
    ; RES can be used
    ; RESB too



   
    ; Malloc 20 bytes for the header
    lda     #20
    ldy     #00

    jsr     XMALLOC_ROUTINE
    
    cmp     #NULL
    bne     @not_null2

    cpy     #NULL
    beq     @not_null2
@out_not_found:
    lda     #ENOMEM         ; Error

    lda     #$13
    sta     $bb80+2

    rts    


@not_null2:
    ; RESD contains pointer to header
    sta     RESD
    sty     RESD+1


    sta     PTR_READ_DEST
    sty     PTR_READ_DEST+1
    ; read 20 bytes in the header

    lda     #'E'
    sta     $bb84


    lda     #20
    ldy     #$00
    jsr     XREADBYTES_ROUTINE
    
    
    ldy     #$00
    lda     (RESD),y ; fixme 65c02

    cmp     #$01
    beq     @is_an_orix_file
    lda     #'F'
    sta     $bb85

    rts
@undebug:
    lda     RESD
    ldy     RESD+1
    
    jsr     XFREE_ROUTINE
    lda     #$00 ; don't update length
    jsr     XCLOSE_ROUTINE
    lda     #ENOENT 
    ; not found it means that we display error message

    rts


@is_an_orix_file:


  	; Switch off cursor
    ldx     #$00
    jsr     XCOSCR_ROUTINE
    ; Storing address to load it

    ldy     #14
    lda     (RESD),y ; fixme 65c02
    sta     PTR_READ_DEST

    ldy     #15
    lda     (RESD),y ; fixme 65c02
    sta     PTR_READ_DEST+1
		
    ; init RES to start code

    ldy     #18
    lda     (RESD),y ; fixme 65c02
    sta     RESE

    ldy     #19
    lda     (RESD),y ; fixme 65c02    
    sta     RESE+1

    ; free header
    lda     RESD
    ldy     RESD+1
    jsr     XFREE_ROUTINE

    lda     #$FF ; read all the binary
    ldy     #$FF
    jsr     XREADBYTES_ROUTINE
    ; FIXME return nb_bytes read malloc must be done
   
    lda     #$00 ; don't update length
    jsr     XCLOSE_ROUTINE


    ; free fp
    lda     RESC
    ldy     RESC+1
    jsr     XFREE_ROUTINE
    jsr     execute
    lda     #EOK
    rts

execute:
    jmp     (RESE) ; jmp : it means that if program launched do an rts, it returns to interpreter



str_root_bin:
    ; If you change this path, you need to change .strlen("/bin/") above
    .asciiz "/bin/"    
.endproc