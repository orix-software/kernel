#define AF_UNSPEC	0
#define AF_UNIX	1	/* Unix domain sockets		*/
#define AF_INET   2	/* Internet IP Protocol 	*/

/* Socket types. */
#define SOCK_STREAM	  3	/* stream (connection) socket	*/
#define SOCK_DGRAM	  2	/* datagram (conn.less) socket	*/
#define SOCK_RAW	     1	/* raw socket			*/
#define SOCK_RDM	     4	/* reliably-delivered message	*/
#define SOCK_SEQPACKET 5	/* sequential packet socket	*/
#define SOCK_PACKET    10	/* linux specific way of	*/

struct sockaddr_in {
   unsigned char sin_family;   // e.g. AF_INET
   unsigned int  sin_port;     // e.g. htons(3490)
   unsigned long sin_addr;     // see struct in_addr, below
};

struct sockaddr {
   unsigned char sa_family;      /* Address family */
   char            sa_data[];      /* Socket address */
};

/* Create a new socket of type TYPE in domain DOMAIN, using
   protocol PROTOCOL.  If PROTOCOL is zero, one is chosen automatically.
      Returns a file descriptor for the new socket, or -1 for errors.  */
unsigned char socket (unsigned char domain, unsigned char  type, unsigned char protocol);
unsigned char bind(int socket, const struct sockaddr_in* addr, unsigned int addrlen);
unsigned char listen(unsigned char socket, unsigned char backlog);
unsigned char accept(int socket, struct sockaddr_in* addr, unsigned int addrlen);


unsigned int recv(unsigned char s, void *buf, unsigned int len, unsigned char flags);
unsigned int send(unsigned char sockfd, const void buf[], unsigned int len, unsigned char flags);

unsigned int socket_close(unsigned char sockfd);

int connect(unsigned int sockfd, const struct sockaddr *addr, unsigned int addrlen);
