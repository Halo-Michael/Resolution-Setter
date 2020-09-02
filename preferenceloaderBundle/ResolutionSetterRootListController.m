#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>

UIAlertController *alert(NSString *alertTitle, NSString *alertMessage, NSString *actionTitle) {
    UIAlertController *theAlert = [UIAlertController
                                alertControllerWithTitle:alertTitle
                                message:alertMessage
                                preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *defaultAction = [UIAlertAction
                                    actionWithTitle:actionTitle
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action) {}];
    [theAlert addAction:defaultAction];
    return theAlert;
}

bool heightError = false, widthError = false, hasSetHeight = false, hasSetWidth = false;

@interface ResolutionSetterRootListController : PSListController

@end

@implementation ResolutionSetterRootListController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
	}

	return _specifiers;
}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier*)specifier {
    if ([[specifier propertyForKey:@"key"] isEqualToString:@"canvas_height"]) {
        if ([value intValue] < 100) {
            heightError = true;
            [self presentViewController:alert(@"Error!", [NSString stringWithFormat:@"Wrong input \"%@\":\nHeight is too low!", value], @"OK") animated:YES completion:nil];
            return;
        } else if ([value intValue] > 9999) {
            heightError = true;
            [self presentViewController:alert(@"Error!", [NSString stringWithFormat:@"Wrong input \"%@\":\nHeight is too high!", value], @"OK") animated:YES completion:nil];
            return;
        } else {
            heightError = false;
            hasSetHeight = true;
        }
    }
    if ([[specifier propertyForKey:@"key"] isEqualToString:@"canvas_width"]) {
        if ([value intValue] < 100) {
            widthError = true;
            [self presentViewController:alert(@"Error!", [NSString stringWithFormat:@"Wrong input \"%@\":\nWidth is too low!", value], @"OK") animated:YES completion:nil];
            return;
        } else if ([value intValue] > 9999) {
            widthError = true;
            [self presentViewController:alert(@"Error!", [NSString stringWithFormat:@"Wrong input \"%@\":\nWidth is too high!", value], @"OK") animated:YES completion:nil];
            return;
        } else {
            widthError = false;
            hasSetWidth = true;
        }
    }
    [super setPreferenceValue:value specifier:specifier];
}

- (id)readPreferenceValue:(PSSpecifier*)specifier {
    if ([[specifier propertyForKey:@"key"] isEqualToString:@"canvas_height"] || [[specifier propertyForKey:@"key"] isEqualToString:@"canvas_width"]) {
        CFStringRef appID = CFSTR("com.apple.iokit.IOMobileGraphicsFamily");
        CFArrayRef keyList = CFPreferencesCopyKeyList(appID, CFSTR("mobile"), kCFPreferencesAnyHost);
        NSDictionary *settings = (NSDictionary *)CFBridgingRelease(CFPreferencesCopyMultiple(keyList, appID, CFSTR("mobile"), kCFPreferencesAnyHost));
        return settings[[specifier propertyForKey:@"key"]];
    }
    return [super readPreferenceValue:specifier];
}

-(void)setresolution {
    [self.view endEditing:YES];
    if (!heightError && !widthError && (hasSetHeight || hasSetWidth)) {
        CFStringRef appID = CFSTR("com.michael.iokit.IOMobileGraphicsFamily");
        CFArrayRef keyList = CFPreferencesCopyKeyList(appID, CFSTR("mobile"), kCFPreferencesAnyHost);
        NSDictionary *settings = (NSDictionary *)CFBridgingRelease(CFPreferencesCopyMultiple(keyList, appID, CFSTR("mobile"), kCFPreferencesAnyHost));
        id canvas_height = nil, canvas_width = nil;
        if (!hasSetHeight) {
            canvas_height = [NSDictionary dictionaryWithContentsOfFile:@"/private/var/mobile/Library/Preferences/com.apple.iokit.IOMobileGraphicsFamily.plist"][@"canvas_height"];
        } else {
            canvas_height = settings[@"canvas_height"];
        }
        if (!hasSetWidth) {
            canvas_width = [NSDictionary dictionaryWithContentsOfFile:@"/private/var/mobile/Library/Preferences/com.apple.iokit.IOMobileGraphicsFamily.plist"][@"canvas_width"];
        } else {
            canvas_width = settings[@"canvas_width"];
        }
        if (canvas_height != nil && canvas_width != nil) {
            system([[NSString stringWithFormat:@"resolution %@ %@ -y", canvas_height, canvas_width] UTF8String]);
        }
    }
}

@end
