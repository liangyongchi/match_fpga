/**
  * @author  GND liangyongchi
  * @version V1.0.0
  * @date    20250304
  * @file    mio_gpio.c
  * @brief   MIO GPIO驱动程序
**/
#include "port_gpio.h"
#define GPIO_DEVICE_ID      XPAR_XGPIOPS_0_DEVICE_ID//宏定义GPIO_DEVICE_ID   设备的ID，如果配置了两组IO 有可能为1
XGpioPs gpiops_inst;                                // GPIO设备的驱动程序实例
/*
 * MIO初始化
 * 参数1: DeviceId 设备的ID
 * 参数2: pin      引脚号 EMIO0  XDC文件约束决定
 * 返回: u16, 0，成功；1，失败
 */
u16 MioGpioInit(void)
{
    int Status = XST_SUCCESS;
    u16 direction = 0;
    XGpioPs_Config *ConfigPtr;
    xil_printf("MioGpioInit\n\r");
    ConfigPtr = XGpioPs_LookupConfig(GPIO_DEVICE_ID);                                      //根据器件ID查找配置信息
    Status = XGpioPs_CfgInitialize(&gpiops_inst, ConfigPtr, ConfigPtr->BaseAddr);    //初始化器件驱动
    if (Status != XST_SUCCESS){
        return XST_FAILURE;
    }
    //user edit
    direction = 1;
    XGpioPs_SetDirectionPin(&gpiops_inst, LED7_PIN, direction);       //设置指定引脚的方向：0输入，1输出
    XGpioPs_SetDirectionPin(&gpiops_inst, LED8_PIN, direction);       //设置指定引脚的方向：0输入，1输出
	XGpioPs_SetDirectionPin(&gpiops_inst, PS_LED_PIN, direction);
    if (direction == 1){
    	XGpioPs_SetOutputEnablePin(&gpiops_inst, LED7_PIN, 1);  //使能指定引脚输出：0禁止输出使能，1使能输出  EMIO不需要使能
    	XGpioPs_SetOutputEnablePin(&gpiops_inst, LED8_PIN, 1);  //使能指定引脚输出：0禁止输出使能，1使能输出  EMIO不需要使能
        XGpioPs_SetOutputEnablePin(&gpiops_inst, PS_LED_PIN, 1);
    }
    return XST_SUCCESS;
}

