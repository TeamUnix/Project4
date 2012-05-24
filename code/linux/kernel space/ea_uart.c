/*
*/

#include "uartioctl.h"

/* Defines and prototypes */
#include "ea_uart.h"




//#include <linux/jiffies.h>

/******************************************************************************
 * Local variables
 *****************************************************************************/
static struct file_operations uart_fops = {
	.owner   = THIS_MODULE,
	.read	 = uart_read,
	.write   = uart_write,
	.open    = uart_open,
	.ioctl	 = uart_ioctl,
	.release = uart_close,
};

struct semaphore sem;
static int flag[NUM_UART_DEVICES];
static char cread;
static DECLARE_WAIT_QUEUE_HEAD(my_queue);

static struct cdev* uart_cdev = NULL;
static int chRefCnt[NUM_UART_DEVICES];
static int endRead[NUM_UART_DEVICES];

/******************************************************************************
 * Print help
 *****************************************************************************/
static void help(void){
	int i = 0;

	printk("Available commands:\n");
    
	for(i = 0; i < sizeof(commands_help)/sizeof(char*); i++){
		printk("  %s\n", commands_help[i]);    
	}
}

/******************************************************************************
 * Interrupt recieve routine UART0
 *****************************************************************************/
static irqreturn_t interrupt_uart0(int irq, void *dev_id){
	
	cread = m_reg_read(urbr[0]);		// Read the buffer
	
	DPRINT("\nREAD VAL: %c\n", cread);	

	m_reg_bfs(VICSoftIntClear, (1<<uirq[0]));
	flag[0] = 1;
	wake_up_interruptible(&my_queue);
	return IRQ_HANDLED;
}

/******************************************************************************
 * Interrupt recieve routine UART1
 *****************************************************************************/
static irqreturn_t interrupt_uart1(int irq, void *dev_id){
	
	cread = m_reg_read(urbr[1]);		// Read the buffer
	
	DPRINT("\nREAD VAL: %c\n", cread);	
	
	m_reg_bfs(VICSoftIntClear, (1<<uirq[1]));
	flag[1] = 1;
	wake_up_interruptible(&my_queue);
	return IRQ_HANDLED;
}

/******************************************************************************
 * Interrupt recieve routine UART2
 *****************************************************************************/
static irqreturn_t interrupt_uart2(int irq, void *dev_id){
	
	cread = m_reg_read(urbr[2]);		// Read the buffer
	
	DPRINT("\nREAD VAL: %c\n", cread);		

	m_reg_bfs(VICSoftIntClear, (1<<uirq[2]));
	flag[2] = 1;
	wake_up_interruptible(&my_queue);
	return IRQ_HANDLED;
}

/******************************************************************************
 * Interrupt recieve routine UART3
 *****************************************************************************/
static irqreturn_t interrupt_uart3(int irq, void *dev_id){
	
	cread = m_reg_read(urbr[3]);		// Read the buffer
	
	DPRINT("\nREAD VAL: %c\n", cread);

	m_reg_bfs(VICSoftIntClear, (1<<uirq[3]));
	flag[3] = 1;
	wake_up_interruptible(&my_queue);
	return IRQ_HANDLED;
}

/******************************************************************************
 * Open uart
 *****************************************************************************/
static int uart_open(struct inode* inode, struct file* file){
	int ret, num = 0;

	num = MINOR(inode->i_rdev);

	DPRINT("\nUART%d open",num);
	
	if(num >= NUM_UART_DEVICES){
		return -ENODEV;
	}

	if(chRefCnt[num] == 0){
		file->private_data =(void *) num;
		if(num == 0 || num == 2 || num == 3){
			m_reg_bfs(PINSEL0, enable_pinsel[num]);
		}
		else if(num == 1){
			m_reg_bfs(PINSEL7, enable_pinsel[num]);
		}
	}
	chRefCnt[num]++;

	flag[num] = 0;
	m_reg_write(uier[num], 0x1);	//Enable interrupt on rx buf not empty
	m_reg_bfs(VICSoftIntClear, (1<<uirq[num])); // Clear interrupts from uart source
	m_reg_bfs(VICIntEnable, (1<<uirq[num]));    // Enable uart interrupt

	ret = request_irq(uirq[num], int_uart[num], SA_INTERRUPT,"UART interrupt", NULL); //NULL = Pointer based on IRC handler

	if(ret){
		printk("IRQ %d is not free. RET: %d\n", UART2_IRQ,ret);
		return ret;
	}

	return 0;
}

/******************************************************************************
 * Close uart
 *****************************************************************************/
static int uart_close(struct inode* inode, struct file* file){
	int num = 0;

	num = MINOR(inode->i_rdev);

	DPRINT("\nUART%d close",num);
	
	if(num >= NUM_UART_DEVICES){
		return -ENODEV;
	}

	chRefCnt[num]--;

	free_irq(uirq[num], NULL);

	return 0;
}

/******************************************************************************
 * Read uart
 *****************************************************************************/
