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
        return (id)CFBridgingRelease(CFPreferencesCopyValue((__bridge CFStringRef)[specifier propertyForKey:@"key"], CFSTR("com.apple.iokit.IOMobileGraphicsFamily"), CFSTR("mobile"), kCFPreferencesAnyHost));
    }
    return [super readPreferenceValue:specifier];
}

-(void)setresolution {
    [self.view endEditing:YES];
    if (!heightError && !widthError && (hasSetHeight || hasSetWidth)) {
        CFTypeRef canvas_height = NULL, canvas_width = NULL;
        if (!hasSetHeight) {
            canvas_height = CFPreferencesCopyValue(CFSTR("canvas_height"), CFSTR("com.michael.iokit.IOMobileGraphicsFamily"), CFSTR("mobile"), kCFPreferencesAnyHost);
        } else {
            canvas_height = CFPreferencesCopyValue(CFSTR("canvas_height"), CFSTR("com.michael.iokit.IOMobileGraphicsFamily"), CFSTR("mobile"), kCFPreferencesAnyHost);
        }
        if (!hasSetWidth) {
            canvas_width = CFPreferencesCopyValue(CFSTR("canvas_width"), CFSTR("com.michael.iokit.IOMobileGraphicsFamily"), CFSTR("mobile"), kCFPreferencesAnyHost);
        } else {
            canvas_width = CFPreferencesCopyValue(CFSTR("canvas_width"), CFSTR("com.michael.iokit.IOMobileGraphicsFamily"), CFSTR("mobile"), kCFPreferencesAnyHost);
        }
        if (canvas_height != NULL && canvas_width != NULL) {
            system([[NSString stringWithFormat:@"resolution %@ %@ -y", canvas_height, canvas_width] UTF8String]);
        }
        if (canvas_height != NULL) {
            CFRelease(canvas_height);
        }
        if (canvas_width != NULL) {
            CFRelease(canvas_width);
        }
    }
}

@end
