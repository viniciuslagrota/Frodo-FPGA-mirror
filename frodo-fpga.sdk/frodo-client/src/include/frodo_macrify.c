/*
 * frodo_macrify.c

 *
 *  Created on: 6 de dez de 2019
 *      Author: Vinicius
 */

#include "global_def.h"
#include "frodo_macrify.h"

/*************************************************************************************************************
***
***	FRODO_MUL_ADD_AS_PLUS_E
***
**************************************************************************************************************/

///////// ORIGINAL

//int frodo_mul_add_as_plus_e(uint16_t *out, const uint16_t *s, const uint16_t *e, const uint8_t *seed_A)
//{ // Generate-and-multiply: generate matrix A (N x N) row-wise, multiply by s on the right.
//  // Inputs: s, e (N x N_BAR)
//  // Output: out = A*s + e (N x N_BAR)
//    int i, j, k;
//    ALIGN_HEADER(32) int16_t a_row[4*PARAMS_N] ALIGN_FOOTER(32) = {0};
//
//    for (i = 0; i < (PARAMS_N*PARAMS_NBAR); i += 2) {
//        *((uint32_t*)&out[i]) = *((uint32_t*)&e[i]);
//    }
//
//#if defined(USE_AES128_FOR_A)
//    int16_t a_row_temp[4*PARAMS_N] = {0};                       // Take four lines of A at once
//#if !defined(USE_OPENSSL)
//    uint8_t aes_key_schedule[16*11];
//    AES128_load_schedule(seed_A, aes_key_schedule);
//#else
//    EVP_CIPHER_CTX *aes_key_schedule;
//    int len;
//    if (!(aes_key_schedule = EVP_CIPHER_CTX_new())) handleErrors();
//    if (1 != EVP_EncryptInit_ex(aes_key_schedule, EVP_aes_128_ecb(), NULL, seed_A, NULL)) handleErrors();
//#endif
//
//    for (j = 0; j < PARAMS_N; j += PARAMS_STRIPE_STEP) {
//        a_row_temp[j + 1 + 0*PARAMS_N] = UINT16_TO_LE(j);       // Loading values in the little-endian order
//        a_row_temp[j + 1 + 1*PARAMS_N] = UINT16_TO_LE(j);
//        a_row_temp[j + 1 + 2*PARAMS_N] = UINT16_TO_LE(j);
//        a_row_temp[j + 1 + 3*PARAMS_N] = UINT16_TO_LE(j);
//    }
//
//    for (i = 0; i < PARAMS_N; i += 4) {
//        for (j = 0; j < PARAMS_N; j += PARAMS_STRIPE_STEP) {    // Go through A, four rows at a time
//            a_row_temp[j + 0*PARAMS_N] = UINT16_TO_LE(i+0);     // Loading values in the little-endian order
//            a_row_temp[j + 1*PARAMS_N] = UINT16_TO_LE(i+1);
//            a_row_temp[j + 2*PARAMS_N] = UINT16_TO_LE(i+2);
//            a_row_temp[j + 3*PARAMS_N] = UINT16_TO_LE(i+3);
//        }
//
//#if !defined(USE_OPENSSL)
//        AES128_ECB_enc_sch((uint8_t*)a_row_temp, 4*PARAMS_N*sizeof(int16_t), aes_key_schedule, (uint8_t*)a_row);
//#else
//        if (1 != EVP_EncryptUpdate(aes_key_schedule, (uint8_t*)a_row, &len, (uint8_t*)a_row_temp, 4*PARAMS_N*sizeof(int16_t))) handleErrors();
//#endif
//#elif defined (USE_SHAKE128_FOR_A)
//#if defined(WINDOWS) | !defined(USE_AVX2)
//    uint8_t seed_A_separated[2 + BYTES_SEED_A];
//    uint16_t* seed_A_origin = (uint16_t*)&seed_A_separated;
//    memcpy(&seed_A_separated[2], seed_A, BYTES_SEED_A);
//    for (i = 0; i < PARAMS_N; i += 4) {
//        seed_A_origin[0] = UINT16_TO_LE(i + 0);
//        shake128((unsigned char*)(a_row + 0*PARAMS_N), (unsigned long long)(2*PARAMS_N), seed_A_separated, 2 + BYTES_SEED_A);
//        seed_A_origin[0] = UINT16_TO_LE(i + 1);
//        shake128((unsigned char*)(a_row + 1*PARAMS_N), (unsigned long long)(2*PARAMS_N), seed_A_separated, 2 + BYTES_SEED_A);
//        seed_A_origin[0] = UINT16_TO_LE(i + 2);
//        shake128((unsigned char*)(a_row + 2*PARAMS_N), (unsigned long long)(2*PARAMS_N), seed_A_separated, 2 + BYTES_SEED_A);
//        seed_A_origin[0] = UINT16_TO_LE(i + 3);
//        shake128((unsigned char*)(a_row + 3*PARAMS_N), (unsigned long long)(2*PARAMS_N), seed_A_separated, 2 + BYTES_SEED_A);
//#else
//    uint8_t seed_A_separated_0[2 + BYTES_SEED_A];
//    uint8_t seed_A_separated_1[2 + BYTES_SEED_A];
//    uint8_t seed_A_separated_2[2 + BYTES_SEED_A];
//    uint8_t seed_A_separated_3[2 + BYTES_SEED_A];
//    uint16_t* seed_A_origin_0 = (uint16_t*)&seed_A_separated_0;
//    uint16_t* seed_A_origin_1 = (uint16_t*)&seed_A_separated_1;
//    uint16_t* seed_A_origin_2 = (uint16_t*)&seed_A_separated_2;
//    uint16_t* seed_A_origin_3 = (uint16_t*)&seed_A_separated_3;
//    memcpy(&seed_A_separated_0[2], seed_A, BYTES_SEED_A);
//    memcpy(&seed_A_separated_1[2], seed_A, BYTES_SEED_A);
//    memcpy(&seed_A_separated_2[2], seed_A, BYTES_SEED_A);
//    memcpy(&seed_A_separated_3[2], seed_A, BYTES_SEED_A);
//    for (i = 0; i < PARAMS_N; i += 4) {
//        seed_A_origin_0[0] = UINT16_TO_LE(i + 0);
//        seed_A_origin_1[0] = UINT16_TO_LE(i + 1);
//        seed_A_origin_2[0] = UINT16_TO_LE(i + 2);
//        seed_A_origin_3[0] = UINT16_TO_LE(i + 3);
//        shake128_4x((unsigned char*)(a_row), (unsigned char*)(a_row + PARAMS_N), (unsigned char*)(a_row + 2*PARAMS_N), (unsigned char*)(a_row + 3*PARAMS_N),
//                    (unsigned long long)(2*PARAMS_N), seed_A_separated_0, seed_A_separated_1, seed_A_separated_2, seed_A_separated_3, 2 + BYTES_SEED_A);
//#endif
//#endif
//        for (k = 0; k < 4 * PARAMS_N; k++) {
//            a_row[k] = LE_TO_UINT16(a_row[k]);
//        }
//        for (k = 0; k < PARAMS_NBAR; k++) {
//            uint16_t sum[4] = {0};
//            for (j = 0; j < PARAMS_N; j++) {                    // Matrix-vector multiplication
//                uint16_t sp = s[k*PARAMS_N + j];
//                sum[0] += a_row[0*PARAMS_N + j] * sp;           // Go through four lines with same s
//                sum[1] += a_row[1*PARAMS_N + j] * sp;
//                sum[2] += a_row[2*PARAMS_N + j] * sp;
//                sum[3] += a_row[3*PARAMS_N + j] * sp;
//            }
//            out[(i+0)*PARAMS_NBAR + k] += sum[0];
//            out[(i+2)*PARAMS_NBAR + k] += sum[2];
//            out[(i+1)*PARAMS_NBAR + k] += sum[1];
//            out[(i+3)*PARAMS_NBAR + k] += sum[3];
//        }
//    }
//
//#if defined(USE_AES128_FOR_A)
//    AES128_free_schedule(aes_key_schedule);
//#endif
//
//#if 0
//	int16_t max = 0, min = 0;
//	printf("A:\n");
//	for (int i = 0; i < 2560; i++)
//	{
//		printf("%d ", a_row[i]);
//		if (max < a_row[i])
//			max = a_row[i];
//
//		if (min > a_row[i])
//			min = a_row[i];
//	}
//	printf("\nMax: %d | Min: %d\n", max, min);
//#endif
//    return 1;
//}

