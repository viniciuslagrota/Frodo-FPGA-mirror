/*
 * global_def.h
 *
 *  Created on: 25 de nov de 2019
 *      Author: Vinicius
 */

#ifndef SRC_INCLUDE_GLOBAL_DEF_H_
#define SRC_INCLUDE_GLOBAL_DEF_H_

#include <stdio.h>
#include <stdlib.h>
#include "xgpio.h"
#include "xllfifo.h"
#include "xgpio.h"
#include "xil_printf.h"

#include "frodo640.h"
#include "keccak_f1600.h"
#include "api_frodo640.h"
#include "test_kem.h"
#include "test_KEM640.h"
#include "kem.h"
#include "random.h"
#include "frodo_macrify.h"

#define ledpin 47

//////////////////////////////////////////////
//
//	Extern
//
//////////////////////////////////////////////
extern uint16_t CDF_TABLE[13];
extern uint16_t CDF_TABLE_LEN;

//////////////////////////////////////////////
//
//	Number of iterations
//
//////////////////////////////////////////////
#define KEM_TEST_ITERATIONS			1

//////////////////////////////////////////////
//
//	Keccak definitions
//
//////////////////////////////////////////////
#define USE_HW

#ifdef USE_HW
//Hardware implementation
#define KeccakF1600_StatePermute 	KeccakF1600_StatePermute_HW
#else
//Software implementation
#define KeccakF1600_StatePermute 	KeccakF1600_StatePermute_SW
#endif

//////////////////////////////////////////////
//
//	Generate random numbers
//
//////////////////////////////////////////////
#define RANDOM_BYTES				1

//////////////////////////////////////////////
//
//	Debug defines
//
//////////////////////////////////////////////
#define DEBUG_GLOBAL_ENABLED 		1
#define DEBUG_ERROR					1
//Main
#define DEBUG_MAIN					1
//Test KEM
#define DEBUG_TEST_KEM				1
//KEM
#define DEBUG_KEM					0
//Keccak_f1600
#define DEBUG_KECCAK_HW				0
#define DEBUG_STATE_MATRIX			0
//Random
#define DEBUG_RANDOM				0
//Noise
#define DEBUG_NOISE					0


//////////////////////////////////////////////
//
//	Debug print
//
//////////////////////////////////////////////
#define print_debug(debugLevel, ...) \
	do { \
		if (DEBUG_GLOBAL_ENABLED && (debugLevel == 1)) \
			printf(__VA_ARGS__); \
		} while (0)

//////////////////////////////////////////////
//
//	AXI GPIO
//
//////////////////////////////////////////////
XGpio axiStartDone;
//XGpio_Config * ConfigPtr0;
XGpio_Config * ConfigPtr1;
XGpio_Config * ConfigPtr2;
XGpio axi_control_timer;
XGpio axi_counter_timer;

//////////////////////////////////////////////
//
//	AXI Stream
//
//////////////////////////////////////////////
XLlFifo fifoKeccak;

//////////////////////////////////////////////
//
//	General defines
//
//////////////////////////////////////////////
#define false						0
#define true						1
#define passed						0
#define failed						1
#define ALIGN_HEADER(N)
#define ALIGN_FOOTER(N) 			__attribute__((aligned(N)))

// Defining method for generating matrix A
#undef _AES128_FOR_A_
#define _SHAKE128_FOR_A_
#if defined(_AES128_FOR_A_)
    #define USE_AES128_FOR_A
#elif defined(_SHAKE128_FOR_A_)
    #define USE_SHAKE128_FOR_A
#else
    ##error -- missing method for generating matrix A
#endif

#endif /* SRC_INCLUDE_GLOBAL_DEF_H_ */
