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

//void frodo_init();
unsigned int get_cyclecount (void);
void init_perfcounters (int32_t do_reset, int32_t enable_divider);
void shake128(unsigned char *output, unsigned long long outlen, const unsigned char *input,  unsigned long long inlen);
int kem_test(const char *named_parameters, int iterations);

#endif /* SRC_INCLUDE_TEST_KEM_H_ */
