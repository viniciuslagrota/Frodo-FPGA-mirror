/*
 * frodo_main.c

 *
 *  Created on: 25 de nov de 2019
 *      Author: Vinicius
 */

#include "global_def.h"
#include "fips202.h"

static enum keccakType
{
	KECCAK_SW,
	KECCAK_HW,
	KECCAK_HW_MM
} keccakStatePermuteType = KECCAK_SW;

void KeccakF1600_StatePermute(uint64_t * state)
{
	switch(keccakStatePermuteType)
	{
		case KECCAK_SW:
		{
			KeccakF1600_StatePermute_SW(state);
			break;
		}
		case KECCAK_HW:
		{
			KeccakF1600_StatePermute_HW(state);
			break;
		}
		case KECCAK_HW_MM:
		{
			KeccakF1600_StatePermute_HW_MM(state);
			break;
		}
	}
}

unsigned int get_cyclecount (void)
{
	unsigned int value;
	// Read CCNT Register
	asm volatile ("MRC p15, 0, %0, c9, c13, 0\t\n": "=r"(value));
	return value;
}

void init_perfcounters (int32_t do_reset, int32_t enable_divider)
{
	// in general enable all counters (including cycle counter)
	int32_t value = 1;

	// peform reset:
	if (do_reset)
	{
		value |= 2;     // reset all counters to zero.
		value |= 4;     // reset cycle counter to zero.
	}

	if (enable_divider)
		value |= 8;     // enable "by 64" divider for CCNT.

	value |= 16;

	// program the performance-counter control-register:
	asm volatile ("MCR p15, 0, %0, c9, c12, 0\t\n" :: "r"(value));

	// enable all counters:
	asm volatile ("MCR p15, 0, %0, c9, c12, 1\t\n" :: "r"(0x8000000f));

	// clear overflows:
	asm volatile ("MCR p15, 0, %0, c9, c12, 3\t\n" :: "r"(0x8000000f));
}

