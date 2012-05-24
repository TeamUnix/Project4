/*
 *  ea_gpio.h - the header file with the ioctl definitions.
 *
 *  The declarations here have to be in a header file, because
 *  they need to be known both to the kernel module
 *  (in chardev.c) and the process calling ioctl (ioctl.c)
 */

#ifndef EA_GPIO_H
#define EA_GPIO_H

/* #include <linux/config.h> */
#include <linux/types.h>
#include <linux/init.h>
#include <linux/fs.h>
#include <linux/module.h>
//#include <linux/delay.h>
#include <linux/cdev.h>
#include <linux/interrupt.h>
#include <asm/semaphore.h>
#include <linux/wait.h>
	/* #include <asm/arch/hardware.h> */
#include <asm/uaccess.h>

#include "lpc24xx.h"

/******************************************************************************
 * Typedefs and defines
 *****************************************************************************/
#if 0
  #define DPRINT(args...) printk(args)
#else
  #define DPRINT(args...)
#endif

#define GPIO_MAJOR 245
#define NUM_GPIO_DEVICES 9

#define GPIO_IRQ 14

#define m_reg_read(reg) (*(volatile unsigned long *)(reg))
#define m_reg_write(reg, data) ((*(volatile unsigned long *)(reg)) = (volatile unsigned long)(data))
#define m_reg_bfs(reg, data) (*(volatile unsigned long *)(reg)) |= (data)
#define m_reg_bfc(reg, data) (*(volatile unsigned long *)(reg)) &= ~(data)

/******************************************************************************
 * Prototypes
******************************************************************************/
static int gpio_open(struct inode* inode, struct file* file);
static int gpio_close(struct inode* inode, struct file* file);
static ssize_t gpio_write(struct file *p_file, const char *p_buf, size_t count, loff_t *p_pos);
static ssize_t gpio_read(struct file *p_file, char *p_buf, size_t count, loff_t *p_pos);
static irqreturn_t interrupt_gpio(int irq, void *dev_id);

static int endRead[NUM_GPIO_DEVICES];

/******************************************************************************
 * Arrays
 *****************************************************************************/
static char* commands_help[] = {
	"GPIO0	0.12	PLC_nReset	Output",
	"GPIO1	0.13	PLC_wake	Output",
	"GPIO2	0.18	PLC_nSleep	Output",
	"GPIO3	2.10	FPGA_int	Input interruptable",
	"GPIO4	1.6	PS_main		Output",
	"GPIO5	1.23	PS1_in		Output",
	"GPIO6	1.25	PS2_in		Output",
	"GPIO7	1.19	PS1_out		Output",
	"GPIO8	1.21	PS2_out		Output",
};

/*
GPIO0	0.12	PLC_nReset	Output
GPIO1	0.13	PLC_wake	Output
GPIO2	0.18	PLC_nSleep	Output
GPIO3	2.10	FPGA_int	Input interruptable
GPIO4	1.6	PS_main		Output
GPIO5	1.23	PS1_in		Output
GPIO6	1.25	PS2_in		Output
GPIO7	1.19	PS1_out		Output
GPIO8	1.21	PS2_out		Output
*/

static u32 enable_pinsel[] ={
        ((1 << 24) | (1 << 25)),	// GPIO0 pinsel0
        ((1 << 26) | (1 << 27)),	// GPIO1 pinsel0
        ((1 << 4)  | (1 << 5)),		// GPIO2 pinsel1
        ((1 << 20) | (1 << 21)),	// GPIO3 pinsel1
        ((1 << 12) | (1 << 13)),	// GPIO4 pinsel7
        ((1 << 14) | (1 << 15)),	// GPIO5 pinsel7
        ((1 << 18) | (1 << 19)),	// GPIO6 pinsel7
        ((1 << 6)  | (1 << 7)),		// GPIO7 pinsel7
        ((1 << 10) | (1 << 11)),	// GPIO8 pinsel7
};

static u32 psel[] ={
        PINSEL0,
        PINSEL0,
        PINSEL1,
        PINSEL4,
	PINSEL2,
	PINSEL3,
	PINSEL3,
	PINSEL3,
	PINSEL3,
};

static u32 gpio_pins[] ={
	(1<<12),
	(1<<13),
	(1<<18),
	(1<<10),
	(1<<6),
	(1<<23),
	(1<<25),
	(1<<19),
	(1<<21),
};

static u32 fdir[] ={
	FIO0DIR,
	FIO0DIR,
	FIO0DIR,
	FIO2DIR,
	FIO1DIR,
	FIO1DIR,
	FIO1DIR,
	FIO1DIR,
	FIO1DIR,
};

static u32 pin_default_reg[] ={
	FIO0SET,
	FIO0SET,
	FIO0SET,
	FIO2SET,
	FIO1SET,
	FIO1CLR,
	FIO1CLR,
	FIO1CLR,
	FIO1CLR,
};

static u32 pin_set[] ={
	FIO0SET,
	FIO0SET,
	FIO0SET,
	FIO2SET,
	FIO1SET,
	FIO1SET,
	FIO1SET,
	FIO1SET,
	FIO1SET,
};

static u32 pin_clear[] ={
	FIO0CLR,
	FIO0CLR,
	FIO0CLR,
	FIO2CLR,
	FIO1CLR,
	FIO1CLR,
	FIO1CLR,
	FIO1CLR,
	FIO1CLR,
};

static u32 pin_read[] ={
	FIO0PIN,
	FIO0PIN,
	FIO0PIN,
	FIO2PIN,
	FIO1PIN,
	FIO1PIN,
	FIO1PIN,
	FIO1PIN,
	FIO1PIN,
};

#endif

