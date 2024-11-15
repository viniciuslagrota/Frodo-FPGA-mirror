/*
 * frodo_macrify.h

 *
 *  Created on: 6 de dez de 2019
 *      Author: Vinicius
 */

#ifndef SRC_INCLUDE_FRODO_MACRIFY_H_
#define SRC_INCLUDE_FRODO_MACRIFY_H_

#include "global_def.h"

void frodo_pack(unsigned char *out, const size_t outlen, const uint16_t *in, const size_t inlen, const unsigned char lsb);
void frodo_unpack(uint16_t *out, const size_t outlen, const unsigned char *in, const size_t inlen, const unsigned char lsb);
void frodo_sample_n(uint16_t *s, const size_t n);
void clear_bytes(uint8_t *mem, size_t n);

int frodo_mul_add_as_plus_e(uint16_t *b, const uint16_t *s, const uint16_t *e, const uint8_t *seed_A);
int frodo_mul_add_as_plus_e_SW(uint16_t *b, const uint16_t *s, const uint16_t *e, const uint8_t *seed_A, uint32_t *u32AccTime, uint32_t *u32ItCounter);
int frodo_mul_add_as_plus_e_HW(uint16_t *b, const uint16_t *s, const uint16_t *e, const uint8_t *seed_A, uint32_t *u32AccTime, uint32_t *u32ItCounter);
int frodo_mul_add_sa_plus_e(uint16_t *b, const uint16_t *s, const uint16_t *e, const uint8_t *seed_A);
int frodo_mul_add_sa_plus_e_SW(uint16_t *out, const uint16_t *s, const uint16_t *e, const uint8_t *seed_A, uint32_t *u32AccTime, uint32_t *u32ItCounter);
int frodo_mul_add_sa_plus_e_HW(uint16_t *out, const uint16_t *s, const uint16_t *e, const uint8_t *seed_A, uint32_t *u32AccTime, uint32_t *u32ItCounter);
void frodo_mul_add_sb_plus_e(uint16_t *out, const uint16_t *b, const uint16_t *s, const uint16_t *e);
void frodo_mul_bs(uint16_t *out, const uint16_t *b, const uint16_t *s);

void frodo_add(uint16_t *out, const uint16_t *a, const uint16_t *b);
void frodo_sub(uint16_t *out, const uint16_t *a, const uint16_t *b);
void frodo_key_encode(uint16_t *out, const uint16_t *in);
void frodo_key_decode(uint16_t *out, const uint16_t *in);

#endif /* SRC_INCLUDE_FRODO_MACRIFY_H_ */
