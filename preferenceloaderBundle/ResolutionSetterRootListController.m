#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>

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
            UIAlertController *error = [UIAlertController alertControllerWithTitle:@"Error!"
                                          message:[NSString stringWithFormat:@"Wrong input:\"%@\", height is too small!", value]
                                          preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
               handler:^(UIAlertAction * action) {}];
            [error addAction:defaultAction];
            [self presentViewController:error animated:YES completion:nil];
            return;
        } else if ([value intValue] > 9999) {
            heightError = true;
            UIAlertController *error = [UIAlertController alertControllerWithTitle:@"Error!"
                                          message:[NSString stringWithFormat:@"Wrong input:\"%@\", height is too large!", value]
                                          preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
               handler:^(UIAlertAction * action) {}];
            [error addAction:defaultAction];
            [self presentViewController:error animated:YES completion:nil];
            return;
        } else {
            heightError = false;
            hasSetHeight = true;
        }
    }
    if ([[specifier propertyForKey:@"key"] isEqualToString:@"canvas_width"]) {
        if ([value intValue] < 100) {
            widthError = true;
            UIAlertController *error = [UIAlertController alertControllerWithTitle:@"Error!"
                                          message:[NSString stringWithFormat:@"Wrong input:\"%@\", width is too small!", value]
                                          preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
               handler:^(UIAlertAction * action) {}];
            [error addAction:defaultAction];
            [self presentViewController:error animated:YES completion:nil];
            return;
        } else if ([value intValue] > 9999) {
            widthError = true;
            UIAlertController *error = [UIAlertController alertControllerWithTitle:@"Error!"
                                          message:[NSString stringWithFormat:@"Wrong input:\"%@\", width is too large!", value]
                                          preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
               handler:^(UIAlertAction * action) {}];
            [error addAction:defaultAction];
            [self presentViewController:error animated:YES completion:nil];
            return;
        } else {
            widthError = false;
            hasSetWidth = true;
        }
    }
    [super setPreferenceValue:value specifier:specifier];
}

- (id)readPreferenceValue:(PSSpecifier*)specifier {
    if ([[specifier propertyForKey:@"key"] isEqualToString:@"canvas_height"]) {
        return [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.apple.iokit.IOMobileGraphicsFamily.plist"][@"canvas_height"];
    }
    if ([[specifier propertyForKey:@"key"] isEqualToString:@"canvas_width"]) {
        return [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.apple.iokit.IOMobileGraphicsFamily.plist"][@"canvas_width"];
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
            canvas_height = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.apple.iokit.IOMobileGraphicsFamily.plist"][@"canvas_height"];
        } else {
            canvas_height = settings[@"canvas_height"];
        }
        if (!hasSetWidth) {
            canvas_width = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.apple.iokit.IOMobileGraphicsFamily.plist"][@"canvas_width"];
        } else {
            canvas_width = settings[@"canvas_width"];
        }
        if (canvas_height != nil && canvas_width != nil) {
            system([[NSString stringWithFormat:@"resolution %@ %@ -y", canvas_height, canvas_width] UTF8String]);
        }
    }
}

@end
