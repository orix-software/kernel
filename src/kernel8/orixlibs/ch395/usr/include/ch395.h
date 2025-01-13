//typedef ch395ipaddress byte[4];
//typedef ch395macaddress byte[6];

unsigned char ch395_get_ic_ver();
void          ch395_reset_all();
unsigned char ch395_check_exist();
void          ch395_init();
unsigned char ch395_get_cmd_status();
void          ch395_get_mac_adress(unsigned char macaddress[]);
void          ch395_set_mac_adress(unsigned char macaddress[]);
void          ch395_get_ip_inf(unsigned char ip_infos[]);

void          ch395_set_ipraw_pro_sn(unsigned char ID_SOCKET);

void          ch395_dhcp_enable(unsigned char mode);
unsigned char ch395_get_dhcp_status();
void          ch395_retran_period(unsigned int period);
void          ch395_set_retran_count(unsigned char period);

void          ch395_set_ip_addr(unsigned char fix);

void          ch395_set_ip_addr_sn(unsigned char ip_addr[], unsigned char ID_SOCKET);
void          ch395_set_proto_type_sn(unsigned char proto,unsigned char ID_SOCKET);
void          ch395_set_des_port_sn(unsigned int port,unsigned char ID_SOCKET);
void          ch395_set_sour_port_sn(unsigned int port,unsigned char ID_SOCKET);
void          ch395_open_socket_sn(unsigned char ID_SOCKET);
void          ch395_tcp_connect_sn(unsigned char ID_SOCKET);
void          ch395_tcp_listen_sn(unsigned char ID_SOCKET);
unsigned int  ch395_get_recv_len_sn(unsigned char ID_SOCKET);

void          ch395_write_send_buf_sn(unsigned char *buffer, unsigned int length,unsigned char ID_SOCKET);
void          ch395_read_recv_buf_sn(unsigned char *buffer, unsigned int length,unsigned char ID_SOCKET);

void          ch395_close_socket_sn(unsigned char ID_SOCKET);
unsigned char ch395_get_int_status_sn(unsigned char ID_SOCKET);
unsigned char ch395_get_socket_status_sn(unsigned char ID_SOCKET); // return 2 bytes
unsigned char ch395_get_phy_status();
void          ch395_get_remot_ipp_sn(unsigned char *ptr, unsigned char socket);

unsigned char ch395_get_glob_int_status();
void          ch395_clear_recv_buf_sn(unsigned char socket);
void          ch395_set_fun_para(unsigned char flag);
void          ch395_tcp_disconnect_sn(unsigned char ID_SOCKET);
void          ch395_set_ttl(unsigned char ID_SOCKET, unsigned char ttl_value);

#define CH395_DETECTED                 0xaa

//void ch395_set_gwip_addr(ch395ipaddress gatewayipadress);

#define CH395_ERR_SUCCESS  0x00 /* Success*/
#define CH395_ERR_BUSY     0x10 /* Occupé, indiquant que la commande est en cours d'exécution */
#define CH395_ERR_MEM      0x11 /* Erreur de gestion de la mémoire */
#define CH395_ERR_BUF      0x12 /* Erreur de tampon */
#define CH395_ERR_TIMEOUT  0x13 /* Timeout */
#define CH395_ERR_RTE      0x14 /* Erreur de routage */
#define CH395_ERR_ABRT     0x15 /* Abandon de la connexion */
#define CH395_ERR_RST      0x16 /* Connexion réinitialisée */
#define CH395_ERR_CLSD     0x17 /* Connexion fermée */
#define CH395_ERR_CONN     0x18 /* Pas de connexion */
#define CH395_ERR_VAL      0x19 /* Mauvaise valeur */
#define CH395_ERR_ARG      0x1A /* Erreur de paramètre */
#define CH395_ERR_USE      0x1B /* Déjà utilisé */
#define CH395_ERR_IF       0x1C /* Erreur MAC */
#define CH395_ERR_ISCONN   0x1D /*  Connecté*/
#define CH395_ERR_OPEN     0x20 /* Ouvert */

#define CH395_DHCP_ENABLE_VAL  0x01
#define CH395_DHCP_DISABLE_VAL 0x00

#define CH395_DHCP_STATUS_ENABLED  0x00
#define CH395_DHCP_STATUS_DISABLED 0x01

#define CH395_SOCKET0              0
#define CH395_SOCKET1              1
#define CH395_SOCKET2              2
#define CH395_SOCKET3              3
#define CH395_SOCKET4              4
#define CH395_SOCKET5              5
#define CH395_SOCKET6              6
#define CH395_SOCKET7              7

#define CH395_PROTO_TYPE_TCP        0x03
#define CH395_PROTO_TYPE_UDP        0x02
#define CH395_PROTO_TYPE_MAC_RAW    0x01
#define CH395_PROTO_TYPE_IP_RAW     0x00

#define CH395_SINT_STAT_TIM_OUT     0x40
#define CH395_SINT_STAT_DISCONNECT  0x10

#define CH395_SINT_STAT_CONNECT     0x08
#define CH395_SINT_STAT_RECV        0x04
#define CH395_SINT_STAT_SEND_OK     0x02
#define CH395_SINT_STAT_SENBUF_FREE 0x01

#define CH395_PHY_DISCONN                   0x01
#define CH395_PHY_10M_FLL                   0x02
#define CH395_PHY_10M_HALF                  0x04
#define CH395_PHY_100M_FLL                  0x08
#define CH395_PHY_100M_HALF                 0x10

#define CH395_SOCKET_CLOSED                 0x00
#define CH395_SOCKET_OPEN                   0x05

#define CH395_TCP_CLOSED                    0x00 // Shutdown
#define CH395_TCP_LISTEN                    0x01
#define CH395_TCP_SYN_SENT                  0x02
#define CH395_TCP_SYN_REVD                  0x03
#define CH395_TCP_ESTABLISHED               0x04
#define CH395_TCP_FIN_WAIT_1                0x05
#define CH395_TCP_FIN_WAIT_2                0x06
#define CH395_TCP_CLOSE_WAIT                0x07
#define CH395_TCP_CLOSING                   0x08
#define CH395_TCP_LAST_ACK                  0x09
#define CH395_TCP_TIME_WAIT                 0x0A

#define CH395_FUN_PARA_FLAG_TCP_SERVER      0x02
#define CH395_FUN_PARA_FLAG_LOW_PWR         0x04
#define CH395_FUN_PARA_FLAG_SOCKET_CLOSE    0x08
#define CH395_FUN_PARA_FLAG_DISABLE_SEND_OK 0x10

#define CH395_GINT_STAT_DHCP                0x08
