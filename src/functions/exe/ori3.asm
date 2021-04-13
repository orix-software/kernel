.define Z00 RES
.define Z02 RESB
.define Z04 DECFIN
.define Z06 DECDEB

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

	dec Z06									; Page -1 = Offset
	beq rel_end								; Fin si chargement en page 1 (adresse par défaut -> rien à faire)

	ldy #$00								; Au cas ou on parte directement vers "reste"
	lda Z04+1
	beq reste

boucle:
	lda (Z02),y								; On prend un octet de la MAP
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
	lda (Z00),y
	adc Z06
	sta (Z00),y
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
	lda Z00
	adc #$08
	sta Z00
	bcc *+4
	inc Z00+1
suite:
;	inc Z02									; Octet suivant dans la MAP
;	bne *+4
;	inc Z02+1

	iny
	bne *+6
	inc Z02+1								; Page suivante dans la MAP
	dec Z04+1
	bne boucle

	;
	; On a traité toutes les pages entières
	; On traite les octets restants
	;
	; On arrive ici avec Y=0
	;
reste:
	lda Z04
	beq rel_end

boucle2:
	lda (Z02),y								; On prend un octet de la MAP
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
	lda (Z00),y
	adc Z06
	sta (Z00),y
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
	lda Z00
	adc #$08
	sta Z00
	bcc *+4
	inc Z00+1
suite2:
;	inc Z02									; Octet suivant dans la MAP
;	bne *+4
;	inc Z02+1

	iny
	dec Z04
	bne boucle2

rel_end:
	inc Z06									; On remet la page de chargement à sa valeur initiale
	rts									; Pour utilisation éventuelle par une autre routine
.endproc