//////// END

// Auxiliar function HW
void frodo_mul_add_as_plus_e_hw_func(uint32_t * A, uint32_t * S, uint32_t * B, uint8_t send_s, uint8_t send_data)
{
	//Variables
	int i;
	u32 readGpio = 0x0;

//	//Set start pin high
//	XGpio_DiscreteWrite(&axiStartBusyMatrix2, 1, 0x1); // Start gpio set high

//	for(j = 0; j < 160; j++)
//	{

		//Sending data A
		for(i = 0; i < 1280; i++)
		{
			memoryMatrixA2[i] = A[i];
//			if(i < 20 || i > 1200)
//			if(i >= PARAMS_N && i < PARAMS_N + 20 )
//				print_debug(DEBUG_MATRIX_MM, "\tSent data A2[%d]: 0x%lx\n", i, A[i]);
		}

		//Sending data S
		if(send_s)
		{
			for(i = 0; i < 2560; i++)
			{
				memoryMatrixS2[i] = S[i];
	//			if(i < 20 || i > 2500)
	//			if(i >= PARAMS_N && i < PARAMS_N + 20 )
	//				print_debug(DEBUG_MATRIX_MM, "\tSent data S2[%d]: 0x%lx\n", i, S[i]);
			}
		}


		//Reading busy bit
		readGpio = XGpio_DiscreteRead(&axiStartBusyMatrix2, 1); //Check done pin
		while(readGpio == 0x1)
		{
			readGpio = XGpio_DiscreteRead(&axiStartBusyMatrix2, 1);
		}
//		print_debug(DEBUG_MATRIX_MM, "[MATRIX] Busy bit low!\n");
//	}

	//Interpret data
	if(send_data)
	{
		for (i = 0; i < 2560; i++)
		{
			B[i] = memoryMatrixB2[i];
	//		if(i < 20 || i > 2500)
	//			print_debug(DEBUG_MATRIX_MM, "\tB2[%d]: 0x%lx\n", i, B[i]);
		}
	}


//	//Set start pin low
//	XGpio_DiscreteWrite(&axiStartBusyMatrix2, 1, 0x0); // Start gpio set low
}

int frodo_mul_add_as_plus_e_HW(uint16_t *out, const uint16_t *s, const uint16_t *e, const uint8_t *seed_A, uint32_t *u32AccTime, uint32_t *u32ItCounter)
//int frodo_mul_add_as_plus_e(uint16_t *out, const uint16_t *s, const uint16_t *e, const uint8_t *seed_A)
{ // Generate-and-multiply: generate matrix A (N x N) row-wise, multiply by s on the right.
  // Inputs: s, e (N x N_BAR)
  // Output: out = A*s + e (N x N_BAR)

#if ENABLE_SW_TIMER
	resetTimer(&general_hw_timer_control);
	startTimer(&general_hw_timer_control);
#endif

	int i, k;
	ALIGN_HEADER(32) int16_t a_row[4*PARAMS_N] ALIGN_FOOTER(32) = {0};

	for (i = 0; i < (PARAMS_N*PARAMS_NBAR); i += 2) {
		*((uint32_t*)&out[i]) = *((uint32_t*)&e[i]);
	}

	uint8_t seed_A_separated[2 + BYTES_SEED_A];
	uint16_t* seed_A_origin = (uint16_t*)&seed_A_separated;
	uint32_t b_matrix[PARAMS_N*PARAMS_NBAR/2];
	memcpy(&seed_A_separated[2], seed_A, BYTES_SEED_A);
	uint8_t req_data = 0;
	uint8_t send_s = 1;

	//Set start pin high
	XGpio_DiscreteWrite(&axiStartBusyMatrix2, 1, 0x1); // Start gpio set high

	for (i = 0; i < PARAMS_N; i += 4) {

#if ENABLE_SW_TIMER
		//Accumulate time (SHAKE will not accumulate)
		stopTimer(&general_hw_timer_control);
		*u32AccTime += getTimer(&general_hw_timer) * 10; //Transform pulses into ns
#endif

		seed_A_origin[0] = UINT16_TO_LE(i + 0);
		shake128((unsigned char*)(a_row + 0*PARAMS_N), (unsigned long long)(2*PARAMS_N), seed_A_separated, 2 + BYTES_SEED_A);
		seed_A_origin[0] = UINT16_TO_LE(i + 1);
		shake128((unsigned char*)(a_row + 1*PARAMS_N), (unsigned long long)(2*PARAMS_N), seed_A_separated, 2 + BYTES_SEED_A);
		seed_A_origin[0] = UINT16_TO_LE(i + 2);
		shake128((unsigned char*)(a_row + 2*PARAMS_N), (unsigned long long)(2*PARAMS_N), seed_A_separated, 2 + BYTES_SEED_A);
		seed_A_origin[0] = UINT16_TO_LE(i + 3);
		shake128((unsigned char*)(a_row + 3*PARAMS_N), (unsigned long long)(2*PARAMS_N), seed_A_separated, 2 + BYTES_SEED_A);

#if ENABLE_SW_TIMER
		//Start time
		resetTimer(&general_hw_timer_control);
		startTimer(&general_hw_timer_control);
#endif

//		for (k = 0; k < 4 * PARAMS_N; k++) {
//			a_row[k] = LE_TO_UINT16(a_row[k]);
//		}

		if(i == PARAMS_N - 4)
			req_data = 1;

		if(i > 0)
			send_s = 0;

		frodo_mul_add_as_plus_e_hw_func((uint32_t *)a_row, (uint32_t *)s, b_matrix, send_s, req_data);
	}

	//Set start pin low
	XGpio_DiscreteWrite(&axiStartBusyMatrix2, 1, 0x0); // Start gpio set low

	for (k = 0; k < (PARAMS_N*PARAMS_NBAR); k++)
	{
		if((k & 0x1) == 0)
			out[k] = (b_matrix[k >> 1] >> 16) + e[k];
		else
			out[k] = (b_matrix[k >> 1] & 0xffff) + e[k];
	}

#if ENABLE_SW_TIMER
	stopTimer(&general_hw_timer_control);

//	print_debug(1, "[AS_HW_IN] Time taken: %lu\n", getTimer(&general_hw_timer_control) * 10);

	//Transfer values
	*u32AccTime += getTimer(&general_hw_timer) * 10; //Transform pulses into ns

	//Add iteration
	*u32ItCounter = *u32ItCounter + 1;
#endif

	return 1;
}

