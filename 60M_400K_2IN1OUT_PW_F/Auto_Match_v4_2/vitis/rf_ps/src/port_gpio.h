#ifndef _PORT_GPIO_H
#define _PORT_GPIO_H

#include "xparameters.h" //
#include "xstatus.h"     //
#include "xil_printf.h"  //
#include "xgpiops.h"     //
#include "sleep.h"       //
#include "stdio.h"       //
typedef enum
{
  GPIO_PIN_RESET = 0,
  GPIO_PIN_SET
}GPIO_PinState;

typedef enum
{
  MIO0  =  0,     //MIO0
  MIO1,
  MIO2,
  MIO3,
  MIO4,
  MIO5,
  MIO6,
  MIO7,
  MIO8,
  MIO9,
  MIO10,
  MIO11,
  MIO12,
  MIO13,
  MIO14,
  MIO15,
  MIO16,
  MIO17,
  MIO18,
  MIO19,
  MIO20,
  MIO21,
  MIO22,
  MIO23,
  MIO24,
  MIO25,
  MIO26,
  MIO27,
  MIO28,
  MIO29,
  MIO30,
  MIO31,
  MIO32,
  MIO33,
  MIO34,
  MIO35,
  MIO36,
  MIO37,
  MIO38,
  MIO39,
  MIO40,
  MIO41,
  MIO42,
  MIO43,
  MIO44,
  MIO45,
  MIO46,
  MIO47,
  MIO48,
  MIO49,
  MIO50,
  MIO51,
  MIO52,
  MIO53,
}MIO_GPIO_PIN;

typedef enum
{
  EMIO0  =  54,     //EMIO0
  EMIO1,
  EMIO2,
  EMIO3,
  EMIO4,
  EMIO5,
  EMIO6,
  EMIO7,
  EMIO8,
  EMIO9,
  EMIO10,
  EMIO11,
  EMIO12,
  EMIO13,
  EMIO14,
  EMIO15,
  EMIO16,
  EMIO17,
  EMIO18,
  EMIO19,
  EMIO20,
  EMIO21,
  EMIO22,
  EMIO23,
  EMIO24,
  EMIO25,
  EMIO26,
  EMIO27,
  EMIO28,
  EMIO29,
  EMIO30,
  EMIO31,
  EMIO32,
  EMIO33,
  EMIO34,
  EMIO35,
  EMIO36,
  EMIO37,
  EMIO38,
  EMIO39,
  EMIO40,
  EMIO41,
  EMIO42,
  EMIO43,
  EMIO44,
  EMIO45,
  EMIO46,
  EMIO47,
  EMIO48,
  EMIO49,
  EMIO50,
  EMIO51,
  EMIO52,
  EMIO53,
  EMIO54,
  EMIO55,
  EMIO56,
  EMIO57,
  EMIO58,
  EMIO59,
  EMIO60,
  EMIO61,
  EMIO62,
  EMIO63
}EMIO_GPIO_PIN;

#define LED7_PIN     MIO30
#define LED8_PIN     MIO20
#define PS_LED_PIN   MIO7

extern XGpioPs gpiops_inst;
//GpioPs_ReadPin(&gpiops_inst, MIO12)
#define	Led7RunOn    {XGpioPs_WritePin(&gpiops_inst, LED7_PIN, GPIO_PIN_SET);}   //向指定引脚写入数据：0或1
#define	Led8RunOn    {XGpioPs_WritePin(&gpiops_inst, LED8_PIN, GPIO_PIN_SET);}   //向指定引脚写入数据：0或1
#define	PSLEDRunOn {XGpioPs_WritePin(&gpiops_inst, PS_LED_PIN, GPIO_PIN_SET);}

#define	Led7RunOff    {XGpioPs_WritePin(&gpiops_inst, LED7_PIN, GPIO_PIN_RESET);}
#define	Led8RunOff    {XGpioPs_WritePin(&gpiops_inst, LED8_PIN, GPIO_PIN_RESET);}
#define	PSLEDRunOff  {XGpioPs_WritePin(&gpiops_inst, PS_LED_PIN, GPIO_PIN_RESET);}

u16 MioGpioInit(void);

#endif /* _PORT_GPIO_H */
