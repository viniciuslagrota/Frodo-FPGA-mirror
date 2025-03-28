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

/* Connection handle for a TCP Client session */

#include "tcp_perf_client.h"
#include "include/global_def.h"
#include "netif/xadapter.h"

static struct tcp_pcb *c_pcb;
static char send_buf[TCP_SEND_BUFSIZE];
static struct perf_stats client;
u32_t u32LenRecv = 0;
u32_t u32KeyExchanged = 0;
u32_t u32PacketExchanged = 0;
u32_t u32TotalKeyExchanged = 0;
u32_t u32TotalPacketExchanged = 0;

void print_app_header()
{
#if LWIP_IPV6==1
	print_debug(DEBUG_ETH, "TCP client connecting to %s on port %d\r\n",
			TCP_SERVER_IPV6_ADDRESS, TCP_CONN_PORT);
	print_debug(DEBUG_ETH, "On Host: Run $iperf -V -s -i %d -w 2M\r\n",
			INTERIM_REPORT_INTERVAL);
#else
	print_debug(DEBUG_ETH, "TCP client connecting to %s on port %d\r\n",
			TCP_SERVER_IP_ADDRESS, TCP_CONN_PORT);
	print_debug(DEBUG_ETH, "On Host: Run $iperf -s -i %d -w 2M\r\n",
			INTERIM_REPORT_INTERVAL);
#endif /* LWIP_IPV6 */
}

static void print_tcp_conn_stats()
{
#if LWIP_IPv6==1
	print_debug(DEBUG_ETH, "[%3d] local %s port %d connected with ",
			client.client_id, inet6_ntoa(c_pcb->local_ip),
			c_pcb->local_port);
	print_debug(DEBUG_ETH, "%s port %d\r\n",inet6_ntoa(c_pcb->remote_ip),
			c_pcb->remote_port);
#else
	print_debug(DEBUG_ETH, "[%3d] local %s port %d connected with ",
			client.client_id, inet_ntoa(c_pcb->local_ip),
			c_pcb->local_port);
	print_debug(DEBUG_ETH, "%s port %d\r\n",inet_ntoa(c_pcb->remote_ip),
			c_pcb->remote_port);
#endif /* LWIP_IPV6 */

	print_debug(DEBUG_ETH, "[ ID] Interval\t\tTransfer   Bandwidth\n\r");
}

static void stats_buffer(char* outString,
		double data, enum measure_t type)
{
	int conv = KCONV_UNIT;
	const char *format;
	double unit = 1024.0;

	if (type == SPEED)
		unit = 1000.0;

	while (data >= unit && conv <= KCONV_GIGA) {
		data /= unit;
		conv++;
	}

	/* Fit data in 4 places */
	if (data < 9.995) { /* 9.995 rounded to 10.0 */
		format = "%4.2f %c"; /* #.## */
	} else if (data < 99.95) { /* 99.95 rounded to 100 */
		format = "%4.1f %c"; /* ##.# */
	} else {
		format = "%4.0f %c"; /* #### */
	}
	sprintf(outString, format, data, kLabel[conv]);
}


/** The report function of a TCP client session */
static void tcp_conn_report(u64_t diff,
		enum report_type report_type)
{
	u64_t total_len;
	double duration, bandwidth = 0;
	char data[16], perf[16], time[64];

	if (report_type == INTER_REPORT) {
		total_len = client.i_report.total_bytes;
	} else {
		client.i_report.last_report_time = 0;
		total_len = client.total_bytes;
	}

	/* Converting duration from milliseconds to secs,
	 * and bandwidth to bits/sec .
	 */
	duration = diff / 1000.0; /* secs */
	if (duration)
		bandwidth = (total_len / duration) * 8.0;

	stats_buffer(data, total_len, BYTES);
	stats_buffer(perf, bandwidth, SPEED);
	/* On 32-bit platforms, xil_printf is not able to print
	 * u64_t values, so converting these values in strings and
	 * displaying results
	 */
	sprintf(time, "%4.1f-%4.1f sec",
			(double)client.i_report.last_report_time,
			(double)(client.i_report.last_report_time + duration));
	print_debug(DEBUG_ETH, "[%3d] %s  %sBytes  %sbits/sec\n\r", client.client_id,
			time, data, perf);

