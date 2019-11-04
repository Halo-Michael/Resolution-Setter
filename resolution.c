#include <spawn.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
extern char **environ;

int run_cmd(char *cmd)
{
    pid_t pid;
    char *argv[] = {"sh", "-c", cmd, NULL};
    int status = posix_spawn(&pid, "/bin/sh", NULL, NULL, argv, environ);
    if (status == 0) {
        if (waitpid(pid, &status, 0) == -1) {
            perror("waitpid");
        }
    }
    return status;
}

void usage()
{
    printf("Usage:\tres|resolution [height] [width] [OPTIONS...]\n");
    printf("\t-h\tPrint this help.\n");
    printf("\t-w\tSet resolution without auto respring. You may need to manual respring.\n");
    printf("\t-y\tPass the confirm message.\n");
    exit(2);
}

int do_check(const char *num)
{
    if (strcmp(num, "0") == 0) {
        return 0;
    }
    char* p = num;
    if (*p < '1' || *p > '9') {
        return 1;
    } else {
        p++;
    }
    while (*p) {
        if(*p < '0' || *p > '9') {
            return 1;
        } else {
            p++;
        }
    }
    return 0;
}

int main(int argc, char **argv)
{
    if (geteuid() != 0) {
        printf("Run this as root!\n");
        exit(1);
    }
    
    if (argc == 2 || argc > 5) {
        usage();
    }
    
    bool use_args = 0;
    
    char height[4], width[4];
    if (argc == 1) {
        printf("Please choice a height to set:");
        scanf("%s", &height);
        if (do_check(height) != 0) {
            printf("Invalid parameters, you may have no idea what you are doing, now exit.\n");
            exit(1);
        }
        printf("Please choice a width to set:");
        scanf("%s", &width);
        if (do_check(width) != 0) {
            printf("Invalid parameters, you may have no idea what you are doing, now exit.\n");
            exit(1);
        }
    }
    
    if (argc > 2 && argc < 6) {
        if (do_check(argv[1]) != 0 || do_check(argv[2]) != 0) {
            printf("Invalid parameters, you may have no idea what you are doing, now exit.\n");
            exit(1);
        }
        if (argc == 4 && strcmp(argv[3], "-w") != 0 && strcmp(argv[3], "-y") != 0) {
            printf("Invalid parameters, you may have no idea what you are doing, now exit.\n");
            exit(1);
        }
        if (argc == 5 && ! ((strcmp(argv[3], "-w") == 0 && strcmp(argv[4], "-y") == 0) || (strcmp(argv[3], "-y") == 0 && strcmp(argv[4], "-w") == 0))) {
            printf("Invalid parameters, you may have no idea what you are doing, now exit.\n");
            exit(1);
        }
        use_args = 1;
    }
    
    bool pass_confirm = 0;
    
    if (argc == 4) {
        if (strcmp(argv[3], "-y") == 0) {
            pass_confirm = 1;
        }
    }
    
    if (argc == 5) {
        if (strcmp(argv[3], "-y") == 0 || strcmp(argv[4], "-y") == 0) {
            pass_confirm = 1;
        }
    }
    
    if (! pass_confirm) {
        char confirm;
        if (! use_args) {
            printf("Are you sure you want to set the resolution to %sx%s?(y/n)", height, width);
        } else {
            printf("Are you sure you want to set the resolution to %sx%s?(y/n)", argv[1], argv[2]);
        }
        confirm = getchar();
        if (confirm == 'n' || confirm == 'N') {
            while (confirm != 'y' && confirm != 'Y') {
                printf("Please choice a height to set:");
                scanf("%s", &height);
                if (do_check(height) != 0) {
                    printf("Invalid parameters, you may have no idea what you are doing, now exit.\n");
                    exit(1);
                }
                printf("Please choice a width to set:");
                scanf("%s", &width);
                if (do_check(width) != 0) {
                    printf("Invalid parameters, you may have no idea what you are doing, now exit.\n");
                    exit(1);
                }
                use_args = 0;
                printf("Are you sure you want to set the resolution to %sx%s?(y/n)", height, width);
                confirm = getchar();
                if (confirm != 'y' && confirm != 'Y' && confirm != 'n' && confirm != 'N') {
                    printf("Invalid parameters, you may have no idea what you are doing, now exit.\n");
                    exit(1);
                }
            }
        } else if (confirm != 'y' && confirm != 'Y') {
            printf("Invalid parameters, you may have no idea what you are doing, now exit.\n");
            exit(1);
        }
    }
    
    if (! access("/var/mobile/Library/Preferences/com.apple.iokit.IOMobileGraphicsFamily.plist",0)) {
        remove("/var/mobile/Library/Preferences/com.apple.iokit.IOMobileGraphicsFamily.plist");
    }
    FILE *fp = fopen("/var/mobile/Library/Preferences/com.apple.iokit.IOMobileGraphicsFamily.plist","a+");
    fprintf(fp, "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n");
    fprintf(fp, "<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">\n");
    fprintf(fp, "<plist version=\"1.0\">\n");
    fprintf(fp, "<dict>\n");
    fprintf(fp, "\t<key>canvas_height</key>\n");
    if (! use_args) {
        fprintf(fp, "\t<integer>%s</integer>\n", height);
    } else {
        fprintf(fp, "\t<integer>%s</integer>\n", argv[1]);
    }
    fprintf(fp, "\t<key>canvas_width</key>\n");
    if (! use_args) {
        fprintf(fp, "\t<integer>%s</integer>\n", width);
    } else {
        fprintf(fp, "\t<integer>%s</integer>\n", argv[2]);
    }
    fprintf(fp, "</dict>\n");
    fprintf(fp, "</plist>\n");
    fclose(fp);
    
    if (argc == 4) {
        if (strcmp(argv[3], "-w") == 0) {
            if (! use_args) {
                printf("Successfully set the resolution to %sx%s, you should manual respring your drvice.\n", height, width);
            } else {
                printf("Successfully set the resolution to %sx%s, you should manual respring your drvice.\n", argv[1], argv[2]);
            }
            run_cmd("killall -9 cfprefsd");
            return 0;
        }
    }
    
    if (argc == 5) {
        if (strcmp(argv[3], "-w") == 0 || strcmp(argv[4], "-w") == 0) {
            if (! use_args) {
                printf("Successfully set the resolution to %sx%s, you should manual respring your drvice.\n", height, width);
            } else {
                printf("Successfully set the resolution to %sx%s, you should manual respring your drvice.\n", argv[1], argv[2]);
            }
            run_cmd("killall -9 cfprefsd");
            return 0;
        }
    }
    
    if (access("/usr/bin/sbreload",0)) {
        if (! use_args) {
            printf("Successfully set the resolution to %sx%s, the device will be respring.\n", height, width);
        } else {
            printf("Successfully set the resolution to %sx%s, the device will be respring.\n", argv[1], argv[2]);
        }
        sleep(1);
        run_cmd("killall -9 cfprefsd && killall -9 backboardd");
    } else {
        if (! use_args) {
            printf("Successfully set the resolution to %sx%s, the device will be respring.\n", height, width);
        } else {
            printf("Successfully set the resolution to %sx%s, the device will be respring.\n", argv[1], argv[2]);
        }
        sleep(1);
        run_cmd("killall -9 cfprefsd && sbreload");
    }
    
    return 0;
}
