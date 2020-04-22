void usage() {
    printf("Usage:\tres|resolution [height] [width] [OPTIONS...]\n");
    printf("\t-h\tPrint this help.\n");
    printf("\t-w\tSet resolution without auto respring. You may need to manual respring.\n");
    printf("\t-y\tPass the confirm message.\n");
}

bool do_check(const char *num)
{
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

int main(int argc, char **argv) {
    if (getuid() != 0) {
        setuid(0);
    }

    if (getuid() != 0) {
        printf("Can't set uid as 0.\n");
        return 1;
    }

    if (argc == 2 || argc > 5) {
        usage();
        return 1;
    }

    if (argc > 2) {
        if (do_check(argv[1]) == false || do_check(argv[2]) == false) {
            printf("Invalid parameters, you may have no idea what you are doing, now exit.\n");
            return 1;
        } else if (strlen(argv[1]) > 4 || strlen(argv[2]) > 4) {
            printf("The resolution is too high, you may have no idea what you are doing, now exit.\n");
            return 1;
        } else if (strlen(argv[1]) < 3 || strlen(argv[2]) < 3) {
            printf("The resolution is too low, you may have no idea what you are doing, now exit.\n");
            return 1;
        }
    }

    char *height, *width;

    if (argc > 2) {
        height = argv[1];
        width = argv[2];
    }

    for (int i = 1; i < argc; i++) {
        if (argc > 2) {
            if (strcmp(argv[i], "-y") == 0) {
                break;
            }
        }
        if (argc == 1 || i == argc - 1) {
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
                        return 1;
                    } else if (count < 4) {
                        printf("Height is too low, you may have no idea what you are doing, now exit.\n");
                        return 1;
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
                        return 1;
                    } else if (count < 4) {
                        printf("Width is too low, you may have no idea what you are doing, now exit.\n");
                        return 1;
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
    }

    if (access("/var/mobile/Library/Preferences/com.apple.iokit.IOMobileGraphicsFamily.plist", F_OK) == 0) {
        remove("/var/mobile/Library/Preferences/com.apple.iokit.IOMobileGraphicsFamily.plist");
    }
    if (access("/var/mobile/Library/Preferences/com.michael.iokit.IOMobileGraphicsFamily.plist", F_OK) == 0) {
        remove("/var/mobile/Library/Preferences/com.michael.iokit.IOMobileGraphicsFamily.plist");
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
        plist[@"canvas_height"] = [NSNumber numberWithInteger:[[NSString stringWithFormat:@"%s", height] integerValue]];
    });
    modifyPlist(@"/var/mobile/Library/Preferences/com.michael.iokit.IOMobileGraphicsFamily.plist", ^(id plist) {
        plist[@"canvas_height"] = [NSNumber numberWithInteger:[[NSString stringWithFormat:@"%s", height] integerValue]];
    });
    modifyPlist(@"/var/mobile/Library/Preferences/com.apple.iokit.IOMobileGraphicsFamily.plist", ^(id plist) {
        plist[@"canvas_width"] = [NSNumber numberWithInteger:[[NSString stringWithFormat:@"%s", width] integerValue]];
    });
    modifyPlist(@"/var/mobile/Library/Preferences/com.michael.iokit.IOMobileGraphicsFamily.plist", ^(id plist) {
        plist[@"canvas_width"] = [NSNumber numberWithInteger:[[NSString stringWithFormat:@"%s", width] integerValue]];
    });

    NSString *command = @"sleep 1 && killall -9 cfprefsd && killall -9 backboardd";
    NSString *prints = [NSString stringWithFormat:@"Successfully set the resolution to %sx%s, the device will be respring.\n", height, width];

    for (int i = 1; i < argc; i++) {
        if (strcmp(argv[i], "-w") == 0) {
            command = @"killall -9 cfprefsd";
            prints = [NSString stringWithFormat:@"Successfully set the resolution to %sx%s, you should manual respring your drvice.\n", height, width];
            break;
        }
    }

    printf("%s", [prints UTF8String]);
    int status = system([command UTF8String]);
    return WEXITSTATUS(status);
}
