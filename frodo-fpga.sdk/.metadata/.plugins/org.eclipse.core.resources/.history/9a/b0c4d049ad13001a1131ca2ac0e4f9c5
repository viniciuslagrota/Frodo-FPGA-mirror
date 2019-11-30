/*
 * frodo_main.c

 *
 *  Created on: 25 de nov de 2019
 *      Author: Vinicius
 */

#include "frodo_main.h"
#include "keccak_f1600.h"

void frodo_init()
{
	xil_printf_macro("Frodo init\n");

	// ------ Test keccak_function ------
	u64 state[25] = { 0 };
	state[0] = 0x000000000000001f;
	state[20] = 0x8000000000000000;
	keccak_f1600_func(state);

}
