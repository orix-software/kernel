#include <stdio.h>
#include <unistd.h>

main() {
    char buf[100];
    printf("\n%s\n",getcwd(buf,100));
}