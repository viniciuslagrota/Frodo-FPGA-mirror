/*
 * global_func.c
 *
 *  Created on: 5 de fev de 2021
 *      Author: vinicius
 */

#include "global_def.h"
#include "sha2.h"

//////////////////////////////////////////////
//
//	Fraction to integrer
//
//////////////////////////////////////////////
int XAdcFractionToInt(float FloatNum)
{
	float Temp;

	Temp = FloatNum;
	if (FloatNum < 0) {
		Temp = -(FloatNum);
	}

	return( ((int)((Temp -(float)((int)Temp)) * (1000.0f))));
}

//////////////////////////////////////////////
//
//	Print temperature
//
//////////////////////////////////////////////
void getChipTemperature()
{
	static XAdcPs XAdcInst;
	XAdcPs_Config *ConfigPtr;
	u32 TempRawData;
	float TempData;
	XAdcPs *XAdcInstPtr = &XAdcInst;

	ConfigPtr = XAdcPs_LookupConfig(XADC_DEVICE_ID);
	XAdcPs_CfgInitialize(XAdcInstPtr, ConfigPtr, ConfigPtr->BaseAddress);
	XAdcPs_SelfTest(XAdcInstPtr);
	XAdcPs_SetSequencerMode(XAdcInstPtr, XADCPS_SEQ_MODE_SAFE);
	TempRawData = XAdcPs_GetAdcData(XAdcInstPtr, XADCPS_CH_TEMP);
	srand(TempRawData); //Get a random seed here!
	TempData = XAdcPs_RawToTemperature(TempRawData);
//	print_debug(DEBUG_MAIN, "[MAIN] The Current Temperature is %0d.%03d Centigrades\n", (int)(TempData), XAdcFractionToInt(TempData));
}

//////////////////////////////////////////////
//
//	Get random seed
//
//////////////////////////////////////////////
u32 getAndInitializeRandomSeed()
{
	static XAdcPs XAdcInst;
	XAdcPs_Config *ConfigPtr;
	u32 TempRawData;
	XAdcPs *XAdcInstPtr = &XAdcInst;

	ConfigPtr = XAdcPs_LookupConfig(XADC_DEVICE_ID);
	XAdcPs_CfgInitialize(XAdcInstPtr, ConfigPtr, ConfigPtr->BaseAddress);
	XAdcPs_SelfTest(XAdcInstPtr);
	XAdcPs_SetSequencerMode(XAdcInstPtr, XADCPS_SEQ_MODE_SAFE);
	TempRawData = XAdcPs_GetAdcData(XAdcInstPtr, XADCPS_CH_TEMP);
	srand(TempRawData); //Get a random seed here!
	TempRawData = rand();
	srand(TempRawData);
	return TempRawData;
}

//////////////////////////////////////////////
//
//	Set random seed
//
//////////////////////////////////////////////
void setRandomSeed(u32 u32RandomSeed)
{
	srand(u32RandomSeed);
}

//////////////////////////////////////////////
//
//	LED initialize
//
//////////////////////////////////////////////
void ledInit(XGpioPs * Gpio)
{
	//---- Blink led ----
	XGpioPs_Config *GPIOConfigPtr;
	GPIOConfigPtr = XGpioPs_LookupConfig(XPAR_PS7_GPIO_0_DEVICE_ID);
	XGpioPs_CfgInitialize(Gpio, GPIOConfigPtr, GPIOConfigPtr ->BaseAddr);
	XGpioPs_SetDirectionPin(Gpio, ledpin, 1);
	XGpioPs_SetOutputEnablePin(Gpio, ledpin, 1);
}

//////////////////////////////////////////////
//
//	Configure timer
//
//////////////////////////////////////////////
void configTimer(XGpio_Config * pConfigStruct, XGpio * pGpioStruct, uint8_t ui8DeviceId, uint8_t ui8Channel)
{
	pConfigStruct = XGpio_LookupConfig(ui8DeviceId);
	XGpio_CfgInitialize(pGpioStruct, pConfigStruct, pConfigStruct->BaseAddress);
	XGpio_DiscreteWrite(pGpioStruct, 0x1, 0x0); //Set enable bit and reset bit low.
	XGpio_DiscreteWrite(pGpioStruct, 0x2, 0x0); //Set enable bit and reset bit low.
}

//////////////////////////////////////////////
//
//	Reset hardware timer
//
//////////////////////////////////////////////
void resetTimer(XGpio * pStruct, uint8_t ui8Channel)
{
	XGpio_DiscreteWrite(pStruct, ui8Channel, 0x0); //Set reset bit low.
	XGpio_DiscreteWrite(pStruct, ui8Channel, 0x1); //Set reset bit high.
	XGpio_DiscreteWrite(pStruct, ui8Channel, 0x0); //Set reset bit low.
}

