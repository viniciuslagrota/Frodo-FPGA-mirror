/*
 * Copyright (C) 2018 - 2019 Xilinx, Inc.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification,
 * are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice,
 *    this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 * 3. The name of the author may not be used to endorse or promote products
 *    derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR IMPLIED
 * WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
 * SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT
 * OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING
 * IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY
 * OF SUCH DAMAGE.
 *
 */

#include <stdio.h>
#include "include/global_def.h"
#include "xparameters.h"
#include "netif/xadapter.h"
#include "platform.h"
#include "platform_config.h"
#include "lwipopts.h"
#include "xil_printf.h"
#include "sleep.h"
#include "lwip/ip_addr.h"
#include "lwip/priv/tcp_priv.h"
#include "lwip/init.h"
#include "lwip/inet.h"
#include "include/test_kem.h"

#if LWIP_IPV6==1
#include "lwip/ip6_addr.h"
#include "lwip/ip6.h"
#else

#if LWIP_DHCP==1
#include "lwip/dhcp.h"
extern volatile int dhcp_timoutcntr;
#endif

#define DEFAULT_IP_ADDRESS	"192.168.1.3"
#define DEFAULT_IP_MASK		"255.255.255.0"
#define DEFAULT_GW_ADDRESS	"192.168.1.1"
#endif /* LWIP_IPV6 */

//////////////////////////////////////////////
//
//	Frodo Variables
//
//////////////////////////////////////////////
extern enum state st;
extern bool bCtReceived;
extern uint8_t pk[CRYPTO_PUBLICKEYBYTES];
#if SERVER_INIT == 0
extern uint8_t sk[CRYPTO_SECRETKEYBYTES];
#endif
extern uint8_t ct[CRYPTO_CIPHERTEXTBYTES];
#if SERVER_INIT == 0
extern uint8_t key_a[2*CRYPTO_BYTES];
#else
extern uint8_t key_b[2*CRYPTO_BYTES];
#endif
uint8_t ss[CRYPTO_BYTES];

//////////////////////////////////////////////
//
//	System Variables
//
//////////////////////////////////////////////
extern XGpio axiStartDone;
extern XGpio axiStartDoneMM;
extern XGpio_Config * ConfigPtr0;
extern XGpio_Config * ConfigPtr1;
extern XGpio_Config * ConfigPtr2;
extern XGpio_Config * ConfigPtr3;
extern XGpio_Config * ConfigPtr4;
extern XGpio_Config * ConfigPtr5;
extern XGpio_Config * ConfigPtr6;
extern XGpio_Config * ConfigPtr7;
extern XGpio_Config * ConfigPtr8;
extern XGpio_Config * ConfigPtr9;
extern XGpio_Config * ConfigPtr10;
extern XGpio_Config * ConfigPtr11;
extern XGpio_Config * ConfigPtr12;
extern XGpio_Config * ConfigPtr13;
extern XGpio keccak_time;
extern XGpio matrix_sa_time;
extern XGpio matrix_as_time;
extern XGpio shake128_time;
extern XGpio reset_matrix_sa_time;
extern XGpio reset_matrix_as_time;
extern XGpio reset_shake128_time;
extern XGpio axiStartBusyMatrix;
extern XGpio axiStartBusyMatrix2;
extern XGpio axiStartBusyShake;
extern XGpio axiInlenOutlen;
extern XGpio general_hw_timer_control;
extern XGpio general_hw_timer;
extern XGpio global_timer_control;
extern XGpio global_timer;
extern u32 *memoryMMkeccak;
extern u32 *memoryMatrixS;
extern u32 *memoryMatrixA;
extern u32 *memoryMatrixB;
extern u32 *memoryMatrixA2;
extern u32 *memoryMatrixS2;
extern u32 *memoryMatrixB2;
extern u32 *memoryMMshake;

extern XGpio_Config * XGpioConfigPtrGlobalTimer;
extern XGpio XGpioGlobalTimer;

extern XUartPs_Config * XUartConfig0;
extern XUartPs XUart0;

extern u8 *TxBufferPtr;
extern u8 *RxBufferPtr;

extern volatile int TcpFastTmrFlag;
extern volatile int TcpSlowTmrFlag;

//Timer
u32 u32Timer;
uint32_t ui32Integer, ui32Fraction;
u32 u32CounterSecs = 0;
u32 u32LastSeen = 0;