	if (report_type == INTER_REPORT)
		client.i_report.last_report_time += duration;
}

/** Close a tcp session */
static void tcp_client_close(struct tcp_pcb *pcb)
{
	err_t err;

	if (pcb != NULL) {
		tcp_sent(pcb, NULL);
		tcp_err(pcb, NULL);
		err = tcp_close(pcb);
		if (err != ERR_OK) {
			/* Free memory with abort */
			tcp_abort(pcb);
		}
	}

	print_debug(DEBUG_ETH, "TCP client closed.\r\n");
#if SERVER_INIT == 0
	//Change st
	st = WAITING_SERVER_CONNECTION;
#else
	//Change st
//	st = WAITING_PK;
	st = RECONNECTING;
#endif
}

/** Error callback, tcp session aborted */
static void tcp_client_err(void *arg, err_t err)
{
	LWIP_UNUSED_ARG(err);
	u64_t now = get_time_ms();
	u64_t diff_ms = now - client.start_time;

	tcp_client_close(c_pcb);
	c_pcb = NULL;
	tcp_conn_report(diff_ms, TCP_ABORTED_REMOTE);
	print_debug(DEBUG_ETH, "TCP connection aborted\n\r");
//	print_debug(DEBUG_ETH, "TCP connection error and ignored\n\r");
}

static err_t tcp_send_perf_traffic(void)
{
	err_t err;
	u8_t apiflags = TCP_WRITE_FLAG_COPY | TCP_WRITE_FLAG_MORE;

	if (c_pcb == NULL) {
		return ERR_CONN;
	}

#ifdef __MICROBLAZE__
	/* Zero-copy pbufs is used to get maximum performance for Microblaze.
	 * For Zynq A9, ZynqMP A53 and R5 zero-copy pbufs does not give
	 * significant improvement hense not used. */
	apiflags = 0;
#endif

	while (tcp_sndbuf(c_pcb) > TCP_SEND_BUFSIZE) {
		err = tcp_write(c_pcb, send_buf, TCP_SEND_BUFSIZE, apiflags);
		if (err != ERR_OK) {
			print_debug(DEBUG_ETH, "TCP client: Error on tcp_write: %d\r\n",
					err);
			return err;
		}

		err = tcp_output(c_pcb);
		if (err != ERR_OK) {
			print_debug(DEBUG_ETH, "TCP client: Error on tcp_output: %d\r\n",
					err);
			return err;
		}
		client.total_bytes += TCP_SEND_BUFSIZE;
		client.i_report.total_bytes += TCP_SEND_BUFSIZE;
	}
#if DEBUG_KYBER == 1
	print_debug(DEBUG_ETH, "Writing data length: %llu\n\r", TCP_SEND_BUFSIZE);
#endif

	if (client.end_time || client.i_report.report_interval_time) {
		u64_t now = get_time_ms();
		if (client.i_report.report_interval_time) {
			if (client.i_report.start_time) {
				u64_t diff_ms = now - client.i_report.start_time;
				u64_t rtime_ms = client.i_report.report_interval_time;
				if (diff_ms >= rtime_ms) {
					tcp_conn_report(diff_ms, INTER_REPORT);
					client.i_report.start_time = 0;
					client.i_report.total_bytes = 0;
				}
			} else {
				client.i_report.start_time = now;
			}
		}

		if (client.end_time) {
			/* this session is time-limited */
			u64_t diff_ms = now - client.start_time;
			if (diff_ms >= client.end_time) {
				/* time specified is over,
				 * close the connection */
				tcp_conn_report(diff_ms, TCP_DONE_CLIENT);
				print_debug(DEBUG_ETH, "TCP test passed Successfully\n\r");
				tcp_client_close(c_pcb);
				c_pcb = NULL;
				return ERR_OK;
			}
		}
	}
	return ERR_OK;
}

