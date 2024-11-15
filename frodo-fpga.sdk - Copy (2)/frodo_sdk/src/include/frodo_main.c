/*
 * frodo_main.c

 *
 *  Created on: 25 de nov de 2019
 *      Author: Vinicius
 */

#include "frodo_main.h"

void frodo_init()
{
	xil_printf("Frodo init\n");

	// ------ Variables ------
	u32 readGpio = 0x0;
	u32 readTimer;
	float fval;
	u32 whole, thousandths;

	// ------ Test FIFO ------

	//Set start pin high
	XGpio_DiscreteWrite(&axiStartDone, 1, 0x1); // Start gpio set high

	//Preparing data
	u32 u32TxWordVec[PACKET_SIZE] = { 0 };
//	u32TxWordVec[0] = 0x0000001f;
//	u32TxWordVec[0] = 0x000003f3;
	u32TxWordVec[0] = 0xd97b5853;
	u32TxWordVec[1] = 0x00000007;
	u32TxWordVec[41] = 0x80000000;

	//Reset and start timer
//	XGpio_DiscreteWrite(&axi_control_timer, 1, 0x1); // Reset
//	XGpio_DiscreteWrite(&axi_control_timer, 1, 0x0); //
//	XGpio_DiscreteWrite(&axi_control_timer, 2, 0x1); // Enable counter

	//Sending data
	for(u32 i = 0; i < PACKET_SIZE; i++)
	{
//		xil_printf("\tSent data %d: 0x%x\n", i, u32TxWordVec[i]);
		if(XLlFifo_iTxVacancy(&fifoKeccak))
			XLlFifo_TxPutWord(&fifoKeccak, u32TxWordVec[i]);
	}

	//Start Transmission by writing transmission length into the TLR
	XLlFifo_iTxSetLen(&fifoKeccak, PACKET_SIZE*4);

	//Check for Transmission completion
	while(!(XLlFifo_IsTxDone(&fifoKeccak))){}
//	xil_printf("Transmission completed.\n");

	//Reading done bit
	readGpio = XGpio_DiscreteRead(&axiStartDone, 1); //Check done pin
	while(readGpio == 0x0)
	{
		readGpio = XGpio_DiscreteRead(&axiStartDone, 1);
	}

	//Stopping timer and reading time
//	XGpio_DiscreteWrite(&axi_control_timer, 2, 0x0); // Disable counter
	readTimer = XGpio_DiscreteRead(&axi_counter_timer, 1);
	fval = (float)readTimer / (float)100;
	whole = fval;
	thousandths = (fval - whole) * 1000;
	xil_printf("Time took to process Keccak-f1600: %d.%03d us\n", whole, thousandths);

	//Interpret data
	while(XLlFifo_iRxOccupancy(&fifoKeccak))
	{
		// Read Receive Length
		u32 ReceiveLength;
		u32 RxWord;
		int i;
		ReceiveLength = (XLlFifo_iRxGetLen(&fifoKeccak))/4;
		xil_printf("Received length: %d bytes.\n", ReceiveLength << 2);
		for (i=0; i < ReceiveLength; i++) {
			RxWord = XLlFifo_RxGetWord(&fifoKeccak);
			xil_printf("\tReceived data: 0x%x\n", RxWord);
		}
	}
	int Status;
	Status = XLlFifo_IsRxDone(&fifoKeccak);
	if(Status != TRUE)
		xil_printf("Failing in receive complete...\n");

	xil_printf("Reception completed.\n");

	//Set start pin low
	XGpio_DiscreteWrite(&axiStartDone, 1, 0x0); // Start gpio set low



}
