#ifndef __COMMON_H_
#define __COMMON_H_

#include "FreeRTOS.h"
#include "task.h"
#include <stdio.h>
#include "xil_printf.h"

void led_task_entry(void);
#define LED_STACK_SIZE 512
#define LED_TASK_PRI   15

#define STATUS_OK 0
#define OK 0


#endif
