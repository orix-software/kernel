#include <stdio.h>

extern void xexec_extern(unsigned char * command);

main() {
    xexec_extern("lsmem");
}