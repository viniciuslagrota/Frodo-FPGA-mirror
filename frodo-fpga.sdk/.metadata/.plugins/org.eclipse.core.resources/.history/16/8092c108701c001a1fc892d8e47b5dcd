/*
 * kem.h
 *
 *  Created on: 1 de dez de 2019
 *      Author: Vinicius
 */

#ifndef SRC_INCLUDE_KEM_H_
#define SRC_INCLUDE_KEM_H_

#include "global_def.h"

#define LE_TO_UINT16(n) (n)
#define UINT16_TO_LE(n) (n)

int crypto_kem_keypair(unsigned char* pk, unsigned char* sk);
int crypto_kem_enc(unsigned char *ct, unsigned char *ss, const unsigned char *pk);

#endif /* SRC_INCLUDE_KEM_H_ */
