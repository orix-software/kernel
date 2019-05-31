.struct XMAINARGS_STRUCT
argc              .byte    ; number of args
argv_ptr          .res     (KERNEL_MAX_ARGS_COMMAND_LINE * 2)
argv_value_ptr    .res     (KERNEL_MAX_LENGTH_BUFEDT)
.endstruct

; Register Modify : A,X,Y
; Register Save : 
; Memory modify : RES,RESB,TR0,TR1
; Memory save : RES,RESB,TR0,TR1

XMAINARGS_ROUTINE_SPLIT_VALUE         :=TR1
XMAINARGS_ROUTINE_ARGV_PTR            :=TR2 ; word
XMAINARGS_ROUTINE_NEXT_ARGV_VALUE_PTR :=TR4 ; word

.proc XMAINARGS_ROUTINE
        sta     RESB                    ; Contains command line pointer
        sty     RESB+1        

        
        lda     #<.sizeof(XMAINARGS_STRUCT)
        ldy     #>.sizeof(XMAINARGS_STRUCT)
        jsr     XMALLOC_ROUTINE

        sta     RES                     ; Contains address of mainargs struct
        sty     RES+1

;        sta     $5000
        ;sty     $5001

        lda     #" " ; Split value 
        sta     XMAINARGS_ROUTINE_SPLIT_VALUE

; ************************* init XMAINARGS_ROUTINE_NEXT_ARGV_VALUE_PTR
        lda     RES+1
        sta     XMAINARGS_ROUTINE_NEXT_ARGV_VALUE_PTR+1
        sta     XMAINARGS_ROUTINE_ARGV_PTR+1
        ;sta     $5003

        ldy     #(XMAINARGS_STRUCT::argv_value_ptr)
        tya
        clc        
        adc     RES
        bcc     S3
        inc     XMAINARGS_ROUTINE_NEXT_ARGV_VALUE_PTR+1
        inc     XMAINARGS_ROUTINE_ARGV_PTR+1
S3:
        sta     XMAINARGS_ROUTINE_NEXT_ARGV_VALUE_PTR
        sta     XMAINARGS_ROUTINE_ARGV_PTR
        ;sta     $5002

; ************************* init XMAINARGS_ROUTINE_ARGV_PTR
        

        lda     XMAINARGS_ROUTINE_NEXT_ARGV_VALUE_PTR
        sta     XMAINARGS_ROUTINE_ARGV_PTR
        lda     XMAINARGS_ROUTINE_NEXT_ARGV_VALUE_PTR+1
        sta     XMAINARGS_ROUTINE_ARGV_PTR+1


        ldy     #$00
        lda     #$00

        ; init  ARGV to 0
.ifpc02 
.pc02
        sta     (RES)
.p02    
.else
        sta     (RES),y
        ;iny 
.endif     

        ldy     #$00
L0:     lda     (RESB),y
        beq     L3
        cmp     XMAINARGS_ROUTINE_SPLIT_VALUE     ; Split value is store in TR1
        bne     L1
        jsr     terminate_param
        iny
        jsr     inc_argv
        
.ifpc02 
.pc02
        bra     L0
.p02    
.else
        jmp     L0                      ; FIXME could be replace by bne
.endif        

L1:  

        sta     (XMAINARGS_ROUTINE_NEXT_ARGV_VALUE_PTR),y
		
        iny
        cpy     #MAX_BUFEDT_LENGTH ; MAX_BUFEDT_LENGTH
        bne     L0
        lda     #$00
L3:	
        jsr     terminate_param
        jsr     inc_argv   
        ; Return pointer
        lda     RES
        ldy     RES+1
        rts

inc_argv:

.ifpc02
.pc02
        lda     (RES)                   ; get argc
        inc     a
        sta     (RES)                   ; get argc
.p02
.else
.p02    
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
.endif    

        rts

terminate_param:
        sty     TR0


        lda     #$00
        sta     (XMAINARGS_ROUTINE_NEXT_ARGV_VALUE_PTR),y
        iny
        tya
        clc        
        adc     XMAINARGS_ROUTINE_NEXT_ARGV_VALUE_PTR
        bcc     S4
        inc     XMAINARGS_ROUTINE_NEXT_ARGV_VALUE_PTR+1
S4:
        sta     XMAINARGS_ROUTINE_NEXT_ARGV_VALUE_PTR

        lda     XMAINARGS_ROUTINE_ARGV_PTR
        clc
        adc     #02
        bcc     S5
        inc     XMAINARGS_ROUTINE_ARGV_PTR+1
S5:     
        sta     XMAINARGS_ROUTINE_ARGV_PTR

     ;   ldy     #$00
        ;lda     XMAINARGS_ROUTINE_NEXT_ARGV_VALUE_PTR
        ;sta     (XMAINARGS_ROUTINE_ARGV_PTR),y
        ;iny
        ;lda     XMAINARGS_ROUTINE_NEXT_ARGV_VALUE_PTR+1
        ;sta     (XMAINARGS_ROUTINE_ARGV_PTR),y



        ldy     TR0
        rts

.endproc        


