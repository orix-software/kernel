#include <stdio.h>

void *realloc_kernel(void *ptr, int size);

void *malloc_kernel(int size);

void system_kernel(char *str);

int main() {
    unsigned char *mystr;

//    printf("Realloc test\n");
//    mystr = malloc_kernel(100);
//    printf("Address after malloc_kernel: %p\n", mystr);

//     mystr = realloc_kernel(mystr, 90);
    
//     if (mystr == NULL)
//         printf("Error NULL\n");
//     else    
//         printf("Address after realloc_kernel: %p\n", mystr);

}