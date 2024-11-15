/*
 * kem.c


 *
 *  Created on: 1 de dez de 2019
 *      Author: Vinicius
 */

#include "kem.h"
#include "frodo640.h"

int crypto_kem_keypair(unsigned char* pk, unsigned char* sk)
{ // FrodoKEM's key generation
  // Outputs: public key pk (               BYTES_SEED_A + (PARAMS_LOGQ*PARAMS_N*PARAMS_NBAR)/8 bytes)
  //          secret key sk (CRYPTO_BYTES + BYTES_SEED_A + (PARAMS_LOGQ*PARAMS_N*PARAMS_NBAR)/8 + 2*PARAMS_N*PARAMS_NBAR + BYTES_PKHASH bytes)
	uint8_t *pk_seedA = &pk[0];
	uint8_t *pk_b = &pk[BYTES_SEED_A];
	uint8_t *sk_s = &sk[0];
	uint8_t *sk_pk = &sk[CRYPTO_BYTES];
	uint8_t *sk_S = &sk[CRYPTO_BYTES + CRYPTO_PUBLICKEYBYTES];
	uint8_t *sk_pkh = &sk[CRYPTO_BYTES + CRYPTO_PUBLICKEYBYTES + 2*PARAMS_N*PARAMS_NBAR];
//	uint16_t B[5120] = {0};
	uint16_t B[PARAMS_N*PARAMS_NBAR] = {0};
	uint16_t S[2*PARAMS_N*PARAMS_NBAR] = {0};               // contains secret data
	uint16_t *E = (uint16_t *)&S[PARAMS_N*PARAMS_NBAR];     // contains secret data
	uint8_t randomness[2*CRYPTO_BYTES + BYTES_SEED_A];      // contains secret data via randomness_s and randomness_seedSE
	uint8_t *randomness_s = &randomness[0];                 // contains secret data
	uint8_t *randomness_seedSE = &randomness[CRYPTO_BYTES]; // contains secret data
	uint8_t *randomness_z = &randomness[2*CRYPTO_BYTES];
	uint8_t shake_input_seedSE[1 + CRYPTO_BYTES];           // contains secret data

	// Generate the secret value s, the seed for S and E, and the seed for the seed for A. Add seed_A to the public key
#if RANDOM_BYTES == 1
	randombytes(randomness, CRYPTO_BYTES + CRYPTO_BYTES + BYTES_SEED_A);
#else
	memset(randomness, 0x2, 2*CRYPTO_BYTES + BYTES_SEED_A);
#endif

	//Debug
#if DEBUG_KEM_KEYPAIR == 1
	print_debug(DEBUG_KEM_KEYPAIR, "[KEM - KEYPAIR] Input: ");
	for (int i = 0; i < BYTES_SEED_A; i++)
	{
		print_debug(DEBUG_KEM_KEYPAIR, "%02x ", randomness_z[i]);
	}
	print_debug(DEBUG_KEM_KEYPAIR, "\n");
	print_debug(DEBUG_KEM_KEYPAIR, "[KEM - KEYPAIR] Input and output length: %d\n", BYTES_SEED_A);
#endif

	shake(pk_seedA, BYTES_SEED_A, randomness_z, BYTES_SEED_A);

	//Debug
#if DEBUG_KEM_KEYPAIR == 1
	print_debug(DEBUG_KEM_KEYPAIR, "[KEM - KEYPAIR] Output: ");
	for (int i = 0; i < BYTES_SEED_A; i++)
	{
		print_debug(DEBUG_KEM_KEYPAIR, "%02x ", *(pk_seedA + i));
	}
	print_debug(DEBUG_KEM_KEYPAIR, "\n\n");
#endif

	// Generate S and E, and compute B = A*S + E. Generate A on-the-fly
	shake_input_seedSE[0] = 0x5F;

	//Debug
#if DEBUG_KEM_KEYPAIR == 1
	print_debug(DEBUG_KEM_KEYPAIR, "[KEM - KEYPAIR] randomness_seedSE: ");
	for (int i = 0; i < CRYPTO_BYTES; i++)
	{
		print_debug(DEBUG_KEM_KEYPAIR, "%02x ", randomness_seedSE[i]);
	}
	print_debug(DEBUG_KEM_KEYPAIR, "\n");
#endif

	memcpy(&shake_input_seedSE[1], randomness_seedSE, CRYPTO_BYTES);

#if DEBUG_KEM_KEYPAIR == 1
	print_debug(DEBUG_KEM_KEYPAIR, "[KEM - KEYPAIR] shake_input_seedSE: ");
	for (int i = 0; i < CRYPTO_BYTES; i++)
	{
		print_debug(DEBUG_KEM_KEYPAIR, "%02x ", shake_input_seedSE[i]);
	}
	print_debug(DEBUG_KEM_KEYPAIR, "\n");
#endif

	shake((uint8_t*)S, 2*PARAMS_N*PARAMS_NBAR*sizeof(uint16_t), shake_input_seedSE, 1 + CRYPTO_BYTES);

#if DEBUG_KEM_KEYPAIR == 1
	print_debug(DEBUG_KEM_KEYPAIR, "[KEM - KEYPAIR] S: ");
	//for (int i = 0; i < 640 * 8 * 2; i++)
	for (int i = 0; i < 20; i++)
	{
		print_debug(DEBUG_KEM_KEYPAIR, "%d ", S[i]);
	}
	print_debug(DEBUG_KEM_KEYPAIR, "\n");
#endif

	for (size_t i = 0; i < 2 * PARAMS_N * PARAMS_NBAR; i++)
	{
		S[i] = LE_TO_UINT16(S[i]);
	}
	frodo_sample_n(S, PARAMS_N*PARAMS_NBAR);

#if DEBUG_KEM_KEYPAIR == 1
	print_debug(DEBUG_KEM_KEYPAIR, "[KEM - KEYPAIR] S: ");
//	for (int i = 0; i < 640 * 8 * 2; i++)
	for (int i = 0; i < 20; i++)
	{
		print_debug(DEBUG_KEM_KEYPAIR, "%d ", (int16_t)(S[i]));
	}
	print_debug(DEBUG_KEM_KEYPAIR, "\n");
#endif

	frodo_sample_n(E, PARAMS_N*PARAMS_NBAR);

#if DEBUG_KEM_KEYPAIR == 1
	print_debug(DEBUG_KEM_KEYPAIR, "[KEM - KEYPAIR] E:");
//	for (int i = 0; i < 640 * 8; i++)
	for (int i = 0; i < 20; i++)
	{
		print_debug(DEBUG_KEM_KEYPAIR, "%d ", (int16_t)(E[i]));
	}
	print_debug(DEBUG_KEM_KEYPAIR, "\n");
#endif

	frodo_mul_add_as_plus_e(B, S, E, pk);

#if DEBUG_KEM_KEYPAIR == 1
	print_debug(DEBUG_KEM_KEYPAIR, "[KEM - KEYPAIR] B: ");
//	for (int i = 0; i < 640 * 8; i++)
	for (int i = 0; i < 20; i++)
	{
		print_debug(DEBUG_KEM_KEYPAIR, "%d ", B[i]);
	}
	print_debug(DEBUG_KEM_KEYPAIR, "\n");
#endif

	// Encode the second part of the public key
	frodo_pack(pk_b, CRYPTO_PUBLICKEYBYTES - BYTES_SEED_A, B, PARAMS_N*PARAMS_NBAR, PARAMS_LOGQ);

	// Add s, pk and S to the secret key
	memcpy(sk_s, randomness_s, CRYPTO_BYTES + 1);
	memcpy(sk_pk, pk, CRYPTO_PUBLICKEYBYTES);
	for (size_t i = 0; i < PARAMS_N * PARAMS_NBAR; i++) {
		S[i] = UINT16_TO_LE(S[i]);
	}
	memcpy(sk_S, S, 2*PARAMS_N*PARAMS_NBAR);

	// Add H(pk) to the secret key
	shake(sk_pkh, BYTES_PKHASH, pk, CRYPTO_PUBLICKEYBYTES);

	// Cleanup:
	clear_bytes((uint8_t *)S, PARAMS_N*PARAMS_NBAR*sizeof(uint16_t));
	clear_bytes((uint8_t *)E, PARAMS_N*PARAMS_NBAR*sizeof(uint16_t));
	clear_bytes(randomness, 2*CRYPTO_BYTES);
	clear_bytes(shake_input_seedSE, 1 + CRYPTO_BYTES);

	return 0;
}

