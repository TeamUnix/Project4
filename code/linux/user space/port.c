/*
 ============================================================================
 Name        : port.c
 Author      : E10-Team3 dENNES
 Description : EA-LPC2478 - Control of the power switches connected
 ============================================================================
 */

#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include "string.h"

#include <fcntl.h>		/* open */
#include <unistd.h>		/* exit */

#define GPIO "/dev/gpio"

/*
	PORT <num> <status>

	Status: in, out, off
	num: 0, 1, 2
	
	in	out
----------------------------
	4	x		PORT0
	5	7		PORT1
	6	8		PORT2
----------------------------
*/


int main(int argc, char *argv[]) {
	int fd;
	int ret;
	int num; 
	char ibuff[10];
	char obuff[10];
	char val;
	char *cmd;
	char dev[3][2];
//O_RDWR, O_WRONLY, O_RDONLY

/*************************** IOCTL ****************************************************/
	num = *argv[1]-'0';
	cmd = argv[2];

	if(num >= 0 && num <= 2){
		if(strncmp("in", cmd, 2) == 0){
			printf("\nINPUT port%d",num);
			dev[num][0] = '1';
			dev[num][1] = '0';
		}

		else if(strncmp("out", cmd, 3) == 0){
			printf("\nOUTPUT");
			dev[num][0] = '0';
			dev[num][1] = '1';
		}

		else if(strncmp("off", cmd, 3) == 0){
			dev[num][0] = '0';
			dev[num][1] = '0';
		}

		else{
			printf("\nSomething wrong");
			exit(-1);
		}

		sprintf(ibuff,"%s%d",GPIO,num+4);
		sprintf(obuff,"%s%d",GPIO,num+6);
	
		printf("\nstring: %s\n", ibuff);


		if((fd = open(ibuff,O_WRONLY)) < 0){
     	          	printf("Cannot open file in.\n");
			exit(-1);
		}		
		ret = write(fd, &dev[num][0], 1);
		if(ret < 0){
			printf("Write failed in: %d\n", ret);
			exit(-1);
		}
		else
			printf("Write in ok\n");
		close(fd);


		if(num != 0){
			if((fd = open(obuff,O_WRONLY)) < 0){
	     	          	printf("Cannot open file out.\n");
				exit(-1);
			}		
			ret = write(fd, &dev[num][1], 1);
			if(ret < 0){
				printf("Write failed out: %d\n", ret);
				exit(-1);
			}
		else
			printf("Write out ok\n");
			close(fd);
		}	





	}


        return 0;
}

