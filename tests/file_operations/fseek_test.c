#include <stdio.h>
#include <stdlib.h>
#include <peekpoke.h>

int main() {
    FILE *fp;
    unsigned int result;
    long position;

    //return 1;
    // Open a file for reading
    fp = fopen("/bin/file", "r");
    if (fp == NULL) {
        printf("Error opened");
        exit(1);
    }

    result = fseek(fp, 10, SEEK_SET);
    if (result != 0) {
        fclose(fp);
        printf("fseek failed \n");
        return 1; // error fseek
    }
    else {
        printf("fseek succeeded\n");
        position = ftell(fp);
        printf("Position fseek : %ld\n", position);
        if (position != 10) {
            printf("return value for ftell is wrong\n");
            fclose(fp);
            return 2; // Exit with error code
        }
    }

    fclose(fp);
    return 0; // Exit with success code
}
