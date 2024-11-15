/*
 * api_frodo640.h

 *
 *  Created on: 1 de dez de 2019
 *      Author: Vinicius
 */

#ifndef SRC_INCLUDE_API_FRODO640_H_
#define SRC_INCLUDE_API_FRODO640_H_

#include "global_def.h"

#define CRYPTO_SECRETKEYBYTES  19888     // sizeof(s) + CRYPTO_PUBLICKEYBYTES + 2*PARAMS_N*PARAMS_NBAR + BYTES_PKHASH
#define CRYPTO_PUBLICKEYBYTES   9616     // sizeof(seed_A) + (PARAMS_LOGQ*PARAMS_N*PARAMS_NBAR)/8
#define CRYPTO_BYTES              16
#define CRYPTO_CIPHERTEXTBYTES  9720     // (PARAMS_LOGQ*PARAMS_N*PARAMS_NBAR)/8 + (PARAMS_LOGQ*PARAMS_NBAR*PARAMS_NBAR)/8

// Algorithm name
#define CRYPTO_ALGNAME "FrodoKEM-640"

int crypto_kem_keypair_Frodo640(unsigned char *pk, unsigned char *sk);
int crypto_kem_enc_Frodo640(unsigned char *ct, unsigned char *ss, const unsigned char *pk);
int crypto_kem_dec_Frodo640(unsigned char *ss, const unsigned char *ct, const unsigned char *sk);

#define DEBUG
#endif /* SRC_INCLUDE_API_FRODO640_H_ */
