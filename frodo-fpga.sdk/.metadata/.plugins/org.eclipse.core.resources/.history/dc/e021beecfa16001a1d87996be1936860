/*
 * fips202.h
 *
 *  Created on: 4 de dez de 2019
 *      Author: Vinicius
 */

#ifndef SRC_INCLUDE_FIPS202_H_
#define SRC_INCLUDE_FIPS202_H_

#include "global_def.h"
#include <stdint.h>
#include "keccak_f1600.h"


//Software implementation
#define KeccakF1600_StatePermute 	KeccakF1600_StatePermute_SW
//Hardware implementation
//#define KeccakF1600_StatePermute 	KeccakF1600_StatePermute_HW

#define SHAKE128_RATE 168
#define SHAKE256_RATE 136

void shake128_absorb(uint64_t *s, const unsigned char *input, unsigned int inputByteLen);
void shake128_squeezeblocks(unsigned char *output, unsigned long long nblocks, uint64_t *s);
void shake128(unsigned char *output, unsigned long long outlen, const unsigned char *input,  unsigned long long inlen);

//void shake256_absorb(uint64_t *s, const unsigned char *input, unsigned int inputByteLen);
//void shake256_squeezeblocks(unsigned char *output, unsigned long long nblocks, uint64_t *s);
//void shake256(unsigned char *output, unsigned long long outlen, const unsigned char *input,  unsigned long long inlen);

void KeccakF1600_StatePermute(uint64_t* state);

#endif /* SRC_INCLUDE_FIPS202_H_ */