static ssize_t uart_read(struct file *p_file, char *p_buf, size_t count, loff_t *p_pos){
	int num = 0;
	
	num = (int)p_file->private_data;

	DPRINT("\nread uart%d\n",num);

	if(num >= NUM_UART_DEVICES){
		return -ENODEV;
	}

	if(endRead[num]){
		endRead[num] = 0;
		return 0;
	}

	if(!(m_reg_read(ulsr[num]) & 0x01)){
		DPRINT("\nBUF EMPT, SLEEP\n");
		wait_event_interruptible(my_queue, (flag[num] != 0));	// Put the function to sleep
		flag[num] = 0;
	}
	else{
		cread = m_reg_read(urbr[num]);
	}
	*p_buf = cread;

	endRead[num] = 1;

	return count;
}


/******************************************************************************
 * IOCTL call
 *****************************************************************************/
static int uart_ioctl(struct inode *inode, struct file *filp, unsigned int cmd, unsigned long arg){
	unsigned int num = 0;
        int err = 0, ret = 0;
	int div, mult,bflag = 0;
	unsigned int baud = 0;

        /* don't even decode wrong cmds: better returning  ENOTTY than EFAULT */
        if (_IOC_TYPE(cmd) != UART_IOC_MAGIC) return -ENOTTY;
        if (_IOC_NR(cmd) > UART_IOC_MAXNR) return -ENOTTY;

        /*
         * the type is a bitmask, and VERIFY_WRITE catches R/W
         * transfers. Note that the type is user-oriented, while
         * verify_area is kernel-oriented, so the concept of "read" and
         * "write" is reversed
         */
        if (_IOC_DIR(cmd) & _IOC_READ) err = !access_ok(VERIFY_WRITE, (void __user *)arg, _IOC_SIZE(cmd));
        else if (_IOC_DIR(cmd) & _IOC_WRITE) err =  !access_ok(VERIFY_READ, (void __user *)arg, _IOC_SIZE(cmd));
        if (err) return -EFAULT;
	// Get minor number
	num = MINOR(inode->i_rdev);
	DPRINT("\nuart%d_ioctl, ioctl_cmd: %u\n",num,cmd);
	// Check if minor number is okay
	if(num >= NUM_UART_DEVICES){
		return -ENODEV;
	}

	switch (cmd) {
	/***************************** HELP ************************************************/
	case IOCTL_HELP:
	    DPRINT("\nHELP\n");
	    help();	// Print different IOCTL call options to user
	  break;
	/***************************** DEFAULT *********************************************/
	case IOCTL_DEFAULT:
	    m_reg_write(ulcr[num], 0x80);	// Enable write to divisor latch
	    m_reg_write(udll[num], (unsigned char)((LPC24xx_Fpclk/(16*9600)) & 0xFF));
	    m_reg_write(udlm[num], (unsigned char)((LPC24xx_Fpclk/(16*9600)) >> 8));
	    m_reg_write(ulcr[num], 0x03);	// 8N1 setup and disable write to divisor latch
	    m_reg_write(ufcr[num], 0x7);	// Enable FIFO's
	  break;
	/***************************** BAUD ************************************************/
	case IOCTL_BAUD:
	    if(arg < 2400 || arg > 230400){	// Verify argument
		printk("\nInvalid parameter");
		return -EFAULT;
	    }
	    bflag = 0;	
	/* From datasheet:
	   Mult values: 1-15, Div: 0-14. Mult shall be bigger than div.
	   DLL shall be above 2 if DLM is zero.

	*/ 
	   // Loop through different div and mult values in order to get a integer value to
	   // the divisor latch reg (DLM+DLL).
	    for(div = 0; div <= 15; div++){
		for(mult = div+1; mult <= 15; mult++){
		    baud = ((16*arg)+((16*arg*div)/mult));
		    if(LPC24xx_Fpclk%baud == 0){
			if((div != 0) && ((LPC24xx_Fpclk/baud) >= 3)){
			    bflag = 1;
			    break;
			}
		    }
		}
		if(bflag==1) break;
	    }
	    DPRINT("\ndiv: %d, mult: %d, baud: %d",div,mult,baud);
	    if(div == 15){	// If no value was found, return error
		printk("\nCannot calculate BAUD!");
		return -EFAULT;
	    }
	    m_reg_bfs(ulcr[num], 0x80); // Enable write to divisor latch
	    m_reg_write(ufdr[num], ((div<<0) | (mult<<4)));	// Write div and mult to fraction dividor reg
	    m_reg_write(udll[num], (unsigned char)((LPC24xx_Fpclk/baud) & 0xFF)); // Input DLL val (8 lowest bits)
	    m_reg_write(udlm[num], (unsigned char)((LPC24xx_Fpclk/baud) >> 8));	  // Input DLM val (8 highest bits)
	    m_reg_bfc(ulcr[num], 0x80);	// Disable write to divisor latch

	  break;
	/***************************** Wordlen *********************************************/
	case IOCTL_WORDLEN:
	    if(arg < 5 || arg > 8){	// Verify that argument is valid
		printk("\nInvalid parameter");
		return -EFAULT;
	    }
	    m_reg_bfc(ulcr[num], 0x3);	// Clear bits holding world lenght
	    m_reg_bfs(ulcr[num], ((arg-5)<<0));	// Inset value for world lenght
	  break;
	/***************************** STOP bits *******************************************/
	case IOCTL_STOPBIT:
	    if(arg != 1 || arg != 2){	// Verify that argument is valid
		printk("\nInvalid parameter");
		return -EFAULT;
	    }
	    m_reg_bfc(ulcr[num], (1<<2)); // Set stop bit to 1
	    if(arg == 2){
	    	m_reg_bfs(ulcr[num], (1<<2)); // Set stop bit to 2
	    }
	  break;
	/***************************** Parity Bit ******************************************/
	case IOCTL_PARBIT:	
	    if(arg < 0 || arg > 4){ // Verify that argument is valid
		printk("\nInvalid parameter");
		return -EFAULT;
	    }
	    m_reg_bfc(ulcr[num], (1<<3));	// Disable parity bits. if 0 was written
	    if(arg > 0){
		m_reg_bfs(ulcr[num], (1<<3));	// Enable parity.
		m_reg_bfs(ulcr[num], ((arg-1)<<4)); // Set parity (odd, even, forced 0 or 1
	    }
	  break;
	/***************************** FIFO Enable *****************************************/
	case IOCTL_FIFO:
	    if(arg != 0 || arg != 1){ // Verify that argument is valid
		printk("\nInvalid parameter");
		return -EFAULT;
	    }
	    m_reg_bfc(ufcr[num], 0x7);	// Disable fifo
	    if(arg==1){
		m_reg_bfs(ufcr[num], 0x7);	// Enable fifo
	    }
	  break;	
	/***************************** FIFO Enable *****************************************/
	case IOCTL_FIFO_TRIG:
	    if(arg != 1 || arg != 4 || arg != 8 || arg != 14){	// Verify that argyment is valid
		printk("\nInvalid parameter");
		return -EFAULT;
	    }
	    m_reg_bfc(ufcr[num], 0xC0);	// Clear bits holding trigger level
	    m_reg_bfs(ufcr[num], (int)((arg/4)<<6));	// 1/4=0, 4/4=1, 8/4=2, 14/4=3
	  break;	
	/***************************** Wrong ***********************************************/
	default:
	    help();	// If wrong parameter sent. Print options. 
	    return -ENOTTY;
	}

        return ret;
}

