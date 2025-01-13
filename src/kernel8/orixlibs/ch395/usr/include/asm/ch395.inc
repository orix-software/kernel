; supports up to 8 sockets
; 10/100M
; PPPOE,IP,DHCP, ARP,ICMP,IGMP,UDP,TCP
; 24K ram
; 4KEEPROM
; 8 GPIO

CH395_DETECTED                = $AA

CH395_COMMAND_PORT            := $381
CH395_DATA_PORT               := $380

CH395_GET_IC_VER              = $01
CH395_SET_BAUDRATE            = $02
CH395_ENTER_SLEEP             = $03
CH395_RESET_ALL	              = $05 ; 50ms
CH395_CHECK_EXIST             = $06
CH395_SET_PHY                 = $20
CH395_GET_GLOB_INT_STATUS_ALL = $19
CH395_SET_MAC_ADDR            = $21 ; 6 ?
CH395_SET_IP_ADDR             = $22 ; 4
CH395_SET_GWIP_ADDR           = $23 ; 4
CH395_SET_MASK_ADDR           = $24 ; 4
CH395_SET_MAC_FILT            = $25
CH395_GET_PHY_STATUS          = $26
CH395_INIT                    = $27
CH395_GET_UNREACH_IPPORT      = $28
CH395_GET_GLOB_INT_STATUS     = $29
CH395_SET_RETRAN_COUNT        = $2A
CH395_SET_RETRAN_PERIOD       = $2B
CH395_GET_CMD_STATUS          = $2C
CH395_GET_REMOT_IPP_SN        = $2D
CH395_CLEAR_RECV_BUF_SN       = $2E
CH395_GET_SOCKET_STATUS_SN    = $2F
CH395_GET_INT_STATUS_SN       = $30
CH395_SET_IP_ADDR_SN          = $31
CH395_SET_DES_PORT_SN         = $32
CH395_SET_SOUR_PORT_SN        = $33
CH395_SET_PROTO_TYPE_SN       = $34
CH395_OPEN_SOCKET_SN          = $35
CH395_TCP_LISTEN_SN           = $36
CH395_TCP_CONNECT_SN          = $37
CH395_TCP_DISNCONNECT_SN      = $38
CH395_WRITE_SEND_BUF_SN       = $39
CH395_GET_RECV_LEN_SN         = $3B
CH395_READ_RECV_BUF_SN        = $3C
CH395_CLOSE_SOCKET_SN         = $3D
CH395_SET_IPRAW_PRO_SN        = $3E
CH395_PING_ENABLE             = $3F
CH395_GET_MAC_ADDR            = $40
CH395_DHCP_ENABLE             = $41
CH395_GET_DHCP_STATUS         = $42
CH395_GET_IP_INF              = $43
CH395_PPPOE_SET_USER_NAME     = $44
CH395_PPPOE_SET_PASSWORD      = $45
CH395_PPPOE_ENABLE            = $46
CH395_GET_PPPOE_STATUS        = $47
CH395_SET_TCP_MSS             = $50
CH395_SET_TTL                 = $51
CH395_SET_RECV_BUF            = $52
CH395_SET_SEND_BUF            = $53
CH395_SET_FUN_PARA            = $55
CH395_SET_KEEP_LIVE_IDLE      = $56
CH395_SET_KEEP_LIVE_INTVL     = $57
CH395_SET_KEEP_LIVE_CNT       = $58
CH395_SET_KEEP_LIVE_SN        = $59
CH395_EEPROM_ERASE            = $E9
CH395_EEPROM_WRITE            = $EA
CH395_EEPROM_READ             = $EB
CH395_READ_GPIO_REG           = $EC
CH395_WRITE_GPIO_REG          = $ED

; Status

