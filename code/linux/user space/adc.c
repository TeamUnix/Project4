/*
 ============================================================================
 Name        : adc.c
 Author      : E10-Team3 Fontex
 Description : EA-LPC2478 - Reads the ADC value from the select channel and converts it to understandable number from 0 to 3.3V
 ============================================================================
 */

#include <stdio.h>
#include <stdlib.h>
#include "string.h"

#define ADC "/dev/adc"

void bitConversion(int value){

        char str[10];

        if((value%100)>9){
                sprintf(str, "%i.%i",value/100,value%100);
        } else {
                sprintf(str, "%i.0%i",value/100,value%100);
        }

        printf("%s\n",str);

}
int main(int argc, char *argv[]) {

        FILE *fp;
        char read[10];

	int num = atoi(argv[1]);
	int ref = atoi(argv[2]);

        if ((fp = fopen(strcat(ADC,argv[1]),"rb"))==NULL){
        //if ((fp = fopen("test.txt","r"))==NULL){
                printf("Cannot open file.\n");
                exit(0);
        }

        //fgets(read,20,fp);

        fread(read,1,10,fp);

        //printf("%s\n",read);

        bitConversion(atoi(read)*(ref)/10230);

        fclose(fp);

        return 0;
}

