/*
 ============================================================================
 Name        : emc.c
 Author      : E10-Team3 dENNES
 Description : EA-LPC2478 - Some external memory controller stuff
 ============================================================================
 */

#include <stdio.h>
#include <stdlib.h>
#include "string.h"

#define m_reg_write(reg, data) ((*(volatile unsigned short *)(reg)) = (volatile unsigned short)(data))
#define m_reg_read(reg) (*(volatile unsigned short *)(reg))

int main(int argc, char *argv[]) {
	int i = 0;
	unsigned int delay = 0;
	unsigned short var = 0;

	if(strncmp("run", argv[1], 3) == 0){
		for(i=0;i<255;i++){
			for(delay = 0; delay < 40000; delay++);
			m_reg_write(0x82000020,i);
		}

		for(i=255;i>=0;i--){
			for(delay = 0; delay < 40000; delay++);
			m_reg_write(0x82000020,i);
		}
	}

	else if(strncmp("loop", argv[1], 4) == 0){
		while(1){
			//for(delay = 0; delay < 500000; delay++);
			//m_reg_write(0x82000020, (m_reg_read(0x82000040) & 0xFF));
			var = m_reg_read(0x82000040);
			printf("val: 0x%X\n", var);
			m_reg_write(0x82000020, var);		
		}
	}

	else if(strncmp("rw", argv[1], 2) == 0){
		var = m_reg_read(0x82000040);
		printf("val: 0x%X\n", var);
		m_reg_write(0x82000020, var);	
	}

	else if(strncmp("rr", argv[1], 2) == 0){
		var = m_reg_read(0x82000040);
		printf("val: 0x%X\n", var);	
	}

	else if(strncmp("irq", argv[1], 3) == 0){
		var = m_reg_read(0x82000000);
		printf("val: 0x%X\n", var);
	}

        return 0;
}