int crypto_kem_enc(unsigned char *ct, unsigned char *ss, const unsigned char *pk)
{ // FrodoKEM's key encapsulation
	const uint8_t *pk_seedA = &pk[0];
	const uint8_t *pk_b = &pk[BYTES_SEED_A];
	uint8_t *ct_c1 = &ct[0];
	uint8_t *ct_c2 = &ct[(PARAMS_LOGQ*PARAMS_N*PARAMS_NBAR)/8];
	uint16_t B[PARAMS_N*PARAMS_NBAR] = {0};
	uint16_t V[PARAMS_NBAR*PARAMS_NBAR]= {0};                 // contains secret data
	uint16_t C[PARAMS_NBAR*PARAMS_NBAR] = {0};
	ALIGN_HEADER(32) uint16_t Bp[PARAMS_N*PARAMS_NBAR] ALIGN_FOOTER(32) = {0};
	ALIGN_HEADER(32) uint16_t Sp[(2*PARAMS_N+PARAMS_NBAR)*PARAMS_NBAR] ALIGN_FOOTER(32) = {0};  // contains secret data
	uint16_t *Ep = (uint16_t *)&Sp[PARAMS_N*PARAMS_NBAR];     // contains secret data
	uint16_t *Epp = (uint16_t *)&Sp[2*PARAMS_N*PARAMS_NBAR];  // contains secret data
	uint8_t G2in[BYTES_PKHASH + BYTES_MU];                    // contains secret data via mu
	uint8_t *pkh = &G2in[0];
	uint8_t *mu = &G2in[BYTES_PKHASH];                        // contains secret data
	uint8_t G2out[2*CRYPTO_BYTES];                            // contains secret data
	uint8_t *seedSE = &G2out[0];                              // contains secret data
	uint8_t *k = &G2out[CRYPTO_BYTES];                        // contains secret data
	uint8_t Fin[CRYPTO_CIPHERTEXTBYTES + CRYPTO_BYTES];       // contains secret data via Fin_k
	uint8_t *Fin_ct = &Fin[0];
	uint8_t *Fin_k = &Fin[CRYPTO_CIPHERTEXTBYTES];            // contains secret data
	uint8_t shake_input_seedSE[1 + CRYPTO_BYTES];             // contains secret data

#if DEBUG_KEM_ENC
	print_debug(DEBUG_KEM_ENC, "[KEM - ENC] Pk: ");
//	for (int i = 0; i < CRYPTO_PUBLICKEYBYTES; i++)
	for (int i = 0; i < 20; i++)
	{
		if (i % 16 == 0)
			print_debug(DEBUG_KEM_ENC, "\n");
		print_debug(DEBUG_KEM_ENC, "%02x", pk[i]);
	}
	print_debug(DEBUG_KEM_ENC, "\n");
#endif

	// pkh <- G_1(pk), generate random mu, compute (seedSE || k) = G_2(pkh || mu)
	shake(pkh, BYTES_PKHASH, pk, CRYPTO_PUBLICKEYBYTES);

#if DEBUG_KEM_ENC == 1
	print_debug(DEBUG_KEM_ENC, "[KEM - ENC] Shake pk: ");
	for (int i = 0; i < BYTES_PKHASH; i++)
	{
		print_debug(DEBUG_KEM_ENC, "%02x ", *(pkh + i));
	}
	print_debug(DEBUG_KEM_ENC, "\n\n");
#endif

#if RANDOM_BYTES == 1
	randombytes(mu, BYTES_MU);
#else
	memset(mu, 0x4, BYTES_MU);
#endif

#if DEBUG_KEM_ENC == 1
	print_debug(DEBUG_KEM_ENC, "[KEM - ENC] mu: ");
	for (int i = 0; i < BYTES_MU; i++)
	{
		print_debug(DEBUG_KEM_ENC, "%02x ", *(mu + i));
	}
	print_debug(DEBUG_KEM_ENC, "\n");
#endif

	shake(G2out, CRYPTO_BYTES + CRYPTO_BYTES, G2in, BYTES_PKHASH + BYTES_MU);

#if DEBUG_KEM_ENC == 1
	print_debug(DEBUG_KEM_ENC, "[KEM - ENC] Shake G2in: ");
	for (int i = 0; i < CRYPTO_BYTES + CRYPTO_BYTES; i++)
	{
		print_debug(DEBUG_KEM_ENC, "%02x ", *(G2out + i));
	}
	print_debug(DEBUG_KEM_ENC, "\n");
#endif

	// Generate Sp and Ep, and compute Bp = Sp*A + Ep. Generate A on-the-fly
	shake_input_seedSE[0] = 0x96;
#if DEBUG_KEM_ENC
	print_debug(DEBUG_KEM_ENC, "[KEM - ENC] seedSE: ");
	for (int i = 0; i < 2 * CRYPTO_BYTES; i++)
	{
		print_debug(DEBUG_KEM_ENC, "%02x ", seedSE[i]);
	}
	print_debug(DEBUG_KEM_ENC, "\n");
#endif

	memcpy(&shake_input_seedSE[1], seedSE, CRYPTO_BYTES);
#if DEBUG_KEM_ENC
	print_debug(DEBUG_KEM_ENC, "[KEM - ENC] shake_input_seedSE: ");
	for (int i = 0; i < CRYPTO_BYTES; i++)
	{
		print_debug(DEBUG_KEM_ENC, "%02x ", shake_input_seedSE[i]);
	}
	print_debug(DEBUG_KEM_ENC, "\n");
#endif

	shake((uint8_t*)Sp, (2*PARAMS_N+PARAMS_NBAR)*PARAMS_NBAR*sizeof(uint16_t), shake_input_seedSE, 1 + CRYPTO_BYTES);

#if DEBUG_KEM_ENC
	print_debug(DEBUG_KEM_ENC, "[KEM - ENC] Sp: ");
//	for (int i = 0; i < (2*PARAMS_N+PARAMS_NBAR)*PARAMS_NBAR*sizeof(uint16_t); i++)
	for (int i = 0; i < 20; i++)
	{
//		if(i % 16 == 15)
//			print_debug(DEBUG_KEM_ENC, "\n");
		print_debug(DEBUG_KEM_ENC, "%04lx", Sp[i]);
	}
	print_debug(DEBUG_KEM_ENC, "\n");
#endif

	for (size_t i = 0; i < (2 * PARAMS_N + PARAMS_NBAR) * PARAMS_NBAR; i++)
	{
		Sp[i] = LE_TO_UINT16(Sp[i]);
	}
	frodo_sample_n(Sp, PARAMS_N*PARAMS_NBAR);

#if DEBUG_KEM_ENC
	print_debug(DEBUG_KEM_ENC, "[KEM - ENC] Sp sampled: ");
//	for (int i = 0; i < PARAMS_N * PARAMS_NBAR; i++)
	for (int i = 0; i < 20; i++)
	{
//		if (i % 16 == 15)
//			print_debug(DEBUG_KEM_ENC, "\n");
		print_debug(DEBUG_KEM_ENC, "%04lx", Sp[i]);
	}
	print_debug(DEBUG_KEM_ENC, "\n");
#endif

	frodo_sample_n(Ep, PARAMS_N*PARAMS_NBAR);

#if DEBUG_KEM_ENC
	print_debug(DEBUG_KEM_ENC, "[KEM - ENC] Ep sampled: ");
//	for (int i = 0; i < PARAMS_N * PARAMS_NBAR; i++)
	for (int i = 0; i < 20; i++)
	{
//		if (i % 16 == 15)
//			print_debug(DEBUG_KEM_ENC, "\n");
		print_debug(DEBUG_KEM_ENC, "%04lx", Ep[i]);
	}
	print_debug(DEBUG_KEM_ENC, "\n");
#endif

	frodo_mul_add_sa_plus_e(Bp, Sp, Ep, pk_seedA);

#if DEBUG_KEM_ENC
	print_debug(DEBUG_KEM_ENC, "[KEM - ENC] Bp: ");
//	for (int i = 0; i < PARAMS_N * PARAMS_NBAR; i++)
	for (int i = 0; i < 20; i++)
	{
//		if (i % 16 == 15)
//			print_debug(DEBUG_KEM_ENC, "\n");
		print_debug(DEBUG_KEM_ENC, "%04lx", Ep[i]);
	}
	print_debug(DEBUG_KEM_ENC, "\n");
#endif

	frodo_pack(ct_c1, (PARAMS_LOGQ*PARAMS_N*PARAMS_NBAR)/8, Bp, PARAMS_N*PARAMS_NBAR, PARAMS_LOGQ);

#if DEBUG_KEM_ENC
	print_debug(DEBUG_KEM_ENC, "[KEM - ENC] ct_c1: ");
//	for (int i = 0; i < (PARAMS_LOGQ * PARAMS_N * PARAMS_NBAR) / 8; i++)
	for (int i = 0; i < 20; i++)
	{
//		if (i % 16 == 15)
//			print_debug(DEBUG_KEM_ENC, "\n");
		print_debug(DEBUG_KEM_ENC, "%02x", Ep[i]);
	}
	print_debug(DEBUG_KEM_ENC, "\n");
#endif

#if DEBUG_KEM_ENC
	print_debug(DEBUG_KEM_ENC, "[KEM - ENC] ct: ");
	for (int i = 0; i < 20; i++)
	{
		print_debug(DEBUG_KEM_ENC, "%d ", ct[i]);
	}
	print_debug(DEBUG_KEM_ENC, "\n");
#endif

	// Generate Epp, and compute V = Sp*B + Epp
	frodo_sample_n(Epp, PARAMS_NBAR*PARAMS_NBAR);
	frodo_unpack(B, PARAMS_N*PARAMS_NBAR, pk_b, CRYPTO_PUBLICKEYBYTES - BYTES_SEED_A, PARAMS_LOGQ);
	frodo_mul_add_sb_plus_e(V, B, Sp, Epp);

	// Encode mu, and compute C = V + enc(mu) (mod q)
	frodo_key_encode(C, (uint16_t*)mu);
	frodo_add(C, V, C);
	frodo_pack(ct_c2, (PARAMS_LOGQ*PARAMS_NBAR*PARAMS_NBAR)/8, C, PARAMS_NBAR*PARAMS_NBAR, PARAMS_LOGQ);

	// Compute ss = F(ct||KK)
	memcpy(Fin_ct, ct, CRYPTO_CIPHERTEXTBYTES);
	memcpy(Fin_k, k, CRYPTO_BYTES);

#if DEBUG_KEM_ENC
	print_debug(DEBUG_KEM_ENC, "[KEM - ENC] Fin: ");
//	for (size_t i = 0; i < CRYPTO_CIPHERTEXTBYTES + CRYPTO_BYTES; i++)
	for (size_t i = 0; i < 20; i++)
	{
//		if (i % 32 == 31)
//			print_debug(DEBUG_KEM_ENC, "\n");
		print_debug(DEBUG_KEM_ENC, "%02x", Fin[i]);
	}
	print_debug(DEBUG_KEM_ENC, "\n");
#endif

	shake(ss, CRYPTO_BYTES, Fin, CRYPTO_CIPHERTEXTBYTES + CRYPTO_BYTES);

#if DEBUG_KEM_ENC
	print_debug(DEBUG_KEM_ENC, "[KEM - ENC] ss: ");
	for (int i = 0; i < CRYPTO_BYTES; i++)
	{
		print_debug(DEBUG_KEM_ENC, "%d ", ss[i]);
	}
	print_debug(DEBUG_KEM_ENC, "\n");
#endif

	// Cleanup:
	clear_bytes((uint8_t *)V, PARAMS_NBAR*PARAMS_NBAR*sizeof(uint16_t));
	clear_bytes((uint8_t *)Sp, PARAMS_N*PARAMS_NBAR*sizeof(uint16_t));
	clear_bytes((uint8_t *)Ep, PARAMS_N*PARAMS_NBAR*sizeof(uint16_t));
	clear_bytes((uint8_t *)Epp, PARAMS_NBAR*PARAMS_NBAR*sizeof(uint16_t));
	clear_bytes(mu, BYTES_MU);
	clear_bytes(G2out, 2*CRYPTO_BYTES);
	clear_bytes(Fin_k, CRYPTO_BYTES);
	clear_bytes(shake_input_seedSE, 1 + CRYPTO_BYTES);
	return 0;
}

