/*
 * global_def.h
 *
 *  Created on: 25 de nov de 2019
 *      Author: Vinicius
 */

#ifndef SRC_INCLUDE_GLOBAL_DEF_H_
#define SRC_INCLUDE_GLOBAL_DEF_H_

#include "xgpio.h"
#include "xllfifo.h"
#include "xgpio.h"
#include "xil_printf.h"
#include "frodo_main.h"

#define ledpin 47

//////////////////////////////////////////////
//
//	AXI GPIO
//
//////////////////////////////////////////////
XGpio axiStartDone;
XGpio_Config * ConfigPtr0;
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

#endif /* SRC_INCLUDE_GLOBAL_DEF_H_ */
