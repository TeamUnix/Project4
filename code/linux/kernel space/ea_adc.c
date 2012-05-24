/*
    This module implements a driver for LPC2468 ADC peripheral.
    Copyright (C) 2007  Embedded Artists AB (www.embeddedartists.com)

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
*/

/* #include <linux/config.h> */
#include <linux/types.h>
#include <linux/init.h>
#include <linux/fs.h>
#include <linux/module.h>
#include <linux/delay.h>
#include <linux/cdev.h>
/* #include <asm/arch/hardware.h> */
#include "lpc24xx.h"


/******************************************************************************
 * Typedefs and defines
 *****************************************************************************/


#if 0
  #define DPRINT(args...) printk(args)
#else
  #define DPRINT(args...)
#endif
#define xDPRINT(args...)

#define ADC_MAJOR 238
#define NUM_ADC_DEVICES 8

#define m_reg_read(reg) (*(volatile unsigned long *)(reg))
#define m_reg_write(reg, data) ((*(volatile unsigned long *)(reg)) = (volatile unsigned long)(data))
#define m_reg_bfs(reg, data) (*(volatile unsigned long *)(reg)) |= (data)
#define m_reg_bfc(reg, data) (*(volatile unsigned long *)(reg)) &= ~(data)



static int adc_open(struct inode* inode, 
                    struct file* file);
static int adc_close(struct inode* inode, 
                     struct file* file);
static ssize_t adc_read(struct file *p_file, 
		      char *p_buf, 
		      size_t count, 
		      loff_t *p_pos);


/******************************************************************************
 * Local variables
 *****************************************************************************/
// Module registration information
static struct file_operations adc_fops = {
  .owner   = THIS_MODULE,
  .read    = adc_read,
  .open    = adc_open,
  .release = adc_close,
};

static struct cdev* adc_cdev = NULL;

static u32 enable_bits[] =
{
  (1 << 14), // ad0.0
  (1 << 16), // ad0.1
  (1 << 18), // ad0.2
  (1 << 20), // ad0.3
  ((1 << 28) | (1 << 29)),      // ad0.4        PINSEL3
  ((1 << 30) | (1 << 31)),      // ad0.5
  ((1 << 24) | (1 << 25)),      // ad0.6        PINSEL0
  ((1 << 26) | (1 << 27))       // ad0.7
};

static u32 disable_bits[] =
{
  ((1 << 14) | (1 << 15)), // p0.23
  ((1 << 16) | (1 << 17)), // p0.24
  ((1 << 18) | (1 << 19)), // p0.25
  ((1 << 20) | (1 << 21)), // p0.26
  ((1 << 28) | (1 << 29)), // ad0.4        PINSEL3
  ((1 << 30) | (1 << 31)), // ad0.5
  ((1 << 24) | (1 << 25)), // ad0.6        PINSEL0
  ((1 << 26) | (1 << 27))  // ad0.7
};

static int chRefCnt[NUM_ADC_DEVICES];
static int endRead[NUM_ADC_DEVICES];


/******************************************************************************
 * Local functions
 *****************************************************************************/

static void adcInit(void)
{
  volatile u32 tmp = 0;

  m_reg_bfs(PCONP, (1 << 12));

  m_reg_write(AD0CR, 
          (1 << 0)                             |  //SEL = 1, dummy channel #1
          ((LPC24xx_Fpclk / 4500000) - 1) << 8 |  //set clock division factor, so ADC clock is 4.5MHz
          (0 << 16)                            |  //BURST = 0, conversions are SW controlled
          (0 << 17)                            |  //CLKS  = 0, 11 clocks = 10-bit result
          (1 << 21)                            |  //PDN   = 1, ADC is active
          (1 << 24)                            |  //START = 1, start a conversion now
          (0 << 27)                               //EDGE  = 0, not relevant when start=1
  );

  //short delay and dummy read
  mdelay(10);
  tmp = m_reg_read(AD0GDR);
}

/************************* ADC read function ************************/
static u16 adcRead(u8 channel)
{
  u16 result;

  //start conversion now (for selected channel)
  m_reg_write(AD0CR, (m_reg_read(AD0CR) & 0xFFFFFF00) | (1 << channel) | (1 << 24));

  //wait til done
  while ((m_reg_read(AD0GDR) & 0x80000000) == 0)
    ;

  //get result and adjust to 10-bit integer
  result = (m_reg_read(AD0GDR) >> 6) & 0x3FF;


  return result;
}

