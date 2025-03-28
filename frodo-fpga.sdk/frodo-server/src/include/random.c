/*
 * random.c

 *
 *  Created on: 1 de dez de 2019
 *      Author: Vinicius
 */
#include "random.h"

int randombytes(unsigned char* random_array, u32 nbytes)
{
	u32 u32Random;
	u32 idx = 0;
	u32 i;

	print_debug(DEBUG_RANDOM, "[RANDOM] Random bytes requested: %lu\n", nbytes);

	for(i = nbytes; i > 3; i = i - 4)
	{
		u32Random = rand();

		idx = nbytes - i;
		random_array[idx + 0] = (u8)((u32Random >> 0) & 0xff);
		random_array[idx + 1] = (u8)((u32Random >> 8) & 0xff);
		random_array[idx + 2] = (u8)((u32Random >> 16) & 0xff);
		random_array[idx + 3] = (u8)((u32Random >> 24) & 0xff);

		print_debug(DEBUG_RANDOM, "[RANDOM] nbytes: %lu  \tRandom: %lx   \t  i : %lu\n", nbytes, u32Random, idx);
		print_debug(DEBUG_RANDOM, "[RANDOM] i : %lu\n", i);
	}

//	switch(i)
//	{
//		case 3:
//			u32Random = rand();
//			random_array[i + 0] = (u32Random >> 0) & 0xff;
//			random_array[i + 1] = (u32Random >> 8) & 0xff;
//			random_array[i + 2] = (u32Random >> 16) & 0xff;
//			break;
//		case 2:
//			u32Random = rand();
//			random_array[i + 0] = (u32Random >> 0) & 0xff;
//			random_array[i + 1] = (u32Random >> 8) & 0xff;
//			break;
//		case 1:
//			u32Random = rand();
//			random_array[i + 0] = (u32Random >> 0) & 0xff;
//			break;
//		case 0:
//
//			break;
//	}


	return passed;
}
