#include <stdio.h>
#include <stdlib.h>
#include <sys/stat.h>
#include <unistd.h>

int main()
{
    if (getuid() != 0) {
        printf("Run this as root!\n");
        return 1;
    }

    chown("/usr/bin/resolution", 0, 0);
    chmod("/usr/bin/resolution", 06755);

    return 0;
}
