/******************************************************************************
*
* Copyright (C) 2009 - 2014 Xilinx, Inc.  All rights reserved.
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* Use of the Software is limited solely to applications:
* (a) running on a Xilinx device, or
* (b) that interact with a Xilinx device through a bus or interconnect.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
* XILINX  BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
* WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF
* OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*
* Except as contained in this notice, the name of the Xilinx shall not be used
* in advertising or otherwise to promote the sale, use or other dealings in
* this Software without prior written authorization from Xilinx.
*
******************************************************************************/

/*
 * helloworld.c: simple test application
 *
 * This application configures UART 16550 to baud rate 9600.
 * PS7 UART (Zynq) is not initialized by this application, since
 * bootrom/bsp configures it to baud rate 115200
 *
 * ------------------------------------------------
 * | UART TYPE   BAUD RATE                        |
 * ------------------------------------------------
 *   uartns550   9600
 *   uartlite    Configurable only in HW design
 *   ps7_uart    115200 (configured by bootrom/bsp)
 */

#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"
#include "sleep.h"
#include "xgpiops.h"
#include "xadcps.h"
#include "include/global_def.h"

#define XADC_DEVICE_ID 		XPAR_XADCPS_0_DEVICE_ID

extern XGpio axiStartDone;
extern XGpio axiStartDoneMM;
extern XGpio_Config * ConfigPtr0;
extern XGpio_Config * ConfigPtr1;
extern XGpio_Config * ConfigPtr2;
extern XGpio_Config * ConfigPtr3;
extern XGpio axi_counter_timer;
extern XGpio axi_counter_timer_mm;
extern XLlFifo fifoKeccak;
extern u32 *memoryMMkeccak;
static XAdcPs XAdcInst;
XAdcPs_Config *ConfigPtr;
u32 TempRawData;
float TempData;
XAdcPs *XAdcInstPtr = &XAdcInst;

int XAdcFractionToInt(float FloatNum)
{
	float Temp;

	Temp = FloatNum;
	if (FloatNum < 0) {
		Temp = -(FloatNum);
	}

	return( ((int)((Temp -(float)((int)Temp)) * (1000.0f))));
}