static err_t tcp_send_traffic(char * pcBuffer, u16_t u16BufferLen)
{
	err_t err;
	u8_t apiflags = TCP_WRITE_FLAG_COPY | TCP_WRITE_FLAG_MORE;

	if (c_pcb == NULL) {
		return ERR_CONN;
	}

#ifdef __MICROBLAZE__
	/* Zero-copy pbufs is used to get maximum performance for Microblaze.
	 * For Zynq A9, ZynqMP A53 and R5 zero-copy pbufs does not give
	 * significant improvement hense not used. */
	apiflags = 0;
#endif

#if DEBUG_FRODO == 1
	print_debug(DEBUG_ETH, "Writing data length: %d\n\r", u16BufferLen);
#endif

	if(st == SENDING_CT)
	{
		u32KeyExchanged++;
		u32TotalKeyExchanged++;
	}

	if(st == SEND_CIPHER_MESSAGE)
	{
		u32PacketExchanged++;
		u32TotalPacketExchanged++;
	}

	if (tcp_sndbuf(c_pcb) > u16BufferLen)
	{
		err = tcp_write(c_pcb, pcBuffer, u16BufferLen, apiflags);
		while (err != ERR_OK) {
			print_debug(DEBUG_ERROR, "TCP client: Error on tcp_write: %d\r\n",
								err);
			return err;
		}

		err = tcp_output(c_pcb);
		if (err != ERR_OK) {
			print_debug(DEBUG_ERROR, "TCP client: Error on tcp_output: %d\r\n",
					err);
			return err;
		}
		client.total_bytes += u16BufferLen;
		client.i_report.total_bytes += u16BufferLen;
	}

	if (client.end_time || client.i_report.report_interval_time)
	{
		u64_t now = get_time_ms();
		if (client.i_report.report_interval_time) {
			if (client.i_report.start_time) {
				u64_t diff_ms = now - client.i_report.start_time;
				u64_t rtime_ms = client.i_report.report_interval_time;
				if (diff_ms >= rtime_ms) {
					tcp_conn_report(diff_ms, INTER_REPORT);
					print_debug(DEBUG_ETH, "Key exchanged: %d | Packet exchanged: %d | Total key exchanged: %d | Total packet exchanged: %d\r\n", u32KeyExchanged, u32PacketExchanged, u32TotalKeyExchanged, u32TotalPacketExchanged);
					u32KeyExchanged = 0;
					u32PacketExchanged = 0;
					client.i_report.start_time = 0;
					client.i_report.total_bytes = 0;
				}
			} else {
				client.i_report.start_time = now;
			}
		}
	}



	return ERR_OK;
}

/** TCP recv callback */
static err_t tcp_client_recv(void *arg, struct tcp_pcb *tpcb, struct pbuf *p, err_t err)
{
	/* do not read the packet if we are not in ESTABLISHED state */
	if (!p) {
		tcp_close(tpcb);
		tcp_recv(tpcb, NULL);
		return ERR_OK;
	}

	tcp_nagle_disable(tpcb);

#if DEBUG_KYBER == 1
	print_debug(DEBUG_ETH, "data length: %d\n\r", p->len);
//	print_debug(DEBUG_ETH, "data total length: %d\n\r", p->tot_len);
//	print_debug(DEBUG_ETH, "next pbuf: 0x%x\n\r", p->next);
#endif
	print_debug(DEBUG_ETH, "data length: %d\n\r", p->len);
	char * pcBuf = p->payload; //Get transmitted data.

#if SERVER_INIT == 0
	if(st == WAIT_CIPHERED_DATA)
	{
		memcpy(cCiphertext + u32LenRecv, pcBuf, p->len);
		u32LenRecv += p->len;

		st = DECIPHER_MESSAGE;
		u32LenRecv = 0;
	}
	else
	{
		memcpy(ct + u32LenRecv, pcBuf, p->len);
		u32LenRecv += p->len;

		if(u32LenRecv >= CRYPTO_CIPHERTEXTBYTES)
		{
			st = CALCULATE_SHARED_SECRET;
			u32LenRecv = 0;
		}
	}
#else
	memcpy(pk + u32LenRecv, pcBuf, p->len);
	u32LenRecv += p->len;
//	print_debug(DEBUG_ETH, "data length: %d | u32LenRecv: %d\n\r", p->len, u32LenRecv);

	if(p->len == TCP_MSS - 14)
		st = WAITING_PK;

	if(u32LenRecv >= CRYPTO_PUBLICKEYBYTES)
	{
		bCtReceived = 1;
		st = CALCULATING_CT;
		u32LenRecv = 0;
	}
#endif

	/* indicate that the packet has been received */
	tcp_recved(tpcb, p->len);

	/* free the received pbuf */
	pbuf_free(p);
	return ERR_OK;
}

