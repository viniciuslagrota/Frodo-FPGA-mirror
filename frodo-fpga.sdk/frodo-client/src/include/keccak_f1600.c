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
	print_debug(DEBUG_STATE_MATRIX, "[KECCAK-f1600] Matrix state:\n");
	for (size_t line = 0; line < 12; line++)
	{
		print_debug(DEBUG_STATE_MATRIX, "(%d, %d) ", x, y);

		for (i = 0; i < 8; i++)
			print_debug(DEBUG_STATE_MATRIX, "%02x", (uint8_t)((s[5 * y + x] >> (8 * i)) & 0xff));

		x++;
		if (x == 5)
		{
			x = 0;
			y++;
			if (y == 5)
				y = 0;
		}

		print_debug(DEBUG_STATE_MATRIX, " ");
		for (i = 0; i < 8; i++)
			print_debug(DEBUG_STATE_MATRIX, "%02x", (uint8_t)((s[5 * y + x] >> (8 * i)) & 0xff));

		print_debug(DEBUG_STATE_MATRIX, " (%d, %d)\n", x, y);

		x++;
		if (x == 5)
		{
			x = 0;
			y++;
			if (y == 5)
				y = 0;
		}
	}
	print_debug(DEBUG_STATE_MATRIX, "(%d, %d) ", x, y);

	for (i = 0; i < 8; i++)
		print_debug(DEBUG_STATE_MATRIX, "%02x", (uint8_t)((s[5 * y + x] >> (8 * i)) & 0xff));

	print_debug(DEBUG_STATE_MATRIX, "\n");
}

//void KeccakF1600_StatePermute_HW(uint64_t * state)
//{
//	print_debug(DEBUG_KECCAK_HW, "[KECCAK-f1600] keccak_f1600_func init\n");
////
//	// ------ Variables ------
//	u32 readGpio = 0x0;
//
//	//Print state matrix
////	printStateMatrixDebug(state);
//
//	//Set start pin high
//	XGpio_DiscreteWrite(&axiStartDone, 1, 0x1); // Start gpio set high
//
//	//Sending data
//	for(u32 i = 0; i < 25; i++)
//	{
//
//		if(XLlFifo_iTxVacancy(&fifoKeccak))
//		{
//			XLlFifo_TxPutWord(&fifoKeccak, (u32)(state[i] & 0xffffffff));
//			print_debug(DEBUG_KECCAK_HW, "\tSent data %lu: 0x%lx\n", (i << 1), (u32)(state[i] & 0xffffffff));
//		}
//
//		if(XLlFifo_iTxVacancy(&fifoKeccak))
//		{
//			XLlFifo_TxPutWord(&fifoKeccak, (u32)(state[i] >> 32));
//			print_debug(DEBUG_KECCAK_HW, "\tSent data %lu: 0x%lx\n", (i << 1) + 1, (u32)(state[i] >> 32));
//		}
//
//	}
//
//	//Start Transmission by writing transmission length into the TLR
//	XLlFifo_iTxSetLen(&fifoKeccak, MATRIX_SIZE*2*4);
//
//	//Check for Transmission completion
//	while(!(XLlFifo_IsTxDone(&fifoKeccak))){}
//	print_debug(DEBUG_KECCAK_HW, "[KECCAK-f1600] Transmission completed.\n");
//
//	//Reading done bit
//	readGpio = XGpio_DiscreteRead(&axiStartDone, 1); //Check done pin
//	while(readGpio == 0x0)
//	{
//		readGpio = XGpio_DiscreteRead(&axiStartDone, 1);
//	}
//
//#if ENABLE_HW_TIMER
//	//Stopping timer and reading time
//	u32 readTimer;
//	float fval;
//	u32 whole, thousandths;
//
//	readTimer = XGpio_DiscreteRead(&axi_counter_timer, 1);
//	fval = (float)readTimer / (float)100;
//	whole = fval;
//	thousandths = (fval - whole) * 1000;
//	print_debug(DEBUG_KECCAK_HW, "[KECCAK-f1600] Time took to process Keccak-f1600: %lu.%03lu us\n", whole, thousandths);
//#endif
//
//	//Interpret data
//	while(XLlFifo_iRxOccupancy(&fifoKeccak))
//	{
//		// Read Receive Length
//		u32 ReceiveLength;
//		u32 RxWord;
//		int i;
//		ReceiveLength = (XLlFifo_iRxGetLen(&fifoKeccak))/4;
//		print_debug(DEBUG_KECCAK_HW, "[KECCAK-f1600] Received length: %lu bytes.\n", ReceiveLength << 2);
//		for (i = 0; i < ReceiveLength; i++) {
//			RxWord = XLlFifo_RxGetWord(&fifoKeccak);
//			if(i & 0x1) //upper word
//				state[i >> 1] |= (u64)(RxWord) << 32;
//			else
//				state[i >> 1] = (u64)(RxWord);
//
//			print_debug(DEBUG_KECCAK_HW, "\tReceived data: 0x%lx\n", RxWord);
//		}
//	}
//	int Status;
//	Status = XLlFifo_IsRxDone(&fifoKeccak);
//	if(Status != TRUE)
//		print_debug(DEBUG_ERROR, "[KECCAK-f1600 - ERROR] Failing in receive complete...\n");
//
//	print_debug(DEBUG_KECCAK_HW, "[KECCAK-f1600] Reception completed.\n");
//
//	//Set start pin low
//	XGpio_DiscreteWrite(&axiStartDone, 1, 0x0); // Start gpio set low
//
//	//Print state matrix
////	printStateMatrixDebug(state);
//
//}

