#include <stdio.h>

main() {
    FILE *fp;

    fp=fopen("/bin/file","r")
    if (fp==null) {
        printf("Error opened");
        exit();
    }

    fseek(fp,10,SEEK_SET);

}