/** TCP sent callback, try to send more data */
static err_t tcp_client_sent(void *arg, struct tcp_pcb *tpcb, u16_t len)
{
#if PERFORMANCE_TEST == 1
//	return tcp_send_perf_traffic();
	return ERR_OK;
#else
//	print_debug(DEBUG_ETH, "Sent callback\n\r");
	if(st == SENDING_CT || st == WAITING_SEND_CT)
		st = WAIT_SERVER_CALCULATE_CT;
	else
		st = GET_SMW3000_DATA;
	return ERR_OK;
#endif
}

/** TCP connected callback (active connection), send data now */
static err_t tcp_client_connected(void *arg, struct tcp_pcb *tpcb, err_t err)
{
	if (err != ERR_OK) {
		tcp_client_close(tpcb);
		print_debug(DEBUG_ETH, "Connection error\n\r");
		return err;
	}
	/* store state */
	c_pcb = tpcb;

	client.start_time = get_time_ms();
	client.end_time = TCP_TIME_INTERVAL * 1000; /* ms */
	client.client_id++;
	client.total_bytes = 0;

	/* report interval time in ms */
	client.i_report.report_interval_time = INTERIM_REPORT_INTERVAL * 1000;
	client.i_report.last_report_time = 0;
	client.i_report.start_time = 0;
	client.i_report.total_bytes = 0;

	print_tcp_conn_stats();

	/* set callback values & functions */
	tcp_nagle_disable(c_pcb);
	tcp_arg(c_pcb, NULL);
	tcp_sent(c_pcb, tcp_client_sent);
	tcp_recv(c_pcb, tcp_client_recv);
	tcp_err(c_pcb, tcp_client_err);

#if SERVER_INIT == 0
	//Change st
	st = CONNECTED_TO_SERVER;
#endif

	/* initiate data transfer */
	return ERR_OK;
}

void transfer_perf_data(void)
{
	if (client.client_id)
		tcp_send_perf_traffic();
}

void transfer_data(char * pcBuffer, u16_t u16BufferLen)
{
	if (client.client_id)
		tcp_send_traffic(pcBuffer, u16BufferLen);
}

void start_application(void)
{
	err_t err;
	struct tcp_pcb* pcb;
	ip_addr_t remote_addr;
	u32_t i;

	print_debug(DEBUG_ETH, "Starting application...\r\n");

#if LWIP_IPV6==1
	remote_addr.type= IPADDR_TYPE_V6;
	err = inet6_aton(TCP_SERVER_IPV6_ADDRESS, &remote_addr);
#else
	err = inet_aton(TCP_SERVER_IP_ADDRESS, &remote_addr);
#endif /* LWIP_IPV6 */

	if (!err) {
		print_debug(DEBUG_ETH, "Invalid Server IP address: %d\r\n", err);
		return;
	}

	/* Create Client PCB */
	pcb = tcp_new_ip_type(IPADDR_TYPE_ANY);
	if (!pcb) {
		print_debug(DEBUG_ETH, "Error in PCB creation. out of memory\r\n");
		return;
	}

	err = tcp_connect(pcb, &remote_addr, TCP_CONN_PORT,
			tcp_client_connected);
	if (err) {
		print_debug(DEBUG_ETH, "Error on tcp_connect: %d\r\n", err);
		tcp_client_close(pcb);
		return;
	}
	client.client_id = 0;

	/* initialize data buffer being sent with same as used in iperf */
	for (i = 0; i < TCP_SEND_BUFSIZE; i++)
		send_buf[i] = (i % 10) + '0';
//		send_buf[i] = 'E';


	return;
}