void KeccakF1600_StatePermute_HW_MM(uint64_t * state)
{
	print_debug(DEBUG_KECCAK_HW_MM, "[KECCAK-f1600] keccak_f1600_mm_func init\n");

	//Variables
	int i;
	u32 readGpio = 0x0;

	//Set start pin high
	XGpio_DiscreteWrite(&axiStartDoneMM, 1, 0x1); // Start gpio set high

	//Sending data
	for(i = 0; i < 25; i++)
	{
		memoryMMkeccak[(i << 1)] = (u32)(state[i] & 0xffffffff);
		print_debug(DEBUG_KECCAK_HW, "\tSent data %lu: 0x%lx\n", (i << 1), (u32)(state[i] & 0xffffffff));

		memoryMMkeccak[(i << 1) + 1] = (u32)(state[i] >> 32);
		print_debug(DEBUG_KECCAK_HW, "\tSent data %lu: 0x%lx\n", (i << 1) + 1, (u32)(state[i] >> 32));
	}

	//Reading done bit
	readGpio = XGpio_DiscreteRead(&axiStartDoneMM, 1); //Check done pin
	while(readGpio == 0x0)
	{
		readGpio = XGpio_DiscreteRead(&axiStartDoneMM, 1);
	}
	print_debug(DEBUG_KECCAK_HW_MM, "[KECCAK-f1600] Done bit high!\n");

	//Interpret data
//	for (i = 0; i < 50; i++)
//	{
//		if(i & 0x1) //upper word
//			state[i >> 1] |= (u64)(memoryMMkeccak[i]) << 32;
//		else
//			state[i >> 1] = memoryMMkeccak[i];
//
//		print_debug(DEBUG_KECCAK_HW, "\tReceived data: 0x%x\n", memoryMMkeccak[i]);
//	}

	for (i = 0; i < 25; i++)
	{
		state[i] = (u64)(memoryMMkeccak[(i << 1) + 1]) << 32 | memoryMMkeccak[i << 1];
	}

//	for (i = 51; i < 64; i++)
//	{
//		print_debug(DEBUG_KECCAK_HW, "\tReceived data (debug): 0x%x\n", memoryMMkeccak[i]);
//	}

	//Set start pin low
	XGpio_DiscreteWrite(&axiStartDoneMM, 1, 0x0); // Start gpio set low

	//Print state matrix
//	printStateMatrixDebug(state);
}

