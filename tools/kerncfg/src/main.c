#include "ch395.h"
#include <string.h>
#include <telestrat.h>

#include <conio.h>
unsigned char enable_dhcp;

void status() {
    
    cputsxy(2,7,"Multitasking : [ ]");
	cputsxy(2,7,"Read from : SDCARD");

}

void quit() {

}

unsigned char config () {
    unsigned char key;
    unsigned char current_menu=0;
    while (1) {
        if (current_menu==0) bgcolor(COLOR_GREEN);
        if (enable_dhcp==1)
            cputsxy(2,7,"Enable DHCP : [X]");
        else
            cputsxy(2,7,"Enable DHCP : [ ]");
        
        cclearxy (0,8,13);
        key=cgetc();
        if (key==8 || key==27 || key==9) {
            cclearxy (0,7,20);
            break;
        }
        if (key==' ') {
            if (current_menu==0) {
                if (enable_dhcp==1) 
                    enable_dhcp=0;
                else
                    enable_dhcp=1;
            }
        }
    }
    return key;
}

void menu (unsigned char current_menu) {
    
    if (current_menu==0)
        bgcolor (COLOR_RED);
    else
    {
        bgcolor (COLOR_BLACK); 
    }
    

    cputsxy(2,5,"STATUS");

    if (current_menu==1)
        bgcolor (COLOR_RED);
    else
    {
        bgcolor (COLOR_BLACK); 
    }

    cputsxy(10,5,"CONFIG");
    
    if (current_menu==2)
        bgcolor (COLOR_RED);
    else
    {
        bgcolor (COLOR_BLACK); 
    }
    
    cputsxy(18,5,"QUIT");
    
    bgcolor (COLOR_BLACK);
    gotoxy(24,5);
    cputc(' '); 
    

}

int main() {
    unsigned char version;
    unsigned char current_menu=0;
    unsigned char key;
    unsigned char validate=1;
    unsigned char redraw=1;
    clrscr();
    
    bgcolor (COLOR_BLUE);
    textcolor(COLOR_WHITE);
    gotoxy(2,1);
    cputs("+------------------------------------+");
    gotoxy(2,2);
   
    cputs("|          Kernel Config tool         |");
    gotoxy(2,3);
    cputs("+------------------------------------+");

    while (1) {
        menu(current_menu);
        if (current_menu==0) status();
		/*
        if (current_menu==1) {
            key=config();
            redraw=0;
        } 
		*/
        if (current_menu==1 && validate==0) break;
        if (validate==0) validate=1;

        if (redraw==1) 
            key=cgetc();
        else
            redraw=1;

        if (key==9) {
            if (current_menu!=2)
                current_menu++;
        }
        if (key==8) {
            if (current_menu!=0)
                current_menu--;
        }
        if (key==13)
            validate=0;

        if (key==27) break;
    }
    clrscr();

return 0;
}