CH395_ERR_SUCCESS             = $00 ; Success
CH395_ERR_BUSY                = $10 ; Occupé, indiquant que la commande est en cours d'exécution
CH395_ERR_MEM                 = $11 ; Erreur de gestion de la mémoire
CH395_ERR_BUF                 = $12 ; Erreur de tampon
CH395_ERR_TIMEOUT             = $13 ; Timeout
CH395_ERR_RTE                 = $14 ; Erreur de routage
CH395_ERR_ABRT                = $15 ; Abandon de la connexion
CH395_ERR_RST                 = $16 ; Connexion réinitialisée
CH395_ERR_CLSD                = $17 ; Connexion fermée
CH395_ERR_CONN                = $18 ; Pas de connexion
CH395_ERR_VAL                 = $19 ; Mauvaise valeur
CH395_ERR_ARG                 = $1A ; Erreur de paramètre
CH395_ERR_USE                 = $1B ; Déjà utilisé
CH395_ERR_IF                  = $1C ; Erreur MAC
CH395_ERR_ISCONN              = $1D ; Connecté
CH395_ERR_OPEN                = $20 ; Ouvert

CH395_DHCP_ENABLE_VAL         = $01
CH395_DHCP_DISABLE_VAL        = $00

CH395_DHCP_STATUS_ENABLED     = $00
CH395_DHCP_STATUS_DISABLED    = $01

CH395_NUMBER_MAX_SOCKET       = $08

CH395_SOCKET0                 = 0
CH395_SOCKET1                 = 1
CH395_SOCKET2                 = 2
CH395_SOCKET3                 = 3
CH395_SOCKET4                 = 4
CH395_SOCKET5                 = 5
CH395_SOCKET6                 = 6
CH395_SOCKET7                 = 7

CH395_PROTO_TYPE_TCP          = $03
CH395_PROTO_TYPE_UDP          = $02
CH395_PROTO_TYPE_MAC_RAW      = $01
CH395_PROTO_TYPE_IP_RAW       = $00

CH395_SINT_STAT_TIM_OUT       = $40
CH395_SINT_STAT_DISCONNECT    = $10
CH395_SINT_STAT_CONNECT       = $08
CH395_SINT_STAT_RECV          = $04
CH395_SINT_STAT_SEND_OK       = $02
CH395_SINT_STAT_SENBUF_FREE   = $01

CH395_PHY_DISCONN             = $01
CH395_PHY_10M_FLL             = $02
CH395_PHY_10M_HALF            = $04
CH395_PHY_100M_FLL            = $08
CH395_PHY_100M_HALF           = $10

CH395_SOCKET_CLOSED           = $00
CH395_SOCKET_OPEN             = $05

CH395_TCP_CLOSED              = $00
CH395_TCP_LISTEN              = $01
CH395_TCP_SYN_SENT            = $02
CH395_TCP_SYN_REVD            = $03
CH395_TCP_ESTABLISHED         = $04
CH395_TCP_FIN_WAIT_1          = $05
CH395_TCP_FIN_WAIT_2          = $06
CH395_TCP_CLOSE_WAIT          = $07
CH395_TCP_CLOSING                   = $08
CH395_TCP_LAST_ACK                  = $09
CH395_TCP_TIME_WAIT                 = $0A

CH395_GINT_STAT_DHCP                = $08
CH395_GINT_STAT_PHY_CHANGE          = $04
CH395_GINT_STAT_IP_CONFLI           = $02
CH395_GINT_STAT_UNREACH             = $01

CH395_FUN_PARA_FLAG_TCP_SERVER      = $02
CH395_FUN_PARA_FLAG_LOW_PWR         = $04
CH395_FUN_PARA_FLAG_SOCKET_CLOSE    = $08
CH395_FUN_PARA_FLAG_DISABLE_SEND_OK = $10

CH395_GINT_STAT_SOCK0               = 16
CH395_GINT_STAT_SOCK1               = 32
CH395_GINT_STAT_SOCK2               = 64
CH395_GINT_STAT_SOCK3               = 128

CH395_GINT_STAT_SOCK4               = 1
CH395_GINT_STAT_SOCK5               = 2
CH395_GINT_STAT_SOCK6               = 3
CH395_GINT_STAT_SOCK7               = 4