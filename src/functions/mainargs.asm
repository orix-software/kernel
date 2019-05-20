KERNEL_MAX_ARGS_COMMAND_LINE = 3

.struct XMAINARGS_STRUCT
__argc       .byte    ; number of args
next_ptr_arg .word
argv         .res     (3 * 2)

.endstruct


.proc XMAINARGS_ROUTINE
        sta     RESB                    ; Contains command line pointer
        sty     RESB+1        

        lda     #<.sizeof(XMAINARGS_STRUCT)
        ldy     #>.sizeof(XMAINARGS_STRUCT)
	jsr     XMALLOC_ROUTINE
        sta     RES                     ; Contains address of mainargs struct
        sty     RES+1
        

        ldy     #$00
L0:     lda     (RESB),y
        beq     L3
        cmp     #" "
        bne     L1
        lda     #$00
        beq     L3
L1: 
		;sta     name,x
        iny
        cpy     #MAX_BUFEDT_LENGTH ; MAX_BUFEDT_LENGTH
        bne     L0
        lda     #0
L3:	
        tya                             ; FIXME 65C02
        pha
        ; argc++
        ldy     #$00
        lda     (RES),y                 ; get argc
        
        tax                             ; bit crap but 6502 can't do inc (RES),y
        inx
        txa
        
        sta     (RES),y                 ; get argc
        

        pla
        tay

        ;ldx     (RES),y
        ;inc     (RES),y
/*
MAXARGS  = 10                   ; Maximum number of arguments allowed
        sta 	  name,x
        inc     __argc          ; argc always is equal to, at least, 1

		
        ldy     #1 * 2          ; Point to second argv slot
		
next:   lda     BUFEDT,x
        beq     done            ; End of line reached
        inx
        cmp     #' '            ; Skip leading spaces
        beq     next		

found:  cmp     #'"'            ; Is the argument quoted?
        beq     setterm         ; Jump if so
        dex                     ; Reset pointer to first argument character

        lda     #' '            ; A space ends the argument
setterm:sta     term            ; Set end of argument marker

; Now, store a pointer, to the argument, into the next slot.

        txa                     ; Get low byte
        clc
        adc 	  #<BUFEDT
        bcc 	  L4
        inc 	  L5+1
L4:
        sta     argv,y          ; argv[y]=&arg
L5:		
        lda     #>BUFEDT
        sta     argv+1,y
        iny
        iny
        inc     __argc          ; Found another arg

; Search for the end of the argument

argloop:lda     BUFEDT,x
        beq     done
        inx
        cmp     term
        bne     argloop

; We've found the end of the argument. X points one character behind it, and
; A contains the terminating character. To make the argument a valid C string,
; replace the terminating character by a zero.

        lda     #0
        sta     BUFEDT-1,x

; Check if the maximum number of command line arguments is reached. If not,
; parse the next one.

        lda     __argc          ; Get low byte of argument count
        cmp     #MAXARGS        ; Maximum number of arguments reached?
        bcc     next            ; Parse next one if not		
		
		
done:   lda     #<argv
        ldx     #>argv
        sta     __argv
        stx     __argv + 1
        rts
		
		
.segment        "INIT"

term:   .res    1


.data

name:   .res    FNAME_LEN + 1
args:   .res    SCREEN_XSIZE * 2 - 1

param_found:
		.res 1
; char* argv[MAXARGS+1]={name};
argv:  
		.addr   name
   .res    MAXARGS * 2
*/ 

	rts
.endproc        