int frodo_mul_add_as_plus_e_SW(uint16_t *out, const uint16_t *s, const uint16_t *e, const uint8_t *seed_A, uint32_t *u32AccTime, uint32_t *u32ItCounter)
//int frodo_mul_add_as_plus_e(uint16_t *out, const uint16_t *s, const uint16_t *e, const uint8_t *seed_A)
{ // Generate-and-multiply: generate matrix A (N x N) row-wise, multiply by s on the right.
  // Inputs: s, e (N x N_BAR)
  // Output: out = A*s + e (N x N_BAR)

#if ENABLE_SW_TIMER
	resetTimer(&general_hw_timer_control);
	startTimer(&general_hw_timer_control);
#endif

	int i, j, k;
	ALIGN_HEADER(32) int16_t a_row[4*PARAMS_N] ALIGN_FOOTER(32) = {0};

	for (i = 0; i < (PARAMS_N*PARAMS_NBAR); i += 2) {
		*((uint32_t*)&out[i]) = *((uint32_t*)&e[i]);
	}

	uint8_t seed_A_separated[2 + BYTES_SEED_A];
	uint16_t* seed_A_origin = (uint16_t*)&seed_A_separated;
	memcpy(&seed_A_separated[2], seed_A, BYTES_SEED_A);

	for (i = 0; i < PARAMS_N; i += 4) {

#if ENABLE_SW_TIMER
		//Accumulate time (SHAKE will not accumulate)
		stopTimer(&general_hw_timer_control);
		*u32AccTime += getTimer(&general_hw_timer) * 10; //Transform pulses into ns
#endif

		seed_A_origin[0] = UINT16_TO_LE(i + 0);
		shake128((unsigned char*)(a_row + 0*PARAMS_N), (unsigned long long)(2*PARAMS_N), seed_A_separated, 2 + BYTES_SEED_A);
		seed_A_origin[0] = UINT16_TO_LE(i + 1);
		shake128((unsigned char*)(a_row + 1*PARAMS_N), (unsigned long long)(2*PARAMS_N), seed_A_separated, 2 + BYTES_SEED_A);
		seed_A_origin[0] = UINT16_TO_LE(i + 2);
		shake128((unsigned char*)(a_row + 2*PARAMS_N), (unsigned long long)(2*PARAMS_N), seed_A_separated, 2 + BYTES_SEED_A);
		seed_A_origin[0] = UINT16_TO_LE(i + 3);
		shake128((unsigned char*)(a_row + 3*PARAMS_N), (unsigned long long)(2*PARAMS_N), seed_A_separated, 2 + BYTES_SEED_A);

#if ENABLE_SW_TIMER
		//Start time
		resetTimer(&general_hw_timer_control);
		startTimer(&general_hw_timer_control);
#endif

		for (k = 0; k < 4 * PARAMS_N; k++) {
			a_row[k] = LE_TO_UINT16(a_row[k]);
		}

		for (k = 0; k < PARAMS_NBAR; k++) {
			uint16_t sum[4] = {0};
			for (j = 0; j < PARAMS_N; j++) {                    // Matrix-vector multiplication
				uint16_t sp = s[k*PARAMS_N + j];
				sum[0] += a_row[0*PARAMS_N + j] * sp;           // Go through four lines with same s
				sum[1] += a_row[1*PARAMS_N + j] * sp;
				sum[2] += a_row[2*PARAMS_N + j] * sp;
				sum[3] += a_row[3*PARAMS_N + j] * sp;
			}
			out[(i+0)*PARAMS_NBAR + k] += sum[0];
			out[(i+2)*PARAMS_NBAR + k] += sum[2];
			out[(i+1)*PARAMS_NBAR + k] += sum[1];
			out[(i+3)*PARAMS_NBAR + k] += sum[3];
		}

	} //for i

#if ENABLE_SW_TIMER
	stopTimer(&general_hw_timer_control);

	//Transfer values
	*u32AccTime += getTimer(&general_hw_timer) * 10; //Transform pulses into ns

	//Add iteration
	*u32ItCounter = *u32ItCounter + 1;
#endif

	return 1;
}

/*************************************************************************************************************
***
***	FRODO_MUL_ADD_SA_PLUS_E
***
**************************************************************************************************************/
///////// ORIGINAL

