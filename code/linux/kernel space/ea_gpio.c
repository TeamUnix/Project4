/*
*/

/* Defines and prototypes */
#include "ea_gpio.h"


//#include <linux/jiffies.h>

/******************************************************************************
 * Local variables
 *****************************************************************************/
static struct file_operations gpio_fops = {
	.owner   = THIS_MODULE,
	.read	 = gpio_read,
	.write   = gpio_write,
	.open    = gpio_open,
	.release = gpio_close,
};

struct semaphore sem;
static int flag;
static DECLARE_WAIT_QUEUE_HEAD(my_queue);

static struct cdev* gpio_cdev = NULL;

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
 * Gpio Init
 *****************************************************************************/
static void gpioInit(void){
	int i=0;
	m_reg_bfs(SCS, 0x1);	// Enable fast I/O on port 0 and 1
	for(i=0 ; i<NUM_GPIO_DEVICES ; i++){
		m_reg_bfc(psel[i], enable_pinsel[i]);
		if(i != 3){
			m_reg_bfs(fdir[i], gpio_pins[i]);
			m_reg_bfs(pin_default_reg[i], gpio_pins[i]);
		}
	}
}

/******************************************************************************
 * Interrupt recieve routine GPIO0
 *****************************************************************************/
static irqreturn_t interrupt_gpio(int irq, void *dev_id){
	
//	cread = m_reg_read(urbr[0]);		// Read the buffer
	
	DPRINT("\nREAD int\n");	

	m_reg_bfs(EXTINT, 1);		// clear pending INT0 interrupts
	flag = 1;
	wake_up_interruptible(&my_queue);
	return IRQ_HANDLED;
}

/******************************************************************************
 * Open gpio
 *****************************************************************************/
static int gpio_open(struct inode* inode, struct file* file){
	int ret, num = 0;

	num = MINOR(inode->i_rdev);

	DPRINT("\nGPIO%d open",num);
	
	if(num >= NUM_GPIO_DEVICES){
		return -ENODEV;
	}

	file->private_data =(void *) num;

	if(num == 3){
		// setup interrupt for pin input
		DPRINT("\nEnable int for input");
		flag = 0;
		m_reg_bfs(EXTMODE, 1);		// INT0 Edge sensitive
		m_reg_bfc(EXTPOLAR, 1);		// falling edge 
		m_reg_bfs(EXTINT, 1);		// clear pending INT0 interrupts

		ret = request_irq(GPIO_IRQ, interrupt_gpio, SA_INTERRUPT,"GPIO P2.10 interrupt", NULL);
					//SA_SHIRQ 	= Shared interrupt
					//SA_INTERRUPT 	= Fast interrupt
	
		if(ret){
			printk("IRQ%d is not free. RET: %d\n", GPIO_IRQ, ret);		
			return ret;
		}
	}

	return 0;
}

/******************************************************************************
 * Close gpio
 *****************************************************************************/
static int gpio_close(struct inode* inode, struct file* file){
	int num = 0;

	num = MINOR(inode->i_rdev);

	DPRINT("\nGPIO%d close",num);
	
	if(num >= NUM_GPIO_DEVICES){
		return -ENODEV;
	}

	if(num == 3){
		free_irq(GPIO_IRQ, NULL);
	}

	return 0;
}

/******************************************************************************
 * Read gpio
 *****************************************************************************/
static ssize_t gpio_read(struct file *p_file, char *p_buf, size_t count, loff_t *p_pos){
	int num = 0;
	char value[count];

	num = (int)p_file->private_data;

	DPRINT("\nread gpio%d\n",num);

	if(num >= NUM_GPIO_DEVICES){
		return -ENODEV;
	}

	if(endRead[num]){
		endRead[num] = 0;
		return 0;
	}

	if(num == 3){
		if((m_reg_read(pin_read[num]) & gpio_pins[num]) > 0){
			DPRINT("\nNo interrupt from FPGA, SLEEP!\n");
			m_reg_bfs(PINSEL4, (1<<20));				// Set p2.10 to EINT0
			wait_event_interruptible(my_queue, (flag != 0));	// Put the function to sleep		
			flag = 0;
		}
		value[0] = '0';
	}
	else{
		DPRINT("\nREAD ELSE");
		if((m_reg_read(pin_read[num]) & gpio_pins[num]) > 0){
			value[0] = '1';
		}
		else{
			value[0] = '0';
		}
	}

	if(copy_to_user(p_buf, value, count)){
		DPRINT("\nFailed: copy_to_user");
		return -EFAULT;
	}

	endRead[num] = 1;

	return 1;
}

/******************************************************************************
 * Write gpio
 *****************************************************************************/
static ssize_t gpio_write(struct file *filp, const char *bufp, size_t count, loff_t *p_pos){
	unsigned int num;
	char value[count];
	num = (unsigned int)filp->private_data;
	
	if(num >= NUM_GPIO_DEVICES){
		return -ENODEV;
	}

	if(copy_from_user(value, bufp, count)){
		return -EFAULT;
	}

	DPRINT("\ngpio%d_write count=%d, buf: %c", num, count, value[0]);

	if(value[0] == '0'){
		//FIO_CLEAR
		DPRINT("\nCLEAR PIN");
		m_reg_bfs(pin_clear[num], gpio_pins[num]);
	}
	else if(value[0] == '1'){
		//FIO_SET
		DPRINT("\nSET PIN");
		m_reg_bfs(pin_set[num], gpio_pins[num]);
	}
	else{
		DPRINT("\nNot a valid character");
		return -EFAULT;
	}

	return count;
}

/******************************************************************************
 * Exit gpio
 *****************************************************************************/
static void __exit gpio_mod_exit(void){
	dev_t dev;

	DPRINT("\ngpio_mod_exit\n");

	dev = MKDEV(GPIO_MAJOR, 0);

	cdev_del(gpio_cdev);

	unregister_chrdev_region(dev, NUM_GPIO_DEVICES);
}

/******************************************************************************
 * Initialize gpio
 *****************************************************************************/
static int __init gpio_mod_init(void){
	int ret;
	dev_t dev;

	DPRINT("\ngpio_mod_init\n");

	gpioInit();

	dev = MKDEV(GPIO_MAJOR, 0);

	ret = register_chrdev_region(dev, NUM_GPIO_DEVICES, "gpio");

	if(ret){
		printk("gpio: failed to register char device\n");
		return ret;
	}

	gpio_cdev = cdev_alloc();

	cdev_init(gpio_cdev, &gpio_fops);
	gpio_cdev->owner = THIS_MODULE;
	gpio_cdev->ops   = &gpio_fops;

	ret = cdev_add(gpio_cdev, dev, NUM_GPIO_DEVICES);

	if(ret){
		printk("gpio: Error adding\n");
	}
	
	return ret;
}


MODULE_LICENSE("GPL");
MODULE_AUTHOR("E10_team3_dennis <90248@hih.au.dk>");
MODULE_DESCRIPTION("\"GPIO for EA2478 board!\" minimal module. Interrupt controlled read");
MODULE_VERSION("dev: 0.20");

// Define init and exit
module_init(gpio_mod_init);
module_exit(gpio_mod_exit);




