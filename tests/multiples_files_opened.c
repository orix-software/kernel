#include <unistd.h>
#include <stdio.h>

// extern void xexec_extern(unsigned char *str);

// extern unsigned char fopen_kernel(unsigned char *str,unsigned char flag);
// extern int fclose_kernel(unsigned char fd);
// extern int fread_kernel(void *ptr, int  size,  unsigned char fd);
// extern int fwrite_kernel(void *ptr, int size,  unsigned char fd);
// extern int fseek_kernel( int offset, unsigned char whence,unsigned char fd);

unsigned char buftoto[1000];
unsigned char buftiti[1000];

void printbuf(unsigned char buf[], unsigned char length) {
    unsigned char i;
    printf("Content : #");
    for (i=0;i<length;i++) {
        printf("%c",buf[i]);
    }
    printf("#\n");
}


    unsigned int nbcharreadtoto=0;
    unsigned int nbcharreadtiti=0;

int main () {
    int value=0;
    unsigned char toread;


    FILE *fp1;
    FILE *fp2;
    FILE *fp3;

    fp1=fopen("toto.txt","r");
    if (fp1==NULL) {
        printf("Can not open toto.txt fp1\n");
        return 1;
    }
    fp2 = fopen("toto.txt","r");

    if (fp2==NULL) {
        printf("Can not open toto.txt fp2\n");
        return 1;
    }

    fp3 = fopen("toto.txt","r");

    if (fp3==NULL) {
        printf("Can not open toto.txt fp3\n");
        return 1;
    }


    //fp=fopen("toto.txt","r");

    nbcharreadtoto = fread(buftoto, 5, 1,  fp1);

    printf("nb bytes read toto.txt : %d\n",nbcharreadtoto);
    printbuf(buftoto,nbcharreadtoto);
    //xexec_extern("lsmem");
  /*
    //fseek_kernel( 0, SEEK_SET,totofp);

    nbcharreadtoto=fread_kernel(buftoto, 20,  totofp);

    printf("nb bytes read toto.txt (second) : %d\n",nbcharreadtoto); 

    printbuf(buftoto,nbcharreadtoto);


    nbcharreadtoto=fread_kernel(buftoto, 5,  totofp);

    printf("nb bytes read toto.txt (third) : %d\n",nbcharreadtoto); 

    printbuf(buftoto,nbcharreadtoto);


    printf("Value fp id toto.txt : %d\n",totofp);
*/



    printf("Value fp id titi.txt : %d\n",fp2);

    nbcharreadtiti=fread(buftiti, 3, 1, fp2);

    printf("nb bytes read titi.txt : %d\n",nbcharreadtiti);
    printbuf(buftiti,nbcharreadtiti);

    toread=2;
    printf("XXXXXXXXX toread: %d\n",toread);

    fseek(  2, SEEK_CUR,fp1);

    nbcharreadtoto=fread(buftoto, 5, 1, fp1);

    printf("nb bytes read toto.txt : %d\n",nbcharreadtoto);

    printbuf(buftoto,nbcharreadtoto);
/*
    fseek_kernel( 2, SEEK_SET,totofp);

    nbcharreadtoto=fread_kernel(buftoto, 5,  totofp);

    printf("nb bytes read toto.txt : %d\n",nbcharreadtoto);  
    
    printbuf(buftoto,nbcharreadtoto);



   // fseek_kernel( 0, SEEK_SET,totofp);

    nbcharreadtoto=fread_kernel(buftoto, 5,  totofp);

    printf("nb bytes read toto.txt : %d\n",nbcharreadtoto);  
    
    printbuf(buftoto,nbcharreadtoto);



    fseek_kernel( 1, SEEK_CUR,titifp);


    nbcharreadtiti=fread_kernel(buftiti, 20,  titifp);

    printf("nb bytes read titi.txt : %d\n",nbcharreadtiti);   

    printbuf(buftiti,nbcharreadtiti);

    //unsigned char buf[]={'a','b','c','d'};
    //FILE *fp;
    //unsigned int nb;

    //fp=fopen("toto.txt","w");
    //nb=fwrite(buf,4,1,fp);
    //printf("nb %d\n",nb);
    //fclose(fp);
    */
    return 0;
}