//int frodo_mul_add_sa_plus_e(uint16_t *out, const uint16_t *s, const uint16_t *e, const uint8_t *seed_A)
//{ // Generate-and-multiply: generate matrix A (N x N) column-wise, multiply by s' on the left.
//  // Inputs: s', e' (N_BAR x N)
//  // Output: out = s'*A + e' (N_BAR x N)
//	int i, j, kk;
//
//	for (i = 0; i < (PARAMS_N*PARAMS_NBAR); i += 2) {
//		*((uint32_t*)&out[i]) = *((uint32_t*)&e[i]);
//	}
//
////	uint16_t out2[PARAMS_N*PARAMS_NBAR];
////	for (i = 0; i < (PARAMS_N*PARAMS_NBAR); i += 2) {
////		*((uint32_t*)&out2[i]) = *((uint32_t*)&e[i]);
////	}
//
////	print_debug(DEBUG_MATRIX_MM, "\tout[0]: 0x%lx\n", out[0]);
////	print_debug(DEBUG_MATRIX_MM, "\tout[1]: 0x%lx\n", out[1]);
////	print_debug(DEBUG_MATRIX_MM, "\tout2[0]: 0x%lx\n", out2[0]);
////	print_debug(DEBUG_MATRIX_MM, "\tout2[1]: 0x%lx\n", out2[1]);
//
//#if defined(USE_AES128_FOR_A)
//	int k;
//	uint16_t a_cols[PARAMS_N*PARAMS_STRIPE_STEP] = {0};
//	ALIGN_HEADER(32) uint16_t a_cols_t[PARAMS_N*PARAMS_STRIPE_STEP] ALIGN_FOOTER(32) = {0};
//	uint16_t a_cols_temp[PARAMS_N*PARAMS_STRIPE_STEP] = {0};
//#if !defined(USE_OPENSSL)
//	uint8_t aes_key_schedule[16*11];
//	AES128_load_schedule(seed_A, aes_key_schedule);
//#else
//	EVP_CIPHER_CTX *aes_key_schedule;
//	int len;
//	if (!(aes_key_schedule = EVP_CIPHER_CTX_new())) handleErrors();
//	if (1 != EVP_EncryptInit_ex(aes_key_schedule, EVP_aes_128_ecb(), NULL, seed_A, NULL)) handleErrors();
//#endif
//
//	for (i = 0, j = 0; i < PARAMS_N; i++, j += PARAMS_STRIPE_STEP) {
//		a_cols_temp[j] = UINT16_TO_LE(i);                       // Loading values in the little-endian order
//	}
//
//	for (kk = 0; kk < PARAMS_N; kk += PARAMS_STRIPE_STEP) {     // Go through A's columns, 8 (== PARAMS_STRIPE_STEP) columns at a time.
//		for (i = 0; i < (PARAMS_N*PARAMS_STRIPE_STEP); i += PARAMS_STRIPE_STEP) {
//			a_cols_temp[i + 1] = UINT16_TO_LE(kk);              // Loading values in the little-endian order
//		}
//
//#if !defined(USE_OPENSSL)
//		AES128_ECB_enc_sch((uint8_t*)a_cols_temp, PARAMS_N*PARAMS_STRIPE_STEP*sizeof(int16_t), aes_key_schedule, (uint8_t*)a_cols);
//#else
//		if (1 != EVP_EncryptUpdate(aes_key_schedule, (uint8_t*)a_cols, &len, (uint8_t*)a_cols_temp, PARAMS_N*PARAMS_STRIPE_STEP*sizeof(int16_t))) handleErrors();
//#endif
//
//		for (i = 0; i < PARAMS_N; i++) {                        // Transpose a_cols to have access to it in the column-major order.
//			for (k = 0; k < PARAMS_STRIPE_STEP; k++) {
//				a_cols_t[k*PARAMS_N + i] = LE_TO_UINT16(a_cols[i*PARAMS_STRIPE_STEP + k]);
//			}
//		}
//
//#if !defined(USE_AVX2)
//		for (i = 0; i < PARAMS_NBAR; i++) {
//			for (k = 0; k < PARAMS_STRIPE_STEP; k += PARAMS_PARALLEL) {
//				uint16_t sum[PARAMS_PARALLEL] = {0};
//				for (j = 0; j < PARAMS_N; j++) {                // Matrix-vector multiplication
//					uint16_t sp = s[i*PARAMS_N + j];
//					sum[0] += sp * a_cols_t[(k+0)*PARAMS_N + j];
//					sum[1] += sp * a_cols_t[(k+1)*PARAMS_N + j];
//					sum[2] += sp * a_cols_t[(k+2)*PARAMS_N + j];
//					sum[3] += sp * a_cols_t[(k+3)*PARAMS_N + j];
//				}
//				out[i*PARAMS_N + kk + k + 0] += sum[0];
//				out[i*PARAMS_N + kk + k + 2] += sum[2];
//				out[i*PARAMS_N + kk + k + 1] += sum[1];
//				out[i*PARAMS_N + kk + k + 3] += sum[3];
//			}
//		}
//	}
//#else  // Using vector intrinsics
//		for (i = 0; i < PARAMS_NBAR; i++) {
//			for (k = 0; k < PARAMS_STRIPE_STEP; k += PARAMS_PARALLEL) {
//				ALIGN_HEADER(32) uint32_t sum[8 * PARAMS_PARALLEL] ALIGN_FOOTER(32);
//				__m256i a[PARAMS_PARALLEL], b, acc[PARAMS_PARALLEL];
//				acc[0] = _mm256_setzero_si256();
//				acc[1] = _mm256_setzero_si256();
//				acc[2] = _mm256_setzero_si256();
//				acc[3] = _mm256_setzero_si256();
//				for (j = 0; j < PARAMS_N; j += 16) {            // Matrix-vector multiplication
//					b = _mm256_load_si256((__m256i*)&s[i*PARAMS_N + j]);
//					a[0] = _mm256_load_si256((__m256i*)&a_cols_t[(k+0)*PARAMS_N + j]);
//					a[0] = _mm256_madd_epi16(a[0], b);
//					acc[0] = _mm256_add_epi16(a[0], acc[0]);
//					a[1] = _mm256_load_si256((__m256i*)&a_cols_t[(k+1)*PARAMS_N + j]);
//					a[1] = _mm256_madd_epi16(a[1], b);
//					acc[1] = _mm256_add_epi16(a[1], acc[1]);
//					a[2] = _mm256_load_si256((__m256i*)&a_cols_t[(k+2)*PARAMS_N + j]);
//					a[2] = _mm256_madd_epi16(a[2], b);
//					acc[2] = _mm256_add_epi16(a[2], acc[2]);
//					a[3] = _mm256_load_si256((__m256i*)&a_cols_t[(k+3)*PARAMS_N + j]);
//					a[3] = _mm256_madd_epi16(a[3], b);
//					acc[3] = _mm256_add_epi16(a[3], acc[3]);
//				}
//				_mm256_store_si256((__m256i*)(sum + (8*0)), acc[0]);
//				out[i*PARAMS_N + kk + k + 0] += sum[8*0 + 0] + sum[8*0 + 1] + sum[8*0 + 2] + sum[8*0 + 3] + sum[8*0 + 4] + sum[8*0 + 5] + sum[8*0 + 6] + sum[8*0 + 7];
//				_mm256_store_si256((__m256i*)(sum + (8*1)), acc[1]);
//				out[i*PARAMS_N + kk + k + 1] += sum[8*1 + 0] + sum[8*1 + 1] + sum[8*1 + 2] + sum[8*1 + 3] + sum[8*1 + 4] + sum[8*1 + 5] + sum[8*1 + 6] + sum[8*1 + 7];
//				_mm256_store_si256((__m256i*)(sum + (8*2)), acc[2]);
//				out[i*PARAMS_N + kk + k + 2] += sum[8*2 + 0] + sum[8*2 + 1] + sum[8*2 + 2] + sum[8*2 + 3] + sum[8*2 + 4] + sum[8*2 + 5] + sum[8*2 + 6] + sum[8*2 + 7];
//				_mm256_store_si256((__m256i*)(sum + (8*3)), acc[3]);
//				out[i*PARAMS_N + kk + k + 3] += sum[8*3 + 0] + sum[8*3 + 1] + sum[8*3 + 2] + sum[8*3 + 3] + sum[8*3 + 4] + sum[8*3 + 5] + sum[8*3 + 6] + sum[8*3 + 7];
//			}
//		}
//	}
//#endif
//	AES128_free_schedule(aes_key_schedule);
//
//#elif defined (USE_SHAKE128_FOR_A)  // SHAKE128
//	int t=0;
//	ALIGN_HEADER(32) uint16_t a_cols[4*PARAMS_N] ALIGN_FOOTER(32) = {0};
//
//#if defined(WINDOWS) | !defined(USE_AVX2)
//	int k;
//	uint8_t seed_A_separated[2 + BYTES_SEED_A];
//	uint16_t* seed_A_origin = (uint16_t*)&seed_A_separated;
//	memcpy(&seed_A_separated[2], seed_A, BYTES_SEED_A);
//
//#if ENABLE_MATRIX_HW
//	uint32_t s_matrix[16];
//	uint32_t * a_matrix;
//	uint8_t idx_s_matrix;
//	uint32_t sum2[PARAMS_N * PARAMS_NBAR / 2];
//	uint16_t out2[PARAMS_N*PARAMS_NBAR] = {0};
//	for (i = 0; i < (PARAMS_N*PARAMS_NBAR); i += 2) {
//		*((uint32_t*)&out2[i]) = *((uint32_t*)&e[i]);
//	}
//
//#if ENABLE_MATRIX_SW == 1 & ENABLE_MATRIX_HW == 1
//	//Previous comparison
//	for (i = 0; i < (PARAMS_N*PARAMS_NBAR); i++)
//	{
//		if(out[i] != out2[i])
//			print_debug(DEBUG_MATRIX_MM, "\tComparison error of previous out at %d\n", i);
//	}
//#endif
//
//#endif
//
//	for (kk = 0; kk < PARAMS_N; kk+=4) {
//
//		//Set start pin high
//		XGpio_DiscreteWrite(&axiStartBusyMatrix, 1, 0x1); // Start gpio set high
//
////		print_debug(DEBUG_MATRIX_MM, "kk: %d\n", kk);
//		seed_A_origin[0] = UINT16_TO_LE(kk + 0);
//		shake128((unsigned char*)(a_cols + 0*PARAMS_N), (unsigned long long)(2*PARAMS_N), seed_A_separated, 2 + BYTES_SEED_A);
//		seed_A_origin[0] = UINT16_TO_LE(kk + 1);
//		shake128((unsigned char*)(a_cols + 1*PARAMS_N), (unsigned long long)(2*PARAMS_N), seed_A_separated, 2 + BYTES_SEED_A);
//		seed_A_origin[0] = UINT16_TO_LE(kk + 2);
//		shake128((unsigned char*)(a_cols + 2*PARAMS_N), (unsigned long long)(2*PARAMS_N), seed_A_separated, 2 + BYTES_SEED_A);
//		seed_A_origin[0] = UINT16_TO_LE(kk + 3);
//		shake128((unsigned char*)(a_cols + 3*PARAMS_N), (unsigned long long)(2*PARAMS_N), seed_A_separated, 2 + BYTES_SEED_A);
//		for (i = 0; i < 4 * PARAMS_N; i++) {
//			a_cols[i] = LE_TO_UINT16(a_cols[i]);
//		}
//
//#if ENABLE_MATRIX_HW
//		idx_s_matrix = 0;
//		for(i = 0; i < PARAMS_NBAR; i++)
//		{
//			for(j = 0; j < 4; j+=2)
//			{
//				s_matrix[idx_s_matrix] = (s[i*PARAMS_N + kk + j] << 16) | s[i*PARAMS_N + kk + j + 1];
//				idx_s_matrix++;
//			}
//		}
//		a_matrix = (uint32_t *)a_cols;
//
//		frodo_mul_add_sa_plus_e_hw(s_matrix, a_matrix, sum2);
//
////		print_debug(DEBUG_MATRIX_MM, "Fim hw\n");
//
////		for(i = 0; i < PARAMS_NBAR; i++)
////		{
////			for(k = 0; k < PARAMS_N; k+=2)
////			{
////				out2[i*PARAMS_N + k] += sum2[i*PARAMS_N + (k >> 1)] & 0xffff;
////				out2[i*PARAMS_N + k + 1] += sum2[i*PARAMS_N + (k >> 1)] >> 16;
//////				if(i == 0 && k < 4)
//////				{
//////					print_debug(DEBUG_MATRIX_MM, "\tsum2h[%d]: 0x%lx\n", i*PARAMS_N + (k >> 1), sum2[i*PARAMS_N + (k >> 1)] & 0xffff);
//////					print_debug(DEBUG_MATRIX_MM, "\tsum2l[%d]: 0x%lx\n", i*PARAMS_N + (k >> 1), sum2[i*PARAMS_N + (k >> 1)] >> 16);
//////				}
////
////			}
////		}
//
//		for (k = 0; k < (PARAMS_N*PARAMS_NBAR); k++)
//		{
//			if((k & 0x1) == 0)
//				out[k] += sum2[k >> 1] & 0xffff;
//			else
//				out[k] += sum2[k >> 1] >> 16;
//		}
//
//		//Compare outs
////		for(i = 0; i < PARAMS_NBAR; i++)
////		{
////			for(k = 0; k < PARAMS_N; k+=2)
////			{
////				if(out[i*PARAMS_N + k] != out2[i*PARAMS_N + k])
////				{
////					print_debug(DEBUG_MATRIX_MM, "out[%d] = 0x%lx != out2[%d] = 0x%lx\n", i*PARAMS_N + k, out[i*PARAMS_N + k], i*PARAMS_N + k, out2[i*PARAMS_N + k]);
////				}
////			}
////		}
//
////		print_debug(DEBUG_MATRIX_MM, "\tsum2[0]: 0x%lx\n", sum2[0] & 0xffff);
////		print_debug(DEBUG_MATRIX_MM, "\tsum2[1]: 0x%lx\n", sum2[0] >> 16);
////		print_debug(DEBUG_MATRIX_MM, "\tsum2[3]: 0x%lx\n", sum2[1] & 0xffff);
////		print_debug(DEBUG_MATRIX_MM, "\tsum2[4]: 0x%lx\n", sum2[1] >> 16);
////
////		print_debug(DEBUG_MATRIX_MM, "Fim um kk\n");
//#endif
//
//#if ENABLE_MATRIX_SW
//		for (i = 0; i < PARAMS_NBAR; i++) {
//			uint16_t sum[PARAMS_N] = {0};
//			for (j = 0; j < 4; j++) {
//				uint16_t sp = s[i*PARAMS_N + kk + j];
//				for (k = 0; k < PARAMS_N; k++) {                // Matrix-vector multiplication
//					sum[k] += sp * a_cols[(t+j)*PARAMS_N + k];
//				}
//			 }
////			print_debug(DEBUG_MATRIX_MM, "\tsum[0]: 0x%lx\n", sum[0]);
////			print_debug(DEBUG_MATRIX_MM, "\tsum[1]: 0x%lx\n", sum[1]);
////			print_debug(DEBUG_MATRIX_MM, "\tsum[2]: 0x%lx\n", sum[2]);
////			print_debug(DEBUG_MATRIX_MM, "\tsum[3]: 0x%lx\n", sum[3]);
//			for(k = 0; k < PARAMS_N; k++){
//				out[i*PARAMS_N + k] += sum[k];
//
//				//Compare with HW
//				if((k & 0x1) == 0)
//				{
//					if(sum[k] != (sum2[(i*PARAMS_N + k) >> 1] & 0xffff))
//						print_debug(DEBUG_MATRIX_MM, "\tPos %d: sum: 0x%lx e  sum2: 0x%lx\n", i*PARAMS_N + k, sum[k], sum2[(i*PARAMS_N + k) >> 1] & 0xffff);
////					else
////						print_debug(DEBUG_MATRIX_MM, "\tPos %d: ok\n", i*PARAMS_N + k);
//
//				}
//				else
//				{
//					if(sum[k] != (sum2[(i*PARAMS_N + k) >> 1] >> 16))
//						print_debug(DEBUG_MATRIX_MM, "\tPos %d: sum: 0x%lx e  sum2: 0x%lx\n", i*PARAMS_N + k, sum[k], sum2[(i*PARAMS_N + k) >> 1] >> 16);
////					else
////						print_debug(DEBUG_MATRIX_MM, "\tPos %d: ok\n", i*PARAMS_N + k);
//				}
//
//			}
//
////			print_debug(DEBUG_MATRIX_MM, "\ts[0:3]: 0x%lx 0x%lx 0x%lx 0x%lx\n", s[0], s[1], s[2], s[3]);
////			print_debug(DEBUG_MATRIX_MM, "\ta[0,640,1280,1920]: 0x%lx 0x%lx 0x%lx 0x%lx\n", a_cols[0], a_cols[640], a_cols[1280], a_cols[1920]);
////			print_debug(DEBUG_MATRIX_MM, "\ta[1,641,1281,1921]: 0x%lx 0x%lx 0x%lx 0x%lx\n", a_cols[1], a_cols[641], a_cols[1281], a_cols[1921]);
////			print_debug(DEBUG_MATRIX_MM, "\ta[2,642,1282,1922]: 0x%lx 0x%lx 0x%lx 0x%lx\n", a_cols[2], a_cols[642], a_cols[1282], a_cols[1922]);
////			print_debug(DEBUG_MATRIX_MM, "\ta[3,643,1283,1923]: 0x%lx 0x%lx 0x%lx 0x%lx\n", a_cols[3], a_cols[643], a_cols[1283], a_cols[1923]);
////			print_debug(DEBUG_MATRIX_MM, "\tsum[0]: 0x%lx\n", sum[0]);
////			print_debug(DEBUG_MATRIX_MM, "\tsum[1]: 0x%lx\n", sum[1]);
////			print_debug(DEBUG_MATRIX_MM, "\tsum[2]: 0x%lx\n", sum[2]);
////			print_debug(DEBUG_MATRIX_MM, "\tsum[3]: 0x%lx\n", sum[3]);
//		}
//#endif
//
//#if ENABLE_MATRIX_HW
//		//Set start pin high
//		XGpio_DiscreteWrite(&axiStartBusyMatrix, 1, 0x0); // Start gpio set low
//#endif
//
//	} //kk for
//
//#if ENABLE_MATRIX_SW == 1 & ENABLE_MATRIX_HW == 1
//	//Post comparison
//	for (i = 0; i < (PARAMS_N*PARAMS_NBAR); i++)
//	{
//		if(out[i] != out2[i])
//			print_debug(DEBUG_MATRIX_MM, "\tComparison error of post out at %d\n", i);
//	}
//#endif
//
//
//#else  // Using vector intrinsics
//	uint8_t seed_A_separated_0[2 + BYTES_SEED_A];
//	uint8_t seed_A_separated_1[2 + BYTES_SEED_A];
//	uint8_t seed_A_separated_2[2 + BYTES_SEED_A];
//	uint8_t seed_A_separated_3[2 + BYTES_SEED_A];
//	uint16_t* seed_A_origin_0 = (uint16_t*)&seed_A_separated_0;
//	uint16_t* seed_A_origin_1 = (uint16_t*)&seed_A_separated_1;
//	uint16_t* seed_A_origin_2 = (uint16_t*)&seed_A_separated_2;
//	uint16_t* seed_A_origin_3 = (uint16_t*)&seed_A_separated_3;
//	memcpy(&seed_A_separated_0[2], seed_A, BYTES_SEED_A);
//	memcpy(&seed_A_separated_1[2], seed_A, BYTES_SEED_A);
//	memcpy(&seed_A_separated_2[2], seed_A, BYTES_SEED_A);
//	memcpy(&seed_A_separated_3[2], seed_A, BYTES_SEED_A);
//	for (kk = 0; kk < PARAMS_N; kk+=4) {
//		seed_A_origin_0[0] = UINT16_TO_LE(kk + 0);
//		seed_A_origin_1[0] = UINT16_TO_LE(kk + 1);
//		seed_A_origin_2[0] = UINT16_TO_LE(kk + 2);
//		seed_A_origin_3[0] = UINT16_TO_LE(kk + 3);
//		shake128_4x((unsigned char*)(a_cols), (unsigned char*)(a_cols + PARAMS_N), (unsigned char*)(a_cols + 2*PARAMS_N), (unsigned char*)(a_cols + 3*PARAMS_N),
//					(unsigned long long)(2*PARAMS_N), seed_A_separated_0, seed_A_separated_1, seed_A_separated_2, seed_A_separated_3, 2 + BYTES_SEED_A);
//
//		for (i = 0; i < PARAMS_NBAR; i++) {
//			__m256i a, b0, b1, b2, b3, acc[PARAMS_N/16];
//			b0 = _mm256_set1_epi16(s[i*PARAMS_N + kk + 0]);
//			b1 = _mm256_set1_epi16(s[i*PARAMS_N + kk + 1]);
//			b2 = _mm256_set1_epi16(s[i*PARAMS_N + kk + 2]);
//			b3 = _mm256_set1_epi16(s[i*PARAMS_N + kk + 3]);
//			for (j = 0; j < PARAMS_N; j+=16) {                  // Matrix-vector multiplication
//				acc[j/16] = _mm256_load_si256((__m256i*)&out[i*PARAMS_N + j]);
//				a = _mm256_load_si256((__m256i*)&a_cols[(t+0)*PARAMS_N + j]);
//				a = _mm256_mullo_epi16(a, b0);
//				acc[j/16] = _mm256_add_epi16(a, acc[j/16]);
//				a = _mm256_load_si256((__m256i*)&a_cols[(t+1)*PARAMS_N + j]);
//				a = _mm256_mullo_epi16(a, b1);
//				acc[j/16] = _mm256_add_epi16(a, acc[j/16]);
//				a = _mm256_load_si256((__m256i*)&a_cols[(t+2)*PARAMS_N + j]);
//				a = _mm256_mullo_epi16(a, b2);
//				acc[j/16] = _mm256_add_epi16(a, acc[j/16]);
//				a = _mm256_load_si256((__m256i*)&a_cols[(t+3)*PARAMS_N + j]);
//				a = _mm256_mullo_epi16(a, b3);
//				acc[j/16] = _mm256_add_epi16(a, acc[j/16]);
//			}
//
//			for (j = 0; j < PARAMS_N/16; j++) {
//				_mm256_store_si256((__m256i*)&out[i*PARAMS_N + 16*j], acc[j]);
//			}
//		}
//	}
//#endif
//#endif
//
//	return 1;
//}

