/*
 * managerTask.c

 *
 *  Created on: 15 de set de 2019
 *      Author: Vinicius
 */

#include "managerTask.h"
#include "xgpiops.h"

#define ledpin 47

void prvManagerTask( void *pvParameters )
{
	xil_printf_m("[MANAGER TASK] Manager task initialized!\n");

	vTaskDelay( pdMS_TO_TICKS( 10 ) ); //Wait other tasks to be initialized.

	//Initializing GPIO LED pin.
	XGpioPs Gpio;
	XGpioPs_Config *GPIOConfigPtr;
	GPIOConfigPtr = XGpioPs_LookupConfig(XPAR_PS7_GPIO_0_DEVICE_ID);
	XGpioPs_CfgInitialize(&Gpio, GPIOConfigPtr, GPIOConfigPtr ->BaseAddr);
	XGpioPs_SetDirectionPin(&Gpio, ledpin, 1);
	XGpioPs_SetOutputEnablePin(&Gpio, ledpin, 1);

	u32 u32LedState = 0x0;
	for(;;)
	{
		u32LedState ^= 0x1;
		XGpioPs_WritePin(&Gpio, ledpin, u32LedState);
		vTaskDelay( pdMS_TO_TICKS( 100 ) );
		u32LedState ^= 0x1;
		XGpioPs_WritePin(&Gpio, ledpin, u32LedState);


		//Debug//

		for(u32 i = 0; i < PACKET_SIZE; i++)
		{
			u32 u32TxWord = i;
			xil_printf_m("\tSent data: 0x%x\n", u32TxWord);
			if(XLlFifo_iTxVacancy(&fifoKeccak))
				XLlFifo_TxPutWord(&fifoKeccak, u32TxWord);
		}

		//Start Transmission by writing transmission length into the TLR
		XLlFifo_iTxSetLen(&fifoKeccak, PACKET_SIZE*4);

		//Check for Transmission completion
		while(!(XLlFifo_IsTxDone(&fifoKeccak))){}

		xil_printf_m("[HW AES TASK] Write process completed. Setting start bit high.\n");

		while(XLlFifo_iRxOccupancy(&fifoKeccak))
		{
			// Read Receive Length
			u32 ReceiveLength;
			u32 RxWord;
			int i;
			ReceiveLength = (XLlFifo_iRxGetLen(&fifoKeccak))/4;
			xil_printf_m("[KECCAK] Received length: %d bytes.\n", ReceiveLength << 2);
			for (i=0; i < ReceiveLength; i++) {
				RxWord = XLlFifo_RxGetWord(&fifoKeccak);
				xil_printf_m("\tReceived data: 0x%x\n", RxWord);
				//*(DestinationBuffer+i) = RxWord; - create queue
			}
		}

		int Status;
		Status = XLlFifo_IsRxDone(&fifoKeccak);
		if(Status != TRUE)
			xil_printf_m("[HW AES TASK] Failing in receive complete...\n");

		xil_printf_m("[HW AES TASK] Reception completed.\n");

		//End debug//

		vTaskDelay( pdMS_TO_TICKS( 500 ) );
	}

}