/************************** Convert int to str ***********************/
static int intToStr(int val, char* pBuf, int bufLen, int base)
{
  static const char* pConv = "0123456789ABCDEF";
  int num = val;
  int len = 0;
  int pos = 0;

while(num > 0)
  {
    len++;
    num /= base;
  }

  if(val == 0)
  {
    len = 1;
  }

  pos = len-1;
  num = val;

  if(pos > bufLen-1)
  {
    pos = bufLen-1;
  }

  for(; pos >= 0; pos--)
  {
    pBuf[pos] = pConv[num % base];
    num /= base;
  }

  return len;
}

/*************************** Open file for read *************************/
static int adc_open(struct inode* inode, 
                    struct file* file)
{
  int channel = 0;

 
  channel = MINOR(inode->i_rdev);

  DPRINT("adc_open %d\n", channel);

  if(channel >= NUM_ADC_DEVICES)
  {
    return -ENODEV;
  }

  if(chRefCnt[channel] == 0)
  {	
	file->private_data = (void *) channel;
	if(channel >= 0 && channel <= 3)
		m_reg_bfs(PINSEL1, enable_bits[channel]);
	else if(channel > 3 && channel < 6)
		m_reg_bfs(PINSEL3, enable_bits[channel]);
	else if(channel >= 6 && channel < 8)
		m_reg_bfs(PINSEL0, enable_bits[channel]);
  }

  chRefCnt[channel]++;

  return 0;
}

/************************** Close file after read ***********************/
static int adc_close(struct inode* inode, 
                     struct file* file)
{
  int channel = 0;

  channel = MINOR(inode->i_rdev);

  DPRINT("adc_close %d\n", channel);

if(channel >= NUM_ADC_DEVICES)
  {
    return -ENODEV;
  }

  chRefCnt[channel]--;

  if(chRefCnt[channel] == 0)
  {
	if(channel >= 0 && channel <= 3)	
		m_reg_bfc(PINSEL1, disable_bits[channel]);
	else if(channel > 3 && channel < 6)
		m_reg_bfc(PINSEL3, disable_bits[channel]);
	else if(channel >= 6 && channel < 8)
		m_reg_bfc(PINSEL0, disable_bits[channel]);
  }

  return 0;
}

/************************ Read file **************************************/
ssize_t adc_read(struct file *p_file, 
		      char *p_buf, 
		      size_t count, 
		      loff_t *p_pos)
{
  u16 res     = 0;
  size_t len  = 0;
  int channel = 0;



  channel = (int)p_file->private_data;

  DPRINT("adc_read %d file=%p, buf=%p, count=%d, off=%u\n", channel,
	p_file, p_buf, count, *p_pos);

  if(endRead[channel])
  {
    endRead[channel] = 0;
    return 0;
  }

  res = adcRead(channel);

  len = intToStr(res, p_buf+*p_pos, count, 10);
  if(len < count)
  {
    p_buf[len++] = '\n';
  }
  endRead[channel] = 1;

  return len;
}

/********************************** EXIT ADC *******************************/
static void __exit adc_mod_exit(void)
{
  dev_t dev;

  DPRINT("adc_mod_exit\n");

  dev = MKDEV(ADC_MAJOR, 0);

  cdev_del(adc_cdev);

unregister_chrdev_region(dev, NUM_ADC_DEVICES);
}

/********************************* INIT ADC *******************************/
static int __init adc_mod_init(void){
  int ret;
  dev_t dev;

  DPRINT("adc_mod_init\n");

  dev = MKDEV(ADC_MAJOR, 0);

  adcInit();

  ret = register_chrdev_region(dev, NUM_ADC_DEVICES, "adc");

  if(ret)
  {
    printk("adc: failed to register char device\n");
    return ret;
  }

  adc_cdev = cdev_alloc();

  cdev_init(adc_cdev, &adc_fops);
  adc_cdev->owner = THIS_MODULE;
  adc_cdev->ops   = &adc_fops;

  ret = cdev_add(adc_cdev, dev, NUM_ADC_DEVICES);

  if (ret)
    printk("adc: Error adding adc\n");

  return ret;
}

MODULE_LICENSE("GPL");
MODULE_AUTHOR("E10_team3_dennis <90248@hih.au.dk>");
MODULE_DESCRIPTION("\"ADC for EA2478 board!\" minimal module, no interrupt");
MODULE_VERSION("dev: 0.01");

// Define init and exit
module_init(adc_mod_init);
module_exit(adc_mod_exit);





