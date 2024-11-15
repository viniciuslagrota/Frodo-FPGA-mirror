/*
 * XIL_PRINTF_CUSTOM.h
 *
 *  Created on: 28 de set de 2019
 *      Author: Vinicius
 */

#ifndef INCLUDE_XIL_PRINTF_CUSTOM_H_
#define INCLUDE_XIL_PRINTF_CUSTOM_H_

#include "FreeRTOS.h"
#include "task.h"
#include "queue.h"
#include "xil_printf.h"
#include "xil_types.h"
#include "xstatus.h"
#include "xgpio.h"
#include "../include/globalDef.h"

typedef struct params_s {
    s32 len;
    s32 num1;
    s32 num2;
    char8 pad_character;
    s32 do_padding;
    s32 left_flag;
    s32 unsigned_flag;
} params_t;

//////////////////////////////////////////////
//
//	Prototypes
//
//////////////////////////////////////////////
void RTOSprintf(const char *pcString, ...);
void xil_printf_m( const char8 *ctrl1, ...);

#endif /* INCLUDE_XIL_PRINTF_CUSTOM_H_ */