int main()
{
    init_platform();
    print_debug(DEBUG_MAIN, "--- Frodo Algortithm ---\n\n");

    //---- Local variables ----
    u32 u32LedState = 0x0;

    //---- Temperature ADC -
    ConfigPtr = XAdcPs_LookupConfig(XADC_DEVICE_ID);
	XAdcPs_CfgInitialize(XAdcInstPtr, ConfigPtr, ConfigPtr->BaseAddress);
	XAdcPs_SelfTest(XAdcInstPtr);
	XAdcPs_SetSequencerMode(XAdcInstPtr, XADCPS_SEQ_MODE_SAFE);
	TempRawData = XAdcPs_GetAdcData(XAdcInstPtr, XADCPS_CH_TEMP);
	TempData = XAdcPs_RawToTemperature(TempRawData);
	print_debug(DEBUG_MAIN, "[MAIN] The Current Temperature is %0d.%03d Centigrades\n", (int)(TempData), XAdcFractionToInt(TempData));

    //---- Blink led ----
	XGpioPs Gpio;
	XGpioPs_Config *GPIOConfigPtr;
	GPIOConfigPtr = XGpioPs_LookupConfig(XPAR_PS7_GPIO_0_DEVICE_ID);
	XGpioPs_CfgInitialize(&Gpio, GPIOConfigPtr, GPIOConfigPtr ->BaseAddr);
	XGpioPs_SetDirectionPin(&Gpio, ledpin, 1);
	XGpioPs_SetOutputEnablePin(&Gpio, ledpin, 1);

	//---- AXI GPIO ---
	ConfigPtr1 = XGpio_LookupConfig(XPAR_AXI_GPIO_1_DEVICE_ID);
	XGpio_CfgInitialize(&axi_counter_timer, ConfigPtr1, ConfigPtr1->BaseAddress);

	ConfigPtr2 = XGpio_LookupConfig(XPAR_AXI_GPIO_2_DEVICE_ID);
	XGpio_CfgInitialize(&axiStartDone, ConfigPtr2, ConfigPtr2->BaseAddress);
	XGpio_DiscreteWrite(&axiStartDone, 1, 0x0); //Set start bit low.

	ConfigPtr3 = XGpio_LookupConfig(XPAR_AXI_GPIO_3_DEVICE_ID);
	XGpio_CfgInitialize(&axiStartDoneMM, ConfigPtr3, ConfigPtr3->BaseAddress);
	XGpio_DiscreteWrite(&axiStartDoneMM, 1, 0x0); //Set start bit low.

	ConfigPtr0 = XGpio_LookupConfig(XPAR_AXI_GPIO_0_DEVICE_ID);
	XGpio_CfgInitialize(&axi_counter_timer_mm, ConfigPtr0, ConfigPtr0->BaseAddress);

	//---- AXI MM ----
	memoryMMkeccak = (u32 *) XPAR_KECCAK_F1600_MM_IP_0_S00_AXI_BASEADDR;
	print_debug(DEBUG_ERROR, "[MAIN] Memory golden word: 0x%lx.\n", memoryMMkeccak[63]);
	if(memoryMMkeccak[63] == 0xfeedfeed)
		print_debug(DEBUG_ERROR, "[MAIN] Golden word correct.\n");
	else
	{
		print_debug(DEBUG_ERROR, "[MAIN - ERROR] Hardware problem: 0x%lx\n", memoryMMkeccak[63]);
		exit(0);
	}

	//---- AXI FIFO ----
	int xStatus;
	int Status;

	//Config FIFO
	XLlFifo_Config *ConfigFifoKeccak;
	ConfigFifoKeccak = XLlFfio_LookupConfig(XPAR_AXI_FIFO_0_DEVICE_ID);
	if (!ConfigFifoKeccak)
		print_debug(DEBUG_ERROR, "[MAIN - ERROR] No configuration found.\n");

	//Initialize FIFO
	print_debug(DEBUG_MAIN, "[MAIN] Fifo keccak address: %d.\n", (int)(&fifoKeccak));
	xStatus = XLlFifo_CfgInitialize(&fifoKeccak, ConfigFifoKeccak, ConfigFifoKeccak->BaseAddress);
	if(XST_SUCCESS != xStatus)
		print_debug(DEBUG_ERROR, "[MAIN - ERROR] Failed to initialize FIFO keccak.\n");

	print_debug(DEBUG_MAIN, "[MAIN] FIFO keccak initialized.\n");

	//Get FIFO status
	Status = XLlFifo_Status(&fifoKeccak);
	XLlFifo_IntClear(&fifoKeccak, 0xffffffff);
	Status = XLlFifo_Status(&fifoKeccak);
	if(Status != 0x0)
		print_debug(DEBUG_ERROR, "[MAIN - ERROR] Reset value wrong.\n");

    while(1)
    {
    	//Blink led
		XGpioPs_WritePin(&Gpio, ledpin, u32LedState);
		u32LedState ^= 0x1;

		//Get random seed.
		TempRawData = XAdcPs_GetAdcData(XAdcInstPtr, XADCPS_CH_TEMP);
		TempData = XAdcPs_RawToTemperature(TempRawData);
		print_debug(DEBUG_MAIN, "[MAIN] The Current Temperature is %0d.%03d �C | Raw data %lu\n", (int)(TempData), XAdcFractionToInt(TempData), TempRawData);
		srand(TempRawData); //Get a random seed here!

		//Frodo system
		kem_test(SYSTEM_NAME, KEM_TEST_ITERATIONS);

    	sleep(1);
    }

    cleanup_platform();
    return 0;
}