///////// END

//Software
int frodo_mul_add_sa_plus_e_SW(uint16_t *out, const uint16_t *s, const uint16_t *e, const uint8_t *seed_A, uint32_t *u32AccTime, uint32_t *u32ItCounter)
{ // Generate-and-multiply: generate matrix A (N x N) column-wise, multiply by s' on the left.
	// Inputs: s', e' (N_BAR x N)
	// Output: out = s'*A + e' (N_BAR x N)
#if ENABLE_SW_TIMER
	resetTimer(&general_hw_timer_control);
	startTimer(&general_hw_timer_control);
#endif

	int i, j, kk;

	for (i = 0; i < (PARAMS_N*PARAMS_NBAR); i += 2) {
		*((uint32_t*)&out[i]) = *((uint32_t*)&e[i]);
	}

	int t=0;
	ALIGN_HEADER(32) uint16_t a_cols[4*PARAMS_N] ALIGN_FOOTER(32) = {0};

	int k;
	uint8_t seed_A_separated[2 + BYTES_SEED_A];
	uint16_t* seed_A_origin = (uint16_t*)&seed_A_separated;
	memcpy(&seed_A_separated[2], seed_A, BYTES_SEED_A);

	for (kk = 0; kk < PARAMS_N; kk+=4) {

#if ENABLE_SW_TIMER
		//Accumulate time (SHAKE will not accumulate)
		stopTimer(&general_hw_timer_control);
		*u32AccTime += getTimer(&general_hw_timer) * 10; //Transform pulses into ns
#endif

//		print_debug(DEBUG_MATRIX_MM, "kk: %d\n", kk);
		seed_A_origin[0] = UINT16_TO_LE(kk + 0);
		shake128((unsigned char*)(a_cols + 0*PARAMS_N), (unsigned long long)(2*PARAMS_N), seed_A_separated, 2 + BYTES_SEED_A);
		seed_A_origin[0] = UINT16_TO_LE(kk + 1);
		shake128((unsigned char*)(a_cols + 1*PARAMS_N), (unsigned long long)(2*PARAMS_N), seed_A_separated, 2 + BYTES_SEED_A);
		seed_A_origin[0] = UINT16_TO_LE(kk + 2);
		shake128((unsigned char*)(a_cols + 2*PARAMS_N), (unsigned long long)(2*PARAMS_N), seed_A_separated, 2 + BYTES_SEED_A);
		seed_A_origin[0] = UINT16_TO_LE(kk + 3);
		shake128((unsigned char*)(a_cols + 3*PARAMS_N), (unsigned long long)(2*PARAMS_N), seed_A_separated, 2 + BYTES_SEED_A);
//		for (i = 0; i < 4 * PARAMS_N; i++) {
//			a_cols[i] = LE_TO_UINT16(a_cols[i]);
//		}

#if ENABLE_SW_TIMER
		//Start time
		resetTimer(&general_hw_timer_control);
		startTimer(&general_hw_timer_control);
#endif

		for (i = 0; i < PARAMS_NBAR; i++) {
			uint16_t sum[PARAMS_N] = {0};
			for (j = 0; j < 4; j++) {
				uint16_t sp = s[i*PARAMS_N + kk + j];
				for (k = 0; k < PARAMS_N; k++) {                // Matrix-vector multiplication
					sum[k] += sp * a_cols[(t+j)*PARAMS_N + k];
				}
			 }
			for(k = 0; k < PARAMS_N; k++){
				out[i*PARAMS_N + k] += sum[k];
			}
		}
	} //kk for

#if ENABLE_SW_TIMER
	stopTimer(&general_hw_timer_control);

	//Transfer values
	*u32AccTime += getTimer(&general_hw_timer) * 10; //Transform pulses into ns

	//Add iteration
	*u32ItCounter = *u32ItCounter + 1;
#endif

	return 1;
}

