/*
 * global_def.h
 *
 *  Created on: 25 de nov de 2019
 *      Author: Vinicius
 */

#ifndef SRC_INCLUDE_GLOBAL_DEF_H_
#define SRC_INCLUDE_GLOBAL_DEF_H_

//////////////////////////////////////////////
//
//	Includes
//
//////////////////////////////////////////////
//System
#include <stdio.h>
#include <stdlib.h>
#include <stdio.h>
#include <stdbool.h>
#include <limits.h>

//Hardware
#include "xil_printf.h"
#include "sleep.h"
#include "xgpio.h"
#include "xgpiops.h"
#include "xuartps.h"
#include "xadcps.h"
#include "xscutimer.h"

//Software
#include "aes256ctr.h"
#include "weg_smw3000.h"
#include "frodo640.h"
#include "keccak_f1600.h"
#include "api_frodo640.h"
#include "test_kem.h"
#include "test_KEM640.h"
#include "kem.h"
#include "random.h"
#include "frodo_macrify.h"

//////////////////////////////////////////////
//
//	Pinout
//
//////////////////////////////////////////////
/*
 * PMOD_09: RX
 * PMOD_10: TX
 * PMOD_11: GND
 */

//////////////////////////////////////////////
//
//	Change key type
//
//////////////////////////////////////////////
#define SERVER_INIT			1	//1: Server generate key pair and send PK | 0: Server waits PK from client
#define CHANGE_KEY_TIME		1   //In minutes, if zero, does not perform AES. Only valid when SERVER_INIT = 0.

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
//	Compilation defines
//
//////////////////////////////////////////////
#define ENABLE_DEBUG				0
#define ENABLE_TEST_KECCAK_SW		0
#define ENABLE_TEST_KECCAK_HW_MM	0
#define ENABLE_TEST_MATRIX_SA		0
#define ENABLE_TEST_MATRIX_AS		0
#define ENABLE_TEST_SHAKE			1

#define ENABLE_KEM_TEST				1
#define ENABLE_HW_TIMER				0
#define ENABLE_SW_TIMER				0
//Just used for debug
#define ENABLE_MATRIX_SW			0
#define ENABLE_MATRIX_HW			0

//////////////////////////////////////////////
//
//	Debug defines
//
//////////////////////////////////////////////
#define DEBUG_GLOBAL_ENABLED 		1
#define DEBUG_ERROR					1
//Frodo
#define DEBUG_FRODO					0
//Main
#define DEBUG_MAIN					1
//Test KEM
#define DEBUG_TEST_KEM				1
//KEM
#define DEBUG_KEM_KEYPAIR			0
#define DEBUG_KEM_ENC				0
#define DEBUG_KEM_DEC				0
//Keccak_f1600
#define DEBUG_KECCAK_HW				0
#define DEBUG_KECCAK_HW_MM			0
#define DEBUG_STATE_MATRIX			1
#define DEBUG_TIMER					0
//Random
#define DEBUG_RANDOM				0
//Noise
#define DEBUG_NOISE					0
//Matrix multiplication
#define DEBUG_MATRIX_MM				1
//SHAKE128
#define DEBUG_SHAKE_MM				0
//Accelerations
#define DEBUG_TIME					1
//ETH
#define	DEBUG_ETH					1
//SMW3000
#define DEBUG_SM_LVL0				0
#define DEBUG_SM_LVL1				0
#define DEBUG_SM_LVL2				1
#define DEBUG_SM_ERROR				1

//////////////////////////////////////////////
//
//	SMW3000
//
//////////////////////////////////////////////
#define LOOP_TEST_SMW3000			0

//////////////////////////////////////////////
//
//	Ethernet
//
//////////////////////////////////////////////
#define PERFORMANCE_TEST	0
#define ENABLE_TIMEOUT		0

//////////////////////////////////////////////
//
//	LED pin
//
//////////////////////////////////////////////
#define ledpin 47

//////////////////////////////////////////////
//
//	Hardware clock period
//
//////////////////////////////////////////////
#define HW_CLOCK_PERIOD			10 //ns

//////////////////////////////////////////////
//
//	Software timer timeout counter
//
//////////////////////////////////////////////
#define TIMER_LOAD_VALUE		5*(XPAR_CPU_CORTEXA9_0_CPU_CLK_FREQ_HZ/2) //1 second if prescale = 0
#define PRESCALE				11 // Total time wait = (PRESCALE + 1) * TIMER_LOAD_VALUE

