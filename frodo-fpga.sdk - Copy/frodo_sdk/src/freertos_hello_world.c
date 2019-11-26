/*
    Copyright (C) 2017 Amazon.com, Inc. or its affiliates.  All Rights Reserved.
    Copyright (C) 2012 - 2018 Xilinx, Inc. All Rights Reserved.

    Permission is hereby granted, free of charge, to any person obtaining a copy of
    this software and associated documentation files (the "Software"), to deal in
    the Software without restriction, including without limitation the rights to
    use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
    the Software, and to permit persons to whom the Software is furnished to do so,
    subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software. If you wish to use our Amazon
    FreeRTOS name, please do so in a fair use way that does not cause confusion.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
    FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
    COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
    IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
    CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

    http://www.FreeRTOS.org
    http://aws.amazon.com/freertos


    1 tab == 4 spaces!
*/

/* FreeRTOS includes. */
#include <stdio.h>
#include <stdlib.h>
#include "FreeRTOS.h"
#include "task.h"
#include "semphr.h"
/* Xilinx includes. */
#include "xil_printf.h"
#include "xgpio.h"
#include "xparameters.h"
#include "include/globalDef.h"
#include "include/xil_printf_custom.h"
#include "tasks/managerTask.h"

/*-----------------------------------------------------------*/

/* The queue used by the Tx and Rx tasks, as described at the top of this
file. */
TaskHandle_t xManagerTask;
extern SemaphoreHandle_t xPrintMutex;

extern XGpio_Config * ConfigPtr0;
extern XGpio axi_control_timer;
extern XGpio_Config * ConfigPtr1;
extern XGpio axi_counter_timer;
extern XLlFifo fifoKeccak;

int main( void )
{
	xPrintMutex = xSemaphoreCreateMutex();

	xil_printf_m( "---- FPGA and ARM architecture for cryptography development ----\n\n" );

	//AXI GPIO
	ConfigPtr0 = XGpio_LookupConfig(XPAR_AXI_GPIO_0_DEVICE_ID);
	XGpio_CfgInitialize(&axi_control_timer, ConfigPtr0, ConfigPtr0->BaseAddress);
	XGpio_DiscreteWrite(&axi_control_timer, 1, 0x0); //Set reset bit low.
	XGpio_DiscreteWrite(&axi_control_timer, 1, 0x1); //Set reset bit high to reset counter.
	XGpio_DiscreteWrite(&axi_control_timer, 1, 0x0); //Set reset bit low.
	XGpio_DiscreteWrite(&axi_control_timer, 2, 0x0); //Set enable bit low.

	ConfigPtr1 = XGpio_LookupConfig(XPAR_AXI_GPIO_1_DEVICE_ID);
	XGpio_CfgInitialize(&axi_counter_timer, ConfigPtr1, ConfigPtr1->BaseAddress);

	//AXI FIFO
	int xStatus;
	int Status;

	//Config FIFO
	XLlFifo_Config *ConfigFifoKeccak;
	ConfigFifoKeccak = XLlFfio_LookupConfig(XPAR_AXI_FIFO_0_DEVICE_ID);
	if (!ConfigFifoKeccak)
		xil_printf_m("[MAIN - ERROR] No configuration found.\n");

	//Initialize FIFO
	xil_printf_m("[MAIN] Fifo keccak address: %d.\n", &fifoKeccak);
	xStatus = XLlFifo_CfgInitialize(&fifoKeccak, ConfigFifoKeccak, ConfigFifoKeccak->BaseAddress);
	if(XST_SUCCESS != xStatus)
		xil_printf_m("[MAIN] Failed to initialize FIFO keccak.\n");

	xil_printf_m("[MAIN] FIFO keccak initialized.\n");

	//Get FIFO status
	Status = XLlFifo_Status(&fifoKeccak);
	XLlFifo_IntClear(&fifoKeccak, 0xffffffff);
	Status = XLlFifo_Status(&fifoKeccak);
	if(Status != 0x0)
		xil_printf_m("[MAIN - ERROR] Reset value wrong.\n");

	//Creating tasks
	xTaskCreate( prvManagerTask, ( const char * ) "ManagerTask", configMINIMAL_STACK_SIZE, NULL,
					 tskIDLE_PRIORITY + 1, &xManagerTask );

	//Start the tasks and timer running.
	vTaskStartScheduler();

	/* If all is well, the scheduler will now be running, and the following line
	will never be reached.  If the following line does execute, then there was
	insufficient FreeRTOS heap memory available for the idle and/or timer tasks
	to be created.  See the memory management section on the FreeRTOS web site
	for more details. */
	for( ;; );
}