// Auxiliar function HW
void frodo_mul_add_sa_plus_e_hw_func(uint32_t * S, uint32_t * A, uint32_t * B, uint8_t req_data)
{
	//Variables
	int i;
	u32 readGpio = 0x0;

	//Sending data S
	for(i = 0; i < 16; i++)
	{
		memoryMatrixS[i] = S[i];
//		print_debug(DEBUG_MATRIX_MM, "\tSent data S[%d]: 0x%lx\n", i, S[i]);
	}

	//Sending data A
	for(i = 0; i < 1280; i++)
	{
		memoryMatrixA[i] = A[i];
//		print_debug(DEBUG_MATRIX_MM, "\tSent data A[%d]: 0x%lx\n", i, A[i]);
	}

	//Reading busy bit
	readGpio = XGpio_DiscreteRead(&axiStartBusyMatrix, 1); //Check done pin
	while(readGpio == 0x1)
	{
		readGpio = XGpio_DiscreteRead(&axiStartBusyMatrix, 1);
	}
//	print_debug(DEBUG_MATRIX_MM, "[MATRIX] Busy bit low!\n");

	//Interpret data
	if(req_data)
	{
		for (i = 0; i < 2560; i++)
		{
			B[i] = memoryMatrixB[i];
	//		if(i < 20 || i > 2500)
	//			print_debug(DEBUG_MATRIX_MM, "\tB[%d]: 0x%lx\n", i, B[i]);
		}
	}

}

