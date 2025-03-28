/*
 * frodo_main.h
 *
 *  Created on: 25 de nov de 2019
 *      Author: Vinicius
 */

#ifndef SRC_INCLUDE_TEST_KEM_H_
#define SRC_INCLUDE_TEST_KEM_H_

#include "global_def.h"

#define PACKET_SIZE		50

enum codeType
{
	SHAKE128_SW_MATRIX_SA_SW_AS_SW,
	SHAKE128_HW_MM_MATRIX_SA_SW_AS_SW,
	SHAKE128_SW_MATRIX_SA_HW_AS_SW,
	SHAKE128_HW_MM_MATRIX_SA_HW_AS_SW,
	SHAKE128_SW_MATRIX_SA_SW_AS_HW,
	SHAKE128_HW_MM_MATRIX_SA_SW_AS_HW,
	SHAKE128_SW_MATRIX_SA_HW_AS_HW,
	SHAKE128_HW_MM_MATRIX_SA_HW_AS_HW
};

//void frodo_init();
void set_hardware_usage(enum codeType code);
unsigned int get_cyclecount (void);
void init_perfcounters (int32_t do_reset, int32_t enable_divider);
void shake128(unsigned char *output, unsigned long long outlen, const unsigned char *input,  unsigned long long inlen);
int kem_test(const char *named_parameters, int iterations);

#endif /* SRC_INCLUDE_TEST_KEM_H_ */
