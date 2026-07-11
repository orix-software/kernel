#include <unistd.h>
#include <stdio.h>

extern void *readdir_kernel(unsigned char *str);

int main () {
    printf("Readdir\n");
    readdir_kernel("");
  
    return 0;
}
