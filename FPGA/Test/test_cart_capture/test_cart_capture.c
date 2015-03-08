
#include <stdio.h>
#include <stdint.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/ioctl.h>
#include <linux/types.h>
#include <linux/spi/spidev.h>
#include <string.h>

#define DEBUG 1

#define PDEBUG(fmt, args...) \
	do { if(DEBUG) printf(fmt, ##args); } while(0) 


#define CMD_RWRDS	(0x80)
#define CMD_READ	(0x40)


int read_usedw(int fd, int* nr_words){
	struct spi_ioc_transfer	xfer[1];
	char tx_buf[20];
	char rx_buf[20];
	int status;

	memset(xfer, 0, sizeof(struct spi_ioc_transfer)); 
	memset(rx_buf, 0, sizeof(rx_buf));

	xfer[0].tx_buf = tx_buf;
	xfer[0].rx_buf = rx_buf;
	xfer[0].len    = 1 + 17;
	
	tx_buf[0] = CMD_RWRDS;

	status = ioctl(fd, SPI_IOC_MESSAGE(1), xfer);
	
	if (status < 1) {
		perror("ioctl(SPI_IOC_MESSAGE) failed");
		return -1;
	}

	PDEBUG("Resp: ");
	for(int i=0; i<2; i++){
		PDEBUG("%02x ", (unsigned char)rx_buf[i]);
	}
	PDEBUG("\n");


	if(nr_words) *nr_words = (int)rx_buf[1];
	return 0;
}

int read_data(int fd, uint32_t* addr, uint32_t* data){
	struct spi_ioc_transfer	xfer[1];
	char tx_buf[20];
	char rx_buf[20];
	int status;

	memset(xfer, 0, sizeof(struct spi_ioc_transfer)); 
	memset(rx_buf, 0, sizeof(rx_buf));

	xfer[0].tx_buf = tx_buf;
	xfer[0].rx_buf = rx_buf;
	xfer[0].len    = 1 + 8;
	
	tx_buf[0] = CMD_READ;

	status = ioctl(fd, SPI_IOC_MESSAGE(1), xfer);
	
	if (status < 1) {
		perror("ioctl(SPI_IOC_MESSAGE) failed");
		return -1;
	}

	PDEBUG("Resp: ");
	for(int i=0; i<9; i++){
		PDEBUG("%02x ", (unsigned char)rx_buf[i]);
	}
	PDEBUG("\n");

	return 0;
}


int main(int argc, char** argv){
	int fd;
	int status;

	fd = open("/dev/spidev0.0", O_RDWR);
	if (fd < 0) {
		perror("open() failed");
		return -1;
	}

	status = read_usedw(fd, NULL);
	if (status) {
		printf("read_usedw() failed: %d\n", status);
	}	

	for(int i = 0; i < 50; i++){
		read_data(fd, NULL, NULL);
	}

	status = read_usedw(fd, NULL);
	if (status) {
		printf("read_usedw() failed: %d\n", status);
	}	

close_file:
	close(fd);
	
	return 0;
}
