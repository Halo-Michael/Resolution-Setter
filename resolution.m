#import <Foundation/Foundation.h>
#import <removefile.h>
#import <sys/stat.h>

typedef struct {
    char *size;
    bool allocated;
} side;

void usage() {
    puts("Usage:\tres|resolution [height] [width] [OPTIONS...]");
    puts("\t-h\tPrint this help.");
    puts("\t-w\tSet resolution without auto respring. You may need to manual respring.");
    puts("\t-y\tPass the confirm message.");
}

bool isNumber(const char *num) {
    if (strcmp(num, "0") == 0) {
        return true;
    }
    const char* p = num;
    if (*p < '1' || *p > '9') {
        return false;
    } else {
        p++;
    }
    while (*p) {
        if(*p < '0' || *p > '9') {
            return false;
        } else {
            p++;
        }
    }
    return true;
}

bool isContains(int argc, char *argv[], const char *theChar) {
    for (int i = 0; i < argc; i++) {
        if (strcmp(argv[i], theChar) == 0) {
            return true;
        }
    }
    return false;
}

int main(int argc, char *argv[]) {
    if (argc == 2 || argc > 5) {
        usage();
        return 1;
    }

    if (isContains(argc, argv, "-h")) {
        usage();
        return 0;
    }

    if (argc > 2) {
        if (!isNumber(argv[1]) || !isNumber(argv[2])) {
            puts("Invalid parameters, you may have no idea what you are doing, now exit.");
            return 1;
        }
    }

    side height = {NULL, false}, width = {NULL, false};

    if (argc > 2) {
        height.size = argv[1];
        width.size = argv[2];
    }

    if (argc == 1 || !isContains(argc, argv, "-y")) {
        char confirm;
        if (argc > 2) {
            printf("Are you sure you want to set the resolution to %sx%s?(y/n)", height.size, width.size);
            confirm = getchar();
            while (getchar() != '\n') {
                getchar();
            }
        }
        if (argc == 1 || confirm == 'n' || confirm == 'N') {
            while (confirm != 'y' && confirm != 'Y') {
                int strLen = 1;
                char *tmp_height = (char *)malloc(sizeof(char) * strLen);
                printf("Please choice a height to set:");
                char ch = getchar();
                while (ch != '\n') {
                    tmp_height = (char *)realloc(tmp_height, sizeof(char) * (++strLen));
                    tmp_height[strLen - 2] = ch;
                    ch = getchar();
                }
                tmp_height[strLen - 1] = '\0';

                if (!isNumber(tmp_height)) {
                    puts("Invalid parameters, you may have no idea what you are doing, now exit.");
                    return 1;
                } else if (strLen > 5) {
                    puts("Height is too high, you may have no idea what you are doing, now exit.");
                    return 2;
                } else if (strLen < 4) {
                    puts("Height is too low, you may have no idea what you are doing, now exit.");
                    return 2;
                }
                height.size = tmp_height;
                height.allocated = true;

                strLen = 1;
                char *tmp_width = (char *)malloc(sizeof(char) * strLen);
                printf("Please choice a width to set:");
                ch = getchar();
                while (ch != '\n') {
                    tmp_width = (char *)realloc(tmp_width, sizeof(char) * (++strLen));
                    tmp_width[strLen - 2] = ch;
                    ch = getchar();
                }
                tmp_width[strLen - 1] = '\0';

                if (!isNumber(tmp_width)) {
                    puts("Invalid parameters, you may have no idea what you are doing, now exit.");
                    return 1;
                } else if (strLen > 5) {
                    puts("Width is too high, you may have no idea what you are doing, now exit.");
                    return 2;
                } else if (strLen < 4) {
                    puts("Width is too low, you may have no idea what you are doing, now exit.");
                    return 2;
                }
                width.size = tmp_width;
                width.allocated = true;

                printf("Are you sure you want to set the resolution to %sx%s?(y/n)", height.size, width.size);
                confirm = getchar();
                while (getchar() != '\n') {
                    getchar();
                }
                if (confirm != 'y' && confirm != 'Y' && confirm != 'n' && confirm != 'N') {
                    puts("Invalid parameters, you may have no idea what you are doing, now exit.");
                    return 1;
                }
            }
        } else if (confirm != 'y' && confirm != 'Y') {
            puts("Invalid parameters, you may have no idea what you are doing, now exit.");
            return 1;
        }
    }

    removefile("/private/var/mobile/Library/Preferences/com.apple.iokit.IOMobileGraphicsFamily.plist", NULL, REMOVEFILE_RECURSIVE);
    removefile("/private/var/mobile/Library/Preferences/com.michael.iokit.IOMobileGraphicsFamily.plist", NULL, REMOVEFILE_RECURSIVE);

    removefile("/private/var/tmp/com.michael.iokit.IOMobileGraphicsFamily", NULL, REMOVEFILE_RECURSIVE);
    mkdir("/private/var/tmp/com.michael.iokit.IOMobileGraphicsFamily", 755);
    lchown("/private/var/tmp/com.michael.iokit.IOMobileGraphicsFamily", 501, 501);
    symlink("../../../tmp/com.michael.iokit.IOMobileGraphicsFamily/com.apple.iokit.IOMobileGraphicsFamily.plist", "/private/var/mobile/Library/Preferences/com.apple.iokit.IOMobileGraphicsFamily.plist");
    lchown("/private/var/mobile/Library/Preferences/com.apple.iokit.IOMobileGraphicsFamily.plist", 501, 501);

    NSDictionary *IOMobileGraphicsFamily = [NSDictionary dictionaryWithObjects:@[[NSNumber numberWithInt:atoi(height.size)], [NSNumber numberWithInt:atoi(width.size)]] forKeys:@[@"canvas_height", @"canvas_width"]];
    [IOMobileGraphicsFamily writeToFile:@"/private/var/tmp/com.michael.iokit.IOMobileGraphicsFamily/com.apple.iokit.IOMobileGraphicsFamily.plist" atomically:NO];
    lchown("/private/var/tmp/com.michael.iokit.IOMobileGraphicsFamily/com.apple.iokit.IOMobileGraphicsFamily.plist", 501, 501);
    CFPreferencesSynchronize(CFSTR("com.apple.iokit.IOMobileGraphicsFamily"), CFSTR("mobile"), kCFPreferencesAnyHost);
    [IOMobileGraphicsFamily writeToFile:@"/private/var/mobile/Library/Preferences/com.michael.iokit.IOMobileGraphicsFamily.plist" atomically:NO];
    lchown("/private/var/mobile/Library/Preferences/com.michael.iokit.IOMobileGraphicsFamily.plist", 501, 501);
    CFPreferencesSynchronize(CFSTR("com.michael.iokit.IOMobileGraphicsFamily"), CFSTR("mobile"), kCFPreferencesAnyHost);

    int ret = 0;
    if (isContains(argc, argv, "-w")) {
        printf("Successfully set the resolution to %sx%s, you should manual respring your drvice.\n", height.size, width.size);
        if (height.allocated) {
            free(height.size);
        }
        if (width.allocated) {
            free(width.size);
        }
    } else {
        printf("Successfully set the resolution to %sx%s, the device will be respring.\n", height.size, width.size);
        if (height.allocated) {
            free(height.size);
        }
        if (width.allocated) {
            free(width.size);
        }
        sleep(1);
        int status = system("killall -9 backboardd");
        ret = WEXITSTATUS(status);
    }
    return ret;
}
