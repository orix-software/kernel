#include <unistd.h>
#include <stdio.h>

main () {
    unsigned char buf[]={'a','b','c','d'};
    FILE *fp;
    unsigned int nb;

    fp=fopen("toto.txt","w");
    nb=fwrite(buf,4,1,fp);
    printf("nb %d\n",nb);
    fclose(fp);
    
}