//////////////////////////////////////////////
//
//	Software timer
//
//////////////////////////////////////////////
XScuTimer xTimer;
XScuTimer_Config *xTimerConfig;
int timerValue;
u32 u32CounterMinutes = 0;

//////////////////////////////////////////////
//
//	AES
//
//////////////////////////////////////////////
extern uint8_t u8AesKeystream[1024];
uint8_t nonce[12] = {0x0};
u32 u32Seed;

extern char cPlainText[1024];
extern char cCipherText[1024];
char aux[32] = "Testando";

gcm_context ctx;            // includes the AES context structure
unsigned char ucAad[32] = "----Version-1.0.0-AES256-GCM----";
unsigned char ucTag[16] = { 0x0 };

//////////////////////////////////////////////
//
//	SMW3000
//
//////////////////////////////////////////////
uint8_t *psmDataPtr;
uint8_t *psmCipheredDataPtr;

//////////////////////////////////////////////
//
//	Prototypes
//
//////////////////////////////////////////////
void platform_enable_interrupts(void);
void start_application(void);
void transfer_perf_data(void);
void transfer_data(char * pcBuffer, u16_t u16BufferLen);
void print_app_header(void);


#if defined (__arm__) && !defined (ARMR5)
#if XPAR_GIGE_PCS_PMA_SGMII_CORE_PRESENT == 1 || \
		 XPAR_GIGE_PCS_PMA_1000BASEX_CORE_PRESENT == 1
int ProgramSi5324(void);
int ProgramSfpPhy(void);
#endif
#endif

#ifdef XPS_BOARD_ZCU102
#ifdef XPAR_XIICPS_0_DEVICE_ID
int IicPhyReset(void);
#endif
#endif

struct netif server_netif;

//////////////////////////////////////////////
//
//	Functions
//
//////////////////////////////////////////////

#if LWIP_IPV6==1
static void print_ipv6(char *msg, ip_addr_t *ip)
{
	print(msg);
	xil_printf(" %s\n\r", inet6_ntoa(*ip));
}
#else
static void print_ip(char *msg, ip_addr_t *ip)
{
//	print(msg);
	print_debug(DEBUG_ETH, "%s %d.%d.%d.%d\r\n", msg, ip4_addr1(ip), ip4_addr2(ip),
			ip4_addr3(ip), ip4_addr4(ip));
}

static void print_ip_settings(ip_addr_t *ip, ip_addr_t *mask, ip_addr_t *gw)
{
	print_ip("Board IP:       ", ip);
	print_ip("Netmask :       ", mask);
	print_ip("Gateway :       ", gw);
}

static void assign_default_ip(ip_addr_t *ip, ip_addr_t *mask, ip_addr_t *gw)
{
	int err;

	print_debug(DEBUG_ETH, "Configuring default IP %s \r\n", DEFAULT_IP_ADDRESS);

	err = inet_aton(DEFAULT_IP_ADDRESS, ip);
	if (!err)
		print_debug(DEBUG_ERROR, "Invalid default IP address: %d\r\n", err);

	err = inet_aton(DEFAULT_IP_MASK, mask);
	if (!err)
		print_debug(DEBUG_ERROR, "Invalid default IP MASK: %d\r\n", err);

	err = inet_aton(DEFAULT_GW_ADDRESS, gw);
	if (!err)
		print_debug(DEBUG_ERROR, "Invalid default gateway address: %d\r\n", err);
}
#endif /* LWIP_IPV6 */

