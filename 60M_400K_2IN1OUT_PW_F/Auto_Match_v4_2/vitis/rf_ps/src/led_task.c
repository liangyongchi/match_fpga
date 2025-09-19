
#include "common.h"
#include "port_gpio.h"
#include "sleep.h"
static void LedTask( void *pvParameters )
{
	MioGpioInit();
    while(1)
	{
    	vTaskDelay(100);
    	Led7RunOn
    	Led8RunOn
		PSLEDRunOn
        vTaskDelay(100);
    	Led7RunOff
    	Led8RunOff
		PSLEDRunOff
        xil_printf("LedTask\r\n");
	}
}

void led_task_entry(void)
{
    static TaskHandle_t task1_handle = NULL;
	BaseType_t xReturn;
	xReturn = xTaskCreate(
        LedTask, 		            /* task */
        "led", 	                    /* name */
		LED_STACK_SIZE, 	        /* The stack allocated to the task. */
        NULL, 						/* The task parameter is not used, so set to NULL. */
        LED_TASK_PRI,			    /* The task runs at the idle priority. */
        &task1_handle );
    if( xReturn == pdPASS ){
        xil_printf("LED TASK create success!\r\n");//xil_printf
    }
    else{
        xil_printf("LED TASK create failed!\r\n");
    }
}

