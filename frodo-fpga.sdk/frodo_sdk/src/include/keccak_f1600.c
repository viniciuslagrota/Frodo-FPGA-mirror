/*
 * keccak-f1600.c

 *
 *  Created on: 30 de nov de 2019
 *      Author: Vinicius
 */

#include "keccak_f1600.h"

void printStateMatrixDebug(uint64_t * s)
{
//	int iCount = 0;
	int x = 0;
	int y = 0;
	int i;
	xil_printf_macro("Matrix state:\n");
	for (size_t line = 0; line < 12; line++)
	{
		xil_printf_macro("(%d, %d) ", x, y);

		for (i = 0; i < 8; i++)
			xil_printf_macro("%02x", (s[5 * y + x] >> (8 * i)) & 0xff);

		x++;
		if (x == 5)
		{
			x = 0;
			y++;
			if (y == 5)
				y = 0;
		}

		xil_printf_macro(" ");
		for (i = 0; i < 8; i++)
			xil_printf_macro("%02x", (s[5 * y + x] >> (8 * i)) & 0xff);

		xil_printf_macro(" (%d, %d)\n", x, y);

		x++;
		if (x == 5)
		{
			x = 0;
			y++;
			if (y == 5)
				y = 0;
		}
	}
	xil_printf_macro("(%d, %d) ", x, y);

	for (i = 0; i < 8; i++)
		xil_printf_macro("%02x", (s[5 * y + x] >> (8 * i)) & 0xff);

	xil_printf_macro("\n");
}

void keccak_f1600_func(uint64_t * state)
{
	xil_printf_macro("keccak_f1600_func init\n");
//
	// ------ Variables ------
	u32 readGpio = 0x0;
	u32 readTimer;
	float fval;
	u32 whole, thousandths;

	//Print state matrix
	printStateMatrixDebug(state);

	//Set start pin high
	XGpio_DiscreteWrite(&axiStartDone, 1, 0x1); // Start gpio set high

	//Sending data
	for(u32 i = 0; i < 25; i++)
	{
//		xil_printf_macro("\tSent data %d: 0x%x\n", i, u32TxWordVec[i]);
		if(XLlFifo_iTxVacancy(&fifoKeccak))
		{
			XLlFifo_TxPutWord(&fifoKeccak, (u32)(state[i] & 0xffffffff));
		}

		if(XLlFifo_iTxVacancy(&fifoKeccak))
		{
			XLlFifo_TxPutWord(&fifoKeccak, (u32)(state[i] >> 32));
		}

	}

	//Start Transmission by writing transmission length into the TLR
	XLlFifo_iTxSetLen(&fifoKeccak, MATRIX_SIZE*2*4);

	//Check for Transmission completion
	while(!(XLlFifo_IsTxDone(&fifoKeccak))){}
//	xil_printf_macro("Transmission completed.\n");

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
	xil_printf_macro("Time took to process Keccak-f1600: %d.%03d us\n", whole, thousandths);

	//Interpret data
	while(XLlFifo_iRxOccupancy(&fifoKeccak))
	{
		// Read Receive Length
		u32 ReceiveLength;
		u32 RxWord;
		int i;
		ReceiveLength = (XLlFifo_iRxGetLen(&fifoKeccak))/4;
		xil_printf_macro("Received length: %d bytes.\n", ReceiveLength << 2);
		for (i = 0; i < ReceiveLength; i++) {
			RxWord = XLlFifo_RxGetWord(&fifoKeccak);
			if(i & 0x1) //upper word
				state[i >> 1] |= (u64)(RxWord) << 32;
			else
				state[i >> 1] = (u64)(RxWord);

//			xil_printf_macro("\tReceived data: 0x%x\n", RxWord);
		}
	}
	int Status;
	Status = XLlFifo_IsRxDone(&fifoKeccak);
	if(Status != TRUE)
		xil_printf_macro("Failing in receive complete...\n");

	xil_printf_macro("Reception completed.\n");

	//Set start pin low
	XGpio_DiscreteWrite(&axiStartDone, 1, 0x0); // Start gpio set low

	//Print state matrix
	printStateMatrixDebug(state);

}