//Hardware
int frodo_mul_add_sa_plus_e_HW(uint16_t *out, const uint16_t *s, const uint16_t *e, const uint8_t *seed_A, uint32_t *u32AccTime, uint32_t *u32ItCounter)
{ // Generate-and-multiply: generate matrix A (N x N) column-wise, multiply by s' on the left.
  // Inputs: s', e' (N_BAR x N)
  // Output: out = s'*A + e' (N_BAR x N)
#if ENABLE_SW_TIMER
	resetTimer(&general_hw_timer_control);
	startTimer(&general_hw_timer_control);
#endif

	int i, j, kk;

	for (i = 0; i < (PARAMS_N*PARAMS_NBAR); i += 2) {
		*((uint32_t*)&out[i]) = *((uint32_t*)&e[i]);
	}

	ALIGN_HEADER(32) uint16_t a_cols[4*PARAMS_N] ALIGN_FOOTER(32) = {0};

	int k;
	uint8_t seed_A_separated[2 + BYTES_SEED_A];
	uint16_t* seed_A_origin = (uint16_t*)&seed_A_separated;
	memcpy(&seed_A_separated[2], seed_A, BYTES_SEED_A);

	uint32_t s_matrix[16];
	uint32_t * a_matrix;
	uint8_t idx_s_matrix;
	uint32_t sum2[PARAMS_N * PARAMS_NBAR / 2];
	uint16_t out2[PARAMS_N*PARAMS_NBAR] = {0};
	for (i = 0; i < (PARAMS_N*PARAMS_NBAR); i += 2) {
		*((uint32_t*)&out2[i]) = *((uint32_t*)&e[i]);
	}

	uint8_t req_data = 0;

	//Set start pin high
	XGpio_DiscreteWrite(&axiStartBusyMatrix, 1, 0x1); // Start gpio set high

	for (kk = 0; kk < PARAMS_N; kk+=4) {

#if ENABLE_SW_TIMER
		//Accumulate time (SHAKE will not accumulate)
		stopTimer(&general_hw_timer_control);
		*u32AccTime += getTimer(&general_hw_timer) * 10; //Transform pulses into ns
#endif

//		print_debug(DEBUG_MATRIX_MM, "kk: %d\n", kk);
		seed_A_origin[0] = UINT16_TO_LE(kk + 0);
		shake128((unsigned char*)(a_cols + 0*PARAMS_N), (unsigned long long)(2*PARAMS_N), seed_A_separated, 2 + BYTES_SEED_A);
		seed_A_origin[0] = UINT16_TO_LE(kk + 1);
		shake128((unsigned char*)(a_cols + 1*PARAMS_N), (unsigned long long)(2*PARAMS_N), seed_A_separated, 2 + BYTES_SEED_A);
		seed_A_origin[0] = UINT16_TO_LE(kk + 2);
		shake128((unsigned char*)(a_cols + 2*PARAMS_N), (unsigned long long)(2*PARAMS_N), seed_A_separated, 2 + BYTES_SEED_A);
		seed_A_origin[0] = UINT16_TO_LE(kk + 3);
		shake128((unsigned char*)(a_cols + 3*PARAMS_N), (unsigned long long)(2*PARAMS_N), seed_A_separated, 2 + BYTES_SEED_A);
//		for (i = 0; i < 4 * PARAMS_N; i++) {
//			a_cols[i] = LE_TO_UINT16(a_cols[i]);
//		}

#if ENABLE_SW_TIMER
		//Start time
		resetTimer(&general_hw_timer_control);
		startTimer(&general_hw_timer_control);
#endif

		idx_s_matrix = 0;
		for(i = 0; i < PARAMS_NBAR; i++)
		{
			for(j = 0; j < 4; j+=2)
			{
				s_matrix[idx_s_matrix] = (s[i*PARAMS_N + kk + j] << 16) | s[i*PARAMS_N + kk + j + 1];
				idx_s_matrix++;
			}
		}
		a_matrix = (uint32_t *)a_cols;

		if(kk == PARAMS_N - 4)
			req_data = 1;

		frodo_mul_add_sa_plus_e_hw_func(s_matrix, a_matrix, sum2, req_data);

		for (k = 0; k < (PARAMS_N*PARAMS_NBAR); k++)
		{
			if((k & 0x1) == 0)
				out[k] = (sum2[k >> 1] & 0xffff) + e[k];
			else
				out[k] = (sum2[k >> 1] >> 16) + e[k];
		}

	} //kk for

	//Set start pin high
	XGpio_DiscreteWrite(&axiStartBusyMatrix, 1, 0x0); // Start gpio set low

#if ENABLE_SW_TIMER
	stopTimer(&general_hw_timer_control);

	//Transfer values
	*u32AccTime += getTimer(&general_hw_timer) * 10; //Transform pulses into ns

	//Add iteration
	*u32ItCounter = *u32ItCounter + 1;
#endif

	return 1;
}

