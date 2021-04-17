



;
; Relocation
;
; Entrée:
;	00-01	: Adresse Programme
;	02-03	: Adresse MAP
;	04-05	: Longueur MAP
;	06	: Page de chargement
;
; Sortie:
;	00-01	: Adresse de l'octet suivant la fin du programme (table link par exemple)
;	02-03	: Adresse de l'octet suivant la fin de la MAP
;	04-05	: 00 00
;	06	: Inchangé
.proc relocate_ori3

	dec ORI3_PAGE_LOAD									; Page -1 = Offset
	beq rel_end								; Fin si chargement en page 1 (adresse par défaut -> rien à faire)

    rts
	ldy #$00								; Au cas ou on parte directement vers "reste"
	lda ORI3_LENGTH_MAP+1
	beq reste

boucle:
	lda (ORI3_MAP_ADRESS),y								; On prend un octet de la MAP
	beq skip8								; 0 -> On saute directement 8 octets du programme

	tax									; Sauvegarde ACC
	tya									; Sauvegarde Y
	pha

	ldy #$07								; 8 Bits
	txa									; Restaure ACC
reloc:
	lsr a
	bcc next

	tax									; Sauvegarde ACC
	clc									; On ajuste l'adresse
	lda (ORI3_PROGRAM_ADRESS),y
	adc ORI3_PAGE_LOAD
	sta (ORI3_PROGRAM_ADRESS),y
	txa									; Restaure ACC
next:
	dey
	bpl reloc
	pla									; Restaure Y
	tay
	;
	; On saute 8 octets
	;
skip8:
	clc									; On saute 8 octets du programme
	lda ORI3_PROGRAM_ADRESS
	adc #$08
	sta ORI3_PROGRAM_ADRESS
	bcc *+4
	inc ORI3_PROGRAM_ADRESS+1
suite:
;	inc ORI3_MAP_ADRESS									; Octet suivant dans la MAP
;	bne *+4
;	inc ORI3_MAP_ADRESS+1

	iny
	bne *+6
	inc ORI3_MAP_ADRESS+1								; Page suivante dans la MAP
	dec ORI3_LENGTH_MAP+1
	bne boucle

	;
	; On a traité toutes les pages entières
	; On traite les octets restants
	;
	; On arrive ici avec Y=0
	;
reste:
	lda ORI3_LENGTH_MAP
	beq rel_end

boucle2:
	lda (ORI3_MAP_ADRESS),y								; On prend un octet de la MAP
	beq skip82								; 0 -> On saute directement 8 octets du programme

	tax									; Sauvegarde ACC
	tya									; Sauvegarde Y
	pla

	ldx #$07								; 8 Bits
	txa									; Restaure ACC
reloc2:
	lsr a
	bcc next2

	tax									; Sauvegarde ACC
	clc									; On ajuste l'adresse
	lda (ORI3_PROGRAM_ADRESS),y
	adc ORI3_PAGE_LOAD
	sta (ORI3_PROGRAM_ADRESS),y
	txa									; Restaure ACC
next2:
	dey
	bpl reloc2
	pla									; Restaure Y
	tay
	;
	; On saute 8 octets
	;
skip82:
	clc									; On saute 8 octets du programme
	lda ORI3_PROGRAM_ADRESS
	adc #$08
	sta ORI3_PROGRAM_ADRESS
	bcc *+4
	inc ORI3_PROGRAM_ADRESS+1
suite2:
;	inc ORI3_MAP_ADRESS									; Octet suivant dans la MAP
;	bne *+4
;	inc ORI3_MAP_ADRESS+1

	iny
	dec ORI3_LENGTH_MAP
	bne boucle2

rel_end:
	inc ORI3_PAGE_LOAD									; On remet la page de chargement à sa valeur initiale
	rts									; Pour utilisation éventuelle par une autre routine
.endproc

