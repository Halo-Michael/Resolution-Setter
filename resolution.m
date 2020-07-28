#import <Foundation/Foundation.h>

void usage() {
    printf("Usage:\tres|resolution [height] [width] [OPTIONS...]\n");
    printf("\t-h\tPrint this help.\n");
    printf("\t-w\tSet resolution without auto respring. You may need to manual respring.\n");
    printf("\t-y\tPass the confirm message.\n");
}

bool do_check(const char *num) {
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

CFNumberRef newInt(int value) {
    return CFNumberCreate(NULL, kCFNumberIntType, &value);
}

int main(int argc, char **argv) {
    if (argc == 2 || argc > 5) {
        usage();
        return 1;
    }

    NSMutableArray *args = [[[NSProcessInfo processInfo] arguments] mutableCopy];
    [args removeObjectAtIndex:0];
    
    if ([args containsObject:@"-h"]) {
        usage();
        return 0;
    }

    if (argc > 2) {
        if (do_check(argv[1]) == false || do_check(argv[2]) == false) {
            printf("Invalid parameters, you may have no idea what you are doing, now exit.\n");
            return 1;
        } else if (strlen(argv[1]) > 4 || strlen(argv[2]) > 4) {
            printf("The resolution is too high, you may have no idea what you are doing, now exit.\n");
            return 2;
        } else if (strlen(argv[1]) < 3 || strlen(argv[2]) < 3) {
            printf("The resolution is too low, you may have no idea what you are doing, now exit.\n");
            return 2;
        }
    }

    char *height, *width;

    if (argc > 2) {
        height = argv[1];
        width = argv[2];
    }

    if (argc == 1 || ![args containsObject:@"-y"]) {
        char confirm;
        if (argc > 2) {
            printf("Are you sure you want to set the resolution to %sx%s?(y/n)", height, width);
            confirm = getchar();
            while (getchar() != '\n') {
                getchar();
            }
        }
        if (argc == 1 || confirm == 'n' || confirm == 'N') {
            while (confirm != 'y' && confirm != 'Y') {
                int strLen = 6;
                char ch = '\0';
                char *tmp_height = (char*)malloc(sizeof(char*) * strLen);
                int count = 0;
                printf("Please choice a height to set:");
                while (ch != '\n') {
                    ch = getchar();
                    count++;
                    if (count >= strLen)
                    {
                        tmp_height = (char*)realloc(tmp_height, sizeof(char*) * (++strLen));
                    }
                    tmp_height[count - 1] = ch;
                }
                tmp_height[count - 1] = '\0';
                
                if (do_check(tmp_height) == false) {
                    printf("Invalid parameters, you may have no idea what you are doing, now exit.\n");
                    return 1;
                } else if (count > 5) {
                    printf("Height is too high, you may have no idea what you are doing, now exit.\n");
                    return 2;
                } else if (count < 4) {
                    printf("Height is too low, you may have no idea what you are doing, now exit.\n");
                    return 2;
                }
                height = tmp_height;

                strLen = 6;
                ch = '\0';
                char *tmp_width = (char*)malloc(sizeof(char*) * strLen);
                count = 0;
                printf("Please choice a width to set:");
                while (ch != '\n') {
                    ch = getchar();
                    count++;
                    if (count >= strLen)
                    {
                        tmp_width = (char*)realloc(tmp_width, sizeof(char*) * (++strLen));
                    }
                    tmp_width[count - 1] = ch;
                }
                tmp_width[count - 1] = '\0';

                if (do_check(tmp_width) == false) {
                    printf("Invalid parameters, you may have no idea what you are doing, now exit.\n");
                    return 1;
                } else if (count > 5) {
                    printf("Width is too high, you may have no idea what you are doing, now exit.\n");
                    return 2;
                } else if (count < 4) {
                    printf("Width is too low, you may have no idea what you are doing, now exit.\n");
                    return 2;
                }
                width = tmp_width;

                printf("Are you sure you want to set the resolution to %sx%s?(y/n)", height, width);
                confirm = getchar();
                while (getchar() != '\n') {
                    getchar();
                }
                if (confirm != 'y' && confirm != 'Y' && confirm != 'n' && confirm != 'N') {
                    printf("Invalid parameters, you may have no idea what you are doing, now exit.\n");
                    return 1;
                }
            }
        } else if (confirm != 'y' && confirm != 'Y') {
            printf("Invalid parameters, you may have no idea what you are doing, now exit.\n");
            return 1;
        }
    }

    remove("/var/mobile/Library/Preferences/com.apple.iokit.IOMobileGraphicsFamily.plist");
    remove("/var/mobile/Library/Preferences/com.michael.iokit.IOMobileGraphicsFamily.plist");

    CFPreferencesSetValue(CFSTR("canvas_height"), newInt(atoi(height)), CFSTR("com.apple.iokit.IOMobileGraphicsFamily"), CFSTR("mobile"), kCFPreferencesAnyHost);
    CFPreferencesSetValue(CFSTR("canvas_width"), newInt(atoi(width)), CFSTR("com.apple.iokit.IOMobileGraphicsFamily"), CFSTR("mobile"), kCFPreferencesAnyHost);
    CFPreferencesSetValue(CFSTR("canvas_height"), newInt(atoi(height)), CFSTR("com.michael.iokit.IOMobileGraphicsFamily"), CFSTR("mobile"), kCFPreferencesAnyHost);
    CFPreferencesSetValue(CFSTR("canvas_width"), newInt(atoi(width)), CFSTR("com.michael.iokit.IOMobileGraphicsFamily"), CFSTR("mobile"), kCFPreferencesAnyHost);

    int ret = 1, status;
    if ([args containsObject:@"-w"]) {
        printf("Successfully set the resolution to %sx%s, you should manual respring your drvice.\n", height, width);
        ret = 0;
    } else {
        printf("Successfully set the resolution to %sx%s, the device will be respring.\n", height, width);
        sleep(1);
        status = system("killall -9 backboardd");
        ret = WEXITSTATUS(status);
    }
    return ret;
}
