/*
 *  ea_uart.h - the header file with the ioctl definitions.
 *
 *  The declarations here have to be in a header file, because
 *  they need to be known both to the kernel module
 *  (in chardev.c) and the process calling ioctl (ioctl.c)
 */

#ifndef EA_UART_H
#define EA_UART_H

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

#define UART_MAJOR 239
#define NUM_UART_DEVICES 4

#define UART0_IRQ 6
#define UART1_IRQ 7
#define UART2_IRQ 28
#define UART3_IRQ 29

#define m_reg_read(reg) (*(volatile unsigned long *)(reg))
#define m_reg_write(reg, data) ((*(volatile unsigned long *)(reg)) = (volatile unsigned long)(data))
#define m_reg_bfs(reg, data) (*(volatile unsigned long *)(reg)) |= (data)
#define m_reg_bfc(reg, data) (*(volatile unsigned long *)(reg)) &= ~(data)

/******************************************************************************
 * Prototypes
 *****************************************************************************/
static int uart_open(struct inode* inode, struct file* file);
static int uart_close(struct inode* inode, struct file* file);
static ssize_t uart_write(struct file *p_file, const char *p_buf, size_t count, loff_t *p_pos);
static ssize_t uart_read(struct file *p_file, char *p_buf, size_t count, loff_t *p_pos);
static int uart_ioctl(struct inode *inode, struct file *filp, unsigned int cmd, unsigned long arg);

static irqreturn_t interrupt_uart0(int irq, void *dev_id);
static irqreturn_t interrupt_uart1(int irq, void *dev_id);
static irqreturn_t interrupt_uart2(int irq, void *dev_id);
static irqreturn_t interrupt_uart3(int irq, void *dev_id);

typedef irqreturn_t (*INTERRUPT_UART)(int irq, void *dev_id);

const INTERRUPT_UART int_uart[NUM_UART_DEVICES] = {interrupt_uart0, interrupt_uart1, interrupt_uart2, interrupt_uart3};

//static irqreturn_t (*interrupt_uart[NUM_UART_DEVICES])(int irq, void *dev_id);

/******************************************************************************
 * Arrays
 *****************************************************************************/
static char* commands_help[] = {
	"IOCTL_HELP : show different help commands",
	"IOCTL_DEFAULT : 8N1, 9600 baud",
	"IOCTL_BAUD : send argument between 2400 and 230400",
	"IOCTL_WORDLEN : send argument 5-8 wordlenght",
	"IOCTL_STOPBIT : send argument, 1 or 2 stop bits", 
	"IOCTL_PARBIT : send arg, 0, 1(odd), 2(even), 3(Forced 1 stick), 4(Forced 0 stick",
	"IOCTL_FIFO : send arg 0 (off), 1 (on)",
	"IOCTL_FIFO_TRIG : send arg number to trig, 1, 4, 8 or 14 characters",
};

static u32 enable_pinsel[] ={
        ((1 << 4)  | (1 << 6)),				// uart0 - PINSEL0
        ((1 << 0)  | (1 << 1) | (1 << 2) | (1 << 3)),	// uart1 - PINSEL7      
        ((1 << 20) | (1 << 22)),			// uart2 - PINSEL0
        ((1 << 1)  | (1 << 3)),				// uart3 - PINSEL0
};

static u32 uthr[] ={
        U0THR,	// uart0
        U1THR,	// uart1
        U2THR,	// uart2
        U3THR,	// uart3
};

static u32 urbr[] ={
        U0RBR,	// uart0
        U1RBR,	// uart1
        U2RBR,	// uart2
        U3RBR,	// uart3
};

static u32 ulsr[] ={
        U0LSR,	// uart0
        U1LSR,	// uart1
        U2LSR,	// uart2
        U3LSR,	// uart3
};

static u32 ulcr[] ={
        U0LCR,	// uart0
        U1LCR,	// uart1
        U2LCR,	// uart2
        U3LCR,	// uart3
};

static u32 uier[] ={
        U0IER,	// uart0
        U1IER,	// uart1
        U2IER,	// uart2
        U3IER,	// uart3
};

static u32 ufcr[] ={
        U0FCR,	// uart0
        U1FCR,	// uart1
        U2FCR,	// uart2
        U3FCR,	// uart3
};

static u32 ufdr[] ={
        U0FDR,	// uart0
        U1FDR,	// uart1
        U2FDR,	// uart2
        U3FDR,	// uart3
};


static u32 uirq[] ={
        UART0_IRQ,	// uart0
        UART1_IRQ,	// uart1
        UART2_IRQ,	// uart2
        UART3_IRQ,	// uart3
};

static u32 udll[] ={
        U0DLL,	// uart0
        U1DLL,	// uart1
        U2DLL,	// uart2
        U3DLL,	// uart3
};

static u32 udlm[] ={
        U0DLM,	// uart0
        U1DLM,	// uart1
        U2DLM,	// uart2
        U3DLM,	// uart3
};

#endif

