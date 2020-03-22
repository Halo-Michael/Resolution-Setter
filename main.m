#include <spawn.h>
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

void usage() {
    printf("Usage:\tres|resolution [height] [width] [OPTIONS...]\n");
    printf("\t-h\tPrint this help.\n");
    printf("\t-w\tSet resolution without auto respring. You may need to manual respring.\n");
    printf("\t-y\tPass the confirm message.\n");
}

int do_check(const char *num)
{
    if (strcmp(num, "0") == 0) {
        return 0;
    }
    const char* p = num;
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

bool modifyPlist(NSString *filename, void (^function)(id)) {
    NSData *data = [NSData dataWithContentsOfFile:filename];
    if (data == nil) {
        return false;
    }
    NSPropertyListFormat format = 0;
    NSError *error = nil;
    id plist = [NSPropertyListSerialization propertyListWithData:data options:NSPropertyListMutableContainersAndLeaves format:&format error:&error];
    if (plist == nil) {
        return false;
    }
    if (function) {
        function(plist);
    }
    NSData *newData = [NSPropertyListSerialization dataWithPropertyList:plist format:format options:0 error:&error];
    if (newData == nil) {
        return false;
    }
    if (![data isEqual:newData]) {
        if (![newData writeToFile:filename atomically:YES]) {
            return false;
        }
    }
    return true;
}

int main(int argc, const char **argv, const char **envp) {
    if (geteuid() != 0) {
        printf("Run this as root!\n");
        return 1;
    }
    
    if (argc == 2 || argc > 5) {
        usage();
        return 1;
    }
    
    bool use_args = NO;
    
    char height[4], width[4];
    if (argc == 1) {
        printf("Please choice a height to set:");
        scanf("%s", height);
        if (do_check(height) != 0) {
            printf("Invalid parameters, you may have no idea what you are doing, now exit.\n");
            return 1;
        }
        printf("Please choice a width to set:");
        scanf("%s", width);
        if (do_check(width) != 0) {
            printf("Invalid parameters, you may have no idea what you are doing, now exit.\n");
            return 1;
        }
    }
    
    bool pass_confirm = NO;
    bool auto_respring = YES;
    
    if (argc > 2) {
        if (do_check(argv[1]) != 0 || do_check(argv[2]) != 0) {
            printf("Invalid parameters, you may have no idea what you are doing, now exit.\n");
            return 1;
        }
        
        NSMutableArray *args = [[[NSProcessInfo processInfo] arguments] mutableCopy];
        [args removeObjectAtIndex:0];
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF beginswith '-'"];
        NSArray *dashedArgs = [args filteredArrayUsingPredicate:pred];
        for (NSString *argument in dashedArgs) {
            if (![argument caseInsensitiveCompare:@"-h"]) {
                usage();
                return 1;
            }
            if (![argument caseInsensitiveCompare:@"-w"]) {
                auto_respring = NO;
            }
            if (![argument caseInsensitiveCompare:@"-y"]) {
                pass_confirm = YES;
            }
        }
        use_args = YES;
    }
    
    if (!pass_confirm) {
        char confirm;
        if (!use_args) {
            printf("Are you sure you want to set the resolution to %sx%s?(y/n)", height, width);
        } else {
            printf("Are you sure you want to set the resolution to %sx%s?(y/n)", argv[1], argv[2]);
        }
        scanf("\n%c", &confirm);
        if (confirm == 'n' || confirm == 'N') {
            while (confirm != 'y' && confirm != 'Y') {
                printf("Please choice a height to set:");
                scanf("%s", height);
                if (do_check(height) != 0) {
                    printf("Invalid parameters, you may have no idea what you are doing, now exit.\n");
                    return 1;
                }
                printf("Please choice a width to set:");
                scanf("%s", width);
                if (do_check(width) != 0) {
                    printf("Invalid parameters, you may have no idea what you are doing, now exit.\n");
                    return 1;
                }
                use_args = 0;
                printf("Are you sure you want to set the resolution to %sx%s?(y/n)", height, width);
                scanf("\n%c", &confirm);
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
    
    if (access("/var/mobile/Library/Preferences/com.apple.iokit.IOMobileGraphicsFamily.plist", F_OK) == 0) {
        remove("/var/mobile/Library/Preferences/com.apple.iokit.IOMobileGraphicsFamily.plist");
    }
    if (access("/var/mobile/Library/Preferences/com.michael.iokit.IOMobileGraphicsFamily.plist", F_OK) == 0) {
        remove("/var/mobile/Library/Preferences/com.michael.iokit.IOMobileGraphicsFamily.plist");
    }
    
    NSString *canvas_height;
    NSString *canvas_width;
    if (!use_args) {
        canvas_height = [NSString stringWithUTF8String:height];
        canvas_width = [NSString stringWithUTF8String:width];
    } else {
        canvas_height = [NSString stringWithUTF8String:argv[1]];
        canvas_width = [NSString stringWithUTF8String:argv[2]];
    }
    
    FILE *fp = fopen("/var/mobile/Library/Preferences/com.apple.iokit.IOMobileGraphicsFamily.plist","a+");
    fprintf(fp, "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n");
    fprintf(fp, "<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">\n");
    fprintf(fp, "<plist version=\"1.0\">\n");
    fprintf(fp, "<dict>\n");
    fprintf(fp, "</dict>\n");
    fprintf(fp, "</plist>\n");
    fclose(fp);
    
    fp = fopen("/var/mobile/Library/Preferences/com.michael.iokit.IOMobileGraphicsFamily.plist","a+");
    fprintf(fp, "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n");
    fprintf(fp, "<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">\n");
    fprintf(fp, "<plist version=\"1.0\">\n");
    fprintf(fp, "<dict>\n");
    fprintf(fp, "</dict>\n");
    fprintf(fp, "</plist>\n");
    fclose(fp);
    
    modifyPlist(@"/var/mobile/Library/Preferences/com.apple.iokit.IOMobileGraphicsFamily.plist", ^(id plist) {
        plist[@"canvas_height"] = [NSNumber numberWithInteger:[canvas_height integerValue]];
    });
    modifyPlist(@"/var/mobile/Library/Preferences/com.michael.iokit.IOMobileGraphicsFamily.plist", ^(id plist) {
        plist[@"canvas_height"] = [NSNumber numberWithInteger:[canvas_height integerValue]];
    });
    modifyPlist(@"/var/mobile/Library/Preferences/com.apple.iokit.IOMobileGraphicsFamily.plist", ^(id plist) {
        plist[@"canvas_width"] = [NSNumber numberWithInteger:[canvas_width integerValue]];
    });
    modifyPlist(@"/var/mobile/Library/Preferences/com.michael.iokit.IOMobileGraphicsFamily.plist", ^(id plist) {
        plist[@"canvas_width"] = [NSNumber numberWithInteger:[canvas_width integerValue]];
    });
    
    if (!auto_respring) {
        if (!use_args) {
            printf("Successfully set the resolution to %sx%s, you should manual respring your drvice.\n", height, width);
        } else {
            printf("Successfully set the resolution to %sx%s, you should manual respring your drvice.\n", argv[1], argv[2]);
        }
        run_cmd("killall -9 cfprefsd");
        return 0;
    }
    
    if (access("/usr/bin/sbreload", F_OK) == 0) {
        if (!use_args) {
            printf("Successfully set the resolution to %sx%s, the device will be respring.\n", height, width);
        } else {
            printf("Successfully set the resolution to %sx%s, the device will be respring.\n", argv[1], argv[2]);
        }
        sleep(1);
        run_cmd("killall -9 cfprefsd && sbreload");
    } else {
        if (!use_args) {
            printf("Successfully set the resolution to %sx%s, the device will be respring.\n", height, width);
        } else {
            printf("Successfully set the resolution to %sx%s, the device will be respring.\n", argv[1], argv[2]);
        }
        sleep(1);
        run_cmd("killall -9 cfprefsd && killall -9 backboardd");
    }
	return 0;
}
