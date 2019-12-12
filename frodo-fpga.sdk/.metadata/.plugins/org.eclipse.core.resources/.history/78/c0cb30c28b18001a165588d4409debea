/*
 * noise.c

 *
 *  Created on: 6 de dez de 2019
 *      Author: Vinicius
 */

#include "noise.h"

uint16_t CDF_TABLE[13] = {4643, 13363, 20579, 25843, 29227, 31145, 32103, 32525, 32689, 32745, 32762, 32766, 32767};
uint16_t CDF_TABLE_LEN = 13;

void frodo_sample_n(uint16_t *s, const size_t n)
{ // Fills vector s with n samples from the noise distribution which requires 16 bits to sample.
  // The distribution is specified by its CDF.
  // Input: pseudo-random values (2*n bytes) passed in s. The input is overwritten by the output.
    unsigned int i, j;

    print_debug(DEBUG_NOISE, "[NOISE] CDF_TABLE: %d %d %d %d %d... with size %d\n", CDF_TABLE[0], CDF_TABLE[1], CDF_TABLE[2], CDF_TABLE[3], CDF_TABLE[4], CDF_TABLE_LEN);

    for (i = 0; i < n; ++i) {
        uint16_t sample = 0;
        uint16_t prnd = s[i] >> 1;    // Drop the least significant bit
        uint16_t sign = s[i] & 0x1;    // Pick the least significant bit

        // No need to compare with the last value.
        for (j = 0; j < (unsigned int)(CDF_TABLE_LEN - 1); j++) {
            // Constant time comparison: 1 if CDF_TABLE[j] < s, 0 otherwise. Uses the fact that CDF_TABLE[j] and s fit in 15 bits.
            sample += (uint16_t)(CDF_TABLE[j] - prnd) >> 15;
        }
        // Assuming that sign is either 0 or 1, flips sample iff sign = 1
        s[i] = ((-sign) ^ sample) + sign;
    }
}