/////////////////////////////////////////////
//
//	AXI GPIO
//
//////////////////////////////////////////////
XGpio_Config * XGpioConfigPtrGlobalTimer;
XGpio XGpioGlobalTimer;
XGpio axiStartDone;
XGpio axiStartDoneMM;
XGpio_Config * ConfigPtr0;
XGpio_Config * ConfigPtr1;
XGpio_Config * ConfigPtr2;
XGpio_Config * ConfigPtr3;
XGpio_Config * ConfigPtr4;
XGpio_Config * ConfigPtr5;
XGpio_Config * ConfigPtr6;
XGpio_Config * ConfigPtr7;
XGpio_Config * ConfigPtr8;
XGpio_Config * ConfigPtr9;
XGpio_Config * ConfigPtr10;
XGpio_Config * ConfigPtr11;
XGpio_Config * ConfigPtr12;
XGpio_Config * ConfigPtr13;
XGpio keccak_time;
XGpio matrix_sa_time;
XGpio matrix_as_time;
XGpio shake128_time;
XGpio reset_matrix_sa_time;
XGpio reset_matrix_as_time;
XGpio reset_shake128_time;
XGpio axiStartBusyMatrix;
XGpio axiStartBusyMatrix2;
XGpio axiStartBusyShake;
XGpio axiInlenOutlen;
XGpio general_hw_timer_control;
XGpio general_hw_timer;
XGpio global_timer_control;
XGpio global_timer;
XUartPs_Config * XUartConfig0;
XUartPs XUart0;
u32 *memoryMMkeccak;
u32 *memoryMatrixS;
u32 *memoryMatrixA;
u32 *memoryMatrixB;
u32 *memoryMatrixA2;
u32 *memoryMatrixS2;
u32 *memoryMatrixB2;
u32 *memoryMMshake;

//////////////////////////////////////////////
//
//	Temperature
//
//////////////////////////////////////////////
#define XADC_DEVICE_ID 		XPAR_XADCPS_0_DEVICE_ID

//////////////////////////////////////////////
//
//	Kyber variables
//
//////////////////////////////////////////////
#if SERVER_INIT == 0
enum state
{
	WAITING_SERVER_CONNECTION,
	CONNECTED_TO_SERVER,
	CREATE_KEY_PAIR,
	SEND_PK,
	WAITING_CT,
	CALCULATE_SHARED_SECRET,
	CALCULATE_AES_BLOCK,
	WAIT_CIPHERED_DATA,
	DECIPHER_MESSAGE
};
#else
enum state
{
	WAITING_PK,
	CALCULATING_CT,
	SENDING_CT,
	CALCULATE_AES_BLOCK,
	GET_SMW3000_DATA,
	CIPHER_MESSAGE,
	SEND_CIPHER_MESSAGE
};
#endif

enum state st;
uint8_t pk[CRYPTO_PUBLICKEYBYTES];
#if SERVER_INIT == 0
uint8_t sk[CRYPTO_SECRETKEYBYTES];
#endif
uint8_t ct[CRYPTO_CIPHERTEXTBYTES];
#if SERVER_INIT == 0
uint8_t key_a[2*CRYPTO_BYTES];
#else
uint8_t key_b[2*CRYPTO_BYTES];
#endif
struct netif *netif;

//////////////////////////////////////////////
//
//	AES
//
//////////////////////////////////////////////
uint8_t u8AesKeystream[1024];
char cPlaintext[1024];
char cCiphertext[1024];

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

//////////////////////////////////////////////
//
//	Debug print
//
//////////////////////////////////////////////
//#define print_debug(debugLevel, ...) \
//	do { \
//		if (DEBUG_GLOBAL_ENABLED && (debugLevel == 1)) \
//			printf(__VA_ARGS__); \
//		} while (0)

#define print_debug(debugLevel, fmt, ...) \
	do { \
		if (DEBUG_GLOBAL_ENABLED && (debugLevel == 1)) \
			printf("%s:%d:%s() | " fmt, __FILE__, __LINE__, __func__, ## __VA_ARGS__); \
		} while (0)

//////////////////////////////////////////////
//
//	Prototypes
//
//////////////////////////////////////////////
void getChipTemperature();
u32 getAndInitializeRandomSeed();
void setRandomSeed(u32 u32RandomSeed);
void ledInit(XGpioPs * Gpio);
void configTimer(XGpio_Config * pConfigStruct, XGpio * pGpioStruct, uint8_t ui8DeviceId, uint8_t ui8Channel);
void resetTimer(XGpio * pStruct, uint8_t ui8Channel);
void startTimer(XGpio * pStruct, uint8_t ui8Channel);
void stopTimer(XGpio * pStruct, uint8_t ui8Channel);
u32 getTimer(XGpio * pStruct, uint8_t ui8Channel);
void floatToIntegers(double dValue, u32 * u32Integer, u32 * u32Fraction);
void resetTimeVariables();
void printTimeVariables();
uint16_t crc16(uint8_t * p, unsigned long len);
uint8_t incrementNonce(uint8_t * nonce, size_t sSize);
uint8_t generateNonce(uint8_t * nonce, size_t sSize);
void printNonce(uint8_t * nonce);

#endif /* SRC_INCLUDE_GLOBAL_DEF_H_ */