/*************************************************************************************************************
***
***	FRODO_MUL_ADD_SB_PLUS_E
***
**************************************************************************************************************/
void frodo_mul_add_sb_plus_e(uint16_t *out, const uint16_t *b, const uint16_t *s, const uint16_t *e)
{ // Multiply by s on the left
  // Inputs: b (N x N_BAR), s (N_BAR x N), e (N_BAR x N_BAR)
  // Output: out = s*b + e (N_BAR x N_BAR)
	int i, j, k;

	for (k = 0; k < PARAMS_NBAR; k++) {
		for (i = 0; i < PARAMS_NBAR; i++) {
			out[k*PARAMS_NBAR + i] = e[k*PARAMS_NBAR + i];
			for (j = 0; j < PARAMS_N; j++) {
				out[k*PARAMS_NBAR + i] += s[k*PARAMS_N + j] * b[j*PARAMS_NBAR + i];
			}
			out[k*PARAMS_NBAR + i] = (uint32_t)(out[k*PARAMS_NBAR + i]) & ((1<<PARAMS_LOGQ)-1);
		}
	}
}

/*************************************************************************************************************
***
***	FRODO_MUL_BS
***
**************************************************************************************************************/
void frodo_mul_bs(uint16_t *out, const uint16_t *b, const uint16_t *s)
{ // Multiply by s on the right
  // Inputs: b (N_BAR x N), s (N x N_BAR)
  // Output: out = b*s (N_BAR x N_BAR)
    int i, j, k;

    for (i = 0; i < PARAMS_NBAR; i++) {
        for (j = 0; j < PARAMS_NBAR; j++) {
            out[i*PARAMS_NBAR + j] = 0;
            for (k = 0; k < PARAMS_N; k++) {
                out[i*PARAMS_NBAR + j] += b[i*PARAMS_N + k] * s[j*PARAMS_N + k];
            }
            out[i*PARAMS_NBAR + j] = (uint32_t)(out[i*PARAMS_NBAR + j]) & ((1<<PARAMS_LOGQ)-1);
        }
    }
}

/*************************************************************************************************************
***
***	FRODO_SUB
***
**************************************************************************************************************/
void frodo_sub(uint16_t *out, const uint16_t *a, const uint16_t *b)
{ // Subtract a and b
  // Inputs: a, b (N_BAR x N_BAR)
  // Output: c = a - b

    for (int i = 0; i < (PARAMS_NBAR*PARAMS_NBAR); i++) {
        out[i] = (a[i] - b[i]) & ((1<<PARAMS_LOGQ)-1);
    }
}

/*************************************************************************************************************
***
***	FRODO_ADD
***
**************************************************************************************************************/
void frodo_add(uint16_t *out, const uint16_t *a, const uint16_t *b)
{ // Add a and b
  // Inputs: a, b (N_BAR x N_BAR)
  // Output: c = a + b

    for (int i = 0; i < (PARAMS_NBAR*PARAMS_NBAR); i++) {
        out[i] = (a[i] + b[i]) & ((1<<PARAMS_LOGQ)-1);
    }
}

/*************************************************************************************************************
***
***	FRODO_KEY_ENCODE
***
**************************************************************************************************************/
void frodo_key_encode(uint16_t *out, const uint16_t *in)
{ // Encoding
    unsigned int i, j, npieces_word = 8;
    unsigned int nwords = (PARAMS_NBAR*PARAMS_NBAR)/8;
    uint64_t temp, mask = ((uint64_t)1 << PARAMS_EXTRACTED_BITS) - 1;
    uint16_t* pos = out;

    for (i = 0; i < nwords; i++) {
        temp = 0;
        for(j = 0; j < PARAMS_EXTRACTED_BITS; j++)
            temp |= ((uint64_t)((uint8_t*)in)[i*PARAMS_EXTRACTED_BITS + j]) << (8*j);
        for (j = 0; j < npieces_word; j++) {
            *pos = (uint16_t)((temp & mask) << (PARAMS_LOGQ - PARAMS_EXTRACTED_BITS));
            temp >>= PARAMS_EXTRACTED_BITS;
            pos++;
        }
    }
}

/*************************************************************************************************************
***
***	FRODO_KEY_DECODE
***
**************************************************************************************************************/
void frodo_key_decode(uint16_t *out, const uint16_t *in)
{ // Decoding
    unsigned int i, j, index = 0, npieces_word = 8;
    unsigned int nwords = (PARAMS_NBAR * PARAMS_NBAR) / 8;
    uint16_t temp, maskex=((uint16_t)1 << PARAMS_EXTRACTED_BITS) -1, maskq =((uint16_t)1 << PARAMS_LOGQ) -1;
    uint8_t  *pos = (uint8_t*)out;
    uint64_t templong;

    for (i = 0; i < nwords; i++) {
        templong = 0;
        for (j = 0; j < npieces_word; j++) {  // temp = floor(in*2^{-11}+0.5)
            temp = ((in[index] & maskq) + (1 << (PARAMS_LOGQ - PARAMS_EXTRACTED_BITS - 1))) >> (PARAMS_LOGQ - PARAMS_EXTRACTED_BITS);
            templong |= ((uint64_t)(temp & maskex)) << (PARAMS_EXTRACTED_BITS * j);
            index++;
        }
	for(j = 0; j < PARAMS_EXTRACTED_BITS; j++)
	    pos[i*PARAMS_EXTRACTED_BITS + j] = (templong >> (8*j)) & 0xFF;
    }
}
