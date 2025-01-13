.include "telestrat.inc"

.export init_network

.import ch395_check_exist
.import ch395_set_fun_para
.import ch395_init
.import ch395_get_phy_status

.import ch395_get_dhcp_status
.import ch395_dhcp_enable

.import ch395_get_ip_inf

.import KERNEL_NETWORK_FLAG
.import KERNEL_NETWORK_SOCKET_LIST
.import KERNEL_NETWORK_SOURCE_PORT

.include   "../../kernel8/orixlibs/ch395/usr/include/asm/ch395.inc"
.include   "../../include/kernel.inc"
.include   "../../include/process.inc"
.include   "../../include/network.inc"
.include   "../../include/memory.inc"

.proc init_network

	lda     #<KERNEL_NETWORK_FLAG
	ldy     #>KERNEL_NETWORK_FLAG

    sta     ADDRESS_READ_BETWEEN_BANK_DOUBLON
    sty     ADDRESS_READ_BETWEEN_BANK_DOUBLON+1

    ldx     #$00
    ldy     #$00
    MEMORY_GET_VALUE_FROM_BANK ; A contains the value
    cmp     KERNEL_NETWORK_STATE_NOT_INITIALIZED
    bne     @ch395_found

    jsr     ch395_check_exist

    cmp     #$AA
    beq     @ch395_found
    lda     #KERNEL_NETWORK_STATE_CHIP_NOT_FOUND
    rts

@ch395_found:
	lda     #<KERNEL_NETWORK_FLAG
	ldy     #>KERNEL_NETWORK_FLAG

    sta     ADDRESS_READ_BETWEEN_BANK_DOUBLON
    sty     ADDRESS_READ_BETWEEN_BANK_DOUBLON+1

    ldx     #$00
    ldy     #$00
    MEMORY_GET_VALUE_FROM_BANK ; A contains the value

    cmp     #KERNEL_NETWORK_STATE_NOT_INITIALIZED
    beq     @initialize
    cmp     #KERNEL_NETWORK_STATE_CHIP_INITIALIZED
    beq     @checking_cable
    cmp     #KERNEL_NETWORK_CABLE_DISCONNECTED
    beq     @checking_cable
    cmp     #KERNEL_NETWORK_CABLE_CONNECTED
    beq     @start_dhcp
    cmp     #KERNEL_NETWORK_STARTING_DHCP
    beq     @start_dhcp
    rts

@initialize:
    jmp     kernel_ch395_initialize

@checking_cable:
    ; Initialize socket list with 0
    lda     #$07
    sta     TR7

@loop:
    ldy     TR7
    lda     #$00
    ldx     #$00
    MEMORY_PUT_VALUE_TO_BANK KERNEL_NETWORK_SOCKET_LIST
    dec     TR7
    bpl     @loop


    jsr     ch395_get_phy_status
    cmp     #CH395_PHY_DISCONN
    beq     @cable_disconnected

    lda     #KERNEL_NETWORK_CABLE_CONNECTED
    ldx     #$00
    ldy     #$00
    MEMORY_PUT_VALUE_TO_BANK KERNEL_NETWORK_FLAG

    lda     #KERNEL_NETWORK_CABLE_CONNECTED

    rts

@start_dhcp:
    ; Check IP
    lda     #<RES
    ldx     #>RES
    jsr     ch395_get_ip_inf

    lda     RES
    cmp     #$00
    beq     @dhcp_not_started

    lda     #KERNEL_NETWORK_FULLY_STARTED
    ldx     #$00
    ldy     #$00
    MEMORY_PUT_VALUE_TO_BANK KERNEL_NETWORK_FLAG
    lda     #KERNEL_NETWORK_FULLY_STARTED
    rts

@dhcp_not_started:
    lda     #CH395_DHCP_ENABLE_VAL
    jsr     ch395_dhcp_enable
    lda     #KERNEL_NETWORK_STARTING_DHCP
    ldx     #$00
    ldy     #$00
    MEMORY_PUT_VALUE_TO_BANK KERNEL_NETWORK_FLAG
    lda     #KERNEL_NETWORK_STARTING_DHCP
    rts

@cable_disconnected:
    lda     #KERNEL_NETWORK_CABLE_DISCONNECTED
    ldx     #$00
    ldy     #$00
    MEMORY_PUT_VALUE_TO_BANK KERNEL_NETWORK_FLAG
    lda     #KERNEL_NETWORK_CABLE_DISCONNECTED
    rts

kernel_ch395_initialize:
    ; Set autoclose socket :
    lda     #CH395_FUN_PARA_FLAG_SOCKET_CLOSE
    jsr     ch395_set_fun_para
    ; Starting stack and exit
    jsr     ch395_init

    lda     #<KERNEL_FIRST_SOURCE_PORT_INIT
    ldx     #$00
    ldy     #$00
    MEMORY_PUT_VALUE_TO_BANK KERNEL_NETWORK_SOURCE_PORT

    lda     #>KERNEL_FIRST_SOURCE_PORT_INIT
    ldx     #$00
    ldy     #$01
    MEMORY_PUT_VALUE_TO_BANK KERNEL_NETWORK_SOURCE_PORT

    lda     #KERNEL_NETWORK_STATE_CHIP_INITIALIZED
    ldx     #$00
    ldy     #$00
    MEMORY_PUT_VALUE_TO_BANK KERNEL_NETWORK_FLAG

    lda     #KERNEL_NETWORK_STATE_CHIP_INITIALIZED

    rts

.endproc
