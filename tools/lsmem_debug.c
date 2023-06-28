#include <stdio.h>

int MALLOC_BUSY_SIZE_LOW=0x570;
int MALLOC_BUSY_SIZE_HIGH=0x567;
int MALLOC_BUSY_BEGIN_HIGH=0x539;
int MALLOC_BUSY_END_HIGH=0x54b;
int MALLOC_BUSY_BEGIN_LOW=0x542;
int MALLOC_BUSY_END_LOW=0x554;
int KERNEL_MAX_NUMBER_OF_MALLOC=0x9;

int MALLOC_FREE_SIZE_HIGH=0x2ba;
int MALLOC_FREE_SIZE_LOW=0x2bf;
int MALLOC_FREE_BEGIN_HIGH=0x52a;
int MALLOC_FREE_BEGIN_LOW=0x525;
int MALLOC_FREE_END_HIGH=0x534;
int MALLOC_FREE_END_LOW=0x52f;
int KERNEL_MALLOC_FREE_CHUNK_MAX=0x5;



void print_busy(unsigned char buffer[]) {
    int i=0;
    MALLOC_BUSY_SIZE_LOW+=37;
    MALLOC_BUSY_SIZE_HIGH+=37;
    MALLOC_BUSY_BEGIN_HIGH+=37;
    MALLOC_BUSY_END_HIGH+=37;
    MALLOC_BUSY_BEGIN_LOW+=37;
    MALLOC_BUSY_END_LOW+=37;

    MALLOC_FREE_SIZE_HIGH+=37;
    MALLOC_FREE_SIZE_LOW+=37;
    MALLOC_FREE_BEGIN_HIGH+=37;
    MALLOC_FREE_BEGIN_LOW+=37;
    MALLOC_FREE_END_HIGH+=37;
    MALLOC_FREE_END_LOW+=37;

    printf("TYPE START END   SIZE PROCESS\n");

    for (i=0;i<KERNEL_MALLOC_FREE_CHUNK_MAX;i++)
        if (buffer[MALLOC_FREE_BEGIN_HIGH+i]!=0)
            printf("FREE #%02X%02X:#%02X%02X #%02X%02X X\n",buffer[MALLOC_FREE_BEGIN_HIGH+i], buffer[MALLOC_FREE_BEGIN_LOW+i], buffer[MALLOC_FREE_END_HIGH+i], buffer[MALLOC_FREE_END_LOW+i],buffer[MALLOC_FREE_SIZE_HIGH+i],buffer[MALLOC_FREE_SIZE_LOW+i]);

    for (i=0;i<KERNEL_MAX_NUMBER_OF_MALLOC;i++)
        if (buffer[MALLOC_BUSY_BEGIN_HIGH+i]!=0)
            printf("BUSY #%02X%02X:#%02X%02X #%02X%02X X\n",buffer[MALLOC_BUSY_BEGIN_HIGH+i], buffer[MALLOC_BUSY_BEGIN_LOW+i], buffer[MALLOC_BUSY_END_HIGH+i], buffer[MALLOC_BUSY_END_LOW+i],buffer[MALLOC_BUSY_SIZE_HIGH+i],buffer[MALLOC_BUSY_SIZE_LOW+i]);
}


int main() {
   FILE *fp;
   int nb;
   unsigned char buffer[100000];




   /* Open file for both reading and writing */
   fp = fopen("orix", "r");

   nb = fread(buffer, 100000, 1, fp);

   fclose(fp);

   print_busy(buffer);

   return(0);


}