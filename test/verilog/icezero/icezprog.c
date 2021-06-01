/*
 *  IceZProg -- Programmer and Debug Tool for the IcoZero Board
 *
 *  Copyright (C) 2017  Clifford Wolf <clifford@clifford.at>
 *  
 *  Permission to use, copy, modify, and/or distribute this software for any
 *  purpose with or without fee is hereby granted, provided that the above
 *  copyright notice and this permission notice appear in all copies.
 *  
 *  THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 *  WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 *  MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 *  ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 *  WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 *  ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 *  OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *
 */

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <unistd.h>
#include <errno.h>
#include <wiringPi.h>

#define CFG_SS   26 // PIN 32, GPIO.26
#define CFG_SCK  27 // PIN 36, GPIO.27
#define CFG_SI   22 // PIN 31, GPIO.22
#define CFG_SO   23 // PIN 33, GPIO.23
#define CFG_RST  25 // PIN 37, GPIO.25
#define CFG_DONE 21 // PIN 29, GPIO.21

void spi_begin()
{
	digitalWrite(CFG_SS, LOW);
	// fprintf(stderr, "SPI_BEGIN\n");
}

void spi_end()
{
	digitalWrite(CFG_SS, HIGH);
	// fprintf(stderr, "SPI_END\n");
}

void uwait_barrier_sync(int n)
{
	int k;
	for (k = 0; k < n; k++)
		asm volatile("" : : : "memory");
	__sync_synchronize();
}

uint32_t spi_xfer(uint32_t data, int nbits)
{
	uint32_t rdata = 0;
	int i;

	for (i = nbits-1; i >= 0; i--)
	{
		uwait_barrier_sync(10);
		digitalWrite(CFG_SO, (data & (1 << i)) ? HIGH : LOW);

		uwait_barrier_sync(10);
		if (digitalRead(CFG_SI) == HIGH)
			rdata |= 1 << i;

		uwait_barrier_sync(10);
		digitalWrite(CFG_SCK, HIGH);

		uwait_barrier_sync(10);
		digitalWrite(CFG_SCK, LOW);
	}

	// fprintf(stderr, "SPI:%d %02x %02x\n", nbits, data, rdata);
	return rdata;
}

void flash_power_up()
{
	spi_begin();
	spi_xfer(0xAB, 8);
	spi_end();
}

void flash_read_id()
{
	int i;
	spi_begin();
	spi_xfer(0x9F, 8);
	printf("Flash ID:");
	for (i = 1; i < 21; i++)
		printf(" %02X", spi_xfer(0, 8));
	printf("\n");
	spi_end();
}

void flash_write_enable()
{
	spi_begin();
	spi_xfer(0x06, 8);
	spi_end();
}

void flash_erase_64kB(int addr)
{
	spi_begin();
	spi_xfer(0xd8, 8);
	spi_xfer(addr, 24);
	spi_end();
}

void flash_write(int addr, char *data, int n)
{
	spi_begin();
	spi_xfer(0x02, 8);
	spi_xfer(addr, 24);
	while (n--)
		spi_xfer(*(data++), 8);
	spi_end();
}

void flash_read(int addr, char *data, int n)
{
	spi_begin();
	spi_xfer(0x03, 8);
	spi_xfer(addr, 24);
	while (n--)
		*(data++) = spi_xfer(0, 8);
	spi_end();
}

void flash_wait()
{
	while (1)
	{
		spi_begin();
		spi_xfer(0x05, 8);
		int status = spi_xfer(0, 8);
		spi_end();

		if ((status & 0x01) == 0)
			break;

		// fprintf(stderr, "[wait]");
		usleep(1000);
	}

	// fprintf(stderr, "[ok]\n");
}

void flash_wrsector(int addr, char *data, int size)
{
	int i;

restart:
	printf("Writing 0x%06x .. 0x%06x:", addr, addr+size-1);
	fflush(stdout);

	printf(" [erasing]");
	fflush(stdout);

	flash_write_enable();
	flash_erase_64kB(addr);
	flash_wait();

	if (size == 0) {
		printf("\n");
		fflush(stdout);
		return;
	}

	printf(" [writing");
	fflush(stdout);

	for (i = 0; i < size; i += 256)
	{
		if (i % 4096 == 0) {
			printf(".");
			fflush(stdout);
		}

		flash_write_enable();
		flash_write(addr+i, data+i, size-i < 256 ? size-i : 256);
		flash_wait();
	}

	printf("] [readback");
	fflush(stdout);

	for (i = 0; i < size; i += 256)
	{
		if (i % 4096 == 0) {
			printf(".");
			fflush(stdout);
		}

		char buffer[256];
		flash_read(addr+i, buffer, size-i < 256 ? size-i : 256);

		if (memcmp(buffer, data+i, size-i < 256 ? size-i : 256)) {
			printf("ERROR\n");
			fflush(stdout);
			goto restart;
		}
	}

	printf("]\n");
	fflush(stdout);
}

int main(int argc, char **argv)
{
	if (argc != 2 || (argv[1][0] == '-' && argv[1][1]) || !argv[1][0]) {
		printf("Usage: %s <binfile>  ... program <binfile> to IceZero flash\n", argv[0]);
		printf("       %s -          ... program stdin to IceZero flash\n", argv[0]);
		printf("       %s .          ... erase first sector of IceZero flash\n", argv[0]);
		printf("       %s ..         ... just restart the FPGA\n", argv[0]);
		return 1;
	}

	wiringPiSetup();

	pinMode(CFG_SS,   OUTPUT);
	pinMode(CFG_SCK,  OUTPUT);
	pinMode(CFG_SI,   INPUT);
	pinMode(CFG_SO,   OUTPUT);
	pinMode(CFG_RST,  OUTPUT);
	pinMode(CFG_DONE, INPUT);

	digitalWrite(CFG_SS,  HIGH);
	digitalWrite(CFG_SCK, LOW);
	digitalWrite(CFG_SO,  LOW);
	digitalWrite(CFG_RST, LOW);

	if (strcmp(argv[1], ".."))
	{
		flash_power_up();
		flash_read_id();
	}

	if (!strcmp(argv[1], "."))
	{
		char buffer[1024];
		int i;

		for (i = 0; i < (int)sizeof(buffer); i++)
			buffer[i] = 0xff;

		flash_wrsector(0, buffer, sizeof(buffer));
	}
	else
	if (strcmp(argv[1], ".."))
	{
		int addr = 0, size = 0;
		char buffer[64*1024];

		FILE *f = strcmp(argv[1], "-") ? fopen(argv[1], "rb") : stdin;

		if (f == NULL) {
			printf("Failed to open %s: %s\n", argv[1], strerror(errno));
			return 1;
		}

		do {
			addr += size;
			size = 0;

			while (size < (int)sizeof(buffer)) {
				int rc = fread(buffer+size, 1, sizeof(buffer)-size, f);
				if (rc <= 0) break;
				size += rc;
			}

			if (size > 0)
				flash_wrsector(addr, buffer, size);
		} while (size == sizeof(buffer));
	}

	digitalWrite(CFG_RST, LOW);
	usleep(2000);

	digitalWrite(CFG_RST, HIGH);
	usleep(500000);

	if (digitalRead(CFG_DONE) != HIGH) {
		printf("Warning: cdone is low\n");
		return 1;
	}

	printf("DONE.\n");
	return 0;
}