int kem_test(const char *named_parameters, int iterations)
{
	// CDF table
//	uint16_t CDF_TABLE[13] = {4643, 13363, 20579, 25843, 29227, 31145, 32103, 32525, 32689, 32745, 32762, 32766, 32767};
//	uint16_t CDF_TABLE_LEN = 13;

	// measure the counting overhead:
	unsigned int overhead = get_cyclecount();
	overhead = get_cyclecount() - overhead;

	unsigned int t_keypair_sw, t_enc_sw, t_dec_sw, t_total_sw;
	unsigned int t_keypair_hw, t_enc_hw, t_dec_hw, t_total_hw;
	unsigned int t_keypair_hw_mm, t_enc_hw_mm, t_dec_hw_mm, t_total_hw_mm;

	/* enable user-mode access to the performance counter*/
	asm ("MCR p15, 0, %0, C9, C14, 0\n\t" :: "r"(1));

	/* disable counter overflow interrupts (just in case)*/
	asm ("MCR p15, 0, %0, C9, C14, 2\n\t" :: "r"(0x8000000f));

	// init counters:
	init_perfcounters (1, 0);

#if ENABLE_KECCAK_DEBUG
	// ------ Test keccak_function ------
	u64 state[25] = { 0 };
	state[0] = 0x000000000000001f;
	state[20] = 0x8000000000000000;
	print_debug(DEBUG_TEST_KEM, "[TEST_KEM] Initializing Hardware function test\n");
	printStateMatrixDebug(state);
	unsigned int t;
	t = get_cyclecount();
	KeccakF1600_StatePermute_HW(state);
	t = get_cyclecount() - t;
	printStateMatrixDebug(state);
	print_debug(DEBUG_TEST_KEM, "[TEST_KEM] Hardware function took exactly %d cycles or %d us (including function call)\n\n", t - overhead, (t - overhead)/666);

	u64 state2[25] = { 0 };
	state2[0] = 0x000000000000001f;
	state2[20] = 0x8000000000000000;
	print_debug(DEBUG_TEST_KEM, "[TEST_KEM] Initializing Software function test\n");
	printStateMatrixDebug(state2);
	t = get_cyclecount();
	KeccakF1600_StatePermute_SW(state2);
	t = get_cyclecount() - t;
	printStateMatrixDebug(state2);
	print_debug(DEBUG_TEST_KEM, "[TEST_KEM] Software function took exactly %d cycles or %d us (including function call)\n\n", t - overhead, (t - overhead)/666);

	u64 state3[25] = { 0 };
	state3[0] = 0x000000000000001f;
	state3[20] = 0x8000000000000000;
	print_debug(DEBUG_TEST_KEM, "[TEST_KEM] Initializing Hardware Memory-Mapped function test\n");
	printStateMatrixDebug(state3);
	t = get_cyclecount();
	KeccakF1600_StatePermute_HW_MM(state3);
	t = get_cyclecount() - t;
	printStateMatrixDebug(state3);
	print_debug(DEBUG_TEST_KEM, "[TEST_KEM] Hardware Memory-Mapped function took exactly %d cycles or %d us (including function call)\n\n", t - overhead, (t - overhead)/666);
#endif

#if ENABLE_KEM_TEST
	// ------ KEM test ------
	uint8_t pk[CRYPTO_PUBLICKEYBYTES];
	uint8_t sk[CRYPTO_SECRETKEYBYTES];
	uint8_t ss_encap[CRYPTO_BYTES], ss_decap[CRYPTO_BYTES];
	uint8_t ct[CRYPTO_CIPHERTEXTBYTES];

	print_debug(DEBUG_TEST_KEM, "\n");
	print_debug(DEBUG_TEST_KEM, "=============================================================================================================================\n");
	print_debug(DEBUG_TEST_KEM, "Testing correctness of key encapsulation mechanism (KEM), system %s, tests for %d iterations\n", named_parameters, iterations);
	print_debug(DEBUG_TEST_KEM, "=============================================================================================================================\n");

	for (int i = 0; i < iterations; i++)
	{
		keccakStatePermuteType = KECCAK_SW;

		t_keypair_sw = get_cyclecount();
		crypto_kem_keypair(pk, sk);
		t_keypair_sw = get_cyclecount() - t_keypair_sw - overhead;
		print_debug(DEBUG_TEST_KEM, "[TEST_KEM] Crypto_kem_keypair using SW took exactly %d cycles or %d us (including function call)\n", t_keypair_sw, (t_keypair_sw)/666);

		t_enc_sw = get_cyclecount();
		crypto_kem_enc(ct, ss_encap, pk);
		t_enc_sw = get_cyclecount() - t_enc_sw - overhead;
		print_debug(DEBUG_TEST_KEM, "[TEST_KEM] Crypto_kem_enc using SW took exactly %d cycles or %d us (including function call)\n", t_enc_sw, (t_enc_sw)/666);

		t_dec_sw = get_cyclecount();
		crypto_kem_dec(ss_decap, ct, sk);
		t_dec_sw = get_cyclecount() - t_dec_sw - overhead;
		print_debug(DEBUG_TEST_KEM, "[TEST_KEM] Crypto_kem_dec using SW took exactly %d cycles or %d us (including function call)\n", t_dec_sw, (t_dec_sw)/666);

		//Total sw time
		t_total_sw = t_keypair_sw + t_enc_sw + t_dec_sw;
		print_debug(DEBUG_TEST_KEM, "[TEST_KEM] Total time using SW is %d cycles or %d us (including function call)\n", t_total_sw, (t_total_sw)/666);
		print_debug(DEBUG_TEST_KEM, "[TEST_KEM] SW tests PASSED. All session keys matched.\n");
		print_debug(DEBUG_TEST_KEM, "\n");

		if (memcmp(ss_encap, ss_decap, CRYPTO_BYTES) != 0) {
			print_debug(DEBUG_ERROR, "[TEST_KEM] SW ERROR!\n");
			return false;
		}

		keccakStatePermuteType = KECCAK_HW;

		t_keypair_hw = get_cyclecount();
		crypto_kem_keypair(pk, sk);
		t_keypair_hw = get_cyclecount() - t_keypair_hw - overhead;
		print_debug(DEBUG_TEST_KEM, "[TEST_KEM] Crypto_kem_keypair using HW took exactly %d cycles or %d us (including function call)\n", t_keypair_hw, (t_keypair_hw)/666);

		t_enc_hw = get_cyclecount();
		crypto_kem_enc(ct, ss_encap, pk);
		t_enc_hw = get_cyclecount() - t_enc_hw - overhead;
		print_debug(DEBUG_TEST_KEM, "[TEST_KEM] Crypto_kem_enc using HW took exactly %d cycles or %d us (including function call)\n", t_enc_hw, (t_enc_hw)/666);

		t_dec_hw = get_cyclecount();
		crypto_kem_dec(ss_decap, ct, sk);
		t_dec_hw = get_cyclecount() - t_dec_hw - overhead;
		print_debug(DEBUG_TEST_KEM, "[TEST_KEM] Crypto_kem_dec using HW took exactly %d cycles or %d us (including function call)\n", t_dec_hw, (t_dec_hw)/666);

		//Total hw time
		t_total_hw = t_keypair_hw + t_enc_hw + t_dec_hw;
		print_debug(DEBUG_TEST_KEM, "[TEST_KEM] Total time using HW is %d cycles or %d us (including function call)\n", t_total_hw, (t_total_hw)/666);
		print_debug(DEBUG_TEST_KEM, "[TEST_KEM] HW tests PASSED. All session keys matched.\n");
		print_debug(DEBUG_TEST_KEM, "\n");

		if (memcmp(ss_encap, ss_decap, CRYPTO_BYTES) != 0) {
			print_debug(DEBUG_ERROR, "[TEST_KEM] HW ERROR!\n");
			return false;
		}

		keccakStatePermuteType = KECCAK_HW_MM;

		t_keypair_hw_mm = get_cyclecount();
		crypto_kem_keypair(pk, sk);
		t_keypair_hw_mm = get_cyclecount() - t_keypair_hw_mm - overhead;
		print_debug(DEBUG_TEST_KEM, "[TEST_KEM] Crypto_kem_keypair using HW_MM took exactly %d cycles or %d us (including function call)\n", t_keypair_hw_mm, (t_keypair_hw_mm)/666);

		t_enc_hw_mm = get_cyclecount();
		crypto_kem_enc(ct, ss_encap, pk);
		t_enc_hw_mm = get_cyclecount() - t_enc_hw_mm - overhead;
		print_debug(DEBUG_TEST_KEM, "[TEST_KEM] Crypto_kem_enc using HW_MM took exactly %d cycles or %d us (including function call)\n", t_enc_hw_mm, (t_enc_hw_mm)/666);

		t_dec_hw_mm = get_cyclecount();
		crypto_kem_dec(ss_decap, ct, sk);
		t_dec_hw_mm = get_cyclecount() - t_dec_hw_mm - overhead;
		print_debug(DEBUG_TEST_KEM, "[TEST_KEM] Crypto_kem_dec using HW_MM took exactly %d cycles or %d us (including function call)\n", t_dec_hw_mm, (t_dec_hw_mm)/666);

		//Total hw time
		t_total_hw_mm = t_keypair_hw_mm + t_enc_hw_mm + t_dec_hw_mm;
		print_debug(DEBUG_TEST_KEM, "[TEST_KEM] Total time using HW_MM is %d cycles or %d us (including function call)\n", t_total_hw_mm, (t_total_hw_mm)/666);
		print_debug(DEBUG_TEST_KEM, "[TEST_KEM] HW_MM tests PASSED. All session keys matched.\n");
		print_debug(DEBUG_TEST_KEM, "\n");

		if (memcmp(ss_encap, ss_decap, CRYPTO_BYTES) != 0) {
			print_debug(DEBUG_ERROR, "[TEST_KEM] HW_MM ERROR!\n");
			return false;
		}

		//Table
		print_debug(DEBUG_TEST_KEM, "\t\tkey pair (us) \t|\t encryption (us) \t|\t decryption (us) \t\t|\t\t total (us) \t\t|\t Improvement (%c) \n", 37);
		print_debug(DEBUG_TEST_KEM, "     -----------------------------------------------------------------------------------------------------------\n");
		print_debug(DEBUG_TEST_KEM, "\t\t\t %d \t\t|\t\t\t %d \t\t|\t\t\t %d \t\t\t|\t\t %d \t\t|\t\t\t -\n", t_keypair_sw/666, t_enc_sw/666, t_dec_sw/666, t_total_sw/666);
		print_debug(DEBUG_TEST_KEM, "     -----------------------------------------------------------------------------------------------------------\n");
		print_debug(DEBUG_TEST_KEM, "\t\t\t %d \t\t|\t\t\t %d \t\t|\t\t\t %d \t\t\t|\t\t %d \t\t|\t\t %.02f\n", t_keypair_hw/666, t_enc_hw/666, t_dec_hw/666, t_total_hw/666, 100.0-((float)t_total_hw/(float)t_total_sw)*100.0);
		print_debug(DEBUG_TEST_KEM, "     -----------------------------------------------------------------------------------------------------------\n");
		print_debug(DEBUG_TEST_KEM, "\t\t\t %d \t\t|\t\t\t %d \t\t|\t\t\t %d \t\t\t|\t\t %d \t\t|\t\t %.02f\n", t_keypair_hw_mm/666, t_enc_hw_mm/666, t_dec_hw_mm/666, t_total_hw_mm/666, 100.0-((float)t_total_hw_mm/(float)t_total_sw)*100.0);
		print_debug(DEBUG_TEST_KEM, "     -----------------------------------------------------------------------------------------------------------\n\n\n");
	}
#endif

	return true;
}