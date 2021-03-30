#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>

bool hasSetHeight = false, hasSetWidth = false;

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
        hasSetHeight = true;
    }
    if ([[specifier propertyForKey:@"key"] isEqualToString:@"canvas_width"]) {
        hasSetWidth = true;
    }
    [super setPreferenceValue:value specifier:specifier];
}

- (id)readPreferenceValue:(PSSpecifier*)specifier {
    if ([[specifier propertyForKey:@"key"] isEqualToString:@"canvas_height"] || [[specifier propertyForKey:@"key"] isEqualToString:@"canvas_width"]) {
        return [[[NSUserDefaults alloc] _initWithSuiteName:@"com.apple.iokit.IOMobileGraphicsFamily" container:[NSURL URLWithString:@"file:///private/var/mobile"]] objectForKey:[specifier propertyForKey:@"key"]];
    }
    return [super readPreferenceValue:specifier];
}

-(void)setresolution {
    [self.view endEditing:YES];
    if (hasSetHeight || hasSetWidth) {
        CFTypeRef canvas_height = NULL, canvas_width = NULL;
        if (!hasSetHeight) {
            canvas_height = CFPreferencesCopyValue(CFSTR("canvas_height"), CFSTR("com.apple.iokit.IOMobileGraphicsFamily"), CFSTR("mobile"), kCFPreferencesAnyHost);
        } else {
            canvas_height = CFPreferencesCopyValue(CFSTR("canvas_height"), CFSTR("com.michael.iokit.IOMobileGraphicsFamily"), CFSTR("mobile"), kCFPreferencesAnyHost);
        }
        if (!hasSetWidth) {
            canvas_width = CFPreferencesCopyValue(CFSTR("canvas_width"), CFSTR("com.apple.iokit.IOMobileGraphicsFamily"), CFSTR("mobile"), kCFPreferencesAnyHost);
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
