;
; Relocation
;
; Entrée:
;	00-01	: Adresse Programme
;	02-03	: Adresse MAP
;	04-05	: Longueur MAP
;	06	    : Page de chargement
;
; Sortie:
;	00-01	: Adresse de l'octet suivant la fin du programme (table link par exemple)
;	02-03	: Adresse de l'octet suivant la fin de la MAP
;	04-05	: 00 00
;	06	    : Inchangé
.proc compute_all_offset_ORI2
    .out     .sprintf("|MODIFY:KERNEL_CREATE_PROCESS_PTR1:compute_all_offset_ORI2")
    .out     .sprintf("|MODIFY:RESD:compute_all_offset_ORI2")
    .out     .sprintf("|MODIFY:RESE:compute_all_offset_ORI2")
    .out     .sprintf("|MODIFY:PTR_READ_DEST:compute_all_offset_ORI2")


    ; RESD contains header

    ; Set the adress in the kernel struct
    ldx     kernel_process + kernel_process_struct::kernel_current_process
    lda     kernel_process + kernel_process_struct::kernel_one_process_struct_ptr_low,x
    sta     KERNEL_CREATE_PROCESS_PTR1
    lda     kernel_process + kernel_process_struct::kernel_one_process_struct_ptr_high,x
    sta     KERNEL_CREATE_PROCESS_PTR1 + 1


    ; Get execution address low
    ldy     #18
    clc
    lda     (RESD),y        ; Get execution address low
    ldy     #kernel_one_process_struct::kernel_process_addr
    sta     (KERNEL_CREATE_PROCESS_PTR1),y ; $741

    ; Gère le cas de l'adresse d'éxecution <> loading adress
    ; Dans ce cas on prend l'execution adress, et on soustrait
    ; cela donnera l'offset de poids fort à ajouter

    ldy     #15             ; Get execution address high
    lda     (RESD),y
    sta     RESE            ; Use RESE as temp value

    ldy     #19             ; Get execution address high
    lda     (RESD),y
    sec
    sbc     RESE
    sta     RESE


    ldy     #kernel_one_process_struct::kernel_process_addr + 1

    ldx     RESD + 1
    inx
    txa
    clc
    adc     RESE
    sta     (KERNEL_CREATE_PROCESS_PTR1),y


    ldy     RESD + 1	; the ptr of the address allocated
    iny

    sty     ORI2_PROGRAM_ADRESS + 1 ; addr $62: $0B
    sty     ORI2_MAP_ADRESS + 1     ; Prepare adresse map but does not compute yet ; $0B
    sty     RESE + 1                ; Set address execution   ; 0B
    sty     PTR_READ_DEST + 1       ; Set address to load the next part of the program
    sty     ORI2_PROGRAM_ADRESS + 1
;

.IFPC02
.pc02
    stz     ORI2_PROGRAM_ADRESS
    stz     ORI2_MAP_ADRESS
    stz     RESE             ; Set address execution
    stz     PTR_READ_DEST
    stz     ORI2_PAGE_LOAD   ; Set to 0 for instance before compute
.p02
.else
    lda     #$00
    sta     ORI2_PROGRAM_ADRESS
    sta     ORI2_MAP_ADRESS
    sta     RESE             ; Set address execution
    sta     PTR_READ_DEST
    sta     ORI2_PAGE_LOAD  ; Set to 0 for instance before compute
.endif


    ldy     #15              ; High start adress
    lda     RESD + 1      ; Align
    clc
    adc     #$01
    cmp     (RESD),y
    beq     @do_not_compute

    sec
    sbc     (RESD),y
    sta     ORI2_PAGE_LOAD

@do_not_compute:
    ; set map length
    ldy     #$07
    lda     (RESD),y
    sta     ORI2_LENGTH_MAP

    ldy     #$08
    lda     (RESD),y
    sta     ORI2_LENGTH_MAP + 1

    ldy     #12
    lda     (RESD),y
    clc
    adc     ORI2_MAP_ADRESS
    bcc     @S2
    inc     ORI2_MAP_ADRESS + 1
@S2:
    sta     ORI2_MAP_ADRESS

    ldy     #13
    lda     (RESD),y ; fixme 65c02
    clc
    adc     ORI2_MAP_ADRESS + 1
    sta     ORI2_MAP_ADRESS + 1


	rts
.endproc