/******************************************************************************
 * Write uart
 *****************************************************************************/
static ssize_t uart_write(struct file *filp, const char *bufp, size_t count, loff_t *p_pos){
	unsigned int num;	
	int ecnt = 0;

	num = (unsigned int)filp->private_data;
	
	if(num >= NUM_UART_DEVICES){
		return -ENODEV;
	}

	DPRINT("\nuart%d_write count=%d", num, count);

	while(!(m_reg_read(ulsr[num]) & 0x20)){
		ecnt++;
		if(ecnt > 100)
		return -ENODEV;
	}
	DPRINT("\nsendval: %c\n",*bufp);

	m_reg_write(uthr[num], *bufp);

	return count;
}

/******************************************************************************
 * Exit uart
 *****************************************************************************/
static void __exit uart_mod_exit(void)
{
	dev_t dev;

	DPRINT("\nuart_mod_exit\n");

	dev = MKDEV(UART_MAJOR, 0);

	cdev_del(uart_cdev);

	unregister_chrdev_region(dev, NUM_UART_DEVICES);
}

/******************************************************************************
 * Initialize uart
 *****************************************************************************/
static int __init uart_mod_init(void){
	int ret;
	dev_t dev;

	DPRINT("\nuart_mod_init\n");

	dev = MKDEV(UART_MAJOR, 0);

	//Enable power to UART2 & UART3 clock
	m_reg_bfs(PCONP, 0x03000000); 
	
	ret = register_chrdev_region(dev, NUM_UART_DEVICES, "uart");

	if(ret){
		printk("uart: failed to register char device\n");
		return ret;
	}

	uart_cdev = cdev_alloc();

	cdev_init(uart_cdev, &uart_fops);
	uart_cdev->owner = THIS_MODULE;
	uart_cdev->ops   = &uart_fops;

	ret = cdev_add(uart_cdev, dev, NUM_UART_DEVICES);

	if(ret){
		printk("uart: Error adding\n");
	}
	
	return ret;
}


MODULE_LICENSE("GPL");
MODULE_AUTHOR("E10_team3_dennis <90248@hih.au.dk>");
MODULE_DESCRIPTION("\"UART for EA2478 board!\" minimal module. Interrupt controlled read");
MODULE_VERSION("dev: 0.20");

// Define init and exit
module_init(uart_mod_init);
module_exit(uart_mod_exit);




