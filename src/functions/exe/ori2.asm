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

    ; Set the adress in the kernel struct
    ldx     kernel_process+kernel_process_struct::kernel_current_process
    lda     kernel_process+kernel_process_struct::kernel_one_process_struct_ptr_low,x
    sta     KERNEL_CREATE_PROCESS_PTR1
    lda     kernel_process+kernel_process_struct::kernel_one_process_struct_ptr_high,x
    sta     KERNEL_CREATE_PROCESS_PTR1+1


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


    ldy     #kernel_one_process_struct::kernel_process_addr+1

    ldx     RESD+1
    inx
    txa
    clc
    adc     RESE
    sta     (KERNEL_CREATE_PROCESS_PTR1),y


    ldy     RESD+1	; the ptr of the address allocated
    iny

    sty     ORI2_PROGRAM_ADRESS+1 ; addr $62: $0B
    sty     ORI2_MAP_ADRESS+1          ; Prepare adresse map but does not compute yet ; $0B
    sty     RESE+1                     ; Set address execution   ; 0B
    sty     PTR_READ_DEST+1            ; Set address to load the next part of the program
    sty     ORI2_PROGRAM_ADRESS+1
;
    lda     #$00
    sta     ORI2_PROGRAM_ADRESS
    sta     ORI2_MAP_ADRESS
    sta     RESE             ; Set address execution
    sta     PTR_READ_DEST

    sta     ORI2_PAGE_LOAD  ; Set to 0 for instance before compute

    ldy     #15              ; High start adress
    lda     RESD+1      ; Align
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
    sta     ORI2_LENGTH_MAP+1

    ldy     #12
    lda     (RESD),y
    clc
    adc     ORI2_MAP_ADRESS
    bcc     @S2
    inc     ORI2_MAP_ADRESS+1
@S2:
    sta     ORI2_MAP_ADRESS

    ldy     #13
    lda     (RESD),y ; fixme 65c02
    clc
    adc     ORI2_MAP_ADRESS+1
    sta     ORI2_MAP_ADRESS+1


	rts
.endproc


.proc relocate_ORI2

    ; On suppose que A = page de chargement du programme (chargé en début de page)
    ; On suppose également que z02-z05 ont été mis à jour par l'appelant (adresse et longueur de la bitmap)
    lda     ORI2_PAGE_LOAD            ; offset à appliquer
    beq     rel_end

	; Length map $47
	ldy     #$00                      ; Au cas ou on parte directement vers "reste"
	lda     ORI2_LENGTH_MAP+1

	beq     reste

boucle:
	lda     (ORI2_MAP_ADRESS),y		  ; On prend un octet de la MAP
	beq     skip8					  ; 0 -> On saute directement 8 octets du programme

	tax								  ; Sauvegarde ACC
	tya							      ; Sauvegarde Y
	pha

	ldy     #$07					  ; 8 Bits
	txa							      ; Restaure ACC
reloc:
	lsr     a
	bcc     next

	tax								  ; Sauvegarde ACC
	clc								  ; On ajuste l'adresse
	lda     (ORI2_PROGRAM_ADRESS),y
	adc     ORI2_PAGE_LOAD
	sta     (ORI2_PROGRAM_ADRESS),y
	txa								  ; Restaure ACC
next:
	dey
	bpl     reloc
	pla							      ; Restaure Y
	tay
	;
	; On saute 8 octets
	;
skip8:
	clc						        ; On saute 8 octets du programme
	lda     ORI2_PROGRAM_ADRESS
	adc     #$08
	sta     ORI2_PROGRAM_ADRESS
	bcc     *+4
	inc     ORI2_PROGRAM_ADRESS+1
suite:
; $1248 don't relocate
; $1268


	iny
	bne *+6
	inc ORI2_MAP_ADRESS+1								; Page suivante dans la MAP
	dec ORI2_LENGTH_MAP+1
	bne boucle

	;
	; On a traité toutes les pages entières
	; On traite les octets restants
	;
	; On arrive ici avec Y=0
	;
reste:
	lda     ORI2_LENGTH_MAP
	beq     rel_end

boucle2:
	lda     (ORI2_MAP_ADRESS),y								; On prend un octet de la MAP
	beq     skip82								; 0 -> On saute directement 8 octets du programme

	tax									; Sauvegarde ACC
	tya									; Sauvegarde Y
	pha


	ldy     #$07								; 8 Bits
	txa									; Restaure ACC
reloc2:
	lsr     a
	bcc     next2

	tax									; Sauvegarde ACC
	clc									; On ajuste l'adresse
	lda     (ORI2_PROGRAM_ADRESS),y
	adc     ORI2_PAGE_LOAD
	sta     (ORI2_PROGRAM_ADRESS),y
	txa									; Restaure ACC
next2:
	dey
	bpl     reloc2
	pla									; Restaure Y
	tay
	;
	; On saute 8 octets
	;
skip82:
	clc									; On saute 8 octets du programme
	lda     ORI2_PROGRAM_ADRESS
	adc     #$08
	sta     ORI2_PROGRAM_ADRESS
	bcc     *+4
	inc     ORI2_PROGRAM_ADRESS+1
suite2:

	iny

	dec     ORI2_LENGTH_MAP
	bne     boucle2

rel_end:
	inc     ORI2_PAGE_LOAD				; On remet la page de chargement à sa valeur initiale
;  @me:
;  	jmp		@me
;  	lda		ORI2_PROGRAM_ADRESS+1

	rts									; Pour utilisation éventuelle par une autre routine
.endproc