void configSoftwareTimer()
{
	xTimerConfig = XScuTimer_LookupConfig(XPAR_PS7_SCUTIMER_0_DEVICE_ID);
	XScuTimer_CfgInitialize(&xTimer, xTimerConfig, xTimerConfig->BaseAddr);
	XScuTimer_DisableAutoReload(&xTimer);
//	XScuTimer_SetPrescaler(&xTimer, PRESCALE);
	XScuTimer_LoadTimer(&xTimer, TIMER_LOAD_VALUE);
	XScuTimer_Start(&xTimer);
	print_debug(DEBUG_MAIN, "Timer configured.\r\n");
}
//////////////////////////////////////////////
//
//	Main
//
//////////////////////////////////////////////
int main(void)
{
	extern struct netif *netif;

	/* the mac address of the board. this should be unique per board */
	unsigned char mac_ethernet_address[] = {
		0x00, 0x0a, 0x35, 0x00, 0x01, 0x03 };

	netif = &server_netif;
#if defined (__arm__) && !defined (ARMR5)
#if XPAR_GIGE_PCS_PMA_SGMII_CORE_PRESENT == 1 || \
		XPAR_GIGE_PCS_PMA_1000BASEX_CORE_PRESENT == 1
	ProgramSi5324();
	ProgramSfpPhy();
#endif
#endif

	/* Define this board specific macro in order perform PHY reset
	 * on ZCU102
	 */
#ifdef XPS_BOARD_ZCU102
	IicPhyReset();
#endif

	init_platform();

	print_debug(DEBUG_MAIN, "--- Frodo Algorithm ---\n\n");

	//---- Local variables ----
	u32 u32LedState = 0x0;

	//---- Initialize LED ----
	XGpioPs Gpio;
	ledInit(&Gpio);

	//---- AXI GPIO ---
	ConfigPtr0 = XGpio_LookupConfig(XPAR_AXI_GPIO_0_DEVICE_ID);
	XGpio_CfgInitialize(&global_timer_control, ConfigPtr0, ConfigPtr0->BaseAddress);
	XGpio_DiscreteWrite(&global_timer_control, 1, 0x0); //Set enable bit low.
	XGpio_DiscreteWrite(&global_timer_control, 2, 0x0); //Set reset bit low.

	ConfigPtr1 = XGpio_LookupConfig(XPAR_AXI_GPIO_1_DEVICE_ID);
	XGpio_CfgInitialize(&matrix_sa_time, ConfigPtr1, ConfigPtr1->BaseAddress);

	ConfigPtr2 = XGpio_LookupConfig(XPAR_AXI_GPIO_2_DEVICE_ID);
	XGpio_CfgInitialize(&matrix_as_time, ConfigPtr2, ConfigPtr2->BaseAddress);

	ConfigPtr3 = XGpio_LookupConfig(XPAR_AXI_GPIO_3_DEVICE_ID);
	XGpio_CfgInitialize(&global_timer, ConfigPtr3, ConfigPtr3->BaseAddress);

	ConfigPtr4 = XGpio_LookupConfig(XPAR_AXI_GPIO_4_DEVICE_ID);
	XGpio_CfgInitialize(&axiStartBusyMatrix, ConfigPtr4, ConfigPtr4->BaseAddress);
	XGpio_DiscreteWrite(&axiStartBusyMatrix, 1, 0x0); //Set start bit low.

	ConfigPtr5 = XGpio_LookupConfig(XPAR_AXI_GPIO_5_DEVICE_ID);
	XGpio_CfgInitialize(&axiStartBusyMatrix2, ConfigPtr5, ConfigPtr5->BaseAddress);
	XGpio_DiscreteWrite(&axiStartBusyMatrix2, 1, 0x0); //Set start bit low.

	ConfigPtr6 = XGpio_LookupConfig(XPAR_AXI_GPIO_6_DEVICE_ID);
	XGpio_CfgInitialize(&axiStartBusyShake, ConfigPtr6, ConfigPtr6->BaseAddress);
	XGpio_DiscreteWrite(&axiStartBusyShake, 1, 0x0); //Set start bit low.

	ConfigPtr7 = XGpio_LookupConfig(XPAR_AXI_GPIO_7_DEVICE_ID);
	XGpio_CfgInitialize(&axiInlenOutlen, ConfigPtr7, ConfigPtr7->BaseAddress);

	ConfigPtr8 = XGpio_LookupConfig(XPAR_AXI_GPIO_8_DEVICE_ID);
	XGpio_CfgInitialize(&shake128_time, ConfigPtr8, ConfigPtr8->BaseAddress);

	ConfigPtr9 = XGpio_LookupConfig(XPAR_AXI_GPIO_9_DEVICE_ID);
	XGpio_CfgInitialize(&reset_shake128_time, ConfigPtr9, ConfigPtr9->BaseAddress);
	XGpio_DiscreteWrite(&reset_shake128_time, 1, 0x0); //Set reset bit low.
	XGpio_DiscreteWrite(&reset_shake128_time, 2, 0x0); //Set reset bit low.

	ConfigPtr10 = XGpio_LookupConfig(XPAR_AXI_GPIO_10_DEVICE_ID);
	XGpio_CfgInitialize(&reset_matrix_sa_time, ConfigPtr10, ConfigPtr10->BaseAddress);
	XGpio_DiscreteWrite(&reset_matrix_sa_time, 1, 0x0); //Set reset bit low.
	XGpio_DiscreteWrite(&reset_matrix_sa_time, 2, 0x0); //Set reset bit low.

	ConfigPtr11 = XGpio_LookupConfig(XPAR_AXI_GPIO_11_DEVICE_ID);
	XGpio_CfgInitialize(&reset_matrix_as_time, ConfigPtr11, ConfigPtr11->BaseAddress);
	XGpio_DiscreteWrite(&reset_matrix_as_time, 1, 0x0); //Set reset bit low.
	XGpio_DiscreteWrite(&reset_matrix_as_time, 2, 0x0); //Set reset bit low.

	ConfigPtr12 = XGpio_LookupConfig(XPAR_AXI_GPIO_12_DEVICE_ID);
	XGpio_CfgInitialize(&general_hw_timer_control, ConfigPtr12, ConfigPtr12->BaseAddress);
	XGpio_DiscreteWrite(&general_hw_timer_control, 1, 0x0); //Set enable bit low.
	XGpio_DiscreteWrite(&general_hw_timer_control, 2, 0x0); //Set reset bit low.

	ConfigPtr13 = XGpio_LookupConfig(XPAR_AXI_GPIO_13_DEVICE_ID);
	XGpio_CfgInitialize(&general_hw_timer, ConfigPtr13, ConfigPtr13->BaseAddress);

	//---- AXI MM ----
//	memoryMMkeccak = (u32 *) XPAR_KECCAK_F1600_MM_IP_0_S00_AXI_BASEADDR;
//	print_debug(DEBUG_ERROR, "[MAIN] Keccak MM initialized.\n");

	memoryMatrixS = (u32 *) XPAR_MATRIX_SA_PLUS_E_MM_IP_0_S00_AXI_BASEADDR;
	memoryMatrixA = (u32 *) XPAR_MATRIX_SA_PLUS_E_MM_IP_0_S01_AXI_BASEADDR;
	memoryMatrixB = (u32 *) XPAR_MATRIX_SA_PLUS_E_MM_IP_0_S02_AXI_BASEADDR;
	print_debug(DEBUG_ERROR, "[MAIN] Matrix SA initialized.\n");

	memoryMatrixA2 = (u32 *) XPAR_MATRIX_AS_PLUS_E_MM_0_S00_AXI_BASEADDR;
	memoryMatrixS2 = (u32 *) XPAR_MATRIX_AS_PLUS_E_MM_0_S01_AXI_BASEADDR;
	memoryMatrixB2 = (u32 *) XPAR_MATRIX_AS_PLUS_E_MM_0_S02_AXI_BASEADDR;
	print_debug(DEBUG_ERROR, "[MAIN] Matrix AS initialized.\n");

	memoryMMshake = (u32 *) XPAR_SHAKE128_IP_0_S00_AXI_BASEADDR;
	print_debug(DEBUG_ERROR, "[MAIN] Shake128 initialized.\n");

	//---- Initialize UART0 ----
	XUartConfig0 = XUartPs_LookupConfig(XPAR_PS7_UART_0_DEVICE_ID);
	XUartPs_CfgInitialize(&XUart0, XUartConfig0, XUartConfig0->BaseAddress);
	XUartPs_SetBaudRate(&XUart0, 115200);

	//---- SMW3000 variables ----
	u32 rv;

	//Alloc keystream
	size_t sSize = sizeof(smDataStruct); //Complete structure
	size_t sSizeCiphered = sizeof(smDataStruct) - 52; //Ignore u32Seed field
#if LOOP_TEST_SMW3000 == 1
	u8 * u8Keystream = (u8 *)malloc(sSize);
	if(u8Keystream == NULL)
		print_debug(DEBUG_MAIN, "Failed to alloc pointer.\r\n");
#endif

	smDataStruct * psmData;
	smDataStruct * psmCipheredData;

#if LOOP_TEST_SMW3000 == 1
	//Create key and nonce
	uint8_t u8Key[32] = { 0x3E };
	uint8_t u8Nonce[12] = { 0x1F };
#endif

	smw3000Init();

	smControlStruct * psmControlStruct;
	psmControlStruct = smw3000GetControlStruct();
	if(psmControlStruct == NULL)
		print_debug(DEBUG_MAIN, "Null pointer error.\r\n");

#if LOOP_TEST_SMW3000 == 1
	while (1) {

		print_debug(DEBUG_MAIN, "\r\n\r\n------------------------------------------------------\r\n", rv);

		rv = smw3000GetAllData();
		if(rv)
		{
			print_debug(DEBUG_MAIN, "Failed to get data (rv: 0x%08x).\r\n", rv);
			continue;
		}
		else
			print_debug(DEBUG_MAIN, "Data successfully acquired.\r\n");

		//Print data for debug purpose
		psmData = smw3000GetDataStruct();
		smw3000PrintDataStruct(psmData);

		//Generate keystream
		aes256ctr_prf(u8Keystream, sSizeCiphered, u8Key, u8Nonce);
		print_debug(DEBUG_MAIN, "Keystream (len: %d): ", sSizeCiphered);
		for(int i = 0; i < sSize; i++)
		{
			printf("%02x ", *(u8Keystream + i));
		}
		printf("\r\n");

		//Function to encrypt data structure
		rv = smw3000CipherDataStruct(u8Keystream);
		if(rv)
		{
			print_debug(DEBUG_MAIN, "Failed to cipher data due to deallocated pointer.\r\n");
			continue;
		}
		else
			print_debug(DEBUG_MAIN, "Data successfully ciphered.\r\n");

		//Print data for debug purpose
		psmCipheredData = smw3000GetCipheredDataStruct();
		smw3000PrintDataStruct(psmCipheredData);

		//Clean data structure
		memset(psmData, 0x0, sSize);
		smw3000PrintDataStruct(psmData);

		rv = smw3000DecipherDataStruct(u8Keystream);
		if(rv)
		{
			print_debug(DEBUG_MAIN, "Failed to cipher data due to deallocated pointer.\r\n");
			continue;
		}
		else
			print_debug(DEBUG_MAIN, "Data successfully deciphered.\r\n");

		//Print deciphered data
		smw3000PrintDataStruct(psmData);

		rv = smw3000CheckCrc();
		if(rv)
			print_debug(DEBUG_MAIN, "CRC failed.\r\n");
		else
			print_debug(DEBUG_MAIN, "CRC success.\r\n");

		sleep(5);
	}
#endif

	xil_printf("\r\n\r\n");
	print_debug(DEBUG_MAIN, "-----lwIP RAW Mode TCP Client Application (TCP MSS: %d)-----\r\n", TCP_MSS);

	/* initialize lwIP */
	lwip_init();

	/* Add network interface to the netif_list, and set it as default */
	if (!xemac_add(netif, NULL, NULL, NULL, mac_ethernet_address,
				PLATFORM_EMAC_BASEADDR)) {
		print_debug(DEBUG_MAIN, "Error adding N/W interface\r\n");
		return -1;
	}

#if LWIP_IPV6==1
	netif->ip6_autoconfig_enabled = 1;
	netif_create_ip6_linklocal_address(netif, 1);
	netif_ip6_addr_set_state(netif, 0, IP6_ADDR_VALID);
	print_ipv6("\n\rlink local IPv6 address is:",&netif->ip6_addr[0]);
#endif /* LWIP_IPV6 */
	netif_set_default(netif);

	/* now enable interrupts */
	platform_enable_interrupts();

	/* specify that the network if is up */
	netif_set_up(netif);

#if (LWIP_IPV6==0)
#if (LWIP_DHCP==1)
	/* Create a new DHCP client for this interface.
	 * Note: you must call dhcp_fine_tmr() and dhcp_coarse_tmr() at
	 * the predefined regular intervals after starting the client.
	 */
	dhcp_start(netif);
	dhcp_timoutcntr = 24;
	while (((netif->ip_addr.addr) == 0) && (dhcp_timoutcntr > 0))
		xemacif_input(netif);

	if (dhcp_timoutcntr <= 0) {
		if ((netif->ip_addr.addr) == 0) {
			print_debug(DEBUG_MAIN, "ERROR: DHCP request timed out\r\n");
			assign_default_ip(&(netif->ip_addr),
					&(netif->netmask), &(netif->gw));
		}
	}

	/* print IP address, netmask and gateway */
#else
	assign_default_ip(&(netif->ip_addr), &(netif->netmask), &(netif->gw));
#endif
	print_ip_settings(&(netif->ip_addr), &(netif->netmask), &(netif->gw));
#endif /* LWIP_IPV6 */
	xil_printf("\r\n");

	/* print app header */
	print_app_header();

	/* start the application*/
	start_application();
	xil_printf("\r\n");

	configSoftwareTimer();

#if USE_HW_ACCELERATION == 0
	set_hardware_usage(SHAKE128_SW_MATRIX_SA_SW_AS_SW);
#else
	set_hardware_usage(SHAKE128_HW_MM_MATRIX_SA_HW_AS_HW);
#endif

	//Initialize AES256-GCM
	gcm_initialize();

	while (1) {

		//---- Get chip temperature ----
		getChipTemperature();

		//Blink led
		XGpioPs_WritePin(&Gpio, ledpin, u32LedState);
		u32LedState ^= 0x1;

		if (TcpFastTmrFlag) {
			tcp_fasttmr();
			TcpFastTmrFlag = 0;
		}
		if (TcpSlowTmrFlag) {
			tcp_slowtmr();
			TcpSlowTmrFlag = 0;
		}
		xemacif_input(netif);

		//Timer
		timerValue = XScuTimer_GetCounterValue(&xTimer);
		if(timerValue == 0)
		{
			XScuTimer_RestartTimer(&xTimer);
			u32CounterSecs++;
			if(u32CounterSecs >= CHANGE_KEY_TIME)
				u32CounterSecs = 0;

			//Check if system is for so long inactive.
			u32 u32InactiveTimeout = u32LastSeen + INACTIVE_TIMEOUT;
			if(u32InactiveTimeout > CHANGE_KEY_TIME)
				u32InactiveTimeout -= CHANGE_KEY_TIME;
			if(u32InactiveTimeout == u32CounterSecs && st != WAITING_PK)
			{
				print_debug(DEBUG_MAIN, "System timeout, stuck in st %d...\r\n", st);
				st = RECONNECTING;
			}

		}

#if PERFORMANCE_TEST == 1
//		//Transfer performance data
		transfer_perf_data();
		sleep(5);
#else

#if SERVER_INIT == 0
		switch(st)
		{
			case WAITING_SERVER_CONNECTION:
				//Do nothing. Wait connection.
			break;
			case CONNECTED_TO_SERVER:
				print_debug(DEBUG_MAIN, "Connected to server!\r\n");
				XScuTimer_Start(&xTimer);
				st = CREATE_KEY_PAIR;
			break;
			case CREATE_KEY_PAIR:
				print_debug(DEBUG_MAIN, "Generating new key pair...\r\n");

				//Start timer
				resetTimer(&global_timer_control, 2);
				u32Timer = getTimer(&global_timer, 1);
				print_debug(DEBUG_MAIN, "Reset Timer SW: %ld ns\n", u32Timer * HW_CLOCK_PERIOD);
				startTimer(&global_timer_control, 1);

				//Generate key pair
				crypto_kem_keypair(pk, sk);

#if DEBUG_FRODO == 1
				print_debug(DEBUG_MAIN, "Public key: ");
				for(int i = 0; i < CRYPTO_PUBLICKEYBYTES; i++)
					printf("%x", pk[i]);
				printf("\r\n\r\n");
#endif
				st = SEND_PK;
			break;
			case SEND_PK:
				//Publish PK
				transfer_data((char *)pk, CRYPTO_PUBLICKEYBYTES);
				st = WAITING_CT;
			break;
			case WAITING_CT:
				//Do nothing. Wait for ciphertext.
			break;
			case CALCULATE_SHARED_SECRET:
				//Check CT received

#if DEBUG_FRODO == 1
				print_debug(DEBUG_MAIN, "ct received: ");
				for(int i = 0; i < CRYPTO_CIPHERTEXTBYTES; i++)
					printf("%x", ct[i]);
				printf("\n\r");
#endif

				//Decapsulation
				crypto_kem_dec(key_a, ct, sk);

				//Stop timer
				stopTimer(&global_timer_control, 1);
				u32Timer = getTimer(&global_timer, 1) * HW_CLOCK_PERIOD;
				floatToIntegers((double)u32Timer/1000000, 		&ui32Integer, &ui32Fraction);
				print_debug(DEBUG_MAIN, "Timer (hw) to process KEM (client side): %lu.%03lu ms\n", ui32Integer, ui32Fraction);

				//Check shared secret
#if DEBUG_FRODO == 1
				print_debug(DEBUG_MAIN, "key_a calculated: ");
				for(int i = 0; i < CRYPTO_BYTES; i++)
					printf("%x", key_a[i]);
				printf("\n\r\n\r");
#endif
//				st = CREATE_KEY_PAIR;
				st = CALCULATE_AES_BLOCK;
			break;
			case CALCULATE_AES_BLOCK:
				nonce[0]++;
				aes256ctr_prf(u8AesKeystream, sSize, key_a, nonce);
#if DEBUG_FRODO == 1
				print_debug(DEBUG_MAIN, "aes256 calculated: ");
				for(int i = 0; i < 32; i++)
					printf("%02x", u8AesKeystream[i]);
				printf("\n\r");
#endif
				st = WAIT_CIPHERED_DATA;
			break;
			case WAIT_CIPHERED_DATA:
				//Wait messages from client
			break;
			case DECIPHER_MESSAGE:
//				print_debug(DEBUG_MAIN, "Ciphertext (bytes): ");
//				for(int i = 0; i < 32; i++)
//				{
//					print_debug(DEBUG_MAIN, "%02x", cCiphertext[i]);
//				}
//				print_debug(DEBUG_MAIN, "\n\r");
//				print_debug(DEBUG_MAIN, "Plaintext (bytes): ");
				for(int i = 0; i < 32; i++)
				{
					cPlaintext[i] = cCiphertext[i] ^ u8AesKeystream[i];
//					print_debug(DEBUG_MAIN, "%02x", cPlaintext[i]);
				}
//				print_debug(DEBUG_MAIN, "\n\r");
				print_debug(DEBUG_MAIN, "Achieved plaintext: %s\r\n", cPlaintext);
				printf("\n\r\n\r");

				st = CALCULATE_AES_BLOCK;
			break;
		}

//		sleep(1);
#else
        //Force go to calculating CT if message received. Necessary if code is inside any function and returns to its previous state.
        if(bCtReceived)
            st = CALCULATING_CT;

		switch(st)
		{
			case WAITING_PK:
				//Do nothing, just wait.
			break;
			case CALCULATING_CT:
				bCtReceived = 0;
				u32LastSeen = u32CounterSecs;
				print_debug(DEBUG_MAIN, "Calculating CT...\r\n");

				//Start timer
				resetTimer(&global_timer_control, 2);
				u32Timer = getTimer(&global_timer, 1);
				print_debug(DEBUG_MAIN, "Reset Timer SW: %ld ns\n", u32Timer * HW_CLOCK_PERIOD);
				startTimer(&global_timer_control, 1);

				crypto_kem_enc(ct, ss, pk);
				shake(key_b, 2*CRYPTO_BYTES, ss, CRYPTO_BYTES);

#if DEBUG_FRODO == 1
				print_debug(DEBUG_MAIN, "pk rcv: ");
				for(int i = 0; i < CRYPTO_PUBLICKEYBYTES; i++)
					printf("%x", pk[i]);
				printf("\n\r\n\r");
#endif
				st = SENDING_CT;
			break;
			case SENDING_CT:
				u32LastSeen = u32CounterSecs;
				print_debug(DEBUG_MAIN, "Sending CT...\r\n");
//				transfer_data(cTxBuffer, sizeof(cTxBuffer));
				transfer_data((char *)ct, CRYPTO_CIPHERTEXTBYTES);

#if DEBUG_FRODO == 1
				print_debug(DEBUG_MAIN, "ct calculated: ");
				for(int i = 0; i < CRYPTO_CIPHERTEXTBYTES; i++)
					printf("%x", ct[i]);
				printf("\n\r");
#endif

				//Check shared secret
#if DEBUG_FRODO == 1
				print_debug(DEBUG_MAIN, "ss calculated: ");
				for(int i = 0; i < CRYPTO_BYTES; i++)
					printf("%02x", ss[i]);
				printf("\n\r");
#endif

#if DEBUG_FRODO == 1
				print_debug(DEBUG_MAIN, "key_b calculated: ");
				for(int i = 0; i < 2*CRYPTO_BYTES; i++)
					printf("%02x", key_b[i]);
				printf("\n\r");
#endif

				//Stop timer
				stopTimer(&global_timer_control, 1);
				u32Timer = getTimer(&global_timer, 1) * HW_CLOCK_PERIOD;
				floatToIntegers((double)u32Timer/1000000, 		&ui32Integer, &ui32Fraction);
				print_debug(DEBUG_MAIN, "Timer (hw) to process KEM (client side): %lu.%03lu ms\n", ui32Integer, ui32Fraction);

				print_debug(DEBUG_MAIN, "CT sent!\r\n");

				//Restart nonce
				memset(nonce, 0x0, 12);

#if KEM_TEST_ONLY == 1
				st = WAITING_PK;
#else
				st = WAITING_SEND_CT;
#endif
			break;
			case WAITING_SEND_CT:
				//Do nothing
			break;
			case WAIT_SERVER_CALCULATE_CT:
				u32LastSeen = u32CounterSecs;
				sleep(5);
				st = GET_SMW3000_DATA;
			break;
			case GET_SMW3000_DATA:
				u32LastSeen = u32CounterSecs;
				print_debug(DEBUG_MAIN, "Getting SMW3000 data...\r\n");

				//Get data pointer
				psmData = smw3000GetDataStruct();

				for(int j = 0; j < MAX_TRY; j++)
				{
#if SIMULATED_DATA == 0
					rv = smw3000GetAllData();
#else
					memcpy(psmData->u8DeviceName, "WEG1053152173", 13);
					psmData->u8Timestamp[0] = 0x07;
					psmData->u8Timestamp[1] = 0xE5;
					psmData->u8Timestamp[2] = 0x09;
					psmData->u8Timestamp[3] = 0x19;
					psmData->u8Timestamp[4] = 0x10;
					psmData->u8Timestamp[5] = 0x2F;
					psmData->u8Timestamp[6] = 0x33;
					psmData->u32VoltageL1 = 212233;
					psmData->u32VoltageL2 = 370;
					psmData->u32VoltageL3 = 401;
					psmData->u32CurrentL1 = 215;
					psmData->u32CurrentL2 = 0;
					psmData->u32CurrentL3 = 0;
					psmData->u32CurrentN = 230;
					psmData->u16Crc = 0x3367;
					rv = 0;
#endif
					if(rv)
					{
						print_debug(DEBUG_ERROR, "Failed to get data (rv: 0x%08x).\r\n", rv);
						usleep(10000);
					}
					else
					{
						print_debug(DEBUG_MAIN, "Data successfully acquired.\r\n");
						break;
					}
				}

				if(!rv)
					st = CIPHER_MESSAGE;
				break;
			case CIPHER_MESSAGE:
				u32LastSeen = u32CounterSecs;
				print_debug(DEBUG_MAIN, "Calculating AES block...\r\n");

				//Get data pointers
				psmData = smw3000GetDataStruct();
				psmCipheredData = smw3000GetCipheredDataStruct();

				//Get random seed
				u32Seed = getAndInitializeRandomSeed();

				//Save seed into structure
				psmData->u32Seed = u32Seed;
				psmCipheredData->u32Seed = u32Seed;

				//Save data into plaintext structure for print purpose
				memcpy(psmData->u8Aad, ucAad, 32);
				memset(ucTag, 0x0, 16);
				memcpy(psmData->u8Tag, ucTag, 16);

				//Print data for debug purpose
				smw3000PrintDataStruct(psmData);

				//Calculate nonce
				rv = generateNonce(u32Seed, nonce, sizeof(nonce));
				if(rv == 0)
					print_debug(DEBUG_MAIN, "Error while generating nonce...\r\n");
				printNonce(nonce);

				//Set pointer
				psmDataPtr = (uint8_t*)psmData->u8DeviceName;
				psmCipheredDataPtr = (uint8_t*)psmCipheredData->u8DeviceName;

				//Perform AES-GCM
				gcm_setkey(&ctx, key_b, (const uint)(2*CRYPTO_BYTES));   // setup our AES-GCM key
				gcm_crypt_and_tag(&ctx, ENCRYPT, nonce, 12, ucAad, 32, psmDataPtr, psmCipheredDataPtr, sSizeCiphered, ucTag, 16);
				memcpy(psmCipheredData->u8Aad, ucAad, 32);
				memcpy(psmCipheredData->u8Tag, ucTag, 16);

				//Print data for debug purpose
				smw3000PrintDataStruct(psmCipheredData);

				st = SEND_CIPHER_MESSAGE;
			break;
			case SEND_CIPHER_MESSAGE:
				u32LastSeen = u32CounterSecs;
				print_debug(DEBUG_MAIN, "Sending ciphered message...\r\n");
				transfer_data((char *)psmCipheredData, sSize);

				st = WAITING_CIPHER_MESSAGE_ACK;
			break;
			case WAITING_CIPHER_MESSAGE_ACK:
				//Do nothing.
			break;
			case RECONNECTING:
				u32LastSeen = u32CounterSecs;
				sleep(5);
				start_application();
				st = WAITING_PK;
			break;

		}
#endif
#endif
	}

	/* never reached */
	cleanup_platform();

	return 0;
}
