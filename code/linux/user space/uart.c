/*
 ============================================================================
 Name        : uart.c
 Author      : E10-Team3 dENNES
 Description : EA-LPC2478 - Some uart read/write stuff
 ============================================================================
 */

#include <stdio.h>
#include <stdlib.h>
#include "string.h"

#include <fcntl.h>		/* open */
#include <unistd.h>		/* exit */
#include <sys/ioctl.h>		/* ioctl */

#include "uartioctl.h"

#define UART "/dev/uart2"

#define m_reg_write(reg, data) ((*(volatile unsigned short *)(reg)) = (volatile unsigned short)(data))
#define m_reg_read(reg) (*(volatile unsigned short *)(reg))

int main(int argc, char *argv[]) {
//        FILE *fp;
	int fd;

		// Control Register0: 0x59 (default: 0x19)
	char *setup[]={"P","Y"};	//0x50 , 0x59

	int ret_val;

	char rb[10] = {0};

/*************************** IOCTL ****************************************************/
	if(strncmp("io", argv[1], 2) == 0){
		if ((fd = open(UART,O_RDWR)) < 0){
     	          	printf("Cannot open file.\n");
			exit(-1);
        	}

		ret_val = ioctl(fd, IOCTL_DEFAULT);
		if(ret_val < 0){
			printf("ioctl_get_msg failed:%d\n", ret_val);
			exit(-1);
		}
		ret_val = ioctl(fd, IOCTL_BAUD, 19200);
		if(ret_val < 0){
			printf("ioctl_get_msg failed:%d\n", ret_val);
			exit(-1);
		}

		close(fd);
	}


	//If
	else if(strncmp("readloop", argv[1], 8) == 0){	//Open the file
		if ((fd = open(UART,O_RDONLY)) < 0){
     	          	printf("Cannot open file.\n");
			exit(-1);
        	}
		while(1){
			if(read(fd,rb,10) != 0) 
				printf("%s\n",rb);
		}
		printf("\n");
		close(fd);
	}

	else if(strncmp("read", argv[1], 4) == 0){	//Open the file
		if ((fd = open(UART,O_RDONLY)) < 0){
     	          	printf("Cannot open file.\n");
			exit(-1);
        	}
		if(read(fd,rb,10) != 0) printf("%s\n",rb);
		close(fd);
	}

	else if(strncmp("help", argv[1], 4) == 0){	//Open the file
		if ((fd = open(UART,O_RDONLY)) < 0){
     	          	printf("Cannot open file.\n");
			exit(-1);
        	}
		ret_val = ioctl(fd, IOCTL_HELP);
		if(ret_val < 0){
			printf("ioctl_get_msg failed:%d\n", ret_val);
			exit(-1);
		}
	}

	else if(strncmp("setup", argv[1], 5) == 0){	//Open the file
		if ((fd = open(UART,O_WRONLY)) < 0){
     	          	printf("Cannot open file.\n");
			exit(-1);
        	}
		ret_val = write(fd, setup[0], sizeof(setup[0]));
		if(ret_val < 0){
			printf("ioctl_get_msg failed:%d\n", ret_val);
			exit(-1);
		}
		ret_val = write(fd, setup[1], sizeof(setup[1]));
		if(ret_val < 0){
			printf("ioctl_get_msg failed:%d\n", ret_val);
			exit(-1);
		}
		close(fd);
	}
	//Write the file
	else{
		if ((fd = open(UART,O_WRONLY)) < 0){
     	          	printf("Cannot open file.\n");
			exit(-1);
        	}
		ret_val = write(fd, argv[1], sizeof(argv[1]));
		if(ret_val < 0){
			printf("ioctl_get_msg failed:%d\n", ret_val);
			exit(-1);
		}

		close(fd);
	}
        return 0;
}

