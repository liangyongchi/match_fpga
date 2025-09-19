/**
  * @author  GND liangyongchi
  * @version V1.0.0
  * @date    20250304
  * @file    mio_gpio.c
  * @brief   MIO GPIO��������
**/
#include "port_gpio.h"
#define GPIO_DEVICE_ID      XPAR_XGPIOPS_0_DEVICE_ID//�궨��GPIO_DEVICE_ID   �豸��ID���������������IO �п���Ϊ1
XGpioPs gpiops_inst;                                // GPIO�豸����������ʵ��
/*
 * MIO��ʼ��
 * ����1: DeviceId �豸��ID
 * ����2: pin      ���ź� EMIO0  XDC�ļ�Լ������
 * ����: u16, 0���ɹ���1��ʧ��
 */
u16 MioGpioInit(void)
{
    int Status = XST_SUCCESS;
    u16 direction = 0;
    XGpioPs_Config *ConfigPtr;
    xil_printf("MioGpioInit\n\r");
    ConfigPtr = XGpioPs_LookupConfig(GPIO_DEVICE_ID);                                      //��������ID����������Ϣ
    Status = XGpioPs_CfgInitialize(&gpiops_inst, ConfigPtr, ConfigPtr->BaseAddr);    //��ʼ����������
    if (Status != XST_SUCCESS){
        return XST_FAILURE;
    }
    //user edit
    direction = 1;
    XGpioPs_SetDirectionPin(&gpiops_inst, LED7_PIN, direction);       //����ָ�����ŵķ���0���룬1���
    XGpioPs_SetDirectionPin(&gpiops_inst, LED8_PIN, direction);       //����ָ�����ŵķ���0���룬1���
	XGpioPs_SetDirectionPin(&gpiops_inst, PS_LED_PIN, direction);
    if (direction == 1){
    	XGpioPs_SetOutputEnablePin(&gpiops_inst, LED7_PIN, 1);  //ʹ��ָ�����������0��ֹ���ʹ�ܣ�1ʹ�����  EMIO����Ҫʹ��
    	XGpioPs_SetOutputEnablePin(&gpiops_inst, LED8_PIN, 1);  //ʹ��ָ�����������0��ֹ���ʹ�ܣ�1ʹ�����  EMIO����Ҫʹ��
        XGpioPs_SetOutputEnablePin(&gpiops_inst, PS_LED_PIN, 1);
    }
    return XST_SUCCESS;
}

