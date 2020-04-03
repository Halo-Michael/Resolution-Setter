#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

int main()
{
    if (getuid() != 0) {
        printf("Run this as root!\n");
        return 1;
    }
    
    system("chown root:wheel /usr/bin/resolution");
    system("chmod 6755 /usr/bin/resolution");
    return 0;
}
