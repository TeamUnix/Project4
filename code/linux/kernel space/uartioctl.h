/*
 *  uartioctl.h - the header file with the ioctl definitions.
 *
 *  The declarations here have to be in a header file, because
 *  they need to be known both to the kernel module
 *  (in chardev.c) and the process calling ioctl (ioctl.c)
 */

#ifndef UARTIOCTL_H
#define UARTIOCTL_H

#include <linux/ioctl.h>

#define UART_IOC_MAGIC  'K'

#define IOCTL_HELP 	_IO(UART_IOC_MAGIC,  1)
#define IOCTL_DEFAULT	_IO(UART_IOC_MAGIC,  2)
#define IOCTL_BAUD 	_IOR(UART_IOC_MAGIC, 3, int)
#define IOCTL_WORDLEN 	_IOR(UART_IOC_MAGIC, 4, int)
#define IOCTL_STOPBIT 	_IOR(UART_IOC_MAGIC, 5, int)
#define IOCTL_PARBIT 	_IOR(UART_IOC_MAGIC, 6, int)
#define IOCTL_FIFO	_IOR(UART_IOC_MAGIC, 7, int)
#define IOCTL_FIFO_TRIG _IOR(UART_IOC_MAGIC, 8, int)

#define UART_IOC_MAXNR 8

#endif

