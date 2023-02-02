#import <Foundation/Foundation.h>
#import <removefile.h>
#import <sys/stat.h>
#import "helpers.h"

#define PROC_ALL_PIDS        1
#define PROC_PIDPATHINFO_MAXSIZE    (4*MAXPATHLEN)
#define SafeFree(x) do { if (x) free(x); } while(false)
#define SafeFreeNULL(x) do { SafeFree(x); (x) = NULL; } while(false)

int proc_listpids(uint32_t type, uint32_t typeinfo, void *buffer, int buffersize);
int proc_pidpath(int pid, void *buffer, uint32_t buffersize);

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
    if (strcmp(num, "0") == 0)
        return true;
    const char* p = num;
    if (*p < '1' || *p > '9')
        return false;
    else
        p++;
    while (*p) {
        if (*p < '0' || *p > '9')
            return false;
        else
            p++;
    }
    return true;
}

bool isContains(int argc, char *argv[], const char *theChar) {
    for (int i = 0; i < argc; i++) {
        if (strcmp(argv[i], theChar) == 0)
            return true;
    }
    return false;
}

char *get_path_for_pid(pid_t pid) {
    char *ret = NULL;
    uint32_t path_size = PROC_PIDPATHINFO_MAXSIZE;
    char *path = malloc(path_size);
    if (path != NULL) {
        if (proc_pidpath(pid, path, path_size) >= 0)
            ret = strdup(path);
        SafeFreeNULL(path);
    }
    return ret;
}

pid_t pidOfProcess(const char *name) {
    char real[PROC_PIDPATHINFO_MAXSIZE];
    bzero(real, sizeof(real));
    realpath(name, real);
    int numberOfProcesses = proc_listpids(PROC_ALL_PIDS, 0, NULL, 0);
    pid_t pids[numberOfProcesses];
    bzero(pids, sizeof(pids));
    proc_listpids(PROC_ALL_PIDS, 0, pids, (int)sizeof(pids));
    bool foundProcess = false;
    pid_t processPid = 0;
    for (int i = 0; i < numberOfProcesses && !foundProcess; ++i) {
        if (pids[i] == 0)
            continue;
        char *path = get_path_for_pid(pids[i]);
        if (path != NULL) {
            if (strlen(path) > 0 && strcmp(path, real) == 0) {
                processPid = pids[i];
                foundProcess = true;
            }
            SafeFreeNULL(path);
        }
    }
    return processPid;
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
            while (getchar() != '\n')
                getchar();
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
                while (getchar() != '\n')
                    getchar();
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
    [IOMobileGraphicsFamily writeToFile:@"/private/var/mobile/Library/Preferences/com.michael.iokit.IOMobileGraphicsFamily.plist" atomically:NO];
    lchown("/private/var/mobile/Library/Preferences/com.michael.iokit.IOMobileGraphicsFamily.plist", 501, 501);
    if (getuid())
        setuid(0);
	if (getuid()) {
		kern_return_t ret = xpc_crasher("com.apple.cfprefsd.daemon");
		if (ret != KERN_SUCCESS)
			return ret;
	}
    else {
        CFPreferencesSynchronize(CFSTR("com.apple.iokit.IOMobileGraphicsFamily"), CFSTR("mobile"), kCFPreferencesAnyHost);
        CFPreferencesSynchronize(CFSTR("com.michael.iokit.IOMobileGraphicsFamily"), CFSTR("mobile"), kCFPreferencesAnyHost);
    }

    if (isContains(argc, argv, "-w")) {
        printf("Successfully set the resolution to %sx%s, you should manual respring your drvice.\n", height.size, width.size);
        if (height.allocated)
            SafeFreeNULL(height.size);
        if (width.allocated)
            SafeFreeNULL(width.size);
    } else {
        printf("Successfully set the resolution to %sx%s, the device will be respring.\n", height.size, width.size);
        if (height.allocated)
            SafeFreeNULL(height.size);
        if (width.allocated)
            SafeFreeNULL(width.size);
        sleep(1);
        if (kill(pidOfProcess("/usr/libexec/backboardd"), SIGKILL)) {
			kern_return_t ret = xpc_crasher("com.apple.backboard.hid-services.xpc");
            if (ret != KERN_SUCCESS)
                return ret;
        }
    }
    return 0;
}
