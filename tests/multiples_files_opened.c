#include <unistd.h>
#include <stdio.h>

extern void xexec_extern(unsigned char *str);

extern unsigned char fopen_kernel(unsigned char *str,unsigned char flag);
extern int fclose_kernel(unsigned char fd);
extern int fread_kernel(void *ptr, int  size,  unsigned char fd);
extern int fwrite_kernel(void *ptr, int size,  unsigned char fd);
extern int fseek_kernel( int offset, unsigned char whence,unsigned char fd);

unsigned char buftoto[1000];
unsigned char buftiti[1000];

void printbuf(unsigned char buf[], unsigned char length) {
    unsigned char i;
    printf("Content : ");
    for (i=0;i<length;i++) {
        printf("%c",buf[i]);
    }
    printf("\n");
}


    unsigned int nbcharreadtoto=0;
    unsigned int nbcharreadtiti=0;
int main () {
    int value=0;
    unsigned char totofp;

    unsigned char titifp;
    unsigned char toread;


    //FILE *fp;


    //printf("Value fp id : %d",value);

    totofp=fopen_kernel("toto.txt","r");
    if (totofp==0xff) {
        printf("Can not open toto.txt\n");
        return 1;
    }
    //fp=fopen("toto.txt","r");

    nbcharreadtoto=fread_kernel(buftoto, 5,  totofp);


    
    

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

    titifp=fopen_kernel("titi.txt","r");

    if (titifp==0xff) {
        printf("Can not open titi.txt\n");
        return 1;
    }

    printf("Value fp id titi.txt : %d\n",titifp);

    nbcharreadtiti=fread_kernel(buftiti, 3,  titifp);

    printf("nb bytes read titi.txt : %d\n",nbcharreadtiti);   
    printbuf(buftiti,nbcharreadtiti);
/*
    toread=2;
    printf("XXXXXXXXX toread: %d\n",toread);
    
  //  fseek_kernel( 10, SEEK_SET,totofp);

    nbcharreadtoto=fread_kernel(buftoto, 5,  totofp);

    printf("nb bytes read toto.txt : %d\n",nbcharreadtoto);  
    
    printbuf(buftoto,nbcharreadtoto);

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