int crypto_kem_dec(unsigned char *ss, const unsigned char *ct, const unsigned char *sk)
{ // FrodoKEM's key decapsulation
    uint16_t B[PARAMS_N*PARAMS_NBAR] = {0};
    uint16_t Bp[PARAMS_N*PARAMS_NBAR] = {0};
    uint16_t W[PARAMS_NBAR*PARAMS_NBAR] = {0};                // contains secret data
    uint16_t C[PARAMS_NBAR*PARAMS_NBAR] = {0};
    uint16_t CC[PARAMS_NBAR*PARAMS_NBAR] = {0};
    ALIGN_HEADER(32) uint16_t BBp[PARAMS_N*PARAMS_NBAR] ALIGN_FOOTER(32) = {0};
    ALIGN_HEADER(32) uint16_t Sp[(2*PARAMS_N+PARAMS_NBAR)*PARAMS_NBAR] ALIGN_FOOTER(32) = {0};  // contains secret data
    uint16_t *Ep = (uint16_t *)&Sp[PARAMS_N*PARAMS_NBAR];     // contains secret data
    uint16_t *Epp = (uint16_t *)&Sp[2*PARAMS_N*PARAMS_NBAR];  // contains secret data
    const uint8_t *ct_c1 = &ct[0];
    const uint8_t *ct_c2 = &ct[(PARAMS_LOGQ*PARAMS_N*PARAMS_NBAR)/8];
    const uint8_t *sk_s = &sk[0];
    const uint8_t *sk_pk = &sk[CRYPTO_BYTES];
    const uint16_t *sk_S = (uint16_t *) &sk[CRYPTO_BYTES + CRYPTO_PUBLICKEYBYTES];
    uint16_t S[PARAMS_N * PARAMS_NBAR];                      // contains secret data
    const uint8_t *sk_pkh = &sk[CRYPTO_BYTES + CRYPTO_PUBLICKEYBYTES + 2*PARAMS_N*PARAMS_NBAR];
    const uint8_t *pk_seedA = &sk_pk[0];
    const uint8_t *pk_b = &sk_pk[BYTES_SEED_A];
    uint8_t G2in[BYTES_PKHASH + BYTES_MU];                   // contains secret data via muprime
    uint8_t *pkh = &G2in[0];
    uint8_t *muprime = &G2in[BYTES_PKHASH];                  // contains secret data
    uint8_t G2out[2*CRYPTO_BYTES];                           // contains secret data
    uint8_t *seedSEprime = &G2out[0];                        // contains secret data
    uint8_t *kprime = &G2out[CRYPTO_BYTES];                  // contains secret data
    uint8_t Fin[CRYPTO_CIPHERTEXTBYTES + CRYPTO_BYTES];      // contains secret data via Fin_k
    uint8_t *Fin_ct = &Fin[0];
    uint8_t *Fin_k = &Fin[CRYPTO_CIPHERTEXTBYTES];           // contains secret data
    uint8_t shake_input_seedSEprime[1 + CRYPTO_BYTES];       // contains secret data

    for (size_t i = 0; i < PARAMS_N * PARAMS_NBAR; i++)
    {
		S[i] = LE_TO_UINT16(sk_S[i]);
	}

    // Compute W = C - Bp*S (mod q), and decode the randomness mu
	frodo_unpack(Bp, PARAMS_N*PARAMS_NBAR, ct_c1, (PARAMS_LOGQ*PARAMS_N*PARAMS_NBAR)/8, PARAMS_LOGQ);
	frodo_unpack(C, PARAMS_NBAR*PARAMS_NBAR, ct_c2, (PARAMS_LOGQ*PARAMS_NBAR*PARAMS_NBAR)/8, PARAMS_LOGQ);
	frodo_mul_bs(W, Bp, S);
	frodo_sub(W, C, W);
	frodo_key_decode((uint16_t*)muprime, W);

	// Generate (seedSE' || k') = G_2(pkh || mu')
	memcpy(pkh, sk_pkh, BYTES_PKHASH);
	shake(G2out, CRYPTO_BYTES + CRYPTO_BYTES, G2in, BYTES_PKHASH + BYTES_MU);

	// Generate Sp and Ep, and compute BBp = Sp*A + Ep. Generate A on-the-fly
	shake_input_seedSEprime[0] = 0x96;
	memcpy(&shake_input_seedSEprime[1], seedSEprime, CRYPTO_BYTES);
	shake((uint8_t*)Sp, (2*PARAMS_N+PARAMS_NBAR)*PARAMS_NBAR*sizeof(uint16_t), shake_input_seedSEprime, 1 + CRYPTO_BYTES);
	for (size_t i = 0; i < (2*PARAMS_N+PARAMS_NBAR)*PARAMS_NBAR; i++) {
		Sp[i] = LE_TO_UINT16(Sp[i]);
	}
	frodo_sample_n(Sp, PARAMS_N*PARAMS_NBAR);
	frodo_sample_n(Ep, PARAMS_N*PARAMS_NBAR);
	frodo_mul_add_sa_plus_e(BBp, Sp, Ep, pk_seedA);

	// Generate Epp, and compute W = Sp*B + Epp
	frodo_sample_n(Epp, PARAMS_NBAR*PARAMS_NBAR);
	frodo_unpack(B, PARAMS_N*PARAMS_NBAR, pk_b, CRYPTO_PUBLICKEYBYTES - BYTES_SEED_A, PARAMS_LOGQ);
	frodo_mul_add_sb_plus_e(W, B, Sp, Epp);

	// Encode mu, and compute CC = W + enc(mu') (mod q)
	frodo_key_encode(CC, (uint16_t*)muprime);
	frodo_add(CC, W, CC);

	// Prepare input to F
	memcpy(Fin_ct, ct, CRYPTO_CIPHERTEXTBYTES);

	// Reducing BBp modulo q
	for (int i = 0; i < PARAMS_N*PARAMS_NBAR; i++) BBp[i] = BBp[i] & ((1 << PARAMS_LOGQ)-1);

	// Is (Bp == BBp & C == CC) = true
	if (memcmp(Bp, BBp, 2*PARAMS_N*PARAMS_NBAR) == 0 && memcmp(C, CC, 2*PARAMS_NBAR*PARAMS_NBAR) == 0) {
		// Load k' to do ss = F(ct || k')
		memcpy(Fin_k, kprime, CRYPTO_BYTES);
	} else {
		// Load s to do ss = F(ct || s)
		memcpy(Fin_k, sk_s, CRYPTO_BYTES);
	}
	shake(ss, CRYPTO_BYTES, Fin, CRYPTO_CIPHERTEXTBYTES + CRYPTO_BYTES);

	// Cleanup:
	clear_bytes((uint8_t *)W, PARAMS_NBAR*PARAMS_NBAR*sizeof(uint16_t));
	clear_bytes((uint8_t *)Sp, PARAMS_N*PARAMS_NBAR*sizeof(uint16_t));
	clear_bytes((uint8_t *)S, PARAMS_N*PARAMS_NBAR*sizeof(uint16_t));
	clear_bytes((uint8_t *)Ep, PARAMS_N*PARAMS_NBAR*sizeof(uint16_t));
	clear_bytes((uint8_t *)Epp, PARAMS_NBAR*PARAMS_NBAR*sizeof(uint16_t));
	clear_bytes(muprime, BYTES_MU);
	clear_bytes(G2out, 2*CRYPTO_BYTES);
	clear_bytes(Fin_k, CRYPTO_BYTES);
	clear_bytes(shake_input_seedSEprime, 1 + CRYPTO_BYTES);

    return 0;
}