//////////////////////////////////////////////
//
//	Start hardware timer
//
//////////////////////////////////////////////
void startTimer(XGpio * pStruct, uint8_t ui8Channel)
{
	XGpio_DiscreteWrite(pStruct, ui8Channel, 0x1); //Set enable bit high.
}

//////////////////////////////////////////////
//
//	Stop hardware timer
//
//////////////////////////////////////////////
void stopTimer(XGpio * pStruct, uint8_t ui8Channel)
{
	XGpio_DiscreteWrite(pStruct, ui8Channel, 0x0); //Set enable bit low.
}

//////////////////////////////////////////////
//
//	Get hardware timer
//
//////////////////////////////////////////////
u32 getTimer(XGpio * pStruct, uint8_t ui8Channel)
{
	return XGpio_DiscreteRead(pStruct, ui8Channel);
}

//////////////////////////////////////////////
//
//	Float to integer and fraction
//
//////////////////////////////////////////////
void floatToIntegers(double dValue, u32 * u32Integer, u32 * u32Fraction)
{
	*u32Integer = dValue;
	*u32Fraction = (dValue - *u32Integer) * 1000;
}

//////////////////////////////////////////////
//
//	CRC16
//
//////////////////////////////////////////////
unsigned long reflect (unsigned long crc, int bitnum) {

    // reflects the lower 'bitnum' bits of 'crc'

    unsigned long i, j=1, crcout=0;

    for (i=(unsigned long)1<<(bitnum-1); i; i>>=1) {
        if (crc & i) crcout|=j;
        j<<= 1;
    }
    return (crcout);
}

uint16_t crc16(uint8_t * p, unsigned long len)
{
    //CRC-16/XMODEM -> https://crccalc.com/
    const int order = 16;
    const unsigned long polynom = 0x1021;
//    const unsigned long crcinit = 0x0000;
//    const unsigned long crcxor = 0x0000;
    const unsigned long crcinit = 0xFFFF;
	const unsigned long crcxor = 0xFFFF;
    const int refin = 1;
    const int refout = 1;

    unsigned long crcmask = ((((unsigned long)1<<(order-1))-1)<<1)|1;
    unsigned long crchighbit = (unsigned long)1<<(order-1);

    unsigned long i, j, c, bit;
    unsigned long crc = crcinit;

    for (i=0; i<len; i++) {

        c = (unsigned long)*p++;
        if (refin) c = reflect(c, 8);

        for (j=0x80; j; j>>=1) {

            bit = crc & crchighbit;
            crc<<= 1;
            if (c & j) bit^= crchighbit;
            if (bit) crc^= polynom;
        }
    }

    if (refout) crc=reflect(crc, order);
    crc^= crcxor;
    crc&= crcmask;

    return(crc);
}

//////////////////////////////////////////////
//
//	Nonce
//
//////////////////////////////////////////////
uint8_t incrementNonce(uint8_t * nonce, size_t sSize)
{
	uint8_t u8Increment = (sSize >> 4) + 1; //sSize/16 + 1 | 16 bytes is the AES256-CTR block size or 128 bits.
	uint8_t u8Carry = 0;
	uint64_t u64Low;
	uint32_t u32High;

	if(nonce == NULL)
		return 0;

	memcpy(&u64Low, nonce, 8);
	memcpy(&u32High, &nonce[8], 4);

	if( u64Low > ULONG_MAX - u8Increment)
		u8Carry++;

	u64Low += u8Increment;
	u32High += u8Carry;

	memcpy(nonce, &u64Low, 8);
	memcpy(&nonce[8], &u32High, 4);

	return 1;
}

uint8_t generateNonce(uint32_t u32Seed, uint8_t * nonce, size_t sSize) //sSize is the size of nonce in bytes
{
	uint8_t u8Out[32];
	uint8_t u8In[4] = { (uint8_t)(u32Seed & 0xFF), (uint8_t)((u32Seed >> 8) & 0xFF), (uint8_t)((u32Seed >> 16) & 0xFF), (uint8_t)((u32Seed >> 24) & 0xFF) };

	if(nonce == NULL)
		return 0;

	sha256(u8Out, u8In, 4);
	memcpy(nonce, u8Out, sSize);

	return 1;
}

void printNonce(uint8_t * nonce)
{
	print_debug(DEBUG_MAIN, "Nonce: 0x");
#if DEBUG_MAIN == 1
	for(int i = 11; i >= 0; i--)
	{
		printf("%02x", nonce[i]);
	}
	printf("\r\n");
#endif
}
